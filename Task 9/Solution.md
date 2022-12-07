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
select t.ticket_no, bp.seat_no 
from 
    tickets t 
    join
    boarding_passes bp 
    on t.ticket_no = bp.ticket_no 
```

Далее можно получить информацию:
```dart
Hash Join  (cost=130190.78..395822.86 rows=7925944 width=17) (actual time=801.647..5345.698 rows=7925812 loops=1)
  Hash Cond: (bp.ticket_no = t.ticket_no)
  ->  Seq Scan on boarding_passes bp  (cost=0.00..137538.44 rows=7925944 width=17) (actual time=0.007..829.646 rows=7925812 loops=1)
  ->  Hash  (cost=78913.57..78913.57 rows=2949857 width=14) (actual time=799.618..799.619 rows=2949857 loops=1)
        Buckets: 2097152  Batches: 4  Memory Usage: 49517kB
        ->  Seq Scan on tickets t  (cost=0.00..78913.57 rows=2949857 width=14) (actual time=0.013..304.767 rows=2949857 loops=1)
Planning Time: 0.229 ms
```

Она не вместилась в память, так как пришлось использовать больше одной пакета (batch) для её размещения.
## Задания 4
## Задания 5
## Задания 6