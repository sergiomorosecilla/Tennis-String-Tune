-- =============================================
-- TENNIS STRING & TUNE 
-- =============================================

-- 1. ENUMS
-- =============================================

CREATE TYPE estado_orden_enum AS ENUM (
  'pendiente',
  'en_proceso',
  'listo',
  'entregado'
);

-- 2. TABLA CLIENTES
-- =============================================

CREATE TABLE clientes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre      TEXT NOT NULL,
  apellidos   TEXT NOT NULL,
  telefono    TEXT NOT NULL,
  email       TEXT UNIQUE,
  notas       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. TABLA RAQUETAS
-- =============================================

CREATE TABLE raquetas (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id              UUID NOT NULL REFERENCES clientes(id)
                            ON DELETE CASCADE,
  marca                   TEXT NOT NULL,
  modelo                  TEXT NOT NULL,
  tension_habitual_main   NUMERIC(4,1),
  tension_habitual_cross  NUMERIC(4,1),
  notas                   TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. TABLA CUERDAS (catálogo)
-- =============================================

CREATE TABLE cuerdas (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre          TEXT NOT NULL,
  marca           TEXT NOT NULL,
  precio_unitario NUMERIC(6,2) NOT NULL,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. TABLA ORDENES_SERVICIO
-- =============================================

CREATE TABLE ordenes_servicio (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id          UUID NOT NULL REFERENCES clientes(id)
                        ON DELETE RESTRICT,
  raqueta_id          UUID NOT NULL REFERENCES raquetas(id)
                        ON DELETE RESTRICT,

  -- Encordado: siempre obligatorio
  srv_encordado       BOOLEAN NOT NULL DEFAULT TRUE,
  cuerda_main_id      UUID NOT NULL REFERENCES cuerdas(id)
                        ON DELETE RESTRICT,
  cuerda_cross_id     UUID NOT NULL REFERENCES cuerdas(id)
                        ON DELETE RESTRICT,
  tension_main        NUMERIC(4,1),
  tension_cross       NUMERIC(4,1),

  -- Servicios opcionales
  srv_grip            BOOLEAN NOT NULL DEFAULT FALSE,
  srv_limpieza        BOOLEAN NOT NULL DEFAULT FALSE,
  srv_logo            BOOLEAN NOT NULL DEFAULT FALSE,

  -- Precio y cobro
  precio_total        NUMERIC(6,2) NOT NULL,
  pagado              BOOLEAN NOT NULL DEFAULT FALSE,

  -- Estado y fechas
  estado              estado_orden_enum NOT NULL DEFAULT 'pendiente',
  fecha_entrada       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  fecha_prevista      DATE,
  fecha_entrega_real  TIMESTAMPTZ,

  notas               TEXT
);

-- 6. ÍNDICES
-- =============================================

CREATE INDEX idx_raquetas_cliente       ON raquetas(cliente_id);
CREATE INDEX idx_ordenes_cliente        ON ordenes_servicio(cliente_id);
CREATE INDEX idx_ordenes_raqueta        ON ordenes_servicio(raqueta_id);
CREATE INDEX idx_ordenes_cuerda_main    ON ordenes_servicio(cuerda_main_id);
CREATE INDEX idx_ordenes_cuerda_cross   ON ordenes_servicio(cuerda_cross_id);
CREATE INDEX idx_ordenes_estado         ON ordenes_servicio(estado);
CREATE INDEX idx_ordenes_fecha          ON ordenes_servicio(fecha_entrada);

-- 7. ROW LEVEL SECURITY (RLS)
-- =============================================

ALTER TABLE clientes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE raquetas          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cuerdas           ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes_servicio  ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Acceso autenticado — clientes"
  ON clientes FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Acceso autenticado — raquetas"
  ON raquetas FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Acceso autenticado — cuerdas"
  ON cuerdas FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Acceso autenticado — ordenes"
  ON ordenes_servicio FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- =============================================
-- Cambio en las RLS pàra que PowerBI pueda leer datos de las tablas 
-- =============================================


alter table public.ordenes_servicio enable row level security;
alter table public.clientes enable row level security;
alter table public.raquetas enable row level security;
alter table public.cuerdas enable row level security;

create policy "Allow anon read ordenes_servicio"
on public.ordenes_servicio
for select
to anon
using (true);

create policy "Allow anon read clientes"
on public.clientes
for select
to anon
using (true);

create policy "Allow anon read raquetas"
on public.raquetas
for select
to anon
using (true);

create policy "Allow anon read cuerdas"
on public.cuerdas
for select
to anon
using (true);

-- 8. DATOS DE PRUEBA
-- =============================================

INSERT INTO clientes (nombre, apellidos, telefono, email) VALUES
  ('Carlos',  'García López',   '612000001', 'carlos@example.com'),
  ('María',   'Fernández Ruiz', '612000002', 'maria@example.com');

INSERT INTO cuerdas (nombre, marca, precio_unitario) VALUES
  ('Alu Power 125',  'Luxilon',  18.90),
  ('RPM Blast 125',  'Babolat',  15.50),
  ('Hyper-G 16',     'Solinco',  13.00);

INSERT INTO raquetas (cliente_id, marca, modelo,
                      tension_habitual_main,
                      tension_habitual_cross)
SELECT id, 'Wilson', 'Pro Staff 97', 24.0, 23.0
FROM clientes WHERE email = 'carlos@example.com';

INSERT INTO raquetas (cliente_id, marca, modelo,
                      tension_habitual_main,
                      tension_habitual_cross)
SELECT id, 'Babolat', 'Pure Drive', 25.0, 24.0
FROM clientes WHERE email = 'maria@example.com';2