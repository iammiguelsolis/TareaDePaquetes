CREATE OR REPLACE PACKAGE pkg_employee AS
    -- 1.1. Operaciones CRUD básicas

    PROCEDURE crear_empleado(
        p_employee_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_email VARCHAR2,
        p_phone_number VARCHAR2,
        p_hire_date DATE,
        p_job_id VARCHAR2,
        p_salary NUMBER,
        p_commission_pct NUMBER,
        p_manager_id NUMBER,
        p_department_id NUMBER
    );
    
    -- READ
    PROCEDURE read_employee(p_employee_id NUMBER);

    -- UPDATE
    PROCEDURE update_employee(p_employee_id NUMBER, p_salary NUMBER);

    -- DELETE
    PROCEDURE delete_employee(p_employee_id NUMBER);
    
    -- 1.1. Rotación de puestos: Los 4 mas rotados
    PROCEDURE mostrar_empleados_mas_rotados;

    -- 1.2. Resumen de contrataciones promedio por mes con respecto a todos los años
    FUNCTION resumen_contrataciones RETURN NUMBER;

    -- 1.3. Gastos en salario y estadística de empleados a nivel regional
    PROCEDURE gastos_salarios_regionales;

    -- 1.4. Calcular tiempo de vacaciones
    FUNCTION calcular_vacaciones RETURN NUMBER;

    -- 1.5. Horas laboradas al mes (simulada)
    FUNCTION horas_laboradas_mes(
        p_employee_id NUMBER,
        p_mes NUMBER,
        p_anio NUMBER
    ) RETURN NUMBER;

    -- 1.6. Horas que falto al mes (simulada)
    FUNCTION horas_faltantes_mes(
        p_employee_id NUMBER,
        p_mes NUMBER,
        p_anio NUMBER
    ) RETURN NUMBER;

    -- 1.7. Calcular el sueldo que recibe al mes
    PROCEDURE calcular_sueldo_mensual(p_mes NUMBER, p_anio NUMBER);

    -- 1.8. Calcular las horas de capacitación que el empleado ha tomado (simulada)
    FUNCTION horas_capacitacion_empleado(p_employee_id NUMBER) RETURN NUMBER;

    -- 1.9. Listar las capacitaciones de todos los empleados (simulada)
    PROCEDURE listar_capacitaciones_empleados;

END pkg_employee;
/
-- ==========================================================
-- CUERPO DEL PAQUETE
-- ==========================================================
CREATE OR REPLACE PACKAGE BODY pkg_employee AS

    -- Crear empleado
    PROCEDURE crear_empleado(
        p_employee_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_email VARCHAR2,
        p_phone_number VARCHAR2,
        p_hire_date DATE,
        p_job_id VARCHAR2,
        p_salary NUMBER,
        p_commission_pct NUMBER,
        p_manager_id NUMBER,
        p_department_id NUMBER
    ) IS
    BEGIN
        INSERT INTO employees VALUES (
            p_employee_id, p_first_name, p_last_name, p_email,
            p_phone_number, p_hire_date, p_job_id, p_salary,
            p_commission_pct, p_manager_id, p_department_id
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Empleado creado correctamente.');
    END;

    -- Leer empleado
    PROCEDURE read_employee(p_employee_id NUMBER) IS
    BEGIN
        FOR emp IN (SELECT * FROM employees WHERE employee_id = p_employee_id) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Empleado: ' || emp.first_name || ' ' || emp.last_name ||
                ' | Puesto: ' || emp.job_id || ' | Salario: ' || emp.salary
            );
        END LOOP;
    END;

    -- Actualizar empleado
    PROCEDURE update_employee(p_employee_id NUMBER, p_salary NUMBER) IS
    BEGIN
        UPDATE employees SET salary = p_salary WHERE employee_id = p_employee_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Salario actualizado correctamente.');
    END;

    -- Eliminar empleado
    PROCEDURE delete_employee(p_employee_id NUMBER) IS
    BEGIN
        DELETE FROM employees WHERE employee_id = p_employee_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Empleado eliminado.');
    END;

    -- 1.1. Rotación de puestos: Los 4 más rotados
    PROCEDURE mostrar_empleados_mas_rotados IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== EMPLEADOS CON MÁS CAMBIOS DE PUESTO ===');
        FOR emp IN (
            SELECT e.employee_id, e.first_name, e.last_name,
                   COUNT(jh.job_id) AS cambios
            FROM employees e
            LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
            GROUP BY e.employee_id, e.first_name, e.last_name
            ORDER BY cambios DESC
            FETCH FIRST 4 ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                emp.employee_id || ' | ' || emp.first_name || ' ' || emp.last_name ||
                ' | Cambios de puesto: ' || emp.cambios
            );
        END LOOP;
    END;

    -- 1.2. Resumen de contrataciones promedio por mes
    FUNCTION resumen_contrataciones RETURN NUMBER IS
        total_meses NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PROMEDIO DE CONTRATACIONES POR MES ===');
        FOR mes IN (
            SELECT TO_CHAR(hire_date, 'Month') AS nombre_mes,
                   COUNT(*) / COUNT(DISTINCT EXTRACT(YEAR FROM hire_date)) AS promedio
            FROM employees
            GROUP BY TO_CHAR(hire_date, 'Month')
            ORDER BY TO_CHAR(TO_DATE(TO_CHAR(hire_date, 'MM'), 'MM'), 'MM')
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(RTRIM(mes.nombre_mes) || ' -> Promedio: ' || ROUND(mes.promedio, 2));
            total_meses := total_meses + 1;
        END LOOP;
        RETURN total_meses;
    END;

    -- 1.3. Gastos en salario y estadística por región
    PROCEDURE gastos_salarios_regionales IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== GASTOS SALARIALES POR REGIÓN ===');
        FOR reg IN (
            SELECT r.region_name,
                   SUM(e.salary) AS total_salarios,
                   COUNT(e.employee_id) AS cantidad_empleados,
                   MIN(e.hire_date) AS mas_antiguo
            FROM regions r
            JOIN countries c ON r.region_id = c.region_id
            JOIN locations l ON c.country_id = l.country_id
            JOIN departments d ON l.location_id = d.location_id
            JOIN employees e ON d.department_id = e.department_id
            GROUP BY r.region_name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Región: ' || reg.region_name || ' | Empleados: ' || reg.cantidad_empleados ||
                ' | Total salarios: ' || reg.total_salarios ||
                ' | Contratación más antigua: ' || TO_CHAR(reg.mas_antiguo, 'DD/MM/YYYY')
            );
        END LOOP;
    END;

    -- 1.4. Calcular tiempo de vacaciones
    FUNCTION calcular_vacaciones RETURN NUMBER IS
        total_monto NUMBER := 0;
    BEGIN
        FOR emp IN (
            SELECT first_name, last_name, salary,
                   TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS anios
            FROM employees
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                emp.first_name || ' ' || emp.last_name || ' | Años: ' || emp.anios
            );
            total_monto := total_monto + (emp.salary * emp.anios / 12);
        END LOOP;
        RETURN total_monto;
    END;

    -- 1.5. Horas laboradas al mes (simulada)
    FUNCTION horas_laboradas_mes(p_employee_id NUMBER, p_mes NUMBER, p_anio NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN 160; -- valor simulado (8h x 20 días)
    END;

    -- 1.6. Horas faltantes al mes (simulada)
    FUNCTION horas_faltantes_mes(p_employee_id NUMBER, p_mes NUMBER, p_anio NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN 8; -- ejemplo: faltó un día
    END;

    -- 1.7. Calcular sueldo mensual
    PROCEDURE calcular_sueldo_mensual(p_mes NUMBER, p_anio NUMBER) IS
        v_base NUMBER;
        v_final NUMBER;
        v_faltas NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== SUELDO MENSUAL ' || p_mes || '/' || p_anio || ' ===');
        FOR emp IN (SELECT employee_id, first_name, last_name, salary FROM employees) LOOP
            v_base := emp.salary;
            v_faltas := horas_faltantes_mes(emp.employee_id, p_mes, p_anio);
            v_final := v_base - (v_base * (v_faltas / 160));
            DBMS_OUTPUT.PUT_LINE(emp.first_name || ' ' || emp.last_name || ' | Sueldo: ' || ROUND(v_final, 2));
        END LOOP;
    END;

    -- 1.8. Horas de capacitación (simulada)
    FUNCTION horas_capacitacion_empleado(p_employee_id NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN 12; -- valor fijo para demostración
    END;

    -- 1.9. Listar capacitaciones (simulada)
    PROCEDURE listar_capacitaciones_empleados IS
    BEGIN
        FOR emp IN (SELECT employee_id, first_name, last_name FROM employees) LOOP
            DBMS_OUTPUT.PUT_LINE(emp.first_name || ' ' || emp.last_name ||
                ' | Total horas capacitación: ' || horas_capacitacion_empleado(emp.employee_id));
        END LOOP;
    END;

END pkg_employee;
/
