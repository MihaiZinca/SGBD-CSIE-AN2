--Sa se initializeze o variabila cu un sir de litere.
--Sa se parcurga sirul si sa se construiasaca subsirul vocalelori si subsirul consoalelor

SET SERVEROUTPUT ON
declare
    v_sir varchar2(30):='uethuhafkakf.#jAMMCLE';
    v_vocale varchar2(30):='';
    v_consoane varchar2(30):='';
    C CHAR;
BEGIN
    FOR I in 1..length(v_sir) LOOP
    C:=SUBSTR(v_sir,i,1);
    
    IF UPPER(C) IN ('A', 'E', 'I', 'O' ,'U') then
        v_vocale:=v_vocale||C;
    elsif UPPER(C) between 'A' and 'Z' then
        v_consoane:=v_consoane||C;
    END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Sir initial='||v_sir);
    DBMS_OUTPUT.PUT_LINE('VOCALE='||v_vocale);
    DBMS_OUTPUT.PUT_LINE('CONSOANE='||v_consoane);
END;
/

SELECT * FROM ANGAJATI ORDER BY 1;
--SA SE AFISEZE ID NUMELE SI PRENUMELE ANG CU ID_ANGAJAT INTRE 105 SI 115
declare 
    TYPE T_ANG iS RECORD(
    id_angajat angajati.id_angajat%TYPE,
    prenume angajati.prenume%TYPE,
    nume angajati.nume%TYPE);
V T_ANG;
N NUMBER;
    
BEGIN
    FOR I in 105..115 LOOP
        SELECT COUNT(*) INTO N FROM ANGAJATI WHERE ID_ANGAJAT=I;
        IF N=1 THEN
            SELECT ID_ANGAJAT,NUME,PRENUME INTO V from 
            ANGAJATI WHERE ID_ANGAJAT=I;
    DBMS_OUTPUT.PUT_LINE(v.id_angajat||' '|| v.nume||' '|| v.prenume);
    END IF;
    END LOOP;
END;
/