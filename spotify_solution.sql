-- Advance SQL project_Spotify
drop table if exists spotify;

CREATE TABLE spotify (
    Artist TEXT,
    Track TEXT,
    Album TEXT,
    Album_type TEXT,
    Danceability FLOAT,
    Energy FLOAT,
    Loudness FLOAT,
    Speechiness FLOAT,
    Acousticness FLOAT,
    Instrumentalness FLOAT,
    Liveness FLOAT,
    Valence FLOAT,
    Tempo FLOAT,
    Duration_min FLOAT,
    Title varchar(255),
    Channel varchar(255),
    Views float,
    Likes BIGINT,
    Comments BIGINT,
    Licensed BOOLEAN,
    official_video BOOLEAN,
    Stream BIGINT,
    EnergyLiveness FLOAT,
    most_playedon varchar(50)
);

select * from spotify
where duration_min=0;

delete from spotify
where duration_min=0;

--Retrieve the names of all tracks that have more than 1 billion streams.
select track from spotify
where stream>1000000000;

-- List all albums along with their respective artists.
select artist, count(track) as total_songs
from spotify
group by 1
order by 1 desc;
distinct album, artist
from spotify
order by 1;

-- Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as Total_Comments from spotify
where licensed = TRUE;

-- Find all tracks that belong to the album type single.

select track from spotify
where album_type = 'single';

--Count the total number of tracks by each artist.
select artist, count(track) as total_songs
from spotify
group by 1
order by 1 desc;

--Calculate the average danceability of tracks in each album

select album, round(avg(danceability)::numeric,2) as Avg_Dancbt
from spotify
group by 1
order by 2 desc;

--Find the top 5 tracks with the highest energy values.
select track, max(energy)
from spotify
group by 1
order by 2 desc
limit 5;

--List all tracks along with their views and likes where official_video = TRUE.

select track, sum(views) as total_views,
sum(likes) as total_likes
from spotify
where official_video = TRUE
group by 1
order by 2 desc;

--For each album, calculate the total views of all associated tracks.
select album,
track,
sum(views) as Total_Views
from spotify
group by 1,2
order by 3 desc;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
select *
from
(
select track,
sum(case when most_playedon='Spotify' then stream end) as streamed_on_spotify,
sum(case when most_playedon='Youtube' then stream end) as streamed_on_Youtube
from spotify
group by 1
) as t1
where
streamed_on_spotify>streamed_on_Youtube
and
streamed_on_Youtube<>0;

-- Find the top 3 most-viewed tracks for each artist using window functions.
select *
from
(
select artist, track, sum(views) as total_view,
dense_rank() over (partition by artist order by sum(views)) as rank1
from spotify
group by 1,2
order by 1,3 asc
) as t1
where rank1<=3
order by artist, rank1 asc;

--Write a query to find tracks where the liveness score is above the average.
select artist, track, liveness
from spotify
where liveness> (select avg(liveness) from spotify);

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH t1 AS (
    SELECT 
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM 
        spotify
    GROUP BY 
        album
)
SELECT 
    album, 
    ROUND((highest_energy - lowest_energy)::numeric, 2) AS energy_diff
FROM 
    t1
ORDER BY 
    energy_diff desc;

--Find tracks where the energy-to-liveness ratio is greater than 1.2.
with t1 as
(
SELECT 
    track, 
    energy / liveness AS EL_ratio
FROM 
    spotify
)
select track, round((EL_ratio)::numeric,2)
from t1
where EL_ratio>1.2
order by 2 desc;

--Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views DESC
    ) AS cumulative_likes
FROM 
    spotify;
