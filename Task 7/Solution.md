## Task 1:
```sql
select 
	extract(year from birthdate) as birthyear, 
	count(medal), 
	count(distinct players.player_id)
from 
	players, 
	results, 
	events 
where 
	players.player_id = results.player_id 
	and 
	results.medal = 'GOLD' 
	and 
	events.event_id = results.event_id 
	and 
	events.olympic_id = 'ATH2004' 
group by extract(year from birthdate)
```

## Task 2:
```sql
select
	"name",
	event_id
from events
where
	is_team_event = 0
	and 
	event_id in (
		select event_id
		from results r
		where r.medal = 'GOLD'
		group by event_id 
		having count(medal) > 1 
	) 
```

## Task 3:
```sql
select distinct
	r1.player_id, e1.olympic_id
from
	results r1 
	join events e1 
		on (e1.event_id = r1.event_id)
	join results r2 
		on (r1.player_id = r2.player_id)
	join events e2 
		on (e2.event_id = r2.event_id)
	join results r3 
		on (r3.player_id = r2.player_id)
	join events e3 
		on (e3.event_id = r3.event_id)
where
	r1.medal = 'GOLD'
	and
	r2.medal = 'SILVER'
	and 
	r3.medal = 'BRONZE'
	and 
	e1.olympic_id = e2.olympic_id 
	and
	e3.olympic_id = e2.olympic_id 
```

## Task 4:
Following query sorts all the countries by their ratio of the players whose names start with the vowel to the number of all people from that country. As there is several countries, which have such ratio being maximum, the answer according to that query will be as follows:
- Turkey                                  
- Finland                                 
- Barbados                                
- Estonia

```sql
select
	c1.country_name as cname,
	 cast(c1.v_players as float) / c2.number_of_players as ratio
from 
	(
		select 
			c."name" as country_name,
			count(*) as v_players
		from
			countries c
			join (
				select p1.country_id
				from players p1
				where substring(p1."name", 1, 1) in ('A', 'E', 'O', 'I', 'U', 'Y')
			) as p
				on c.country_id = p.country_id
		group by c.name
	) as c1
	join (
		select 
			c."name" as country_name,
			count(*) as number_of_players
		from
			countries c
			join players p
				on c.country_id = p.country_id
		group by c.name
	) as c2
		on c2.country_name = c1.country_name
order by cast(c1.v_players as float) / c2.number_of_players desc limit 4
```

## Task 5:
```sql
select 
	cast(count(distinct e.event_id) as float) / c.population as ratio,
	c."name"
from 
	results r
	join players p
		on r.player_id = p.player_id
	join events e 
		on r.event_id = e.event_id 
	join countries c 
		on p.country_id = c.country_id 
where 
	e.is_team_event = 1
	and
	e.olympic_id = 'SYD2000'
group by c."name", c.population, r.medal  
order by r.medal limit 5
```