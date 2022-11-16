Создаем три таблицы. Таблица пользователя:
```sql
CREATE TABLE users
(
    email TEXT PRIMARY KEY,
    birthdate DATE
);
```
Здесь мы ожидаем, что у каждого пользователя уникальная почта. Далее создадим список предсказаний, которые входят в каталог:
```sql
CREATE TABLE forecast
(
    id SERIAL PRIMARY KEY,
    price DOUBLE PRECISION,
    title TEXT
);
```
Здесь мы делаем инкремент, чтобы итерировать **id**, при этом также добавим цену на услугу и **title** в качестве её названия. Связывать таблицы пользователей и прогнозов мы будем через таблицу подписок:
```sql
CREATE TABLE subscription
(
    id SERIAL primary key,
    userEmail TEXT,
    forecastId INTEGER,
    startYear INTEGER,
    startMonth INTEGER,
    duration INTEGER,
    FOREIGN KEY (forecastId) REFERENCES forecast(id),
    FOREIGN KEY (userEmail) REFERENCES users(email)
);
```
Она содержит ключи для ссылки на пользователей и прогнозы для создания связи M2M, причем здесь также есть информация о датах начала подписки и конца.
Обратим внимание, что год начала мы задаем через номер месяца начала и номер года начала, для которых достаточно целого числа. Так же мы указываем длительность в виде числа месяцев. 
Причина, по которой мы не используем тип **DATE** или **TIMESTAMP** связана с упрощением математики, более того не надо будет беспокоиться о том, что у разных месяцев может отличатся число дней.

Для первого запроса нам было предложено использовать гипотетическую функцию для получения числа месяцев в данном году: 
```
fff(startYear, startMonth, duration, year)
```
Таким образом первый запрос имеет вид: 
```sql
select 
    u.email, 
    sum(f.price * fff(s.startYear, s.startMonth, s.duration, 2022))
from 
    users u
    join subscription s
        on (s.userEmail = u.email)
    join forecast f 
        on (f.id = s.forecastId)
group by u.email
```

Далее нам надо написать условие для того, чтобы даты подписки пересекались. 

Дата начала для одной подписки можно задать: 
```sql
s.startYear * 12 + s.startMonth
```

А дата конца может быть найдена:
```sql
s.startYear * 12 + s.startMonth + s.duration
```
Таким образом начало либо конец первой подписки должны попасть в интервал другой подписки, чтобы у них было пересечение:
```sql
s1.start between s2.start and s2.end or s1.end between s2.start and s2.end 
```
Что в наших терминах для начала и конца может быть написано в условии к запросу: 
```sql 
select distinct 
    u1.email, 
    u2.email
from
    users u1
    join subscription s1
        on (s1.userEmail = u1.email)
    join subscription s2
        on (s1.forecastId = s2.forecastId)
    join users u2
        on (u2.email = s2.userEmail)
where 
    u1.email <> u2.email
    and 
    (
        s1.startYear * 12 + s1.startMonth + s1.duration between s2.startYear * 12 + s2.startMonth and s2.startYear * 12 + s2.startMonth + s2.duration
        or 
        s1.startYear * 12 + s1.startMonth between s2.startYear * 12 + s2.startMonth and s2.startYear * 12 + s2.startMonth + s2.duration 
    )
```

Для пересечения двух месяцев:
```sql 
select
    first_user, second_user, count(intersection) as sum_total
from (
    select 
        u1.email as first_user, 
        u2.email as second_user,
        max(0, min(s2.startYear * 12 + s2.startMonth + s2.duration - s1.startYear * 12 - s1.startMonth, s1.startYear * 12 + s1.startMonth + s1.duration - s2.startYear * 12 - s2.startMonth)) as intersection
    from
        users u1
        join subscription s1
            on (s1.userEmail = u1.email)
        join subscription s2
            on (s1.forecastId = s2.forecastId)
        join users u2
            on (u2.email = s2.userEmail)
    where 
        u1.email <> u2.email
)
group by u1.email, u2.email
where sum_total >= 2
```
Здесь длинная строчка находит пересечение в данной паре подписок:
```sql
max(0, min(s2.startYear * 12 + s2.startMonth + s2.duration - s1.startYear * 12 - s1.startMonth, s1.startYear * 12 + s1.startMonth + s1.duration - s2.startYear * 12 - s2.startMonth))
```