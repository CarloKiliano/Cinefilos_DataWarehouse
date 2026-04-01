DELETE DATABASE IF EXISTS proyecto_cinefilos_estrella;
CREATE DATABASE proyecto_cinefilos_estrella;

\c proyecto_cinefilos_estrella

create table dim_tiempo (
  llave_tiempo  integer primary key,
  mes_id        smallint not null check (mes_id between 1 and 12),
  mes_descripcion varchar(50) not null,
  dia_id        smallint not null check (dia_id between 1 and 31),
  dia_descripcion varchar(50) not null,
  edicion_festival_id integer not null,
  edicion_festival_descripcion varchar(100) not null
);

create table dim_evento (
  llave_evento   integer primary key,
  nombre_evento  varchar(150) not null,
  tipo_evento    varchar(50) not null
);

create table dim_geografia (
  llave_geografia   integer primary key,
  pais_sede_id      integer not null,
  pais_sede_desc    varchar(100) not null,
  ciudad_sede_id    integer,
  ciudad_sede_desc  varchar(100),
  lugar_cine_id     integer,
  lugar_cine_desc   varchar(100),
  sala_id           integer
);

create table dim_pelicula (
  llave_pelicula       integer primary key,
  nombre_seccion_id    integer not null,
  descripcion_seccion  varchar(200),
  nombre_seccion       varchar(100) not null,
  tipo_pelicula        varchar(100),
  pelicula_id          integer not null,
  titulo_pelicula      varchar(200) not null
);


create table fact_ventas (
  -- claves foráneas (FKs) a las dimensiones
  llave_tiempo    integer not null,
  llave_evento    integer not null,
  llave_geografia integer not null,
  llave_pelicula  integer not null,

  -- medidas
  boletos_vendidos integer       not null check (boletos_vendidos >= 0),
  ingresos_totales numeric(14,2) not null check (ingresos_totales >= 0),
  ganancias_totales numeric(14,2) not null default 0 check (ganancias_totales >= 0),

  -- clave primaria compuesta (todas las FKs)
  primary key (llave_tiempo, llave_evento, llave_geografia, llave_pelicula),

  -- constraints de claves foráneas
  foreign key (llave_tiempo)    references dim_tiempo(llave_tiempo),
  foreign key (llave_evento)    references dim_evento(llave_evento),
  foreign key (llave_geografia) references dim_geografia(llave_geografia),
  foreign key (llave_pelicula)  references dim_pelicula(llave_pelicula)
);

-- Índices para optimizar consultas
create index ix_fact_tiempo     on fact_ventas (llave_tiempo);
create index ix_fact_evento     on fact_ventas (llave_evento);
create index ix_fact_geografia  on fact_ventas (llave_geografia);
create index ix_fact_pelicula   on fact_ventas (llave_pelicula);
