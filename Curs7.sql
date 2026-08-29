SET SERVEROUTPUT ON
declare 
 cursor c is select id_angajat,prenume,nume,salariul from angajati order by salariul desc;
begin
 --open c;
 for r in c loop
 dbms_output.put_line(r.prenume||' '||r.nume||' '||r. salariul); 
 end loop;
 --open c;
 close c;
end;
/

declare
  cursor c is select id_comanda from rand_comenzi group by id_comanda order by sum(pret*cantitate) desc;
  cursor d(p_id_comanda number) is select p.denumire_produs,o.pret,o.cantitate,
  o.cantitate*o.pret rand_val  
  from produse p join rand_comenzi o on p.id_produs =o.id_produs where o.id_comanda=p_id_comanda
  order by rand_val desc;
  v_order_id number;
  v_val number:=0;
begin
  open c;
  fetch c into v_order_id;
  close c;
  for r in d(v_order_id) loop
      dbms_output.put_line(d%rowcount||' - '||r.denumire_produs ||': '||r.pret||'*'||r.cantitate||'='||r.rand_val);
      v_val := v_val + r.rand_val;
  end loop;
  dbms_output.put_line('Valoarea totala a comenzii '||v_order_id||' este '||v_val);
end;
/


declare
  cursor c is select id_comanda,sum(pret*cantitate) from rand_comenzi group by id_comanda order by sum(pret*cantitate) desc;
  cursor d(p_id_comanda number) is select p.denumire_produs,o.pret,o.cantitate,
  o.cantitate*o.pret rand_val  
  from produse p join rand_comenzi o on p.id_produs =o.id_produs where o.id_comanda=p_id_comanda
  order by rand_val desc;
  v_order_id number;
  v_val number:=0;
begin
  open c;
  fetch c into v_order_id,v_val;
  close c;
  for r in d(v_order_id) loop
      dbms_output.put_line(d%rowcount||' - '||r.denumire_produs ||': '||r.pret||'*'||r.cantitate||'='||r.rand_val);      
  end loop;
  dbms_output.put_line('Valoarea totala a comenzii '||v_order_id||' este '||v_val);
end;
/

-- inline cursor
sa se afiseze angajatii din dep cu cei mai multi ang

SELECT ID_DEPARTAMENT FROM ANGAJATI GROUP BY ID_DEPARTAMENT ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY;
DECLARE
  V_ID_DEP NUMBER;
begin
 SELECT ID_DEPARTAMENT INTO V_ID_DEP FROM ANGAJATI GROUP BY ID_DEPARTAMENT ORDER BY COUNT(*) DESC
   FETCH FIRST 1 ROW ONLY;
 for r in (select id_angajat,prenume,nume,salariul from angajati
  where id_departament=V_ID_DEP order by salariul
  desc) loop 
   dbms_output.put_line(r.prenume||' '||r.nume||' '||r. salariul); 
 end loop;
end;
/

DECLARE
  V_ID_DEP NUMBER;
  CURSOR C (P_ID_DEP NUMBER) IS select id_angajat,prenume,nume,salariul from angajati
  where id_departament=V_ID_DEP order by salariul desc;
begin
 SELECT ID_DEPARTAMENT INTO V_ID_DEP FROM ANGAJATI GROUP BY ID_DEPARTAMENT ORDER BY COUNT(*) DESC
   FETCH FIRST 1 ROW ONLY;
 for r in C(V_ID_DEP) loop 
   dbms_output.put_line(r.prenume||' '||r.nume||' '||r. salariul); 
 end loop;
end;
/

select id_angajat,id_departament ,prenume,nume,salariul from angajati 
where id_departament=50 order by salariul desc;
declare
 cursor c(p_id number) is select id_angajat,id_departament ,prenume,nume,salariul from angajati 
 where id_departament=p_id order by salariul desc for update WAIT 3; /* SAU NOWAIT*/
 cursor d is select id_departament  from angajati group by id_departament  order by count(*) desc;
 n number(3);
begin
 open d;
 fetch d into n;
 close d;
 for r in c(n) loop -- ACESTEA SUNT DATELE "VAZUTE" DE CURSOR, NU CELE ACTUALIZATE DE UPDATE
 update angajati set salariul=salariul+10 where current of c;
 dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;
 dbms_output.NEW_line;
 
 for r in c(n) loop 
  dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;  
 EXCEPTION WHEN OTHERS THEN
  dbms_output.put_line('NU AM PUTUT BLOCA RANDURILE');
  dbms_output.put_line(SQLERRM);
end;
/

COMMIT;


declare
type t_c is ref cursor return angajati%rowtype;
c t_c;
 cursor d is select id_departament from angajati group by id_departament order by count(*) desc;
 n number(3);
 r angajati%rowtype;
begin
 open d;
 fetch d into n;
 close d;
 open c for select * from angajati where id_departament=n order by salariul desc;
 loop 
 fetch c into r;
 exit when c%notfound; 
 dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;
 close c;
end;
/

declare
type t_c is ref cursor return angajati%rowtype;
c t_c;
 cursor d is select id_departament from angajati group by id_departament order by count(*) desc;
 n number(3);
 r angajati%rowtype;
begin
 open d;
 fetch d into n;
 close d;
 open c for 'select * from angajati where id_departament=:1 order by salariul desc' using n;
 loop 
 fetch c into r;
 exit when c%notfound; 
 dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;
 close c;
end;
/

declare
type t_c is ref cursor;
c t_c;
 cursor d is select id_departament from angajati group by id_departament order by count(*) desc;
 n number(3);
 r angajati%rowtype;
begin
 open d;
 fetch d into n;
 close d;
 open c for 'select * from angajati where id_departament=:1 order by salariul desc' using n;
 loop 
 fetch c into r;
 exit when c%notfound; 
 dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;
 close c;
end;
/

declare
 c SYS_REFCURSOR;
 cursor d is select id_departament from angajati group by id_departament order by count(*) desc;
 n number(3);
 r angajati%rowtype;
begin
 open d;
 fetch d into n;
 close d;
 open c for 'select * from angajati where id_departament=:1 order by salariul desc' using n;
 loop 
 fetch c into r;
 exit when c%notfound; 
 dbms_output.put_line(r.id_departament||' '||r.prenume||' '||r.nume||' '||r.salariul); 
 end loop;
 close c;
end;
/

VARIABLE dept_sel REFCURSOR
BEGIN
   OPEN :dept_sel FOR SELECT * FROM DEPARTMENTE;
 END;
/
PRINT dept_sel

create or replace function syscursor_dep return sys_refcursor is
 c sys_refcursor;
 cursor d is select id_departament from angajati group by id_departament order by count(*) desc;
 n number(3);
 r angajati%rowtype;
begin
 open d;
 fetch d into n;
 close d;
 open c for 'select * from angajati where id_departament=:1 order by salariul desc' using n;
 return c;
end;
/

var rc refcursor;
exec :rc:=syscursor_dep;
print rc
SET SERVEROUTPUT ON
declare
 p varchar2(128);
 x varchar2(50);
begin
 p:='begin dbms_output.put_line(''Message=''||:1); end;';
 x:='ABCDDD';
 execute immediate p using x;
end;
/
