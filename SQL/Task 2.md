## Задание 1
Ключ нужен для того, чтобы связь можно было однозначно индефицировать и не возникло коллизии данных принадлежащих двум разным связям.
## Задание 2
### Библиотека
1. Читать(**Номер билета**, ФИО)
2. Книга(**ISBN**, Название, Список авторов, Число страниц)
3. Копия(**ISBN**, <ins>Номер</ins>)
4. Издательство(*<ins>Название</ins>*, Адрес)
5. Категория(*<ins>Название</ins>*, Название родительской)
6. Читатель_Копия(**Номер билета**, **ISBN**, <ins>Номер копии</ins>)
7. Категория_Книга(**ISBN**, **Название категории**)

### Адрес
1. Квартира(**Название страны**, <ins>Название города</ins>, <ins>Название улицы</ins>, <ins>Номер дома</ins>, <ins>Номер квартиры</ins>)
2. Дом(**Название страны**, <ins>Название города</ins>, <ins>Название улицы</ins>, <ins>Номер дома</ins>)
3. Улица(**Название страны**, <ins>Название города</ins>, <ins>Название улицы</ins>)
4. Город(**Название страны**, <ins>Название города</ins>)
5. Страна(**Название страны**)

### Матч
1. Судья(**ФИО**)
2. Матч(**ID-матча**, ФИО судьи, ID команды 1, ID команды 2)
3. Команда(**ID**)

### Родители
1. Ребенок(**ID Мамы**, **ID Папы**, <ins>ID</ins>)
2. Мама(**ID**)
3. Папа(**ID**)

### ER-диаграмма
1. Сущность(**Название сущности**)
2. Атрибут сущности(**Название сущности**, <ins>Название</ins>)
3. Атрибут слабой сущности(**Название родительской сущности**, <ins>Название</ins>, <ins>Название</ins>, <ins>Название слабой сущности</ins>)
4. Атрибут слабой сущности(**Название родительской сущности**, <ins>Название</ins>, <ins>Название слабой сущности</ins>)
5. Слабая сущность(**Название родительской сущности**,  <ins>Название слабой сущности</ins>)
6. Слабая связь(**Название родительской сущности**, <ins>ID</ins>) 
7. Связь(**ID**, Название действия)
8. Связь_Сущность(**ID**, Кардинальность входа, Кардинальность выхода, ID сущности, ID связи)

## Задание 3
### Метро
1. Station(**Name**, #Tracks, City)
2. City(**Name**, **Region**)
3. Train(**Train Number**, Start_station, End_station, Current_station, Next_station, Departure_time, Arrival_time)

### Больница
1. Caregiver(**PersNr**, #Name, StatNr, Qualification)
2. Doctor(**PersNr**, #Name, StatNr, Area, Rank)
3. Station(**StatNr**, Name)
4. Room(**StatNr**, <ins>RoomNr</ins>, #Beds)
5. Patient(**PatientNr**, Name, Disease, DoctorNr, admission_to, admission_from)
