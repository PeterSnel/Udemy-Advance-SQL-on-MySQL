-- S03-P01
CREATE INDEX idx_personal_code_2chars ON sample_staff.employee (personal_code(2));

EXPLAIN SELECT employee.first_name, employee.last_name, employee.personal_code 
FROM sample_staff.employee USE INDEX (idx_personal_code_2chars) 
WHERE 1=1
	AND employee.personal_code = 'AA-751492'
;

SELECT employee.first_name, employee.last_name, employee.personal_code 
FROM sample_staff.employee USE INDEX (idx_personal_code_2chars) 
WHERE 1=1 
	AND employee.personal_code = 'AA-751492'
;
