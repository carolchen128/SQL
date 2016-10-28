# stanford database course-SQL queries
use rating
# 1. Find the titles of all movies directed by Steven Spielberg. 
SELECT title FROM movie
where director ='Steven Spielberg';

# 2.Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
select distinct year
from movie join rating using (mID)
where stars >=4
order by year;

# 3.Find the titles of all movies that have no ratings. 
select distinct title
from movie left outer join rating using (mID)
where stars is null;

# 4.Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
select name
from reviewer join rating using (rID)
where ratingDate is null;

# 5.Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
select RE.name, Mo.title, RA.stars, RA.ratingDate
from reviewer as RE, movie as MO, rating as RA
where RE.rID = RA.rID and RA.mID = Mo.mID
order by RE.name, Mo.title, RA.stars;

# 6.For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
select name, title
from rating R1, rating R2, movie M, reviewer RE
where R1.rID = RE.rID and R1.mID =M.mID
  and R1.rID = R2.rID AND R1.mID = R2.mID
  and R1.stars <R2.stars and R1.ratingDate < R2.ratingDate;

# 7.For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
select title, max(stars)
from movie join rating using (mID)
group by movie.mID
order by title;

# 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select title, max(stars)-min(stars) as ratingspread
from movie join rating using (mID)
group by mID
order by ratingspread desc, title;

# 9.Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
select avg(before1980.A1)-avg(after1980.A2) as difference
from (select avg(stars) as A1 
from movie join rating using (mID)
where year <1980
group by mID) as before1980, 
(select avg(stars) as A2 
from movie join rating using (mID)
where year >1980
group by mID) as after1980;

# 10.Find the names of all reviewers who rated Gone with the Wind. 
select distinct name
from reviewer 
inner join rating using (rID) 
inner join movie using (mID)
where title ="Gone with the Wind";

# 11. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
select name, title, stars
from movie 
inner join rating using (mID)
inner join reviewer using (rID)
where name = director;

# 12.Return all reviewer names and movie names together in a single list, alphabetized.
(select name alist from reviewer )
union
(select title alist from movie)
order by alist;

# 13.Find the titles of all movies not reviewed by Chris Jackson.
select distinct title
from movie
where mID not in (
select distinct mID
from rating
inner join reviewer using (rID)
where name = 'Chris Jackson');

# 14. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
select distinct name1, name2
from (
select R1.rID as rID1, Re1.name as name1, R2.rID, Re2.name as name2, R1.mID
from Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
where R1.mID = R2.mID
and R1.rID = Re1.rID
and R2.rID = Re2.rID
and Re1.name <> Re2.name
order by Re1.name) as pair
where name1 < name2;

# 15. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 
select name, title, stars
from movie 
inner join rating using (mID)
inner join reviewer using (rID)
where stars = (select min(stars) from Rating);

# 16.List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
select title, avg(stars) as rate
from movie join rating using (mID)
group by mID
order by rate desc,title;

# 17.Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 
select name
from reviewer join rating using (rID)
group by name
having count(name) >=3;

# 18.Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title.
select title, director 
from movie 
where director in (
select director 
from movie group by director having count(*) >1)
order by director, title;

# 19.Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
Select title, avg(stars) AS avg_stars
From rating join movie using (mID)
Group by mID
having avg(stars) =
 ( select max(avg_stars) from 
     ( Select title, avg(stars) AS avg_stars
       From rating join movie using (mID)
       Group by mID
     ) T
 );
 
# 20. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
Select title, avg(stars) AS avg_stars
From rating join movie using (mID)
Group by mID
having avg(stars) =
 ( select min(avg_stars) from 
     ( Select title, avg(stars) AS avg_stars
       From rating join movie using (mID)
       Group by mID
     ) T
 );
 
# 21.For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating
select director, title, max(stars)
from movie join rating using(mID)
where director is not null
group by director;

# 22. Add the reviewer Roger Ebert to your database, with an rID of 209. 
insert into reviewer values (209,'Roger Ebert');

# 23.Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.
insert into rating
select (select rID from reviewer where name ='James Cameron'),mID, 5,null 
from movie;

# 24.For all movies that have an average rating of 4 stars or higher, add 25 to the release year
update movie
set year = year+25
where mID in (select mID from (select * from movie) T join rating using (mID)
                 group by mID
                 having avg(stars) >=4);

# 25.Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from rating
where stars < 4 and mID in (select mID from movie where year <1970 or year >2000);
