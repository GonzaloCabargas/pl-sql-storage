select * from resumen_empleados_mensual;

create sequence sq_resumen;
create sequence sq_error_proceso;
set SERVEROUTput on;
var uf number;
exec :uf:= 29100;
DECLARE
    EXECUTE IMMEDIATE ('TRUNCATE TABLE RESUMEN_EMPLEADOS_MENSUAL');
    cursor cur_emp is
        select rutemp, pnombre||' '||snombre||' '||ap_paterno||' '||ap_materno as nombre,
        to_char(sysdate,'yyyy')-to_char(fecha_naci,'yyyy') as edad,
        to_char(sysdate,'yyyy')-to_char(fecha_ingreso,'yyyy') as ant,
        sueldo, te.id_templeado, te.vacaciones, afp.porcentaje as porc_afp,
        ts.porcentaje as porc_salud,
        sg.prima_mensual,co.nomb_comuna
        from empleados e 
        inner join tipo_empleado te on e.id_tipoempleado = te.id_templeado
        inner join tipo_afp afp on e.id_afp = afp.id_afp
        inner join tipo_salud ts on e.id_tiposalud = ts.id_tiposalud
        inner join seguro sg on e.id_seguro = sg.id_seguro
        inner join comuna co on e.id_comuna = co.id_comuna
        order by rutemp;
    v_afp number:=0;
    v_salud number:=0;
    v_seguro number:=0;
    v_bono_vaca number:=0;
    
BEGIN
    for x in cur_emp
    loop
        v_afp:= round(x.sueldo * (x.porc_afp/100),0);
        v_salud:= round(x.sueldo* x.porc_salud,0);
        v_seguro:=round(x.prima_mensual*:uf,0);
        declare
            v_error varchar2(200);
        begin
            select valor_bono
            into v_bono_vaca
            from bono_vacaciones
            where x.vacaciones between dia_min and dia_max;
        exception
            when others then
                v_error:=sqlerrm;
                v_bono_vaca:=0;
                insert into error_procesos values
                    (sq_error_proceso.nextval, 'error en dias vaciones', v_error);    
        end;
        --asignacion vacaciones adicional
        if v_bono_vaca>0 then
            declare
            begin
                if x.nomb_comuna in('Renca','Puente Alto','Maipu','Conchali','Independencia')then
                    v_bono_vaca:=v_bono_vaca+10000;
                end if;
            end;
        end if;
        insert into resumen_empleados_mensual values(sq_resumen.nextval,x.rutemp,x.nombre,x.edad,x.ant,
                                                    x.sueldo,v_afp,v_salud,v_seguro,v_bono_vaca,x.vacaciones);
    end loop;
END;

select * from resumen_empleados_mensual;
select * from error_procesos;
-------------------------------------------------------------------------------------------------------------

create table resumen_bonos(
    id_tipo_empleado number primary key,
    cantidad_empleados number,
    monto_total_vacaciones number
);

DECLARE
    cursor cur_tipo_emp is select * from tipo_empleado;
    cursor cur_vaca(p_id number) is select vacaciones from empleados e
                       inner join tipo_empleado te on e.id_tipoempleado = te.id_templeado
                       where e.id_tipoempleado = p_id;
    v_cantidad number:=0;
    v_total_vacaciones number:=0;
BEGIN
    for x in cur_tipo_emp
    loop
        select count(*) into v_cantidad from empleados
        where id_tipoempleado = x.id_templeado;
        v_total_vacaciones:=0;
        for y in cur_vaca(x.id_templeado)
        loop
            declare
                v_error varchar2(200);
                v_valor_vacaciones number:=0;
            begin
                select valor_bono
                into v_valor_vacaciones
                from bono_vacaciones
                where y.vacaciones between dia_min and dia_max;
                v_total_vacaciones:=v_total_vacaciones+v_valor_vacaciones;
            exception
                when others then
                    v_error:=sqlerrm;
                    v_valor_vacaciones:=0;
                    insert into error_procesos values
                        (sq_error_proceso.nextval, 'error en dias vaciones', v_error);    
            end;
        end loop;
        insert into resumen_bonos values(x.id_templeado,v_cantidad,v_total_vacaciones);
        dbms_output.put_line('Tipo: '|| x.id_templeado||' cantidad: '||v_cantidad||' total: '||v_total_vacaciones);
    end loop;
END;

select * from resumen_bonos;


