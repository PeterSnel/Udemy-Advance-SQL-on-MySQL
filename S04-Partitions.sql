-- 150ms
SELECT * /* Select without specifying a partition */
FROM `sample_staff`.`invoice`
WHERE 1=1
AND YEAR(`invoice`.`invoiced_date`) = '1986'
AND MONTH(`invoice`.`invoiced_date`) = 3
LIMIT 10
;

-- 1ms
SELECT * /* Select within a particular partition */
FROM `sample_staff`.`invoice` PARTITION (`p1986sp3`)
WHERE 1=1
AND YEAR(`invoice`.`invoiced_date`) = '1986'
AND MONTH(`invoice`.`invoiced_date`) = 3
LIMIT 10
;

SELECT /* Select a list of all partitions from a table */
`table_name`,
`partition_ordinal_position`,
`table_rows`,
`partition_method`,
`partitions`.*
FROM information_schema.partitions
WHERE 1=1
AND `table_schema` = 'sample_staff'
AND `table_name` = 'invoice'
;

-- Query to create the invoice table with partitions:
CREATE TABLE `invoice` (
`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
`employee_id` int(11) unsigned NOT NULL DEFAULT '0',
`invoiced_date` date NOT NULL,
`paid_flag` tinyint(4) NOT NULL DEFAULT '0',
`insert_dt` datetime NOT NULL,
`insert_user_id` int(11) NOT NULL DEFAULT '-1',
`insert_process_code` varchar(255) DEFAULT NULL,
`update_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP,
`update_user_id` int(11) NOT NULL DEFAULT '-1',
`update_process_code` varchar(255) DEFAULT NULL,
`deleted_flag` tinyint(4) NOT NULL DEFAULT '0',
PRIMARY KEY (`id`, `invoiced_date`)
) ENGINE=InnoDB
	DEFAULT CHARSET=utf8
PARTITION BY RANGE( YEAR(invoiced_date) )
SUBPARTITION BY HASH( MONTH(invoiced_date) )
SUBPARTITIONS 12 (
	PARTITION p1984 VALUES LESS THAN (1985),
	PARTITION p1985 VALUES LESS THAN (1986),
	PARTITION p1986 VALUES LESS THAN (1987),
	PARTITION p1987 VALUES LESS THAN (1988),
	PARTITION p1988 VALUES LESS THAN (1989),
	PARTITION p1989 VALUES LESS THAN (1990),
	PARTITION p1990 VALUES LESS THAN (1991),
	PARTITION p1991 VALUES LESS THAN (1992),
	PARTITION p1992 VALUES LESS THAN (1993),
	PARTITION p1993 VALUES LESS THAN (1994),
	PARTITION pOTHER VALUES LESS THAN MAXVALUE
);

-- Example of LIST PARTITION
CREATE TABLE employee (
	id INT NOT NULL,
	store_id INT,
	...
)
PARTITION BY LIST(store_id) (
	PARTITION pNorth VALUES IN (3,5,6,9,17),
	PARTITION pEast VALUES IN (1,2,10,11,19,20),
	PARTITION pWest VALUES IN (4,12,13,14,18),
	PARTITION pCentral VALUES IN (7,8,15,16)
);

-- ##### Coding Practices ######
-- P01
CREATE TABLE invoice_partitioned (
	id INT(11) unsigned auto_increment NOT NULL, 
	employee_id INT(11) unsigned NOT NULL DEFAULT '0', 
	department_code VARCHAR(5), 
	invoiced_date DATE NOT NULL, 
	paid_flag tinyint(4) NOT NULL DEFAULT '0', 
	insert_dt datetime NOT NULL, 
	insert_user_id INT(11) NOT NULL DEFAULT '-1', 
	insert_process_code VARCHAR(255) DEFAULT NULL, 
	update_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	update_user_id INT(11) NOT NULL DEFAULT '-1', 
	update_process_code VARCHAR(255) DEFAULT NULL, 
	deleted_flag tinyint(4) NOT NULL, 
	PRIMARY KEY (id, department_code)
);

INSERT INTO invoice_partitioned (
	id, 
	employee_id, 
	department_code, 
	invoiced_date, 
	paid_flag, 
	insert_dt, 
	insert_user_id, 
	insert_process_code, 
	update_dt, 
	update_user_id, 
	update_process_code, 
	deleted_flag
)
SELECT 
	invoice.id, 
	invoice.employee_id, 
	department.code, 
	invoice.invoiced_date, 
	invoice.paid_flag, 
	invoice.insert_dt, 
	invoice.insert_user_id, 
	invoice.insert_process_code, 
	invoice.update_dt, 
	invoice.update_user_id, 
	invoice.update_process_code, 
	invoice.deleted_flag 
FROM invoice 

INNER JOIN department_employee_rel ON 1=1 
	AND invoice.employee_id = department_employee_rel.employee_id 
	AND invoice.invoiced_date BETWEEN department_employee_rel.from_date 
		AND IFNULL(department_employee_rel.to_date, '2002-08-01') 
	AND department_employee_rel.deleted_flag = 0 
INNER JOIN department ON 1=1 
	AND department_employee_rel.department_id = department.id 
	AND department.deleted_flag = 0 
;

SELECT 
	id, 
	employee_id, 
	count(id) AS count 
FROM department_employee_rel 
WHERE from_date >= '1985-01-01' AND to_date <= '1987-12-01' 
GROUP BY employee_id 
ORDER BY count DESC 
LIMIT 10;
