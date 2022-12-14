import pandas as pd
import psycopg2
import streamlit as st
from configparser import ConfigParser

"# Demo: Soundtrack Query and IMDB Metadata Application"


@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}


@st.cache
def query_db(sql: str):
    # print(f"Running query_db(): {sql}")

    db_info = get_config()

    # Connect to an existing database
    conn = psycopg2.connect(**db_info)

    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Execute a command: this creates a new table
    cur.execute(sql)

    # Obtain data
    data = cur.fetchall()

    column_names = [desc[0] for desc in cur.description]

    # Make the changes to the database persistent
    conn.commit()

    # Close communication with the database
    cur.close()
    conn.close()

    df = pd.DataFrame(data=data, columns=column_names)

    return df


sql_tvshow_names = "SELECT show_name FROM TVShows;"
sql_movie_names = "SELECT movie_name FROM Movies;"
sql_genre_names = "SELECT DISTINCT(genre) FROM Title_Genres;"

"## Songs Played in a particular Movie"

try:
    query1_names = query_db(sql_movie_names)["movie_name"].tolist()
    query1_selectbox = st.selectbox("Choose a movie", query1_names)
except:
    st.write("Sorry this movie does not exist in our database or input is wrong.")

if query1_selectbox:
    sql_songs = f"select S.song_name,C.composer_name,SM.description,S.duration from Songs S,Composers C,Songs_Movies SM,Song_Composers SC,Movies M where SC.composer_id=C.composer_id and SC.song_id = S.song_id and SM.song_id=S.song_id and SM.movie_id=M.movie_id and M.movie_name ='{query1_selectbox}' order by S.song_name,C.composer_name;"

    try:
        song_info = query_db(sql_songs)
        st.dataframe(song_info)
    except:
        st.write("Sorry! your query did not execute, please try again.")

"## Songs played in a particular TV Show,season and episode"

try:
    altquery1_names = query_db(sql_tvshow_names)["show_name"].tolist()
    altquery1_selectbox = st.selectbox("Pick a Show", altquery1_names)
    #season = query_db("select distinct(E.season_number) from Episodes E,TVShows T where E.tvshow_id=T.tvshow_id and T.show_name='{altquery1_selectbox}';")["season_number"].tolist()
    season_number = st.text_input("Enter season number")
    #episode = query_db("select count(E.episode_id) from Episodes E,TVShows T where E.tvshow_id=T.tvshow_id and T.show_name='{altquery1_selectbox}' group by E.season_number;")["count"].tolist()
    episode_number = st.text_input("Enter episode number")
except:
    st.write("Sorry this movie does not exist in our database or input is wrong.")

if altquery1_selectbox:
    sql_episode_songs = f"select S.song_name,C.composer_name,SE.description,S.duration from Songs S,Composers C,Songs_Episodes SE,Song_Composers SC,Episodes E,TVShows T where SC.composer_id=C.composer_id and SC.song_id=S.song_id and SE.song_id=S.song_id and SE.episode_id=E.episode_id and E.tvshow_id=T.tvshow_id and T.show_name='{altquery1_selectbox}' and E.episode_number='{episode_number}' and E.season_number='{season_number}' order by S.song_name,C.composer_name;"

    try:
        song_episode_info = query_db(sql_episode_songs)
        st.dataframe(song_episode_info)
    except:
        st.write("Sorry! your query did not execute, please try again.")
else:
    st.write("Invalid Season Number or Episode Number")

"## Details of Composers who have composed at least 3 songs for a particular TVShow"

try:
    query2_names = query_db(sql_tvshow_names)["show_name"].tolist()
    query2_selectbox = st.selectbox("Choose a TV Show", query2_names)
except:
    st.write("Sorry this TV Show does not exist in our database or input is wrong")
if query2_selectbox:
    sql_composer_tvshows = f"select C.composer_name,T.show_name,count(SE.song_id) as song_count from Composers C,Songs_Episodes SE,Song_Composers SC,TVShows T,Episodes E where SE.song_id = SC.song_id and SC.composer_id=C.composer_id and SE.episode_id=E.episode_id and E.tvshow_id = T.tvshow_id and T.show_name='{query2_selectbox}' group by T.show_name,C.composer_name having count(*)>2 order by C.composer_name,T.show_name;"

    try:
        tvshow_composers = query_db(sql_composer_tvshows)
        st.dataframe(tvshow_composers)
    except:
        st.write("Sorry! your query did not execute, please try again.")

"## Listing director actor pairs in Episodes with greater than 20 collaborations"

episodeactordirectorpairs = f"select D.director_name,A.actor_name,T.show_name ,count(*) as collaborations from Directors D,Actors A,Episode_Actors EA,Episodes E,TVShows T where EA.episode_id=E.episode_id and EA.actor_id=A.actor_id and E.director_id=D.director_id and T.tvshow_id=E.tvshow_id group by D.director_name,A.actor_name,T.show_name having count(*)>20 order by D.director_name,A.actor_name;"

try:
    pairs = query_db(episodeactordirectorpairs)
    st.dataframe(pairs)
except:
    st.write("Sorry! your query did not execute, please try again.")

"## Pairs of directors such that director1 and director2 have directed the same show, but director 1 has more episodes than director2. Both must have directed at least 10 episodes"

directorpairs = f"WITH episode_count as ( SELECT d.director_name as dname, e.tvshow_id, count(e.tvshow_id) as episodes_directed FROM directors d, episodes e WHERE e.director_id = d.director_id GROUP BY tvshow_id,d.director_name HAVING count(*)>10) SELECT ec1.dname as director1, ec2.dname as director2,T.show_name as tv_show FROM episode_count ec1, episode_count ec2,TVShows T WHERE ec1.tvshow_id = ec2.tvshow_id and ec1.tvshow_id=T.tvshow_id AND ec1.episodes_directed > ec2.episodes_directed ORDER BY director1, director2;"

try:
    pair_directors = query_db(directorpairs)
    st.dataframe(pair_directors)
except:
    st.write("Sorry! your query did not execute, please try again.")

"## Getting Top 5 rated Episodes of a TV Show along with average ratings and director information."

tv_shows = "SELECT show_name FROM TVShows;"

try:
    query5_names = query_db(sql_tvshow_names)["show_name"].tolist()
    query5_selectbox = st.selectbox("Choose TV Show", query5_names)
except:
    st.write("Sorry this TV Show does not exist in our database or input is wrong.")

if query5_selectbox:
    sql_toprated = f"WITH episode_ratings as (SELECT e.episode_id,e.episode_name,e.tvshow_id,t.show_name, e.director_id,d.director_name,r.average_rating::float,r.num_votes FROM episodes e, ratings r,directors d,TVShows t WHERE e.episode_id = r.title_id and e.director_id=d.director_id and t.tvshow_id=e.tvshow_id) SELECT er1.episode_name, er1.director_name, er1.average_rating FROM episode_ratings er1 LEFT JOIN episode_ratings er2 ON er1.tvshow_id = er2.tvshow_id AND (er1.average_rating < er2.average_rating OR (er1.average_rating = er2.average_rating AND er1.num_votes < er2.num_votes)) WHERE er1.show_name = '{query5_selectbox}' GROUP BY er1.episode_name, er1.show_name, er1.director_name, er1.average_rating HAVING COUNT(er2.average_rating) < 5 ORDER BY er1.show_name, er1.average_rating DESC;"
    try:
        top_rated_info = query_db(sql_toprated)
        st.dataframe(top_rated_info)
    except:
        st.write("Sorry! your query did not execute, please try again.")

"## Getting 10 most common composers of a given genre of TV Show/Movie"

try:
    query6_names = query_db(sql_genre_names)["genre"].tolist()
    query6_selectbox = st.selectbox("Choose a genre", query6_names)
except:
    st.write("Sorry this genre does not exist in our database.")

if query6_selectbox:
    sql_genrecomposers = f"WITH song_genre AS (SELECT song_id, title_id, genre FROM Songs_Movies sm, title_genres tg WHERE sm.movie_id = tg.title_id AND genre ilike '%{query6_selectbox}%' UNION SELECT song_id, title_id, genre FROM Songs_Episodes se, title_genres tg WHERE se.tvshow_id = tg.title_id AND genre ilike '%{query6_selectbox}%' GROUP BY title_id, song_id, genre) SELECT c.composer_name, genre, COUNT(distinct title_id) FROM song_genre sg, Songs s, Composers c, Song_Composers sc WHERE sg.song_id = s.song_id AND s.song_id = sc.song_id AND sc.composer_id = c.composer_id GROUP BY c.composer_name, genre ORDER BY COUNT(distinct title_id) DESC, c.composer_name LIMIT 10;"
    try:
        genre_composers = query_db(sql_genrecomposers)
        st.dataframe(genre_composers)
    except:
        st.write("Sorry! your query did not execute, please try again.")

"## Get all the movies/tvshow genres of a particular composer "

query7_textbox = st.text_input("Enter name of Composer")

if query7_textbox:
    sql_composers_genre = f"WITH songs_and_composers AS (SELECT s.song_id, c.composer_id, c.composer_name, s.song_name FROM Song_Composers sc, songs s, Composers c WHERE sc.song_id = s.song_id AND sc.composer_id = c.composer_id AND c.composer_name ILIKE '%{query7_textbox}%'),composer_genre AS (SELECT sac.composer_id, sac.composer_name, genre, count(distinct sm.movie_id) FROM songs_and_composers sac, Songs_Movies sm, title_genres tg WHERE sm.movie_id = tg.title_id AND sm.song_id = sac.song_id GROUP BY sac.composer_name, sac.composer_id, genre UNION SELECT sac.composer_id, sac.composer_name, genre, count(distinct se.tvshow_id) FROM songs_and_composers sac, Songs_Episodes se, title_genres tg WHERE se.tvshow_id = tg.title_id AND sac.song_id = se.song_id GROUP BY sac.composer_id, sac.composer_name, genre) SELECT composer_name, genre, SUM(count) FROM composer_genre GROUP BY composer_id, composer_name, genre;"
    try:
        composers_genre = query_db(sql_composers_genre)
        st.dataframe(composers_genre)
    except:
        st.write("Sorry! your query did not execute, please try again.")

"## Get all the songs played in a Episode which contain a particular word.For example romantic episodes tend to have the word Love in them"

query8_textbox = st.text_input("Enter any word")

if query8_textbox:
    sql_title_songs = f"select S.song_name,T.show_name,E.episode_name from Songs_Episodes SE,Songs S,TVShows T,Episodes E where E.episode_id=SE.episode_id and T.tvshow_id=SE.tvshow_id and SE.song_id=S.song_id and S.song_name Ilike '%{query8_textbox}%';"
    try:
        title_songs = query_db(sql_title_songs)
        st.dataframe(title_songs)
    except:
        st.write("Sorry! your query did not execute, please try again.")
