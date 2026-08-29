set SERVEROUTPUT on
DECLARE
  TYPE T_REC IS RECORD(
    NUME_CLIENT CLIENTI.NUME_CLIENT%TYPE,
    PRENUME_CLIENT CLIENTI.PRENUME_CLIENT%TYPE,
    LIMITA_CREDIT CLIENTI.LIMITA_CREDIT%TYPE
  );
  TYPE T_CLIENT IS TABLE OF T_REC INDEX BY PLS_INTEGER;
  V T_CLIENT;  
BEGIN
  SELECT NUME_CLIENT,PRENUME_CLIENT,LIMITA_CREDIT
  BULK COLLECT INTO V FROM CLIENTI 
    WHERE ID_CLIENT IN (SELECT ID_CLIENT FROM COMENZI)
    AND LIMITA_CREDIT>300
    ORDER BY LIMITA_CREDIT DESC; 
  FOR I IN 1..V.COUNT LOOP  
   DBMS_OUTPUT.PUT_LINE(I||'->'||V(I).NUME_CLIENT||' '||V(I).PRENUME_CLIENT||
     ' '||V(I).LIMITA_CREDIT);    
  END LOOP;
  V.DELETE;  
END;
/

SA SE AFISEZE PENTRU FIECARE CLIENT, VALOAREA TOTALA A COMENZILOR PRECUM SI DATA ULTIMEI COMENZI
DATELE VOR FI ORDONDATE DUPA VALOAREA TOTALA A COMENZILOR
SE VOR AFISA SI CLIENTII CARE NU AU DAT COMENZI

SELECT NUME_CLIENT,PRENUME_CLIENT,SUM(PRET*CANTITATE) VAL, MAX(DATA)
FROM CLIENTI C JOIN COMENZI O ON C.ID_CLIENT=O.ID_CLIENT
JOIN RAND_COMENZI R ON O.ID_COMANDA=R.ID_COMANDA
GROUP BY NUME_CLIENT,PRENUME_CLIENT
ORDER BY VAL DESC;

DECLARE
  TYPE T_REC IS RECORD(
    NUME_CLIENT CLIENTI.NUME_CLIENT%TYPE,
    PRENUME_CLIENT CLIENTI.PRENUME_CLIENT%TYPE,
    VAL NUMBER,
    DATA_C DATE);
  TYPE T_CLIENT IS TABLE OF T_REC INDEX BY PLS_INTEGER;
  V T_CLIENT;  
BEGIN
  SELECT NUME_CLIENT,PRENUME_CLIENT,SUM(PRET*CANTITATE) VAL, MAX(DATA)
  BULK COLLECT INTO V
FROM CLIENTI C LEFT JOIN COMENZI O ON C.ID_CLIENT=O.ID_CLIENT
LEFT JOIN RAND_COMENZI R ON O.ID_COMANDA=R.ID_COMANDA
GROUP BY NUME_CLIENT,PRENUME_CLIENT
ORDER BY VAL DESC NULLS LAST;
  --V.DELETE(3,315);
  FOR I IN 1..V.COUNT LOOP   
   DBMS_OUTPUT.PUT_LINE(I||'->'||V(I).NUME_CLIENT||' '||V(I).PRENUME_CLIENT||
     ' '||V(I).VAL||' '||V(I).DATA_C);    
  END LOOP;
  V.DELETE;  
END;
/

DECLARE
  TYPE T_REC IS RECORD(
    NUME_CLIENT CLIENTI.NUME_CLIENT%TYPE,
    PRENUME_CLIENT CLIENTI.PRENUME_CLIENT%TYPE,
    VAL NUMBER,
    DATA_C DATE);
  TYPE T_CLIENT IS TABLE OF T_REC INDEX BY PLS_INTEGER; -- INDEX BY TABLE, ASSOCIATIVE ARRAY
  V T_CLIENT;
  I PLS_INTEGER;
BEGIN
  SELECT NUME_CLIENT,PRENUME_CLIENT,SUM(PRET*CANTITATE) VAL, MAX(DATA)
  BULK COLLECT INTO V
FROM CLIENTI C LEFT JOIN COMENZI O ON C.ID_CLIENT=O.ID_CLIENT
LEFT JOIN RAND_COMENZI R ON O.ID_COMANDA=R.ID_COMANDA
GROUP BY NUME_CLIENT,PRENUME_CLIENT
ORDER BY VAL DESC NULLS LAST;
  V.DELETE(3,315);
  I:=V.FIRST;
  WHILE I IS NOT NULL LOOP   
   DBMS_OUTPUT.PUT_LINE(I||'->'||V(I).NUME_CLIENT||' '||V(I).PRENUME_CLIENT||
     ' '||V(I).VAL||' '||V(I).DATA_C);    
   I:=V.NEXT(I);  
  END LOOP;
  V.DELETE;  
END;
/

DECLARE
  TYPE T_REC IS RECORD(
    NUME_CLIENT CLIENTI.NUME_CLIENT%TYPE,
    PRENUME_CLIENT CLIENTI.PRENUME_CLIENT%TYPE,
    VAL NUMBER,
    DATA_C DATE);
  TYPE T_CLIENT IS TABLE OF T_REC; -- NESTED TABLE
  V T_CLIENT;
  I PLS_INTEGER;
BEGIN
  SELECT NUME_CLIENT,PRENUME_CLIENT,SUM(PRET*CANTITATE) VAL, MAX(DATA)
  BULK COLLECT INTO V
FROM CLIENTI C LEFT JOIN COMENZI O ON C.ID_CLIENT=O.ID_CLIENT
LEFT JOIN RAND_COMENZI R ON O.ID_COMANDA=R.ID_COMANDA
GROUP BY NUME_CLIENT,PRENUME_CLIENT
ORDER BY VAL DESC NULLS LAST;
 -- V.DELETE(3,315);
  I:=V.FIRST;
  WHILE I IS NOT NULL LOOP   
   DBMS_OUTPUT.PUT_LINE(I||'->'||V(I).NUME_CLIENT||' '||V(I).PRENUME_CLIENT||
     ' '||V(I).VAL||' '||V(I).DATA_C);    
   I:=V.NEXT(I);  
  END LOOP;
  V.DELETE;  
END;
/


DECLARE
  TYPE T_REC IS RECORD(
    NUME_CLIENT CLIENTI.NUME_CLIENT%TYPE,
    PRENUME_CLIENT CLIENTI.PRENUME_CLIENT%TYPE,
    VAL NUMBER,
    DATA_C DATE);
  TYPE T_CLIENT IS VARRAY(400) OF T_REC; -- VARRAY
  V T_CLIENT;
  I PLS_INTEGER;
BEGIN
  SELECT NUME_CLIENT,PRENUME_CLIENT,SUM(PRET*CANTITATE) VAL, MAX(DATA)
  BULK COLLECT INTO V
FROM CLIENTI C LEFT JOIN COMENZI O ON C.ID_CLIENT=O.ID_CLIENT
LEFT JOIN RAND_COMENZI R ON O.ID_COMANDA=R.ID_COMANDA
GROUP BY NUME_CLIENT,PRENUME_CLIENT
ORDER BY VAL DESC NULLS LAST;
  --V.DELETE(3,315);
  V.TRIM(50);-- STERGEM 50 DE ELEMENTE DE LA DREAPTA COLECTIEI
  DBMS_OUTPUT.PUT_LINE('NR='||V.COUNT);
  I:=V.FIRST;
  WHILE I IS NOT NULL LOOP   
   DBMS_OUTPUT.PUT_LINE(I||'->'||V(I).NUME_CLIENT||' '||V(I).PRENUME_CLIENT||
     ' '||V(I).VAL||' '||V(I).DATA_C);    
   I:=V.NEXT(I);  
  END LOOP;
  V.DELETE;  
END;
/

SET SERVEROUTPUT ON
DECLARE
TYPE tab_ind IS TABLE OF NUMBER INDEX BY VARCHAR2(1);
t tab_ind;
i varchar2(1);
BEGIN
t('a') := ASCII('a'); t('z') := 200;
t('b') := ASCII('b'); t('B') := ASCII('B');
t('x') := ASCII('x'); t('X') := ASCII('X');
i := t.FIRST;
WHILE i IS NOT NULL LOOP
  DBMS_OUTPUT.PUT_LINE('t('||i ||')='||t(i));
  i := t.NEXT(i);
END LOOP;
END; 
/

set serveroutput on
DECLARE
TYPE tab_ind IS TABLE OF angajati%ROWTYPE
INDEX BY PLS_INTEGER;
t tab_ind;
BEGIN
SELECT * BULK COLLECT INTO t
FROM angajati minus
SELECT * 
FROM angajati
WHERE ROWNUM<=50;
DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
DBMS_OUTPUT.PUT_LINE('Numar de elemente '||t.COUNT);
FOR i IN t.FIRST..t.LAST LOOP
    DBMS_OUTPUT.PUT_LINE(t(i).prenume||' '|| t(i).nume);
END LOOP;
--delete from angajati where 1=2;
--DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
FOR i IN t.FIRST..t.LAST loop
    update angajati set salariul=salariul+1 where id_angajat=t(i).id_angajat;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
end loop;
END;
/


DECLARE
TYPE tab_ind IS TABLE OF angajati%ROWTYPE
INDEX BY PLS_INTEGER;
t tab_ind;
BEGIN
SELECT * BULK COLLECT INTO t
FROM angajati minus
SELECT * 
FROM angajati
WHERE ROWNUM<=50;
DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
DBMS_OUTPUT.PUT_LINE('Numar de elemente '||t.COUNT);
FOR i IN t.FIRST..t.LAST LOOP
    DBMS_OUTPUT.PUT_LINE(t(i).prenume||' '|| t(i).nume);
END LOOP;
delete from angajati where 1=2;
DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
FORALL i IN t.FIRST..t.LAST 
    update angajati set salariul=salariul+1 where id_angajat=t(i).id_angajat;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
END;
/


set serveroutput on
DECLARE
TYPE tab_imb IS TABLE OF NUMBER;
t tab_imb := tab_imb(1,20,3,40,5);
t_null tab_imb;
BEGIN
t.EXTEND(5);
FOR i IN 6..10 LOOP
t(i):=t(i-1)+5;
END LOOP;
DBMS_OUTPUT.PUT('Colectia are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
DBMS_OUTPUT.PUT(t(i) || ' ');
END LOOP;
DBMS_OUTPUT.NEW_LINE;
t.delete;
IF t IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('Colectia este nula');
   else 
    DBMS_OUTPUT.PUT_line('Colectia are ' || t.COUNT ||' elemente');
END IF;
t.extend(2);
t(1):=500;t(2):=700;
DBMS_OUTPUT.PUT_line('Colectia are ' || t.COUNT ||' elemente');
t := t_null;
IF t IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('Colectia este nula');
   else 
    DBMS_OUTPUT.PUT_line('Colectia are ' || t.COUNT ||' elemente');
END IF;
--DBMS_OUTPUT.PUT_line('Colectia are ' || t.COUNT ||' elemente');
END;
/

create type t_grade_celsius is table of number(5,2);
/
create table localitati(
id_loc number primary key,
denumire varchar2(100),
grade t_grade_celsius)
  nested table grade store as t_grade ;
insert into localitati values(1,'Constanta', t_grade_celsius(10,15,17,20)); 
insert into localitati values(2,'Bucuresti', t_grade_celsius(7,11,15,17,21)); 
commit;

declare
  v t_grade_celsius;
begin
null;
end;
/

select * from t_grade;
drop table t_grade;

select * from table(select grade from localitati where id_loc=1);

select id_loc,denumire,b.* from localitati a,table(a.grade) b;

update localitati set grade=t_grade_celsius(10,15,17,20,27,21,21) where id_loc=1;

DECLARE
TYPE tab_vec IS VARRAY(10) OF NUMBER;
t tab_vec := tab_vec();
BEGIN
FOR i IN 1..10 LOOP
  t.EXTEND;
  t(i):=i;
END LOOP;
DBMS_OUTPUT.PUT('Colectia are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
    DBMS_OUTPUT.PUT(t(i) || ' ');
END LOOP;
DBMS_OUTPUT.NEW_LINE;
FOR i IN 1..10 LOOP
  IF i mod 2 = 1 THEN t(i):=null;
  END IF;
END LOOP;
DBMS_OUTPUT.PUT('Colectia are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
    DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' ');
END LOOP;
DBMS_OUTPUT.NEW_LINE;
--t.delete(1); -- wrong number or types of arguments in call to 'DELETE'
t.DELETE;
DBMS_OUTPUT.PUT_LINE('Colectia are '||t.COUNT||' elemente');
END;
/
drop table echipe;
drop type t_vect_proiecte;

CREATE OR REPLACE TYPE t_vect_proiecte AS VARRAY(10) OF varchar2(32);
/
CREATE TABLE echipe
( id_echipa NUMBER(4) PRIMARY KEY,
denumire VARCHAR2(40),
proiecte t_vect_proiecte);


insert into echipe values (1,'Inspire',t_vect_proiecte('HR Application','Trading Application'));
insert into echipe values (2,'Excel',t_vect_proiecte('Client Support','HR Application','Trading Application'));
insert into echipe values (3,'Global',t_vect_proiecte('Advanced Support','Big Data Analitics','Cloud Migration'));

update echipe set proiecte=t_vect_proiecte('Big Data Analitics','Cloud Migration')  where id_echipa=3;
select id_echipa,denumire,b.*  from echipe a, table(a.proiecte) b;