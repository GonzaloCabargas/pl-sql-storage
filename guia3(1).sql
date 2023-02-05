

var b_fecha number
exec :b_fecha := 2021;
var b_bono_general number
var b_por_aum1 number
var b_por_aum2 number
var b_por_aum3 number
exec :b_bono_general := 250
exec :b_por_aum1 := 300;  
exec :b_por_aum2 := 550 ;
exec :b_por_aum3 := 700;
set SERVEROUTPUT ON
declare
v_fecha number := 2021;  
  
cursor cursor_detalle(fecha number) is 
SELECT  fecha  , 
       SUM(TC) TC ,
       SUM(TA) TA,
       SUM(TSA) TSA
FROM (       
    SELECT  to_char(ttc.fecha_transaccion ,'mmyyyy') fecha,
    case  when ttc.cod_tptran_tarjeta = 101 then ttc.monto_transaccion else 0 end TC,
    case  when ttc.cod_tptran_tarjeta = 102 then ttc.monto_transaccion else 0 end TA,
   case  when ttc.cod_tptran_tarjeta = 103 then ttc.monto_transaccion else 0 end TSA
    FROM transaccion_tarjeta_cliente ttc   
full join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta =  ttc.cod_tptran_tarjeta
) 
where SUBSTR(fecha,3,6) = 2021
GROUP BY  fecha
order by fecha;

vc_cur_cli SYS_REFCURSOR; 
TYPE tipo_cur_emp IS REF CURSOR RETURN detalle_puntos_tarjeta_catb%ROWTYPE;

v_cursor detalle_puntos_tarjeta_catb%ROWTYPE;


TYPE tp_varray_bono IS VARRAY(4) 
         OF number;
v_array_bono  tp_varray_bono;

v_total_puntos number :=0;
v_edad number;
v_puntos_compras number;
v_puntos_avances number;
v_puntos_super_avance number;
begin

EXECUTE IMMEDIATE ('TRUNCATE TABLE RESUMEN_PUNTOS_TARJETA_CATB');
EXECUTE IMMEDIATE ('TRUNCATE TABLE DETALLE_PUNTOS_TARJETA_CATB');

v_array_bono:= tp_varray_bono(:b_bono_general,:b_por_aum1,:b_por_aum2,:b_por_aum3);

open vc_cur_cli for
select tc.numrun, c.dvrun ,
tc.nro_tarjeta ,
ttc.nro_transaccion ,
ttc.fecha_transaccion ,
ttt.nombre_tptran_tarjeta,
ttc.monto_transaccion,
0
from cliente c 
join tarjeta_cliente tc on c.numrun = tc.numrun
join transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = tc.nro_tarjeta
join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta =  ttc.cod_tptran_tarjeta
where to_char(ttc.fecha_transaccion, 'yyyy') = 2021
order by fecha_transaccion, numrun, nro_transaccion;


loop 
 FETCH vc_cur_cli into v_cursor;
 EXIT WHEN vc_cur_cli %NOTFOUND;


select round(MONTHS_BETWEEN(SYSDATE,c.fecha_nacimiento) /12) into v_edad from  cliente c
where c.numrun = v_cursor.numrun;
 DBMS_OUTPUT.PUT_LINE('============================');
DBMS_OUTPUT.PUT_LINE('edad. '|| v_edad);
DBMS_OUTPUT.PUT_LINE('v_cursor. '|| v_cursor.numrun);
DBMS_OUTPUT.PUT_LINE('monto_transaccion. '|| v_cursor.monto_transaccion);

if (v_edad >= 65) then 
    v_total_puntos :=
    case 
    when 
    v_cursor.monto_transaccion BETWEEN 500000 and 700000 then trunc(v_cursor.monto_transaccion /100000) * (250 +300)
    when 
    v_cursor.monto_transaccion BETWEEN 700001 and 900000 then trunc(v_cursor.monto_transaccion /100000) * (250 +550)
    when 
    v_cursor.monto_transaccion > 900000 then trunc(v_cursor.monto_transaccion /100000) * (250 +700)
    else trunc(v_cursor.monto_transaccion /100000) * 250 
    end;
else
     v_total_puntos :=trunc(v_cursor.monto_transaccion /100000) * 250 ;
end if;


insert into detalle_puntos_tarjeta_catb values (v_cursor.numrun, v_cursor.dvrun, v_cursor.nro_tarjeta,v_cursor.nro_transaccion,
v_cursor.fecha_transaccion, v_cursor.tipo_transaccion, v_cursor.monto_transaccion,v_total_puntos );--

 DBMS_OUTPUT.PUT_LINE('v_total_puntos  '|| v_total_puntos);
 DBMS_OUTPUT.PUT_LINE('');

 DBMS_OUTPUT.PUT_LINE('============================');

end loop;
close vc_cur_cli;

for item in cursor_detalle(v_fecha) loop

    DBMS_OUTPUT.PUT_LINE('Item.TC '|| item.TC);
    if Item.TC = 0 then 
        v_puntos_compras :=0;
    else 
        v_puntos_compras := trunc(item.TC/ 100000) * 250;
    end if;
  
    if Item.TA = 0 then 
        v_puntos_avances :=0;
    else 
        v_puntos_avances := trunc(item.TA/ 100000) * 250;
    end if;
    
      if Item.TSA = 0 then 
        v_puntos_super_avance :=0;
    else 
        v_puntos_super_avance := trunc(item.TSA/ 100000) * 250;
    end if;
    DBMS_OUTPUT.PUT_LINE('Item.TC '|| item.fecha);
    
   insert into resumen_puntos_tarjeta_catb values (item.fecha,item.TC,v_puntos_compras, item.TA,v_puntos_avances,item.TSA,v_puntos_super_avance);
    
end loop;    
end;

--select * from resumen_puntos_tarjeta_catb;


--select * from detalle_puntos_tarjeta_catb;


