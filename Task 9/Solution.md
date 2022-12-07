## Задания 1
Добрый вечер. Ответ на вопрос:

Cross Join

Оптимизатор будет использовать соединение вложенным циклом, повторяя процесс соединения, пока во внешнем присоединяемом наборе не останется строк.

```sql
EXPLAIN (costs off) SELECT *
FROM airports a 
cross JOIN tickets t
```
```dart
Nested Loop
  ->  Seq Scan on tickets t
  ->  Materialize
        ->  Seq Scan on airports_data ml
```

## Задания 2
```sql
select distinct a1.airport_code , a2.airport_code 
from 
    airports a1
    cross join
        airports a2
```

Планировщик использует агрегацию через хэш (для ускорения) и вложенный цикл - проходит по всем строкам airoports_data и для каждой проходит значение по строкам второго и возвращает список.
 
```dart
HashAggregate  (cost=197.62..305.78 rows=10816 width=8)
  Group Key: ml.airport_code, ml_1.airport_code
  ->  Nested Loop  (cost=0.00..143.54 rows=10816 width=8)
        ->  Seq Scan on airports_data ml  (cost=0.00..4.04 rows=104 width=4)
        ->  Materialize  (cost=0.00..4.56 rows=104 width=4)
              ->  Seq Scan on airports_data ml_1  (cost=0.00..4.04 rows=104 width=4)
```
## Задания 3
```sql
set work_mem = '64MB'
 
explain (analyze)
select f.flight_no, bp.seat_no  
from 
	flights f 
	join 
	boarding_passes bp 
	on bp.flight_id = f.flight_id 

```

Далее можно получить информацию:
```dart
Hash Join  (cost=8508.51..229824.96 rows=7925944 width=10) (actual time=47.194..2944.236 rows=7925812 loops=1)
  Hash Cond: (bp.flight_id = f.flight_id)
  ->  Seq Scan on boarding_passes bp  (cost=0.00..137538.44 rows=7925944 width=7) (actual time=0.032..797.593 rows=7925812 loops=1)
  ->  Hash  (cost=4772.67..4772.67 rows=214867 width=11) (actual time=46.805..46.806 rows=214867 loops=1)
        Buckets: 131072  Batches: 4  Memory Usage: 3338kB
        ->  Seq Scan on flights f  (cost=0.00..4772.67 rows=214867 width=11) (actual time=0.007..19.095 rows=214867 loops=1)
```

Она не вместилась в память, так как пришлось использовать больше одной пакета (batch) для её размещения, а именно **Batches: 4**. Отметим, что это верно в случае, если мы отвели отдельно больше памяти: 
`set work_mem = '64MB'`
## Задания 4
Запрос изменяется не очень сильно:
```sql
explain (analyze)
select f.flight_no, count(*) 
from 
	flights f 
	join 
	boarding_passes bp 
	on 
    bp.flight_id = f.flight_id 
group by f.flight_id 
```
Для работы аналитической функции необходимо выполнить группировку по ключу (f.flight_id). Согласно результатам планировщика это и происходит. Выполненные нами операции происходят по группам, что приводит к другому набору действий, в отличие от предыдущего номера. Соединение считается параллельно для всех групп, причем происходит соединение слиянием, а не хешированием. 
```dart
Finalize GroupAggregate  (cost=1011.30..283220.97 rows=214867 width=19) (actual time=6.590..1619.068 rows=139880 loops=1)
  Group Key: f.flight_id
  ->  Gather Merge  (cost=1011.30..278923.63 rows=429734 width=19) (actual time=6.528..1550.295 rows=160942 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial GroupAggregate  (cost=11.27..228321.64 rows=214867 width=19) (actual time=0.088..1329.860 rows=53647 loops=3)
              Group Key: f.flight_id
              ->  Merge Join  (cost=11.27..209660.59 rows=3302477 width=11) (actual time=0.063..1040.241 rows=2641937 loops=3)
                    Merge Cond: (bp.flight_id = f.flight_id)
                    ->  Parallel Index Only Scan using boarding_passes_flight_id_seat_no_key on boarding_passes bp  (cost=0.43..159594.92 rows=3302477 width=4) (actual time=0.026..467.353 rows=2641937 loops=3)
                          Heap Fetches: 0
                    ->  Index Scan using flights_pkey on flights f  (cost=0.42..8247.62 rows=214867 width=11) (actual time=0.021..61.016 rows=214857 loops=3)
```
## Задания 5
```sql
explain
select 
	t.passenger_name, 
	f.flight_no  
from 
	tickets t 
	join 
	ticket_flights tf 
	on tf.ticket_no=t.ticket_no 
	join 
	flights f 
	on tf.flight_id = f.flight_id
```
Планировщик использует **Соединение Хэшированием**, для того, чтобы объединить join-таблицу полетов и билетов (ticket_flights) c полетами (tf.flight_id = f.flight_id). После для каждого такого соединения оно добавляет новое, присоединяя к данной паре сам билет, перебирая все билеты и выбирая те, которые имеют id, какой хранится в join-таблице. Для данной задачи так же используется хэш-таблица.
```dart
Hash Join  (cost=144461.29..560274.50 rows=8391852 width=23)
  Hash Cond: (tf.flight_id = f.flight_id)
  ->  Hash Join  (cost=135952.78..430342.95 rows=8391852 width=20)
        Hash Cond: (tf.ticket_no = t.ticket_no)
        ->  Seq Scan on ticket_flights tf  (cost=0.00..153851.52 rows=8391852 width=18)
        ->  Hash  (cost=78913.57..78913.57 rows=2949857 width=30)
              ->  Seq Scan on tickets t  (cost=0.00..78913.57 rows=2949857 width=30)
  ->  Hash  (cost=4772.67..4772.67 rows=214867 width=11)
        ->  Seq Scan on flights f  (cost=0.00..4772.67 rows=214867 width=11)
```
## Задания 6
```sql 
explain declare c cursor for
select * 
from 
	aircrafts a
	join seats s 
	on a.aircraft_code = s.aircraft_code 
order by a.aircraft_code;
```


Будет использоваться **Соединение Слиянием**. Это связано с тем, что мы добавили order by, который требует сортировки, а она и будет совершаться в момент слияния. Без order by выгоднее было бы использовать соединение хэшем.  Соритировка происходит по ключу `a.aircraft_code`, а join по парам индексов `aircrafts_data`.
```dart
Merge Join  (cost=1.51..420.71 rows=1339 width=67)
  Merge Cond: (s.aircraft_code = ml.aircraft_code)
  ->  Index Scan using seats_pkey on seats s  (cost=0.28..64.60 rows=1339 width=15)
  ->  Sort  (cost=1.23..1.26 rows=9 width=52)
        Sort Key: ml.aircraft_code
        ->  Seq Scan on aircrafts_data ml  (cost=0.00..1.09 rows=9 width=52)
```