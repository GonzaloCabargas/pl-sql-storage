
var b_fecha number
exec :b_fecha := 2022
set SERVEROUTPUT ON
DECLARE
CURSOR cur_detalle_sbif is
    select 
    tc.numrun rut,
    c.dvrun dv_rut,
    tc.nro_tarjeta nro_tarjeta ,
    ttc.nro_transaccion  nro_transaccion,
    ttc.fecha_transaccion fecha_transaccion ,
    ttt.nombre_tptran_tarjeta tipo_movimiento,
    ttc.monto_transaccion total
    from cliente c 
    join tarjeta_cliente tc on c.numrun = tc.numrun
    join transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = tc.nro_tarjeta
    join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta =  ttc.cod_tptran_tarjeta and ttc.cod_tptran_tarjeta in (102,103)
    where to_char(ttc.fecha_transaccion, 'yyyy') = 2022
    order by  ttc.nro_transaccion ,fecha_transaccion ;


CURSOR cur_resumen_sbif(parameter_date number) is
    select 
    to_char(ttc.fecha_transaccion, 'mmyyyy') fecha,
    ttt.nombre_tptran_tarjeta movimiento_tarjeta,
    sum(ttc.monto_transaccion) total
    from 
    transaccion_tarjeta_cliente ttc
    join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta =  ttc.cod_tptran_tarjeta and ttc.cod_tptran_tarjeta in (102,103)
    where to_char(ttc.fecha_transaccion, 'yyyy') = parameter_date
    group by to_char(ttc.fecha_transaccion, 'mmyyyy'),ttt.nombre_tptran_tarjeta
    order by 1;
v_fecha number := 2022;    
v_porcentaje_sbif number;
v_total_sbif number;
begin

EXECUTE IMMEDIATE ('TRUNCATE TABLE DETALLE_APORTE_SBIF');
EXECUTE IMMEDIATE ('TRUNCATE TABLE RESUMEN_APORTE_SBIF');

for item in cur_detalle_sbif loop

select porc_aporte_sbif / 100 into v_porcentaje_sbif 
from tramo_aporte_sbif where item.total BETWEEN tramo_inf_av_sav and tramo_sup_av_sav ;

if v_porcentaje_sbif >0 then
    v_total_sbif := item.total *  v_porcentaje_sbif ;
end if;

    DBMS_OUTPUT.PUT_LINE('============================');
    DBMS_OUTPUT.PUT_LINE('rut. '||item.rut);
    DBMS_OUTPUT.PUT_LINE('dv_rut. '||item.dv_rut);
    DBMS_OUTPUT.PUT_LINE('nro_tarjeta. '||item.nro_tarjeta);
    DBMS_OUTPUT.PUT_LINE(' nro_transaccion. '|| item.nro_transaccion);
    DBMS_OUTPUT.PUT_LINE('fecha_transaccion. '||item.fecha_transaccion);
    DBMS_OUTPUT.PUT_LINE('tipo_movimiento. '||item.tipo_movimiento);
    DBMS_OUTPUT.PUT_LINE('total. '||item.total);
     DBMS_OUTPUT.PUT_LINE('total. '||v_total_sbif);
    
     insert into DETALLE_APORTE_SBIF values (item.rut,item.dv_rut,item.nro_tarjeta, item.nro_transaccion,item.fecha_transaccion,
    item.tipo_movimiento,item.total,v_total_sbif);
end loop;

for val in cur_resumen_sbif( v_fecha ) loop
v_porcentaje_sbif := 0;
v_porcentaje_sbif := 0;
 DBMS_OUTPUT.PUT_LINE('total. '||val.total);
   select porc_aporte_sbif / 100 into v_porcentaje_sbif 
    from tramo_aporte_sbif where val.total BETWEEN tramo_inf_av_sav and tramo_sup_av_sav ; 
       DBMS_OUTPUT.PUT_LINE('total. '||val.total);

   if v_porcentaje_sbif >0 then
      v_total_sbif := val.total *  v_porcentaje_sbif ;
   end if;
    
    insert into RESUMEN_APORTE_SBIF values (val.fecha, val.movimiento_tarjeta,val.total,  v_total_sbif);
    end loop;
end;

select * from RESUMEN_APORTE_SBIF;
