CREATE OR REPLACE TRIGGER trg_verificar_sueldo
BEFORE INSERT OR UPDATE OF SALARY, JOB_ID ON EMPLOYEES
FOR EACH ROW
DECLARE
    v_min_salary JOBS.MIN_SALARY%TYPE;
    v_max_salary JOBS.MAX_SALARY%TYPE;
BEGIN
    SELECT MIN_SALARY, MAX_SALARY
    INTO v_min_salary, v_max_salary
    FROM JOBS
    WHERE JOB_ID = :NEW.JOB_ID;

    IF :NEW.SALARY < v_min_salary OR :NEW.SALARY > v_max_salary THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Error: El sueldo ' || :NEW.SALARY ||
            ' no está dentro del rango permitido (' ||
            v_min_salary || ' - ' || v_max_salary ||
            ') para el puesto ' || :NEW.JOB_ID || '.'
        );
    END IF;
END;
/

-- EJEMPLO
INSERT INTO JOBS VALUES ('DEV', 'Desarrollador', 2000, 5000);

-- BUENA
INSERT INTO EMPLOYEES (
    EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY
) VALUES (
    101, 'Juan', 'Pérez', 'JPEREZ', SYSDATE, 'DEV', 3000
);

-- MALO
INSERT INTO EMPLOYEES (
    EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY
) VALUES (
    102, 'Ana', 'López', 'ALOPEZ', SYSDATE, 'DEV', 7000
);