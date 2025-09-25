DROP TABLE meetings

CREATE TABLE meetings
(
   id int PRIMARY key,
   start_time varchar(5),
   end_time varchar(5)
 )


insert into meetings values (1, '08:00', '09:15');
insert into meetings values (2, '13:20', '15:20');
insert into meetings values (3, '10:00', '14:00');
insert into meetings values (4, '13:55', '16:25');
insert into meetings values (5, '14:00', '17:45');
insert into meetings values (6, '14:05', '17:45');



  select max(minimum_rooms_required)  rooms
   from (    
             select count(*) minimum_rooms_required 
               from meetings m 
		            left join meetings m1 on m.start_time between m1.start_time and m1.end_time 
	       group by m.id  
		 ) a
		 