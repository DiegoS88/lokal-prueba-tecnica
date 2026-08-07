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
3. `/cart` → carrito **agrupado por proveedor**, subtotales por proveedor, total general;
   se puede modificar o eliminar cantidades.
4. Confirmar compra → se crea la orden con sus subórdenes y se descuenta stock.
5. `/orders` → listado **"Mis Órdenes"** con las órdenes de la tienda actual
   (`current_store`), cada una con su detalle.
6. `/orders/:id` → ver una orden, sus subórdenes y los precios de cada item (es la misma
   vista de confirmación que se muestra al crearla).

## Decisiones de diseño más importantes

1. **Montos enteros en la unidad base de la moneda** en lugar de decimales/float:
   evita errores de redondeo de punto flotante. La conversión a moneda ocurre solamente
   en la vista (dividiendo por `10**precision`).
2. **Precio congelado al momento de la compra**: cada `OrderItem`/`SuborderItem` guarda
   `unit_price` y `line_total`. Un cambio posterior del precio del producto no afecta
   las órdenes ya creadas.
3. **Creación de la orden atómica** en `Orders::Create` (service object). Toda la
   operación corre en una transacción: si falla (stock insuficiente, producto inexistente,
   cantidad inválida) se hace rollback y no queda una orden/suborden creada parcialmente
   ni stock descontado.
4. **Totales guardados (denormalizados)**: `Order#total`, `Suborder#subtotal`,
   `OrderItem#line_total` y `SuborderItem#line_total` se calculan al crear y se
   persisten. Así consultar una orden no depende de recalcular montos cada vez.
5. **Carrito en `session`** (no persistido): suficiente para el alcance; sin modelos de
   carrito ni detección de usuarios.
6. **Frontend con vistas Rails (ERB) + importmap/Stimulus**, sin build: integra de forma
   limpia y cubre el flujo funcional pedido.
7. **Sin autenticación**: se usa siempre la tienda de los datos iniciales
   (`current_store`).
8. **Moneda configurable en el modelo `Currency`**: los montos se guardan como enteros en
   la unidad base de la moneda y se muestran dividiendo por `10**precision` (CLP con
   precisión 3 en el seed). El formateo se concentra en el helper `money`.

## Supuestos

- Una sola tienda compradora (la del seed); sin multi-tenant.
- Siempre existe una moneda activa (se crea en el seed): `Currency.default` es la primera
  fila de la tabla y `Currency.divisor`/`Currency.precision` dependen de ella.
- El carrito es por sesión; no hay usuarios, no hay pedido con cuenta.
- El stock es la única fuente de disponibilidad; no hay "reserva" previa, se descuenta
  al confirmar la compra.
- Una suborden contiene únicamente productos de su mismo proveedor (validado en el modelo).
- Sin impuestos ni envíos (fuera de alcance).

## Casos borde

Cubiertos (con test o validación):
- Cantidad ≤ 0 al agregar/actualizar → mensaje claro.
- Agregar o actualizar por encima del stock del producto → error con el disponible. La
  validación vive en el modelo (`Product#can_supply?`) y, en el carrito, el frontend
  además recorta la cantidad al stock al modificarla.
- Todos los productos de una suborden pertenecen al mismo proveedor (validado en el
  modelo `Suborder`).
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

- Usé Opencode, una herramienta gratuita con la cual pude acceder al modelo DeepSeek V4 Flash, para comenzar lo usé para que me ayudara a generar un plan de implementación con el enunciado de la tarea, luego de darle feedback y pedirle algunas modificaciones, pasamos a implementar. Con esto ya tenía una aplicación base funcional, sobre la cual fuí refactorizando para hacer el codigo mas limpio, arreglando bugs y tambien agregando un poco mas de estilo a la aplicación para que sea mas intuitiva de usar. Ademas, le pedí que me ayudara a crear tests para validar los requeriimientos del enunciado y luego arregle un poco los test que había generado.

## Estructura

```
app/models                     # Store, Provider, Product, Currency, Order, OrderItem, Suborder, SuborderItem
app/services/orders/create.rb  # creación atómica de la orden (transacción)
app/controllers                # catalog, cart, orders
app/views                      # vistas ERB del catálogo, carrito y órdenes (listado + detalle)
app/javascript/controllers     # Stimulus: carrito (totales y recorte de stock en vivo)
db/migrate                     # esquema
db/seeds.rb                    # datos iniciales
test/                          # model tests, service test, integration test
```