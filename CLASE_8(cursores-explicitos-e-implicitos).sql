--CURSORES IMPLICITOS
select * from clientes;

declare 
begin
    update clientes set puntos=10 where dv_cliente='7';
    if sql%notfound then
        dbms_output.put_line('no modifico ninguno');
    else
        dbms_output.put_line('actualizo n° '||sql%rowcount);
    end if;
end;
----------------------------------
--eliminar desde la tabla pago_credito los pagos hechos en el 2017
-- y cuente cuantos campos fueron eliminados
declare
begin
    delete from pago_credito where to_char(fecha_pago,'yyyy')=2017;
    if sql%found then
        dbms_output.put_line('se eliminaron '|| sql%rowcount);
    else
        dbms_output.put_line('no elimino registro');
    end if;
end;
rollback;
-------------------------------------------------------
declare
    v_rut clientes.run_cliente%type;
    v_error varchar2(200);
begin
    select run_cliente into v_rut
    from clientes
    where dv_cliente ='7';
    dbms_output.put_line('el cliente existe');
exception
    when no_data_found then
        dbms_output.put_line('no existe cliente');
    when too_many_rows then
        dbms_output.put_line('muchas filas de retorno');
    when others then
    v_error:= sqlerrm;
        dbms_output.put_line('error: '|| v_error);
end;
select * from clientes;
--------------------------------------------------------------------------
--cursores con lista de variables
DECLARE
    cursor cur_emp is (select run_cliente, dv_cliente from clientes);
    v_run clientes.run_cliente%type;
    v_dv clientes.dv_cliente%type;
BEGIN
    open cur_emp;
    loop
        fetch cur_emp into v_run, v_dv;
        exit when cur_emp%notfound;
            dbms_output.put_line('rut: '||v_run||'-'||v_dv);
    end loop;
    close cur_emp;
END; 

--otra forma de hacerlo
DECLARE
    cursor cur_emp is (select run_cliente, dv_cliente from clientes);
    reg_emp cur_emp%rowtype;
BEGIN
    open cur_emp;
    loop
        fetch cur_emp into reg_emp;
        exit when cur_emp%notfound;
            dbms_output.put_line('rut: '||reg_emp.run_cliente||'-'||reg_emp.dv_cliente);
    end loop;
    close cur_emp;
END;
--------------------------------------------------------------------------
--pasar datos de una tabla a otra
create table clie(
    run varchar2(20),
    dv varchar2(2)
);

DECLARE
    cursor cur_emp is (select run_cliente, dv_cliente from clientes);
    v_run clientes.run_cliente%type;
    v_dv clientes.dv_cliente%type;
BEGIN
    open cur_emp;
    loop
        fetch cur_emp into v_run, v_dv;
        exit when cur_emp%notfound;
            dbms_output.put_line('rut: '||v_run||'-'||v_dv);
            insert into clie values(v_run,v_dv);
    end loop;
    close cur_emp;
END; 
select * from clie;

--otra forma de agregar datos a una tabla
create table clie2 as (
select run_cliente, dv_cliente from clientes);
select * from clie2;
------------------------------------------------------------------
--cursores con parametros
var anno_proceso number;
exec :anno_proceso:=2018;
declare
    cursor cur_creditos(p_anno number)is
        select * from creditos 
        where to_char(fecha_credito,'yyyy')=p_anno;
    reg_creditos cur_creditos%rowtype;
    v_total number:=0;
begin
    open cur_creditos(:anno_proceso);
    loop
        fetch cur_creditos into reg_creditos;
        exit when cur_creditos%notfound;
            DBMS_OUTPUT.PUT_LINE('monto: '||to_char(reg_creditos.monto_pago,'$999g999g999'));
            v_total:=v_total+reg_creditos.monto_pago;
    end loop;
    close cur_creditos;
    DBMS_OUTPUT.PUT_LINE('total: '|| to_char(v_total,'999g999g999'));
end;
-------------------------------------------------------------------
--ver cada cliente con sus creditos
declare
    cursor cur_clientes is
        select * from clientes;
    cursor cur_creditos(p_run varchar2) is
        select * from creditos
        where run_cliente=p_run;
    reg_cli cur_clientes%rowtype;
    reg_cre cur_creditos%rowtype;
    v_total number:=0;
    v_nombre varchar2(100);
begin
    open cur_clientes;
    loop
        fetch cur_clientes into reg_cli;
        exit when cur_clientes%notfound;
            v_nombre:=reg_cli.nombre||' '||reg_cli.appaterno||' '||reg_cli.apmaterno;
            DBMS_OUTPUT.PUT_LINE('nombre: '||v_nombre||' direccion: '|| reg_cli.direccion);
            open cur_creditos(reg_cli.run_cliente);
            loop
                fetch cur_creditos into reg_cre;
                exit when cur_creditos%notfound;
                DBMS_OUTPUT.PUT_LINE('id: '||reg_cre.id_credito||' monto: '||reg_cre.monto_pago||' cuotas: '||reg_cre.cuotas);
            end loop;
            close cur_creditos;
    end loop;
    close cur_clientes;
end;
 