select Reader.LastName
from Reader
where Reader.LastName = "Moscow"

select Book.Title, Book.Author
from Book join Publisher on Book.PubName = Publisher.PubName
where Publisher.PubKind in ('Science', 'Reference')

select Book.Title, Book.Author
from (Book join Borrowing on Book.ISBN = Borrowing.ISBN join Reader on Reader.ID = Borrowing.ReaderNr)
where Reader.FirstName = "Иван" and Reader.LastName = "Иванов"

select Book.ISBN
from (Book join BookCat on BookCat.ISBN = Book.ISBN join Category on Category.CategoryName = BookCat.CategoryName)
where Category.CategoryName = "Mountains" and not Category.CategoryName = "Travel"

select distinct Reader.FirstName, Reader.LastName
from Reader join Borrowing on Borrowing.ReaderNr = Reader.ID
where Borrowing.ReturnData is not null

select distinct Reader.FirstName, Reader.LastName
from Reader join Borrowing on Borrowing.ReaderNr = Reader.ID
where (Reader.FirstName != "Иван" or Reader.LastName != "Иванов") and Borrowing.ISBN in (
    select Borrowing.ISBN
    from Borrwing join Reader on Reader.ID = Borrowing.ReaderNr
    where Reader.FirstName = "Иван" and Reader.LastName = "Иванов"
) 