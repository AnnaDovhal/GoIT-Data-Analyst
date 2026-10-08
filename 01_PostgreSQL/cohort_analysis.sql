
/*КРОК 0 
Знайомимося з таблицями:
- Перегляд перших рядків*/

SELECT * FROM cohort_users_raw 
LIMIT 10; 

SELECT * FROM cohort_events_raw 
LIMIT 10; 

/*ОСНОВНИЙ ЗАПИТ*/

with clean_users as
/*КРОК 1 
Готуємо таблицю cohort_users_raw:
- trim прибирає пробіли
- split_part ділить стрінг по пробілу і витягує 1шу частину = забираємо дату без часу
- regexp_replace заміняє /. на -
- TO_DATE перетворює у дату по заданому формату
*/
	(select user_id,promo_signup_flag -- витягуємо потрібні колонки
	, CASE  -- умова для різних форматів дати (рік з 2 або 4 символів)
		WHEN regexp_replace(split_part(trim(signup_datetime), ' ', 1), '[/.]', '-', 'g') ~ '^\d{1,2}-\d{1,2}-\d{4}$' -- рік = 4 символи
			THEN TO_DATE(regexp_replace(split_part(trim(signup_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YYYY')
		WHEN regexp_replace(split_part(trim(signup_datetime), ' ',1), '[/.]', '-','g') ~ '^\d{1,2}-\d{1,2}-\d{2}$' -- рік = 2 символи
	        THEN TO_DATE(regexp_replace(split_part(trim(signup_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YY')
	    ELSE Null
	  END AS signup_ts -- перетворена дата
	from cohort_users_raw),
clean_events as
/*КРОК 2 
Готуємо таблицю cohort_events_raw:
- trim прибирає пробіли
- split_part ділить стрінг по пробілу і витягує 1шу частину = забираємо дату без часу
- regexp_replace заміняє /. на -
- TO_DATE перетворює у дату по заданому формату
*/
	(select user_id, event_type -- витягуємо потрібні колонки
	, CASE -- умова для різних форматів дати (рік з 2 або 4 символів)
		WHEN regexp_replace(split_part(trim(event_datetime), ' ', 1), '[/.]', '-', 'g') ~ '^\d{1,2}-\d{1,2}-\d{4}$' -- рік = 4 символи
			THEN TO_DATE(regexp_replace(split_part(trim(event_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YYYY')
		WHEN regexp_replace(split_part(trim(event_datetime), ' ',1), '[/.]', '-','g') ~ '^\d{1,2}-\d{1,2}-\d{2}$' -- рік = 2 символи
	        THEN TO_DATE(regexp_replace(split_part(trim(event_datetime), ' ', 1), '[/.]', '-', 'g'), 'DD-MM-YY')
	    ELSE Null
	  END AS events_ts -- перетворена дата
	from cohort_events_raw),
joined_table as
/*КРОК 3 
Об'єднуємо дві попередньо підготовані таблиці:
- date_trunc "обрізає" дату до місяця (всі 1им числом), ::date перетворює тип даних для гарного виводу без часу 
- extract витягує з дат рік або місяць
- using(user_id) замінює ON u.user_id=e.user_id
*/
	(select u.user_id , u.promo_signup_flag -- витягуємо потрібні колонки
	, date_trunc('month', u.signup_ts)::date as cohort_month -- місяць реєстрації позначає когорти
	, date_trunc('month', e.events_ts)::date as activity_month -- місяць події позначає активацію
	, (extract(year from e.events_ts) - extract(year from u.signup_ts))*12 -- кількість місяців при різниці у роках
		+ extract(month from e.events_ts) - extract(month from u.signup_ts) as month_offset -- різниця місяців
	from clean_users u
		join clean_events e
			using(user_id)		
	
	/*Фільтруємо:
	- дати не пусті
	- тип події не пустий і не тестовий
	- дата події не раніше за реєстрацію
	*/
		
	where u.signup_ts is not null 
			and e.events_ts is not null
			and e.event_type is not null
			and e.event_type != 'test_event'
			and u.signup_ts <= e.events_ts )
/*КРОК 4
Агрегуємо і виводимо фінальні дані:
- count distinct рахує унікальних користувачів 
- group by групує по колонкам
- where activity_month between задає рамки спостереження
*/
select promo_signup_flag,  cohort_month, month_offset
	, count(distinct user_id) as users_total
from joined_table
where activity_month between '2025-01-01' and '2025-06-01'
group by promo_signup_flag,  cohort_month, month_offset
order by promo_signup_flag,  cohort_month, month_offset