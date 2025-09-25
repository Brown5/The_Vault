 create table #companies (
      name varchar(30) not null,
      country varchar(30) not null,
      unique(name)
  );
  create table #trades (
      id integer not null,
      seller varchar(30) not null,
      buyer varchar(30) not null,
      value integer not null,
      unique(id)
  );




insert into  #companies values ('Alice s.p.', 'Wonderland');
insert into  #companies values ('Y-zap', 'Wonderland');
insert into  #companies values ('Absolute', 'Mathlands');
insert into  #companies values ('Arcus t.g.', 'Mathlands');
insert into  #companies values ('Lil Mermaid', 'Underwater Kingdom');
insert into  #companies values ('None at all', 'Nothingland');
insert into  #trades values (20121107, 'Lil Mermaid', 'Alice s.p.', 10);
insert into  #trades values (20123112, 'Arcus t.g.', 'Y-zap', 30);
insert into  #trades values (20120125, 'Alice s.p.', 'Arcus t.g.', 100);
insert into  #trades values (20120216, 'Lil Mermaid', 'Absolute', 30);
insert into  #trades values (20120217, 'Lil Mermaid', 'Absolute', 50);
	
	SELECT c.country 
	      ,COALESCE(sum(tr.value),0) export
	      ,COALESCE(sum(tr2.value),0) import
	  FROM #companies c
	       LEFT JOIN #trades tr ON tr.seller = c.name
	       LEFT JOIN #trades tr2 ON tr2.buyer = c.name
GROUP BY c.country
ORDER BY c.country

