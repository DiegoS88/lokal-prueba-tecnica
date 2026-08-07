# Mini marketplace B2B — Prueba técnica

Aplicación Rails de un pequeño marketplace donde una tienda compra productos de varios
proveedores. Al confirmar la compra se crea una **orden** que agrupa los productos en
**subórdenes**, una por proveedor involucrado.

## Requisitos

- Ruby 3.2
- SQLite (incluido)
- Node (opcional, para tools de asset de Rails)

## Instalación y ejecución

```bash
bundle install                 # gemas quedan en vendor/bundle (configurado en .bundle/config)
bin/rails db:create db:migrate db:seed   # crea la BD y los datos iniciales
bin/rails server                # http://localhost:3000
```

Datos iniciales en `db/seeds.rb` (idempotente): una tienda **Tienda Demo**, dos
proveedores y tres productos de cada uno, con precios y stock distintos.

## Ejecutar tests

```bash
bin/rails test                 # model tests + test del servicio + test de integración
bundle exec rubocop            # estilo de código (usa rubocop-rails-omakase)
```

## Flujo

1. `/` → catálogo de productos (con stock disponible).
2. Agregar productos al carrito (guardado en `session`, no persiste en BD).
3. `/cart` → carrito **agrupado por proveedor**, subtotales por proveedor y total
   general; modificar o eliminar cantidades.
4. Confirmar compra → se crea la orden con sus subórdenes y se descuenta stock.
5. `/orders/:id` → ver la orden, sus subórdenes y los precios de cada item.

## Decisiones de diseño más importantes

1. **Montos en céntimos (enteros)** en lugar de decimales/float: evita errores de
   redondeo de punto flotante. La conversión a moneda ocurre solamente en la vista.
2. **Precio congelado al momento de la compra**: cada `OrderItem`/`SuborderItem` guarda
   `unit_price_cents` y `line_total_cents`. Un cambio posterior del precio del producto
   no afecta las órdenes ya creadas.
3. **Creación de la orden atómica** en `Orders::Create` (service object). Toda la
   operación corre en una transacción: si falla (stock insuficiente, producto inexistente,
   cantidad inválida) se hace rollback y no queda una orden/suborden creada parcialmente
   ni stock descontado.
4. **Totales guardados (denormalizados)**: `Order#total_cents`, `Suborder#subtotal_cents`
   y `OrderItem#line_total_cents` se calculan al crear y se persisten. Así la consulta no
   reescrita depende de datos viejos.
5. **Carrito en `session`** (no persistido): suficiente para el alcance; sin modelos de
   carrito ni detección de usuarios.
6. **Frontend con vistas Rails (ERB) + importmap/Stimulus**, sin build: integra de forma
   limpia y cubre el flujo funcional pedido.
7. **Sin autenticación**: se usa siempre la tienda de los datos iniciales
   (`current_store`).

## Supuestos

- Una sola tienda compradora (la del seed); sin multi-tenant.
- El carrito es por sesión; no hay usuarios, no hay pedido con cuenta.
- El stock es la única fuente de disponibilidad; no hay "reserva" previa, se descuenta
  al confirmar la compra.
- Una suborden contiene únicamente productos de su mismo proveedor (validado en el modelo).
- Sin impuestos ni envíos (fuera de alcance).

## Casos borde

Cubiertos (con test o validación):
- Cantidad ≤ 0 al agregar/actualizar → mensaje claro.
- Agregar o actualizar por encima del stock del producto → error con la disponible.
- Carrito vacío → no se crea orden.
- Stock insuficiente al confirmar la compra → rollback total (no quedan subórdenes
  parciales) y el stock no se descuenta.
- Precio congelado en el momento: cambiar el precio del producto tras comprar no altera
  la orden.
- Descuento de stock correcto al confirmar.

Dejados fuera (documentados porque se priorizó):
- Concurrencia de varias compras sobre el mismo último ítem disponible: la transacción y
  el `lock` reducen el problema pero no hay gestión avanzada de stock ni reintentos.
- Cambio de precio/pedido antes de confirmar (por ejemplo, si el stock de un producto
  agotado cambia entre el agregado y la confirmación): se valida siempre en la
  confirmación.

## Qué cambiaría para producción

- Autenticación real de tiendas y proveedores, y roles.
- Carrito persistido en base de datos en vez de `session`.
- PostgreSQL en lugar de SQLite, con bloqueo de filas estable y reintentos para el stock.
- Montos con tipo `decimal` (o integración con un sistema de monedas/impuestos) y
  registro de pagos reales.
- IDs tipo UUID, arquitectura más desacoplada (events/queues) y CI con los standards
  (brakeman, bundler-audit) en el pipeline.
- Tests end-to-end con navegador real (Capybara/Selenium).

## Qué implementaría después

- Historial de precios y versiones de catálogo.
- Cancelación parcial por suborden y reconciliación con proveedores.
- Pequeño panel para que los proveedores actualicen stock.

## Uso de herramientas de inteligencia artificial

- Utilicé el asistente (edición, búsquedas en el repo) para:
  - Descomponer el problema en hitos y planificar.
  - Redactar el esqueleto de migraciones, modelos, servicio y tests.
  - Ayudar a resolver el setup de entorno (Ruby/Rails/Bundler) y errores de fixtures
    que rompían conteos en los tests.

Verificación y correcciones sobre lo generado:
- **Verifiqué** las migraciones línea por línea (revisé `db/migrate`), incluido el caso
  de `product:true` y que el esquema quedara como esperaba.
- **Corregí** errores introducidos por el código asistido: `redirect_to.add` en el
  controlador y el uso de variable `items` vs `@items` en el servicio.
- **Descarté** propuestas de mayor complejidad que no pidan: fixtures para todos los
  modelos, carrito persistido, autenticación, decimales y frontend con build.
- **Validé** cada iteración ejecutando la suite (`bin/rails test`) en conjunto con
  RuboCop en lugar de confiar en el output generado.

## Estructura

```
app/models                     # Store, Provider, Product, Order, OrderItem, Suborder, SuborderItem
app/services/orders/create.rb  # creación atómica de la orden (transacción)
app/controllers                # catalog, cart, orders
app/views                      # vistas ERB del catálogo, carrito y orden
db/migrate                     # esquema
db/seeds.rb                    # datos iniciales
test/                          # model tests, service test, integration test
```