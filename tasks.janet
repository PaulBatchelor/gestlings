(do
(def sql-query  ``
WITH
durations AS
(SELECT time, UUID, substr(value,12) as duration FROM wikizet
WHERE VALUE like '$duration:%'),

task_links AS
(SELECT UUID, substr(value, 2) as task_id FROM wikizet
WHERE UUID in (SELECT UUID from durations) AND
value LIKE '#%' AND
value IS NOT '#e6a96e1d-fe3a-481c-9e6a-c0d500e76aa4'),

task_names AS
(SELECT UUID, substr(value, 2) as task_name from wikizet
WHERE UUID in (SELECT task_id from task_links) AND
value like '>%'),

task_times AS
(SELECT durations.time as task_start, task_id, sum(duration) as total_duration from
task_links INNER JOIN durations on task_links.UUID = durations.UUID
GROUP BY task_id)

SELECT
date(task_start, 'localtime') as task_start_local,
time(total_duration, 'unixepoch') as total_duration,
task_name FROM task_times
INNER join task_names on task_names.UUID = task_times.task_id
ORDER BY strftime("%s", task_start) DESC;
``)

(def query (sqlite3/eval (ww-db) sql-query))
(each row query
(org
(string
(row "task_start_local") " "
(row "total_duration") " "
(row "task_name") "\n\n")))
)
