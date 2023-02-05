VAR b_por_aum1 NUMBER
VAR b_por_aum2 NUMBER
VAR b_por_aum3 NUMBER
VAR b_por_aum4 NUMBER
VAR b_por_aum5 NUMBER
VAR b_por_aum6 NUMBER
VAR b_por_aum7 NUMBER
EXEC :b_por_aum1:= 1200
EXEC :b_por_aum2:= 1300
EXEC :b_por_aum3:= 1700
EXEC :b_por_aum4:= 1900
EXEC :b_por_aum5:= 1100
EXEC :b_por_aum6:= 2000
EXEC :b_por_aum7:= 2300
set SERVEROUTPUT ON
DECLARE
CURSOR cur_datos_cli IS
   SELECT 
    p.pac_run,
    p.dv_run, 
    p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno,
    a.ate_id,
    pa.fecha_venc_pago, 
    pa.fecha_pago,
    pa.fecha_pago - pa.fecha_venc_pago,
    e.esp_id,
    e.nombre,
    round(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/ 12)
    FROM paciente p 
    JOIN atencion a ON p.pac_run = a.pac_run
    join especialidad_medico em on em.esp_id = a.esp_id and em.med_run = a.med_run
    join especialidad e on e.esp_id = em.esp_id
    join pago_atencion pa on pa.ate_id = a.ate_id
    where to_char(a.fecha_atencion,'yyyy') = '2021' and  pa.fecha_pago - pa.fecha_venc_pago > 0
    and em.esp_id in (100,300,200,400,900,500,600,700,1100,1400,1800)
    order by pa.fecha_venc_pago, p.apaterno;
      
-- DCLARO EL ARRAY PARA ALMACENAR LOS VALORES DE MULTA POR ESPECIALIDAD      
TYPE tp_varray_multas IS VARRAY(7) 
         OF NUMBER;
v_array_multa  tp_varray_multas;


TYPE tipo_reg_paciente is RECORD 
    (rut NUMBER,
    dv_rut NCHAR(1),
    nombre NVARCHAR2(60),
    id_atencion number,
    fecha_venc_pago date,
    fecha_pago date,
    dias_morosidad number,
    id_especialidad  number,
    especialidad NVARCHAR2(30),
    edad number);
reg_cliente  tipo_reg_paciente;
reg_cliente2  tipo_reg_paciente;


v_total_multa number;
v_desc_tercera_edad number;
BEGIN
EXECUTE IMMEDIATE ('TRUNCATE TABLE PAGO_MOROSO');
  OPEN cur_datos_cli;
  v_array_multa:= tp_varray_multas(:b_por_aum1,:b_por_aum2,:b_por_aum3,:b_por_aum4,:b_por_aum5,:b_por_aum6,:b_por_aum7);
  
  
LOOP 
    
    FETCH cur_datos_cli INTO reg_cliente;
    EXIT WHEN cur_datos_cli%NOTFOUND;
    
    v_total_multa:= 
    CASE 
        WHEN reg_cliente.id_especialidad = 100 OR reg_cliente.id_especialidad = 300 THEN
        reg_cliente.dias_morosidad * v_array_multa(1)
        WHEN reg_cliente.id_especialidad = 200  THEN
        reg_cliente.dias_morosidad * v_array_multa(2)
        WHEN reg_cliente.id_especialidad = 400 OR reg_cliente.id_especialidad = 900 THEN
        reg_cliente.dias_morosidad * v_array_multa(3)
        WHEN reg_cliente.id_especialidad = 500 OR reg_cliente.id_especialidad = 600 THEN
        reg_cliente.dias_morosidad * v_array_multa(4)
        WHEN reg_cliente.id_especialidad = 700 THEN
        reg_cliente.dias_morosidad * v_array_multa(5)
         WHEN reg_cliente.id_especialidad = 1100  THEN
        reg_cliente.dias_morosidad * v_array_multa(6)
        WHEN reg_cliente.id_especialidad = 1400 OR reg_cliente.id_especialidad = 1800 THEN
        reg_cliente.dias_morosidad * v_array_multa(7)
        
        
        end;
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('reg_cliente.nombre '|| reg_cliente.nombre);
        DBMS_OUTPUT.PUT_LINE('reg_cliente '||reg_cliente.id_especialidad);
        DBMS_OUTPUT.PUT_LINE('reg_cliente.nombre '|| reg_cliente.id_atencion);
        DBMS_OUTPUT.PUT_LINE('v_total_multa '|| v_total_multa);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('================================');
        if reg_cliente.edad >  64 then 
            
            select porcentaje_descto/ 100
            into v_desc_tercera_edad 
            from porc_descto_3ra_edad
            where reg_cliente.edad BETWEEN anno_ini and anno_ter;
            
            v_total_multa := v_total_multa * (1 - v_desc_tercera_edad);
        end if;
        
        
        insert into pago_moroso  values (reg_cliente.rut, reg_cliente.dv_rut,reg_cliente.nombre,reg_cliente.id_atencion,
        reg_cliente.fecha_venc_pago,reg_cliente.fecha_pago,reg_cliente.dias_morosidad,
        reg_cliente.especialidad,v_total_multa);
        
 END LOOP;
CLOSE cur_datos_cli;
END; 


/*
Cirugía General y Dermatología
Ortopedia y Traumatología 
Inmunología y Otorrinolaringología
Fisiatría y Medicina Interna
Medicina General
Psiquiatría Adultos
Cirugía Digestiva y Reumatología

*/

select * from pago_moroso;

SELECT 
    p.pac_run,
    p.dv_run, 
    p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno,
    a.ate_id,
    a.fecha_atencion,
    pa.fecha_venc_pago, 
    pa.fecha_pago,
    pa.fecha_pago - pa.fecha_venc_pago,
    e.esp_id,
    e.nombre,
    round(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/ 12)
    FROM paciente p 
    JOIN atencion a ON p.pac_run = a.pac_run
    join especialidad_medico em on em.esp_id = a.esp_id and em.med_run = a.med_run
    join especialidad e on e.esp_id = em.esp_id
    join pago_atencion pa on pa.ate_id = a.ate_id
    where to_char(a.fecha_atencion,'yyyy') = '2020' and  pa.fecha_pago - pa.fecha_venc_pago > 0
  --  and to_char(pa.fecha_venc_pago,'yyyy') = '2021'
    order by pa.fecha_venc_pago, p.apaterno;
    
