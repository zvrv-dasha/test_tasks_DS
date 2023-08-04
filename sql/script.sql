DROP TABLE IF EXISTS subjects_with_rf;
DROP TABLE IF EXISTS pivot_data;
DROP TABLE IF EXISTS temp_table;

-- Создание временной таблицы всех регионов + РФ + записи "Не через ЕПГУ"
CREATE TEMPORARY TABLE subjects_with_rf AS
SELECT 'Российская Федерация' AS "Субъект РФ", 
	SUM("Всего записей") AS "Всего записей", 
	SUM("ЕПГУ") AS "ЕПГУ", 
    SUM("РПГУ") AS "РПГУ", 
	SUM("Регистратура") AS "Регистратура", 
	SUM("Инфомат") AS "Инфомат", 
	SUM("Call center") AS "Call center", 
    SUM("АРМ медработника") AS "АРМ медработника", 
	SUM("Прочие") AS "Прочие", 
	(SUM("Всего записей") - SUM("ЕПГУ")) AS "Записей не через ЕПГУ"
FROM test.fer
UNION ALL
SELECT "Субъект РФ", 
	"Всего записей", 
	"ЕПГУ", 
	"РПГУ", 
	"Регистратура", 
	"Инфомат", 
	"Call center", 
	"АРМ медработника", 
	"Прочие", 
	(SUM("Всего записей") - SUM("ЕПГУ")) AS "Записей не через ЕПГУ"
FROM test.fer
GROUP BY "Субъект РФ", "Всего записей", "ЕПГУ", "РПГУ", "Регистратура", "Инфомат", "Call center", "АРМ медработника", "Прочие";

SELECT *
FROM subjects_with_rf;

-- временная таблица для создания "сводной" таблицы
CREATE TEMP TABLE pivot_data AS
SELECT "Субъект РФ", "Вид обращения", "Количество записей"
FROM (
    SELECT "Субъект РФ", 'ЕПГУ' AS "Вид обращения", "ЕПГУ" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'РПГУ' AS "Вид обращения", "РПГУ" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'Регистратура' AS "Вид обращения", "Регистратура" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'Инфомат' AS "Вид обращения", "Инфомат" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'Call center' AS "Вид обращения", "Call center" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'АРМ медработника' AS "Вид обращения", "АРМ медработника" AS "Количество записей"
    FROM subjects_with_rf
    UNION ALL
    SELECT "Субъект РФ", 'Прочие' AS "Вид обращения", "Прочие" AS "Количество записей"
    FROM subjects_with_rf
	UNION ALL
    SELECT "Субъект РФ", 'Записей не через ЕПГУ' AS "Вид обращения", "Записей не через ЕПГУ" AS "Количество записей"
    FROM subjects_with_rf
	UNION ALL
    SELECT "Субъект РФ", 'Всего записей' AS "Вид обращения", "Всего записей" AS "Количество записей"
    FROM subjects_with_rf
) AS sub
GROUP BY "Субъект РФ", "Вид обращения", "Количество записей";

-- таблица с доп. столбцом "Всего записей" для дальнейшего подсчета процента
CREATE TEMP TABLE temp_table AS
SELECT pivot_data."Субъект РФ", pivot_data."Вид обращения", pivot_data."Количество записей", subjects_with_rf."Всего записей"
FROM pivot_data
FULL JOIN subjects_with_rf ON subjects_with_rf."Субъект РФ" = pivot_data."Субъект РФ";

-- итоговый запрос с экспортом в csv
COPY
(SELECT "Субъект РФ", "Вид обращения",
CASE
	WHEN "Количество записей" = 0 THEN ''
	ELSE CAST("Количество записей" AS VARCHAR(10))
END,
CASE
	WHEN (ROUND((CAST("Количество записей" AS NUMERIC) / CAST("Всего записей" AS NUMERIC) * 100.00), 2)) = 0 THEN ''
	ELSE CAST(ROUND((CAST("Количество записей" AS NUMERIC) / CAST("Всего записей" AS NUMERIC) * 100.00), 2) AS VARCHAR(10))
END AS "%"
FROM temp_table
GROUP BY "Субъект РФ", "Вид обращения", "Количество записей", "Всего записей"
ORDER BY 
	CASE 
    	WHEN "Субъект РФ" = 'Российская Федерация' THEN 0
    	ELSE 1
	END, 
	"Субъект РФ", 
	CASE "Вид обращения"
		WHEN 'ЕПГУ' THEN 0
		WHEN 'РПГУ' THEN 1
		WHEN 'Регистратура' THEN 2
		WHEN 'Инфомат' THEN 3
		WHEN 'Call center' THEN 4
		WHEN 'АРМ медработника' THEN 5
		WHEN 'Прочие' THEN 6
		WHEN 'Записей не через ЕПГУ' THEN 7
		ELSE 8
	END)
TO 'C:\Users\zvrvd\Desktop\sql_task\pivot_data.csv' DELIMITER ';' CSV HEADER;