--CURSO PL/SQL YOUTUBE

--VIDEO2: VARIABLES
set SERVEROUTPUT ON;

DECLARE
  identificador integer := 50;
  nombre VARCHAR2(25) := 'jose feliciano';
  apodo CHAR(10) := 'joselo';
  sueldo number(5):=30000;
  comision decimal(4,2):=50.20;
  fecha_actual date := (sysdate);
  fecha date:=TO_DATE('2020/07/09','yyyy/mm/dd');
  saludo VARCHAR2(50)default 'buenos dias a todos';
  
BEGIN
  DBMS_OUTPUT.put_line('el valor de la variable es '||identificador);
  DBMS_OUTPUT.put_line('el nombre del usuario es '||nombre);
  DBMS_OUTPUT.put_line('el apodo del usuario es '||apodo);
  DBMS_OUTPUT.put_line('el sueldo del usuario es '||sueldo);
  DBMS_OUTPUT.put_line('la comision es de '||comision);
  DBMS_OUTPUT.put_line('la fecha actual es '||fecha_actual);
  DBMS_OUTPUT.put_line('la fecha de contrato es '||fecha);
  DBMS_OUTPUT.put_line(saludo);
END;


------------------------------------------------------------------------------
--VIDEO3: CONSTANTES
--LAS CONSTANTES NO SON MODIFICABLES
DECLARE
  mensaje constant VARCHAR2(30):='buenos dias';
  numero constant NUMBER(6):=30000;
BEGIN
  DBMS_OUTPUT.put_line(mensaje);
  DBMS_OUTPUT.put_line(numero);
END;


------------------------------------------------------------------------------
--VIDEO4: CONDICIONALES IF-ELSE-ELSIF
DECLARE
  a number(2):=50;
  b number(2):=20;
BEGIN
  if a > b then
  dbms_output.put_line(a||' es mayor que: '||b);
  else
  dbms_output.put_line(b||' es mayor que '||a);
  end if;
END;

DECLARE
  numero number(3):=100;
BEGIN
  if(numero = 10)then
  dbms_output.put_line('el numero es 10');
  elsif (numero = 20) then
  dbms_output.put_line('el numero es 20');
  elsif(numero = 30)then
  dbms_output.put_line('el numero es 30');
  else
  dbms_output.put_line('ninguno de los valores fue encontrado');
  end if;
  dbms_output.put_line('el numero es '||numero);
END;


------------------------------------------------------------------------------
--VIDEO 5: BUCLES
DECLARE
  valor number:=10;
BEGIN
  loop
    DBMS_OUTPUT.PUT_LINE (valor);
    valor:=valor+10;
    if (valor > 50) then
    exit;
    end if;
  end loop;
  DBMS_OUTPUT.put_line('el valor final es '||valor);
END;
/*
existen distintos tipos de bucles

loop basico:
    loop
        secuencia
    fin del loop;

WHILE
    WHILE condicion LOOP
        secuencia de instrucciones;
    FIN DEL LOOP;

FOR
    FOR contador IN valor1..valor2 LOOP
        secuencia de instrucciones;
    FIN DEL LOOP;

LOOPS ANIDADOS
    LOOP PRINCIPAL
        primera secuencia de instrucciones;
        LOOP ANIDADO
            segunda secuencia de instrucciones;
        FIN LOOP ANIDADO;
    FIN LOOP PRINCIPAL;  
*/


------------------------------------------------------------------------------
--VIDEO 6: MANEJO DE STRINGS
DECLARE
  nombre VARCHAR2(20);
  direccion varchar2(30);
  detalles clob;
  eleccion char(1);
BEGIN
  nombre:='pedro perez';
  direccion:='calle primera no1';
  detalles:='este es el detalle de la variable clob que iniciamos en la seccion declarativa, es una 
             variable de gran almacenamiento';
  eleccion:='y';
  if eleccion = 'y' then
      dbms_output.put_line(nombre);
      dbms_output.put_line(direccion);
      dbms_output.put_line(detalles);
  end if;
END;
---------------------------------
DECLARE
  saludo varchar2(12):='hola a todos';
BEGIN
  DBMS_OUTPUT.PUT_LINE(upper(saludo));-- convierte todo a mayuscula
 
  DBMS_OUTPUT.PUT_LINE(lower(saludo));-- convierte todo a minuscula
  
  DBMS_OUTPUT.PUT_LINE(initcap(saludo));-- convierte a mayusculas las primeras letras
  
  DBMS_OUTPUT.PUT_LINE(substr(saludo,1,2)); --1: a partir de tal caracter 2: la cantidad de caracteres q buscara
  
  DBMS_OUTPUT.PUT_LINE(instr(saludo, 'o')); -- busca el caracter y señala la posicion de este
  
END;

-----------------------------------
DECLARE
  saludo2 VARCHAR2(30) :='###hola a todos###';
BEGIN
  DBMS_OUTPUT.PUT_LINE(rtrim(saludo2, '#'));--corte de la derecha todos los caracteres #
  DBMS_OUTPUT.PUT_LINE(ltrim(saludo2, '#'));--corte de la izquierda todos los caracteres #
  DBMS_OUTPUT.PUT_LINE(trim('#' from saludo2));--limpia todos los caracteres #
END;



------------------------------------------------------------------------------
--VIDEO 7: BUCLE WHILE
DECLARE
  valor number(2):=10;
BEGIN
  while valor<20 loop
      DBMS_OUTPUT.PUT_LINE('el valor es '||valor);
      valor :=valor+1;
  end loop;
  DBMS_OUTPUT.PUT_LINE('el ultimo valor es '||valor);
END;
------------------------------------
DECLARE
  numero number:=0;
  resultado number;
BEGIN
  while numero <= 5 loop
    resultado :=3*numero;
    DBMS_OUTPUT.PUT_LINE('3 x '||numero||' = '||resultado);
    numero :=numero+1;
    end loop;
END;

------------------------------------------------------------------------------
--VIDEO 8: BUCLE FOR
DECLARE
  numero number(2);
BEGIN
  for numero in 10..20 loop
    DBMS_OUTPUT.PUT_LINE('valor de numero: '||numero);
  end loop;
END;
--------------IN REVERSE---------------------
BEGIN
    for f in reverse 0..5 loop
    DBMS_OUTPUT.PUT_LINE('valor de f = '||f);
    end loop;
END;

-------------TABLA DE MULTIPLICAR-------------
BEGIN
  for f in 1..10 loop
  DBMS_OUTPUT.PUT_LINE('2 x '||f||' = '||(f*2));
  end loop;
END;

------------------------------------------------------------------------------
--VIDEO 9: BUCLES ANIDADOS

DECLARE
  bucle1 number :=0;
  bucle2 number;
BEGIN
  loop
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    DBMS_OUTPUT.PUT_LINE('valor de bucle externo = '||bucle1);
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    bucle2:=0;
        loop
            DBMS_OUTPUT.PUT_LINE('valor de bucle anidado = '||bucle2);
            bucle2:=bucle2 + 1;
            exit when bucle2=5;
        end loop;
    bucle1:=bucle1 + 1;
    exit when bucle1=3;
    end loop;
END;











