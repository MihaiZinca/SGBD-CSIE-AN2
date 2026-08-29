--Folosind o colectie sa se afiseze denumirea produselor,valoara totala a comenzilor precum si data ultimei 
--comenzi pt produsul respectiv
-- Se vor afisa produsele ordonate desc dupa data ultimei comenzi

SET SERVEROUT ON

DECLARE
    TYPE R_PR IS RECORD(
        denumire_produs VARCHAR2(50),
        valoare_totala NUMBER,
        data_ultima_comanda TIMESTAMP
    );
    
    TYPE T_PR IS TABLE OF R_PR INDEX BY PLS_INTEGER;  --INDEX BY TABLE/ ASSOCIATIVE ARRAY 
    V T_PR;
    I PLS_INTEGER;
    
BEGIN
    SELECT p.denumire_produs,
           SUM(r.cantitate * r.pret) AS valoare_totala,
           MAX(c.data) AS data_ultima_comanda
    BULK COLLECT INTO V
    FROM produse p
    JOIN rand_comenzi r ON p.id_produs = r.id_produs
    JOIN comenzi c ON r.id_comanda = c.id_comanda
    GROUP BY p.denumire_produs
    ORDER BY max(c.data) DESC;

    I := V.FIRST;
    WHILE I IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(V(I).denumire_produs || ' || Total=' || V(I).valoare_totala ||  ' || Ultima comanda=' || V(I).data_ultima_comanda);
        I := V.NEXT(I);
    END LOOP;
V.DELETE;
END;
/



DECLARE
    TYPE R_PR IS RECORD(
        denumire_produs VARCHAR2(50),
        valoare_totala NUMBER,
        data_ultima_comanda TIMESTAMP
    );
    
    TYPE T_PR IS TABLE OF R_PR;  --NESTED TABLE
    V T_PR;
    I PLS_INTEGER;
    
BEGIN
    SELECT p.denumire_produs,
           SUM(r.cantitate * r.pret) AS valoare_totala,
           MAX(c.data) AS data_ultima_comanda
    BULK COLLECT INTO V
    FROM produse p
    JOIN rand_comenzi r ON p.id_produs = r.id_produs
    JOIN comenzi c ON r.id_comanda = c.id_comanda
    GROUP BY p.denumire_produs
    ORDER BY max(c.data) DESC;
    
    V.TRIM; --functioneaza ca la varray

    I := V.FIRST;
    WHILE I IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(V(I).denumire_produs || ' || Total=' || V(I).valoare_totala ||  ' || Ultima comanda=' || V(I).data_ultima_comanda);
        I := V.NEXT(I);
    END LOOP;
V.DELETE;
END;
/

DECLARE
    TYPE R_PR IS RECORD(
        denumire_produs VARCHAR2(50),
        valoare_totala NUMBER,
        data_ultima_comanda TIMESTAMP
    );
    
    TYPE T_PR IS VARRAY(200) OF R_PR;  --VARRAY DIM MAXIMA 200
    V T_PR;
    I PLS_INTEGER;
    
BEGIN
    SELECT p.denumire_produs,
           SUM(r.cantitate * r.pret) AS valoare_totala,
           MAX(c.data) AS data_ultima_comanda
    BULK COLLECT INTO V
    FROM produse p
    JOIN rand_comenzi r ON p.id_produs = r.id_produs
    JOIN comenzi c ON r.id_comanda = c.id_comanda
    GROUP BY p.denumire_produs
    ORDER BY max(c.data) DESC;

    --v.delete(5,180); nu putem sterge VALORI DE LA MIJLOC
    V.TRIM; --sterge de la inceputul colectiei - va sterge ultimul element 
    V.TRIM(5); --va sterge ultimele 5 elemente
    I := V.FIRST;
    WHILE I IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(V(I).denumire_produs || ' || Total=' || V(I).valoare_totala ||  ' || Ultima comanda=' || V(I).data_ultima_comanda);
        I := V.NEXT(I);
    END LOOP;
V.DELETE;
END;
/


/*CURSORUL
    -IMPLICIT -CURSORUL SQL
        -SQL%FOUND, SQL%NOTFOUND, SQL%ROWCOUNT, SQL%ISOPEN (NU PREA ARE UTILITATE,este mereu false)
    
    -EXPLICIT
*/

DECLARE
    TYPE R_PR IS RECORD(
        denumire_produs VARCHAR2(50),
        valoare_totala NUMBER,
        data_ultima_comanda TIMESTAMP
    );
    
    TYPE T_PR IS VARRAY(200) OF R_PR;  --VARRAY DIM MAXIMA 200
    V T_PR;
    I PLS_INTEGER;
    
BEGIN
    SELECT p.denumire_produs,
           SUM(r.cantitate * r.pret) AS valoare_totala,
           MAX(c.data) AS data_ultima_comanda
    BULK COLLECT INTO V
    FROM produse p
    JOIN rand_comenzi r ON p.id_produs = r.id_produs
    JOIN comenzi c ON r.id_comanda = c.id_comanda
    GROUP BY p.denumire_produs
    ORDER BY max(c.data) DESC;
    
    DBMS_OUTPUT.PUT_LINE(V.COUNT);
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);

END;
/

--SA SE MAREASCA CU 5$% SALARIUL ANG CARE AU INTERMEDIAT CEL PUTIN 2 COMENZI. 
--SA SE AFISEZE NR SALARIILOR MARITE

BEGIN
    UPDATE ANGAJATI SET SALARIUL=SALARIUL*1.05
    WHERE ID_ANGAJAT IN (
    SELECT ID_ANGAJAT 
    FROM COMENZI
    GROUP BY ID_ANGAJAT
    HAVING COUNT(*)>=2);
    
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('S-AU MODIFICAT SAL');
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
    ELSE
        DBMS_OUTPUT.PUT_LINE('NU S-AU MODIFICAT SAL');
    END IF;
END;    
/

SELECT * FROM ANGAJATI WHERE ID_ANGAJAT IN(
SELECT ID_ANGAJAT 
FROM COMENZI 
GROUP BY ID_ANGAJAT 
HAVING COUNT(*)>=2);
ROLLBACK;



--SA SE MAREASCA CU 5$% SALARIUL ANG CARE AU INTERMEDIAT CEL PUTIN 2 COMENZI. 
--SA SE AFISEZE NR SALARIILOR MARITE SI ID_URILE ANG CARE AU PRIMIT MARIREA
DECLARE
    TYPE T_ANG IS TABLE OF NUMBER;
    V T_ANG;
BEGIN
    UPDATE ANGAJATI SET SALARIUL=SALARIUL*1.05
    WHERE ID_ANGAJAT IN (
    SELECT ID_ANGAJAT 
    FROM COMENZI
    GROUP BY ID_ANGAJAT
    HAVING COUNT(*)>=2) RETURNING ID_ANGAJAT BULK COLLECT INTO V;

    
    FOR I in 1..V.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(V(I));
    END LOOP;
END;    
/

-- SA SE STEARGA TOATE PRODUSELE CARE NU FOST COMANDATE NICIODATA
--SA SE AFISEZE NR DE PRODUSE STERSE PRECUM SI DENUMIREA LOC

DECLARE
    TYPE T_PROD IS TABLE OF VARCHAR(200);
    V T_PROD;
BEGIN
    DELETE FROM PRODUSE 
    WHERE ID_PRODUS NOT IN (
    SELECT ID_PRODUS
    FROM RAND_COMENZI
    GROUP BY ID_PRODUS) RETURNING DENUMIRE_PRODUS BULK COLLECT INTO V;
    
    DBMS_OUTPUT.PUT_LINE(V.COUNT);
    
    FOR I in 1..V.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(V(I));
    END LOOP;
    
END;    
/
ROLLBACK;


DECLARE
    TYPE T_REC IS RECORD(
    ID_PRODUS NUMBER,
    DENUMIRE_PRODUS VARCHAR2(100));
    TYPE T_ANG IS TABLE OF T_REC;
    V T_ANG;
BEGIN
    DELETE FROM PRODUSE 
    WHERE ID_PRODUS NOT IN (
    SELECT ID_PRODUS
    FROM RAND_COMENZI
    GROUP BY ID_PRODUS) RETURNING ID_PRODUS,DENUMIRE_PRODUS BULK COLLECT INTO V;
    
    DBMS_OUTPUT.PUT_LINE(V.COUNT);
    
    FOR I in 1..V.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(V(I).ID_PRODUS|| '' ||v(i).denumire_produs);
    END LOOP;
    
END;    
/