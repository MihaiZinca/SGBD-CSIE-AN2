SET SERVEROUTPUT ON

--3
CREATE OR REPLACE TRIGGER VERIFICA_SALA BEFORE UPDATE OF SALARIUL ON ANGAJATI FOR EACH ROW
DECLARE
    V_MAX NUMBER;
BEGIN 
    SELECT SALARIU_MAX INTO V_MAX
    FROM FUNCTII
    WHERE ID_FUNCTIE=:NEW.ID_FUNCTIE;
    
    IF :NEW.SALARIUL>V_MAX THEN
        RAISE_APPLICATION_ERROR(-20000,'EROARE  SALARIU MAI MARE DECAT MAX');
    END IF;
END;
/


UPDATE ANGAJATI
SET SALARIUL=199
WHERE ID_ANGAJAT=101;

--8
Creați un declanșator (trigger) care permite mărirea limitei de credit a clienților cu:

maximum 25% pentru clienții ale căror achiziții totale sunt de cel puțin 20.000

maximum 15% pentru clienții ale căror achiziții totale sunt de cel puțin 10.000

maximum 10% pentru clienții ale căror achiziții totale 
sunt mai mici de 10.000 sau care nu au efectuat nicio achiziție

CREATE OR REPLACE TRIGGER TRG_LIMITA_CREDIT BEFORE UPDATE OF LIMITA_CREDIT ON CLIENTI FOR EACH ROW
DECLARE 
    V_TOTAL NUMBER;
BEGIN
    IF :NEW.LIMITA_CREDIT>:OLD.LIMITA_CREDIT THEN
        
        SELECT SUM(R.PRET*R.CANTITATE) INTO V_TOTAL
        FROM COMENZI C
        JOIN RAND_COMENZI R ON C.ID_COMANDA=R.ID_COMANDA
        WHERE C.ID_CLIENT=:NEW.ID_CLIENT;
        
        IF V_TOTAL>=20000 AND :NEW.LIMITA_CREDIT>:OLD.LIMITA_CREDIT *1.25 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Depaseste maximul de 25%');
        ELSIF V_TOTAL>=10000 AND V_TOTAL<20000 AND :NEW.LIMITA_CREDIT>:OLD.LIMITA_CREDIT * 1.15 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Depaseste maximul de 15%');
        ELSIF V_TOTAL<10000 AND :NEW.LIMITA_CREDIT>:OLD.LIMITA_CREDIT * 1.1 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Depaseste maximul de 10%');
        END IF;
    END IF;
    
END;
/
    
UPDATE CLIENTI
SET LIMITA_CREDIT = LIMITA_CREDIT * 2
WHERE ID_CLIENT = 101;

--10
/*Scrieți o procedură într-un pachet care folosește o colecție PL/SQL 
pentru a afișa maximum primii 3 angajați care:

Au funcția cu denumirea Y (transmisă ca parametru)

Au salariul mai mare decât X (transmis ca parametru)

Au gestionat cel puțin o comandă în anul curent*/

CREATE OR REPLACE PACKAGE PL IS
PROCEDURE VER_ANG(P_DEN_FUNCTIE VARCHAR2,P_SAL NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY PL IS

PROCEDURE VER_ANG(P_DEN_FUNCTIE VARCHAR2,P_SAL NUMBER) IS
    CURSOR C IS SELECT
    A.ID_ANGAJAT,A.NUME,A.PRENUME,A.SALARIUL
    FROM ANGAJATI A
    JOIN FUNCTII F ON A.ID_FUNCTIE=F.ID_FUNCTIE
    JOIN COMENZI C ON A.ID_ANGAJAT=C.ID_ANGAJAT
    WHERE F.DENUMIRE_FUNCTIE=P_DEN_FUNCTIE AND A.SALARIUL>P_SAL
    AND EXTRACT(YEAR FROM C.DATA)=EXTRACT(YEAR FROM SYSDATE);
    
    R C%ROWTYPE;
    V_NR NUMBER DEFAULT 0;
    BEGIN
        OPEN C;
        LOOP
            FETCH C INTO R;
            EXIT WHEN C%NOTFOUND OR V_NR=3;
            
            V_NR:=V_NR+1;
            DBMS_OUTPUT.PUT_LINE('Angajat ' || R.ID_ANGAJAT || ' - ' || R.PRENUME || ' ' || R.NUME || ', Salariu: ' || R.SALARIUL);
        END LOOP;
        CLOSE C;
        
        IF V_NR=0 THEN
            RAISE_APPLICATION_ERROR(-20000,'NU EXISTA ANGJ');
        END IF;
        
    END;
    
END;
/

DECLARE
    NU_EXISTA EXCEPTION;
    PRAGMA EXCEPTION_INIT(NU_EXISTA,-20000);
BEGIN
    PL.VER_ANG('Sales Representative', 5000);
    EXCEPTION
        WHEN NU_EXISTA THEN
            DBMS_OUTPUT.PUT_LINE('A APARUT EROAREA '||SQLERRM);
END;
/


--11
DECLARE
    CURSOR C IS SELECT
    ID_PRODUS,
    DENUMIRE_PRODUS,
    CATEGORIE,
    PRET_LISTA,
    PRET_MIN
    FROM PRODUSE
    WHERE CATEGORIE='hardware1'
    GROUP BY ID_PRODUS,DENUMIRE_PRODUS,CATEGORIE,PRET_LISTA,PRET_MIN;
    
    R C%ROWTYPE;
    EX_PROD EXCEPTION;
    PRAGMA EXCEPTION_INIT(EX_PROD,-20000);
BEGIN 
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        
        IF R.PRET_LISTA>1.02*R.PRET_MIN THEN
            DBMS_OUTPUT.PUT_LINE(R.DENUMIRE_PRODUS||'-'||R.PRET_MIN);
        ELSE
            RAISE_APPLICATION_ERROR(-20000,'PRODUSUL '||R.DENUMIRE_PRODUS||' ARE UN PRET MAI MIC DECAT' ||(1.02*R.PRET_MIN));
        END IF;
    END LOOP;
    CLOSE C;
    
    EXCEPTION
        WHEN EX_PROD THEN
            DBMS_OUTPUT.PUT_LINE('A APARUT EROAREA: '||SQLERRM);
END;
/


--21
CREATE OR REPLACE FUNCTION GET_ANGAJATI_MANAGER(P_ID_MANAGER NUMBER)RETURN NUMBER IS
V_TOT NUMBER;
BEGIN
    SELECT COUNT(*) INTO V_TOT
    FROM ANGAJATI
    WHERE ID_MANAGER=P_ID_MANAGER;
    
    RETURN NVL(V_TOT,0);
END;
/

CREATE OR REPLACE PROCEDURE AFISARE_ECHIPA(P_ID_MANAGER NUMBER,NR NUMBER) IS
    CURSOR C IS SELECT
    ID_ANGAJAT,
    NUME,
    PRENUME,
    DATA_ANGAJARE
    FROM ANGAJATI
    WHERE ID_MANAGER=P_ID_MANAGER
    ORDER BY DATA_ANGAJARE;
    
    R C%ROWTYPE;
    V_TOT NUMBER;
    V_NR NUMBER DEFAULT 0;
    
BEGIN
    V_TOT:=GET_ANGAJATI_MANAGER(P_ID_MANAGER);
    
    IF V_TOT<NR THEN
        RAISE_APPLICATION_ERROR(-20001, 'PREA PUTINI ANGAJATI! Are doar ' || V_TOT);
    END IF;
    
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND OR V_NR=NR;
        V_NR:=V_NR+1;
        DBMS_OUTPUT.PUT_LINE('Angajat: ' || R.ID_ANGAJAT || ' - ' || R.PRENUME || ' ' || R.NUME || ', Data: ' || R.DATA_ANGAJARE);
    END LOOP;
    CLOSE C;

END;
/

DECLARE
    E_CUSTOM EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_CUSTOM, -20001);
BEGIN
    AFISARE_ECHIPA(100, 3);
EXCEPTION
    WHEN E_CUSTOM THEN
        DBMS_OUTPUT.PUT_LINE('Blocat de exceptie: ' || SQLERRM);
END;
/


--22
CREATE OR REPLACE PACKAGE PO IS
    PROCEDURE AFISARE_ANGA(P_NR_ANG NUMBER,P_DENUMIRE_DEP VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY PO IS

    PROCEDURE AFISARE_ANGA(P_NR_ANG NUMBER,P_DENUMIRE_DEP VARCHAR2) IS
        CURSOR C IS SELECT
        A.ID_ANGAJAT,
        A.NUME,
        A.PRENUME,
        A.SALARIUL,
        D.DENUMIRE_DEPARTAMENT
        FROM ANGAJATI A
        JOIN DEPARTAMENTE D ON A.ID_DEPARTAMENT=D.ID_DEPARTAMENT
        WHERE D.DENUMIRE_DEPARTAMENT=P_DENUMIRE_DEP
        ORDER BY A.SALARIUL DESC;
        
        R C%ROWTYPE;
        
        V_NR NUMBER DEFAULT 0;
    BEGIN
        OPEN C;
        LOOP
            FETCH C INTO R;
            EXIT WHEN C%NOTFOUND;
            V_NR:=V_NR+1;
            DBMS_OUTPUT.PUT_LINE(R.ID_ANGAJAT||' '||R.SALARIUL);
        END LOOP;
        
       
        CLOSE C;
         IF V_NR<P_NR_ANG THEN
            RAISE_APPLICATION_ERROR(-20001,'PREA PUTINI ANGJ');
        END IF;
        
    END;
END;
/ 

DECLARE
    NU_EXISTA EXCEPTION;
    PRAGMA EXCEPTION_INIT(NU_EXISTA,-20001);
BEGIN
    PO.AFISARE_ANGA(30,'Marketing');
    EXCEPTION
        WHEN NU_EXISTA THEN
            DBMS_OUTPUT.PUT_LINE('A APARUT O EROARE' ||SQLERRM);
END;
/

--23
CREATE OR REPLACE TRIGGER AD_COM BEFORE INSERT ON COMENZI FOR EACH ROW
DECLARE 
    V_NR NUMBER;
BEGIN
    SELECT COUNT(*) INTO V_NR
    FROM CLIENTI
    WHERE ID_CLIENT=:NEW.ID_CLIENT
    AND EXTRACT(YEAR FROM DATA_NASTERE)<2000;
    
    IF V_NR=1 THEN
        RAISE_APPLICATION_ERROR(-20000,'NU SE POATE');
    END IF;
END;
/

INSERT INTO COMENZI (ID_COMANDA, DATA, MODALITATE, ID_CLIENT, STARE_COMANDA, ID_ANGAJAT)
VALUES (9999, SYSDATE, 'online', 101, 1, 100);

--24
DECLARE
    CURSOR C IS SELECT
    ID_ANGAJAT,
    NUME
    FROM ANGAJATI
    WHERE ID_FUNCTIE='SA_REP';
    
    R C%ROWTYPE;
    V_NR_COMENZI NUMBER DEFAULT 0;
    NU_EXISTA EXCEPTION;
    PRAGMA EXCEPTION_INIT(NU_EXISTA,-20000);
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        
        SELECT COUNT(*) INTO V_NR_COMENZI
        FROM COMENZI
        WHERE ID_ANGAJAT=R.ID_ANGAJAT
        AND EXTRACT(YEAR FROM DATA)=EXTRACT(YEAR FROM SYSDATE);
        
        IF V_NR_COMENZI>0 THEN
            DBMS_OUTPUT.PUT_LINE(R.NUME||' '||V_NR_COMENZI);
        ELSE 
            RAISE_APPLICATION_ERROR(-20000,'ANGAJATUL '||R.NUME||' NU A INTERMEDIAT NICIO COMANDA');
        END IF;
    END LOOP;
    CLOSE C;
    
    EXCEPTION 
        WHEN NU_EXISTA THEN
            DBMS_OUTPUT.PUT_LINE('A APARUT EROAREA'||SQLERRM);
END;
/


--25
DECLARE
    CURSOR C IS SELECT
    A.ID_ANGAJAT,
    A.NUME,
    A.SALARIUL,
    A.ID_DEPARTAMENT,
    D.DENUMIRE_DEPARTAMENT
    FROM ANGAJATI A
    JOIN DEPARTAMENTE D ON A.ID_DEPARTAMENT=D.ID_DEPARTAMENT;
    
    R C%ROWTYPE;
    EX EXCEPTION;
    PRAGMA EXCEPTION_INIT(EX,-20000);
    SAL NUMBER;
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        
        SELECT AVG(SALARIUL) INTO SAL
        FROM ANGAJATI
        WHERE ID_DEPARTAMENT=R.ID_DEPARTAMENT;
        
        IF R.SALARIUL < SAL THEN
                RAISE_APPLICATION_ERROR(-20000, 'Angajatul ' || R.NUME || ' are salariul mai mic decat media pentru departamentul '||R.DENUMIRE_DEPARTAMENT);
  
        END IF;
    END LOOP;
    CLOSE C;
    
    EXCEPTION 
        WHEN EX THEN
            DBMS_OUTPUT.PUT_LINE('A APARUT EROAREA'||SQLERRM);
END;
/


--26
CREATE OR REPLACE TRIGGER TG_CO BEFORE INSERT ON COMENZI FOR EACH ROW
DECLARE 
    V_NR NUMBER DEFAULT 0;
BEGIN
    SELECT COUNT(*)INTO V_NR
    FROM ANGAJATI A
    WHERE A.ID_ANGAJAT=:NEW.ID_ANGAJAT
    AND (ID_FUNCTIE='SA_REP' OR ID_FUNCTIE='SA_MAN');
    
    IF V_NR=0 THEN
        RAISE_APPLICATION_ERROR(-20000,'COMADA NU E PERMISA');
    END IF;
END;
/

INSERT INTO COMENZI (ID_COMANDA, DATA, MODALITATE, ID_CLIENT, STARE_COMANDA, ID_ANGAJAT) 
VALUES (8888, SYSDATE, 'direct', 105, 2, 102);


--27
DECLARE
    CURSOR C IS SELECT
    A.ID_ANGAJAT,
    A.NUME,
    A.PRENUME,
    A.SALARIUL,
    D.ID_DEPARTAMENT
    FROM ANGAJATI A
    JOIN DEPARTAMENTE D ON A.ID_DEPARTAMENT=D.ID_DEPARTAMENT
    ORDER BY SALARIUL ASC;
    
    R C%ROWTYPE;
    MAXI NUMBER;
    EXC EXCEPTION;
    PRAGMA EXCEPTION_INIT(EXC,-20000);
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        
        SELECT MAX(SALARIUL) INTO MAXI
        FROM ANGAJATI
        WHERE ID_DEPARTAMENT=R.ID_DEPARTAMENT;
        
        IF MAXI=R.SALARIUL THEN
            RAISE_APPLICATION_ERROR(-20000,'ANGAJATUL '||R.NUME||' ARE UN SALARIUL MAXIM PT DEP SAU');
        ELSE
            DBMS_OUTPUT.PUT_LINE(R.NUME||' '||R.PRENUME);
        END IF;
    END LOOP;
    CLOSE C;
    
    EXCEPTION
        WHEN EXC THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/


--EX DIN SGBD.DOCX

--1
/*
1.	Creați un declanșator (trigger) care se va activa la fiecare adaugare în tabela COMENZI. 
Acest declanșator va trebui să verifice dacă angajatul asociat cu comanda 
(conform id_angajat din tabela COMENZI) are salariul mai mic decât 7000.
Dacă este așa, atunci comanda nu ar trebui să fie permisă. 
Testati declansatorul folosind o instructiune LMD.
*/

CREATE OR REPLACE TRIGGER TG_VERIFICA_SAL BEFORE INSERT ON COMENZI FOR EACH ROW
DECLARE 
    V_SAL NUMBER;
BEGIN
    SELECT SALARIUL INTO V_SAL
    FROM ANGAJATI
    WHERE ID_ANGAJAT=:NEW.ID_ANGAJAT;
    
    IF V_SAL<7000 THEN
        RAISE_APPLICATION_ERROR(-20000,'ANGAJATUL ARE SAL <7000');
    END IF;
END;
/

INSERT INTO COMENZI (ID_COMANDA, DATA, MODALITATE, ID_CLIENT, STARE_COMANDA, ID_ANGAJAT)
VALUES (9999, SYSDATE, 'online', 101, 1, 102);


--2
/*
2.	Scrieți un bloc PL/SQL care să parcurgă toți angajații din tabela ANGAJATI. 
Dacă un angajat a fost angajat după o dată specificată (să spunem '20.05.2010'), 
atunci ar trebui să ridicați o excepție definită de utilizator. Tratați excepția.
*/

DECLARE
    CURSOR C IS SELECT
    ID_ANGAJAT,
    NUME,
    DATA_ANGAJARE
    FROM ANGAJATI;
    
    R C%ROWTYPE;
    EXC EXCEPTION;
    PRAGMA EXCEPTION_INIT(EXC,-20000);
BEGIN
    OPEN C;
        LOOP
            FETCH C INTO R;
            EXIT WHEN C%NOTFOUND;
            IF R.DATA_ANGAJARE>TO_DATE('20.05.2024','DD.MM.YYYY') THEN
                RAISE_APPLICATION_ERROR(-20000,'ANGAJAT DUPA DATA SPEC');
            ELSE 
                DBMS_OUTPUT.PUT_LINE(R.NUME||' '||R.DATA_ANGAJARE);
            END IF;
        END LOOP;
    CLOSE C;
    
  EXCEPTION
     WHEN EXC THEN
       DBMS_OUTPUT.PUT_LINE(SQLERRM);
    
END;
/

--3
/*Creati o procedura care afiseaza primele 5 departamente in ordinea descrescatoare al 
salariului mediu al angajatilor. Se vor afisa doar departamentele cu salariul 
mediu mai mare decat o valoare x, primita ca parametru. 
Daca niciun departament nu are salariul mediu mai mare decat x,
sa se afiseze un mesaj. Sa se apeleze procedura dintr-un bloc anonim.
Va rog furnizati codul si captura de ecran cu rezultatul + codul.*/

CREATE OR REPLACE PROCEDURE GET_TOP_5(X NUMBER)IS
    CURSOR C IS SELECT
    ID_DEPARTAMENT,AVG(SALARIUL) AS SAL
    FROM ANGAJATI
    GROUP BY ID_DEPARTAMENT
    HAVING AVG(SALARIUL)>X
    ORDER BY SAL DESC;
    
    R C%ROWTYPE;
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND OR C%ROWCOUNT>5;
        DBMS_OUTPUT.PUT_LINE(R.ID_DEPARTAMENT||' '||R.SAL);
    END LOOP;
    
    IF C%ROWCOUNT=0 THEN
        DBMS_OUTPUT.PUT_LINE('NICIUN DEPARTAMENT NU ARE SAL MEDIU MAI MARE DECAT '||X);
    END IF;
    CLOSE C;
END;
/

BEGIN
    GET_TOP_5(1500);
END;
/


--4
/* Să se construiască un declanșator care să nu permită comenzi de la clienti 
necasatoriti, nascuti intre 1960 si 1965. Sa se testeze declansatorul folosind o 
instrucțiune LMD. */

CREATE OR REPLACE TRIGGER TG_COMANDA BEFORE INSERT ON COMENZI FOR EACH ROW
DECLARE 
    V_NR NUMBER DEFAULT 0;
BEGIN
    SELECT COUNT(*) INTO V_NR
    FROM CLIENTI
    WHERE ID_CLIENT=:NEW.ID_CLIENT
    AND STAREA_CIVILA='single' AND (EXTRACT(YEAR FROM DATA_NASTERE) BETWEEN 1960 AND 1965);
    
    IF V_NR>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'NU SE PERMITE INSERAREA');
    END IF;
END;
/

--5
/*
. Să se construiască un declanșator care să nu permită marirea salariului unui angajat 
care nu a intermediat nicio comanda. 
Sa se testeze triggerul folosind o instrucțiune LMD.*/

CREATE OR REPLACE TRIGGER TG_SAL BEFORE UPDATE OF SALARIUL ON ANGAJATI FOR EACH ROW
DECLARE 
    V_NR NUMBER DEFAULT 0;
BEGIN
    IF :NEW.SALARIUL>:OLD.SALARIUL THEN
        SELECT COUNT(*) INTO V_NR
        FROM COMENZI 
        WHERE ID_ANGAJAT=:NEW.ID_ANGAJAT;
        
        IF V_NR=0 THEN
            RAISE_APPLICATION_ERROR(-20000,'NU ARE COMENZI');
        END IF;
    
    END IF;
    
END;
/

UPDATE ANGAJATI
SET SALARIUL = SALARIUL + 500
WHERE ID_ANGAJAT = 101;


--6
/*
Să se construiască un declanșator care să nu permită ca o COMANDA sa fie intermediată de
un angajat cu salariul mai mare decat 10000, angajat in 2014 sau 2015.
Sa se testeze declansatorul folosind o instrucțiune LMD.
*/

CREATE OR REPLACE TRIGGER TG_COMANDA BEFORE INSERT ON COMENZI FOR EACH ROW
DECLARE 
    V_NR NUMBER;
BEGIN
    SELECT COUNT(*)INTO V_NR
    FROM ANGAJATI
    WHERE ID_ANGAJAT=:NEW.ID_ANGAJAT
    AND SALARIUL>10000 AND ( EXTRACT(YEAR FROM DATA_ANGAJARE)=2014 OR EXTRACT(YEAR FROM DATA_ANGAJARE)=2015);
    
    IF V_NR>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'NU SE POATE INTERMEDIA COMANDA DE ACEST ANGAJAT');
    END IF;
END;
/
INSERT INTO COMENZI (ID_COMANDA, DATA, MODALITATE, ID_CLIENT, STARE_COMANDA, ID_ANGAJAT)
VALUES (9111, SYSDATE, 'direct', 101, 1, 100);

--7
/*
Sa se construiască o procedură care afișează folosind un cursor numele și prenumele angajatilor 
din departamentul cu cel mai mic salariu mediu. 
După afișarea angajatilor se va afișa si numarul angajatilor din respectivul departament. 
Să se apeleze procedura dintr-un bloc anonim. 
*/

CREATE OR REPLACE PROCEDURE PROD_ANGAJ IS
    CURSOR C IS SELECT
    NUME,PRENUME,ID_DEPARTAMENT
    FROM ANGAJATI 
    WHERE ID_DEPARTAMENT=(
        SELECT ID_DEPARTAMENT
        FROM ANGAJATI
        WHERE ID_DEPARTAMENT IS NOT NULL
        GROUP BY ID_DEPARTAMENT
        ORDER BY AVG(SALARIUL) ASC
        FETCH FIRST 1 ROW ONLY
        );
        
    R C%ROWTYPE;
    V_NR NUMBER DEFAULT 0;
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        V_NR:=V_NR+1;
        DBMS_OUTPUT.PUT_LINE(R.NUME || ' ' || R.PRENUME);
    END LOOP;
    CLOSE C;
    DBMS_OUTPUT.PUT_LINE('TOTAL'||V_NR);
END;
/
    
BEGIN
    PROD_ANGAJ;
END;
/


--8

CREATE OR REPLACE TRIGGER TG_SALA BEFORE UPDATE OF SALARIUL ON ANGAJATI FOR EACH ROW
DECLARE 
    V_MAX NUMBER;
BEGIN
   SELECT SALARIU_MAX INTO V_MAX
   FROM FUNCTII
   WHERE ID_FUNCTIE=:NEW.ID_FUNCTIE;
   
   IF :NEW.SALARIUL>V_MAX THEN
        RAISE_APPLICATION_ERROR(-20000,'EROARE  SALARIU MAI MARE DECAT MAX');
    END IF;
END;
/


--9
/*
Creați un bloc PL/SQL care folosește să folosească un cursor pentru a itera prin toate
produsele asociate cu o comandă (din tabela RAND_COMENZI), spre exemplu comanda 2380. 
Dacă prețul unui produs este mai mic decât 110% * prețul minim al acelui produs (conform 
tabelei PRODUSE), blocul va ridica o excepție definită de utilizator. Tratați excepția.
*/

DECLARE
    CURSOR C IS SELECT
        R.ID_PRODUS,
        R.PRET,
        P.PRET_MIN,
        P.DENUMIRE_PRODUS
        FROM RAND_COMENZI R
        JOIN PRODUSE P ON R.ID_PRODUS=P.ID_PRODUS
        WHERE R.ID_COMANDA=2380;
        
        
    R C%ROWTYPE;
    EXC EXCEPTION;
    PRAGMA EXCEPTION_INIT(EXC,-20000);
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO R;
        EXIT WHEN C%NOTFOUND;
        IF R.PRET<(R.PRET_MIN *1.10) THEN
                RAISE_APPLICATION_ERROR(-20000,'Produsul "' || R.DENUMIRE_PRODUS || '" are un pret mai mic decat ' || (R.PRET_MIN * 1.10));
        END IF;
    END LOOP;
    CLOSE C;
    
    EXCEPTION
        WHEN EXC THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
        
        


