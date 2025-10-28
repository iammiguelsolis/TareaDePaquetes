CREATE TABLE HorarioEmpleado (
    EMPLOYEE_ID     NUMBER(6) PRIMARY KEY,
    DIA_SEMANA      VARCHAR2(10),
    HORA_INICIO     DATE,
    HORA_FIN        DATE
);

CREATE TABLE AsistenciaEmpleado (
    ID_ASISTENCIA   NUMBER PRIMARY KEY,
    EMPLOYEE_ID     NUMBER(6),
    FECHA_ASISTENCIA DATE,
    HORA_INICIO     DATE,
    HORA_FIN        DATE,
    CONSTRAINT FK_ASIST_EMP FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEES(EMPLOYEE_ID)
);


CREATE OR REPLACE TRIGGER trg_verificar_asistencia
BEFORE INSERT ON AsistenciaEmpleado
FOR EACH ROW
DECLARE
    v_dia_semana   VARCHAR2(10);
    v_dia_horario  VARCHAR2(10);
    v_hora_inicio  DATE;
    v_hora_fin     DATE;
BEGIN
    v_dia_semana := TO_CHAR(:NEW.FECHA_ASISTENCIA, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH');
    v_dia_semana := RTRIM(UPPER(v_dia_semana)); 

    SELECT UPPER(DIA_SEMANA), HORA_INICIO, HORA_FIN
    INTO v_dia_horario, v_hora_inicio, v_hora_fin
    FROM HorarioEmpleado
    WHERE EMPLOYEE_ID = :NEW.EMPLOYEE_ID;

    IF v_dia_semana != v_dia_horario THEN
        RAISE_APPLICATION_ERROR(-20001, 'El día de la fecha no coincide con el horario del empleado.');
    END IF;

    IF TO_CHAR(:NEW.HORA_INICIO, 'HH24:MI') != TO_CHAR(v_hora_inicio, 'HH24:MI') THEN
        RAISE_APPLICATION_ERROR(-20002, 'La hora de inicio no coincide con la hora registrada en el horario del empleado.');
    END IF;

    IF TO_CHAR(:NEW.HORA_FIN, 'HH24:MI') != TO_CHAR(v_hora_fin, 'HH24:MI') THEN
        RAISE_APPLICATION_ERROR(-20003, 'La hora de término no coincide con la hora registrada en el horario del empleado.');
    END IF;
END;
/

-- EJEMPLO
INSERT INTO HorarioEmpleado VALUES (
    100, 'LUNES', TO_DATE('08:00', 'HH24:MI'), TO_DATE('16:00', 'HH24:MI')
);

-- BUENO
INSERT INTO AsistenciaEmpleado VALUES (
    1, 100, TO_DATE('2025-10-27', 'YYYY-MM-DD'), TO_DATE('08:00', 'HH24:MI'), TO_DATE('16:00', 'HH24:MI')
);

INSERT INTO AsistenciaEmpleado VALUES (
    2, 100, TO_DATE('2025-10-28', 'YYYY-MM-DD'), TO_DATE('08:00', 'HH24:MI'), TO_DATE('16:00', 'HH24:MI')
);
-- MALO