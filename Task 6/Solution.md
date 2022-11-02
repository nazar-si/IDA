Task 2:
```sql
select employee_id, 
round(salary/avg(salary) over (partition by department_id), 2) sal 
from employees
```

Task 3:
```sql
select employee_id, job_id, department_id, 
round(sal_department,2) as sal_depart, round(sal_job,2) as sal_j, round(sal_department / sal_job,2) as difference
from (select 
        employee_id, 
        department_id, 
        job_id, 
        avg(salary)	over (partition by department_id) as sal_department, 
        avg(salary) over (partition by job_id) as sal_job 
    from employees) 
    as diff order by department_id, job_id
```

Task 4:
```sql
select employee_id, department_id, min_salary 
from (select 
		employee_id, 
		last_name, 
		department_id, 
		min(salary) over (partition by department_id) as min_salary 
    from employees) 
	as min_s order by department_id, last_name
```

Task 5:
```sql
create table scores (
    man_id int , 
    division int, 
    score int
)

insert into scores (man_id, division, score)
select employee_id as man_id, department_id as division, salary as score
from employees

select man_id, division, score 
from (select 
        man_id, 
        division, 
        score, 
        dense_rank () over (partition by division order by score desc) rating
	from scores_zh_m) 
as scores 
where rating <= 3
order by division, score desc
```