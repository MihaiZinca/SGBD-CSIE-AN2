/*
scalar=un singur tip 
composite=nu tin doar o valoare, ci mai multe
record: mai multe valori de tipuri diferite


punem mai multe begin end pe o ramura cand vrem sa tratam exceptia fixa acolo nu pana la finalul programului
*/

SET SERVEROUTPUT ON

DECLARE
    x angajati%ROWTYPE;
BEGIN
    SELECT * INTO x FROM angajati
    WHERE id_angajat = 100;

    dbms_output.put_line(x.id_angajat);
    dbms_output.put_line(x.prenume);
    dbms_output.put_line(x.nume);
    dbms_output.put_line(x.email);
END;
/

DECLARE
    --V_ID_ANGAJAT NUMBER; 
    v_id_angajat angajati.id_angajat%TYPE;
    v_prenume VARCHAR2(30);
    v_nume  VARCHAR2(30);
    v_email VARCHAR2(30);
    V_IMPZOIT CONSTANT NUMBER(3) DEFAULT 16;
    V_NOTA NUMBER(2) NOT NULL:=10;
BEGIN
    SELECT
        id_angajat,
        prenume,
        nume,
        email
    INTO
        v_id_angajat,
        v_prenume,
        v_nume,
        v_email
    FROM
        angajati
    WHERE
        id_angajat = 100;

    dbms_output.put_line(v_id_angajat);
    dbms_output.put_line(v_prenume);
    dbms_output.put_line(v_nume);
    dbms_output.put_line(v_email);
END;
/

DECLARE
V_SALARIU NUMBER:=150000;
BEGIN
    CASE
    WHEN V_SALARIU IS NULL THEN
        dbms_output.put_line('SALARIU LIPSA');
    WHEN V_SALARIU<10000 OR V_SALARIU>10000 THEN
        dbms_output.put_line('salariul eronat');
    END CASE;
    EXCEPTION
        WHEN CASE_NOT_FOUND THEN  
         dbms_output.put_line('salariul mare');
END;
/