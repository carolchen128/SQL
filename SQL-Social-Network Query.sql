# Students at your hometown high school have decided to organize their social network using databases. 
# So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema: 

# Highschooler ( ID, name, grade ) 
# English: There is a high school student with unique ID and a given first name in a certain grade. 

# Friend ( ID1, ID2 ) 
# English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 

# Likes ( ID1, ID2 ) 
# English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. 

use social;

# 1.Find the names of all students who are friends with someone named Gabriel. 
select name 
from highschooler 
where ID in (
select distinct friend.ID2 
from highschooler, friend
where highschooler.ID = friend.ID1  and name ="Gabriel");

# 2.For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 
select sname, sgrade, lname,lgrade
from (
select H1.name as sname, H1.grade as sgrade, H2.name as lname, H2.grade as lgrade, (H1.grade-H2.grade) as gradediff
from likes L, highschooler H1, highschooler H2
where H1.ID = L.ID1 and H2.ID=L.ID2) N
where gradediff >1; 

# 3.For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 
select h1.name, h1.grade, h2.name, h2.grade  
from Likes l1, Likes l2, Highschooler h1, Highschooler h2
where l1.ID1=l2.ID2 and l2.ID1=l1.ID2 and l1.ID1=h1.ID and l1.ID2=h2.ID and h1.name<h2.name;

# 4.Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 
select distinct name, grade
from highschooler 
where ID not in (
select ID1 from likes union select ID2 from likes)
order by grade, name;

# 5.For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select h1.name as sname, h1.grade as sgrade, h2.name as lname, h2.grade as lgrade
from highschooler h1, highschooler h2, likes
where h1.ID =likes.ID1 and h2.ID =likes.ID2 and h2.ID not in (select ID1 from likes);

# 6.Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
select distinct name,grade
from highschooler
where ID not in (
select distinct ID1
from highschooler h1, highschooler h2, friend
where h1.ID =friend.ID1 and h2.ID =friend.ID2 and h1.grade <>h2.grade)
order by grade, name;

# 7.For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 
select distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1, Likes, Highschooler H2, Highschooler H3, Friend F1, Friend F2
where H1.ID = Likes.ID1 and Likes.ID2 = H2.ID and
  H2.ID not in (select ID2 from Friend where ID1 = H1.ID) and
  H1.ID = F1.ID1 and F1.ID2 = H3.ID and
  H3.ID = F2.ID1 and F2.ID2 = H2.ID;
  
# 8.Find the difference between the number of students in the school and the number of different first names.
 select count(*)-count(distinct name) as diff
 from highschooler; 
 
# 9.Find the name and grade of all students who are liked by more than one other student. 
select name, grade
from (select ID2,count(ID2) as diff
from likes group by ID2) as N, highschooler
where ID=ID2 and diff >1;

# 10.For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 
select h1.name as aname, h1.grade as agrade, h2.name as bname, h2.grade as bgrade, h3.name as cname, h3.grade as cgrade
from likes l1, likes l2, highschooler h1, highschooler h2, highschooler h3
where l1.ID2 =l2.ID1 and l2.ID2<> l1.ID1 and l1.ID1=h1.ID and l2.ID1=h2.ID and l2.ID2= h3.ID;

# 11.Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 
select name, grade
from highschooler, (select distinct ID1 from Friend where ID1 not in 
(select distinct friend.ID1
from highschooler h1, highschooler h2, friend
where h1.ID =friend.ID1 and h2.ID =friend.ID2 and h1.grade =h2.grade)) as sample 
where ID =sample.ID1;

# 12.What is the average number of friends per student? (Your result should be just one number.) 
select avg(freq)
from (
select ID1, count(ID1) as freq
from friend
group by ID1) as sample;

# 13.Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 
select count(*)
from (
select ID2
from friend
where ID1 = (select ID from highschooler where name ='Cassandra')
union
select ID2 
from friend
where ID1 in (select ID2 from friend
where ID1 = (select ID from highschooler where name ='Cassandra')) and ID2 not in (select ID from highschooler where name ='Cassandra')) as sample
;

# 14.Find the name and grade of the student(s) with the greatest number of friends. 
select name, grade
from highschooler, friend
where ID =ID1 
group by ID1
having count(ID1) = (select max(freq) from (select count(ID1) as freq from friend group by ID1) as N) 

# 15.It's time for the seniors to graduate. Remove all 12th graders from Highschooler. 
delete from highschooler 
where grade =12;

# 16.If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. 
delete from likes
where exists (select * from friend f 
     where (f.ID1=likes.ID1) and (f.ID2=likes.ID2)) 
and not exists (select * from likes LB 
	 where (likes.ID1=LB.ID2)and (likes.ID2=LB.ID1));
     
# 17.For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. 
insert into friend
select distinct f1.ID1, f2.ID2
from friend f1, friend f2
where f1.ID2 = f2.ID1 and f1.ID1<>f2.ID2 
      and f1.ID1 not in (select f3.ID1 from friend f3 where f3.ID2=f2.ID2);
