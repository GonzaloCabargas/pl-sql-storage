set serveroutput on
--creacion de objetos de tipo CLOB
drop table informe;
drop table vacaciones2021;

create table informe(
    rut varchar2(45),
    comentario clob default empty_clob()
);
--inisertar registro en informe
insert into informe values('11111111-1','es un buen');
select * from informe;
--actualizar el registro para agregar mas
--datos en 'comentario'
DECLARE
      v_clob clob;
      v_largo number;
BEGIN
    select comentario into v_clob
    from informe where rut= '11111111-1'for update;
    --saber el largo del texto q voy a agregar
    select length (' hombre de familia') into v_largo from dual;
    dbms_lob.writeappend(v_clob,v_largo,' hombre de familia');
    commit;
END;
---------------------------------------------------------------
--insertar imagenes
create table vacaciones2021(
    cod number primary key,
    descripcion varchar2(80),
    foto blob default empty_blob()
);
select * from vacaciones2021;

--crear una referencia hacia un directorio existente
--en el disco(se crea carpeta en disco C: llamada vaca2021)
--se debe ejecutar como administrador SYSTEM
create or replace directory OBJ_VACACIONES as 'c:\vaca2021\';
--dar permisos de directorio al usuario o esquema PENITENCIARIA
grant read, write on directory OBJ_VACACIONES TO penitenciaria;

--podemos insertar la imagen
DECLARE
    v_blob blob;
    v_bfile bfile;
    v_foto varchar2(80);
BEGIN
    insert into vacaciones2021 values(1,'cartagena en cuarentena',empty_blob())
    RETURNING foto into v_blob;
    
    v_foto:='castillo.jpg';
    --se hace referencia a donde esta ubicada la foto
    v_bfile:=bfilename('OBJ_VACACIONES',v_foto);
    --abrir la ubicacion del directorio para leer la foto
    dbms_lob.open(v_bfile, dbms_lob.lob_readonly);
    --cargar la foto
    dbms_lob.loadfromfile(v_blob,v_bfile, dbms_lob.getlength(v_bfile));
    --cierra la ubicacion
    dbms_lob.close(v_bfile);
END;
select * from vacaciones2021;

-------------------------------------------------------------------
--gestionar una carga masiva de fotos
--en carpeta 'imputados' del disco c:
select * from imputados;

--agregar el campo tipo fotografia
alter table imputados add foto blob default empty_blob();

--crear el objeto de tipo directorio(ejecutar siendo SYSTEM)
create or replace directory OBJ_IMPUTADOS as 'c:\imputados\';
grant read, write on directory OBJ_IMPUTADOS to penitenciaria;

declare
    v_blob blob;
    v_bfile bfile;
    v_foto varchar2(80);
begin
    for x in (select * from imputados)
    loop
        begin
            v_foto:=x.rut||'.jpg';
        
            select foto into v_blob
            from imputados where rut=x.rut for update;
            
            v_bfile:=bfilename('OBJ_IMPUTADOS',v_foto);
            dbms_lob.open(v_bfile,dbms_lob.lob_readonly);
            dbms_lob.loadfromfile(v_blob,v_bfile,dbms_lob.getlength(v_bfile));
            dbms_lob.close(v_bfile);
            commit;
        --en caso de no encontrar la foto creamos una excepcion
        exception
            when others then
                dbms_output.put_line('foto: '|| v_foto ||' no esta');
        end;
    end loop;
end;
select * from imputados;

--insertar imagenes y guardar errores en tabla
--creamos la tabla de errores
drop table error_fotografias;
create table error_fotografias(
    id number primary key,
    descripcion varchar2(200),
    foto varchar2(200)
);
create sequence seq_error_foto;

--insertar imagenes
declare
    v_blob blob;
    v_bfile bfile;
    v_foto varchar2(200);
    v_mensaje_error varchar2(200);
begin 
    for x in (select * from imputados)
    loop
        declare    
        begin
            v_foto := x.rut || '.jpg';
            select foto into v_blob
            from imputados where rut=x.rut for update;
            v_bfile:=bfilename('OBJ_IMPUTADOS',v_foto);
            dbms_lob.open(v_bfile,dbms_lob.lob_readonly);
            dbms_lob.loadfromfile(v_blob,v_bfile,dbms_lob.getlength(v_bfile));
            dbms_lob.close(v_bfile);
            commit;
        exception
            when others then 
                v_mensaje_error:= sqlerrm;
                insert into error_fotografias values(
                SEQ_ERROR_FOTO.nextval, v_mensaje_error,v_foto);
        end;
    end loop;
end;
select * from error_fotografias;

----------------------------------------------------------
--OBJETOS COMPUESTOS
declare
    type tipo_reg is record(
        nombre varchar2(45),
        edad number(2),
        rut varchar2(12)
    );
    reg_emp tipo_reg;
begin
    reg_emp.nombre:='Gonzalo';
    reg_emp.edad:=25;
    reg_emp.rut:='07254336-4';
    dbms_output.put_line('Nombre: '||reg_emp.nombre);
    dbms_output.put_line('Edad: '||reg_emp.edad);
    dbms_output.put_line('Rut: '||reg_emp.rut);
end;


--crear un tipo tabla
declare
    type tipo_nombres is table of
        imputados.nombre%type
        index by PLS_INTEGER;
    v_nombre tipo_nombres;
begin
    v_nombre(1):= 'Marco';
    v_nombre(3):= 'Antonio';
    v_nombre(8):= 'Pedro';
    dbms_output.put_line('Nombre1 :'||v_nombre(1));
end;
-------------------------------------------------
--creacion de tabla y recorrer con for
declare
    type comunas is table of varchar2(100) index by PLS_INTEGER;
    v_comunas comunas;
begin
    v_comunas(1):= 'Las Condes';
    v_comunas(2):= 'Vitacura';
    v_comunas(3):= 'Providencia';
    v_comunas(4):= 'La reina';
    v_comunas(5):= 'Puente Alto';
    v_comunas(6):= 'Maipu';
    v_comunas(7):= 'San Miguel';
    
    for x in v_comunas.first..v_comunas.last
    loop
        dbms_output.put_line('Comuna :'||v_comunas(x));
    end loop;
end;

-----------------------------------------------------
--CURSORES
--creacion de cursor basico
declare
    cursor cur_imp is select * from imputados;
    --se crea un obj del tipo del cursor usando %rowtype
    reg_imputados cur_imp%rowtype;
begin
    --un cursos primero se abre
    if not cur_imp%isopen then
        open cur_imp;
    end if;
    --recorrer cursor
    loop
        --recuperar un registro del cursor
        fetch cur_imp into reg_imputados;
        --salir cuendo no hay mas
        exit when cur_imp%notfound or cur_emp%rowcount=10; 
        --procesar el registro recuperado
        dbms_output.put_line('nombre: '||reg_imputados.nombre);
    end loop;
    if cur_imp%isopen then
        close cur_imp;
    end if;
end;