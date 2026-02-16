# 🧪 Guía Completa de Pruebas - Sistema P-Monokera

## 📋 Resumen del Sistema

El sistema P-Monokera es una aplicación de microservicios con:
- **Frontend:** Next.js (Puerto 3000)
- **Customer Service:** Rails API (Puerto 3001)
- **Order Service:** Rails API (Puerto 3002)
- **Base de Datos:** PostgreSQL

---

## 🚀 Cómo Iniciar el Sistema Completo

### Opción 1: Usar el Script Automático (Recomendado)

```bash
cd /home/runner/work/Pmonokera/Pmonokera
./start_services.sh
```

Este script:
1. ✅ Inicia PostgreSQL
2. ✅ Verifica/crea las bases de datos
3. ✅ Inicia Customer Service (puerto 3001)
4. ✅ Inicia Order Service (puerto 3002)
5. ✅ Inicia Frontend (puerto 3000)
6. ✅ Verifica que todos funcionen

### Opción 2: Manual (3 Terminales Separadas)

**Terminal 1 - Customer Service:**
```bash
cd customer-service
PORT=3001 bundle exec rails s -p 3001 -b 0.0.0.0
```

**Terminal 2 - Order Service:**
```bash
cd order-service
PORT=3002 bundle exec rails s -p 3002 -b 0.0.0.0
```

**Terminal 3 - Frontend:**
```bash
cd frontend
npm run dev
```

---

## 🧪 Pruebas Funcionales Completas

### 1. Verificar que Todos los Servicios Estén Corriendo

```bash
# PostgreSQL
sudo systemctl status postgresql

# Customer Service
curl http://localhost:3001/customers/1

# Order Service
curl http://localhost:3002/orders

# Frontend
curl http://localhost:3000
```

**Resultado Esperado:**
- PostgreSQL: Estado "active"
- Customer Service: JSON con información del cliente
- Order Service: Array JSON con órdenes
- Frontend: HTML con "Sistema de Órdenes"

---

### 2. Probar la API de Customer Service

#### Test 1: Obtener información de un cliente existente

```bash
curl -s http://localhost:3001/customers/1 | json_pp
```

**Resultado Esperado:**
```json
{
  "customer_name": "Nombre del Cliente",
  "address": "Dirección del cliente",
  "orders_count": 0
}
```

#### Test 2: Intentar obtener un cliente que no existe

```bash
curl -s http://localhost:3001/customers/999 | json_pp
```

**Resultado Esperado:**
```json
{
  "error": "Cliente no encontrado"
}
```

---

### 3. Probar la API de Order Service

#### Test 1: Listar todas las órdenes

```bash
curl -s http://localhost:3002/orders | json_pp | head -20
```

**Resultado Esperado:**
Array con 20 órdenes, cada una con:
- `id`
- `customer_id`
- `product_name`
- `quantity`
- `price`
- `status`
- `created_at`

#### Test 2: Filtrar órdenes por cliente

```bash
curl -s "http://localhost:3002/orders?customer_id=1" | json_pp
```

**Resultado Esperado:**
Array con órdenes solo del cliente 1

#### Test 3: Crear una nueva orden

```bash
curl -X POST http://localhost:3002/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "product_name": "Laptop Dell XPS",
      "quantity": 1,
      "price": 2500000,
      "status": "pending"
    }
  }' | json_pp
```

**Resultado Esperado:**
```json
{
  "id": 21,
  "customer_id": 1,
  "product_name": "Laptop Dell XPS",
  "quantity": 1,
  "price": "2500000.0",
  "status": "pending",
  "created_at": "2026-02-16T..."
}
```

#### Test 4: Intentar crear orden con cliente inexistente

```bash
curl -X POST http://localhost:3002/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 999,
      "product_name": "Producto",
      "quantity": 1,
      "price": 100,
      "status": "pending"
    }
  }' | json_pp
```

**Resultado Esperado:**
```json
{
  "error": "Cliente 999 no encontrado en customer-service"
}
```

---

### 4. Probar el Frontend (Interfaz Web)

#### Acceder a la Aplicación

1. Abrir navegador en: **http://localhost:3000**

#### Verificar Componentes de la Interfaz

**✅ Encabezado:**
- Título: "Sistema de Órdenes"
- Descripción: "Gestiona tus órdenes de forma eficiente"

**✅ Formulario de Creación:**
- Campo: Cliente (número, 1-10)
- Campo: Nombre del Producto (texto)
- Campo: Cantidad (número, mínimo 1)
- Campo: Precio Unitario (número decimal)
- Campo: Estado (dropdown con 5 opciones)
- Botón: "➕ Crear Orden"

**✅ Sección de Órdenes:**
- Título: "📋 Órdenes"
- Botón: "�� Actualizar"
- Tabla con columnas:
  - ID
  - Cliente ID
  - Producto
  - Cantidad
  - Precio
  - Estado
  - Fecha Creación

**✅ Paginación:**
- Botón: "← Anterior"
- Info: "Página X de Y"
- Info: "Mostrando X a Y de Z órdenes"
- Botón: "Siguiente →"

---

### 5. Pruebas de Funcionalidad en el Frontend

#### Test 1: Ver las Órdenes Existentes

**Pasos:**
1. Abrir http://localhost:3000
2. Esperar que cargue la página
3. Observar la tabla de órdenes

**Resultado Esperado:**
- Se muestran 20 órdenes en la tabla
- Cada orden tiene toda su información visible
- Los estados se muestran con colores distintivos

#### Test 2: Crear una Nueva Orden

**Pasos:**
1. En el formulario, ingresar:
   - Cliente: `1`
   - Producto: `Teclado Mecánico RGB`
   - Cantidad: `2`
   - Precio: `350000`
   - Estado: `⏳ Pendiente`
2. Click en "➕ Crear Orden"
3. Esperar la notificación

**Resultado Esperado:**
- Aparece notificación: "Orden creada exitosamente"
- La tabla se actualiza automáticamente
- La nueva orden aparece en la lista
- El formulario se limpia

#### Test 3: Probar Validaciones del Formulario

**Test 3a: Campo Cliente Vacío**
- Dejar cliente vacío
- Intentar crear orden
- Esperado: Mensaje de error

**Test 3b: Producto Vacío**
- Ingresar cliente pero dejar producto vacío
- Intentar crear orden
- Esperado: Mensaje de error

**Test 3c: Cantidad Inválida**
- Ingresar cantidad 0 o negativa
- Intentar crear orden
- Esperado: Mensaje de error

**Test 3d: Precio Inválido**
- Ingresar precio 0 o negativo
- Intentar crear orden
- Esperado: Mensaje de error

#### Test 4: Actualizar la Lista de Órdenes

**Pasos:**
1. Click en botón "🔄 Actualizar"
2. Esperar recarga

**Resultado Esperado:**
- La tabla se recarga
- Se muestran todas las órdenes actualizadas

#### Test 5: Probar Paginación (si hay más de 20 órdenes)

**Pasos:**
1. Si hay más de 20 órdenes, click en "Siguiente →"
2. Observar cambio de página
3. Click en "← Anterior"

**Resultado Esperado:**
- La página cambia correctamente
- Se muestran diferentes órdenes
- El contador de páginas se actualiza

#### Test 6: Probar con Cliente Inexistente

**Pasos:**
1. Ingresar cliente: `999`
2. Llenar otros campos correctamente
3. Intentar crear orden

**Resultado Esperado:**
- Error: "Cliente 999 no encontrado"
- La orden NO se crea

---

### 6. Pruebas de Integración

#### Test 1: Verificar Comunicación Frontend ↔ Order Service

**Pasos:**
1. Abrir DevTools del navegador (F12)
2. Ir a la pestaña Network
3. Refrescar la página
4. Observar las peticiones HTTP

**Resultado Esperado:**
- Se ve petición GET a http://localhost:3002/orders
- Estado: 200 OK
- Respuesta: Array de órdenes en JSON

#### Test 2: Verificar Comunicación Order Service ↔ Customer Service

**Pasos:**
1. Crear una orden con customer_id válido
2. Verificar en los logs del order-service

**Resultado Esperado:**
- Order Service hace GET a Customer Service
- Valida que el cliente existe
- Crea la orden exitosamente

---

### 7. Pruebas de Estados de Órdenes

El sistema maneja 5 estados diferentes:

1. **⏳ PENDING (Pendiente)**
   - Color: Amarillo/Ámbar
   - Significado: Orden recién creada

2. **✅ COMPLETED (Completada)**
   - Color: Verde
   - Significado: Orden procesada exitosamente

3. **🚚 SHIPPED (Enviada)**
   - Color: Azul
   - Significado: Orden en tránsito

4. **📦 DELIVERED (Entregada)**
   - Color: Verde oscuro
   - Significado: Orden recibida por el cliente

5. **❌ CANCELLED (Cancelada)**
   - Color: Rojo
   - Significado: Orden cancelada

**Test:**
Crear una orden con cada estado y verificar que se muestra correctamente en la tabla.

---

### 8. Pruebas de Rendimiento Básicas

#### Test 1: Tiempo de Carga Inicial

**Pasos:**
1. Abrir DevTools → Network
2. Refrescar la página
3. Observar el tiempo total de carga

**Resultado Esperado:**
- Carga completa en menos de 2 segundos

#### Test 2: Tiempo de Respuesta de APIs

```bash
# Customer Service
time curl -s http://localhost:3001/customers/1 > /dev/null

# Order Service
time curl -s http://localhost:3002/orders > /dev/null
```

**Resultado Esperado:**
- Customer Service: < 200ms
- Order Service: < 300ms

---

### 9. Pruebas de Datos

#### Verificar Datos en la Base de Datos

```bash
# Customers
PGPASSWORD='Junio.2021' psql -h 127.0.0.1 -U postgres -d customer_service_development \
  -c "SELECT id, name, address, orders_count FROM customers LIMIT 5;"

# Orders
PGPASSWORD='Junio.2021' psql -h 127.0.0.1 -U postgres -d order_service_development \
  -c "SELECT id, customer_id, product_name, quantity, price, status FROM orders LIMIT 5;"
```

**Resultado Esperado:**
- 10 clientes en la BD
- 20 órdenes en la BD
- Todos los datos correctamente formateados

---

### 10. Pruebas de Errores

#### Test 1: Backend Detenido

**Pasos:**
1. Detener Order Service
2. Intentar cargar órdenes en el frontend

**Resultado Esperado:**
- Mensaje: "No hay órdenes disponibles"
- O mensaje de error de conexión

#### Test 2: Base de Datos Detenida

**Pasos:**
1. Detener PostgreSQL
2. Intentar acceder a las APIs

**Resultado Esperado:**
- Error 500: Database connection error

---

## 📊 Checklist de Pruebas Completas

### Infraestructura
- [ ] PostgreSQL corriendo
- [ ] Customer Service corriendo (puerto 3001)
- [ ] Order Service corriendo (puerto 3002)
- [ ] Frontend corriendo (puerto 3000)

### APIs
- [ ] GET /customers/:id responde correctamente
- [ ] GET /customers/999 retorna 404
- [ ] GET /orders retorna lista completa
- [ ] GET /orders?customer_id=X filtra correctamente
- [ ] POST /orders crea orden exitosamente
- [ ] POST /orders valida cliente inexistente

### Frontend
- [ ] Página carga correctamente
- [ ] Formulario se visualiza completo
- [ ] Tabla de órdenes carga datos
- [ ] Crear orden funciona
- [ ] Validaciones funcionan
- [ ] Botón actualizar funciona
- [ ] Paginación funciona (si aplica)
- [ ] Notificaciones se muestran

### Integración
- [ ] Frontend obtiene datos de Order Service
- [ ] Order Service valida clientes en Customer Service
- [ ] Datos se persisten en PostgreSQL
- [ ] Actualizaciones se reflejan en tiempo real

### Rendimiento
- [ ] Carga inicial < 2 segundos
- [ ] APIs responden < 300ms
- [ ] No hay memory leaks

---

## 🎯 Casos de Uso Completos

### Caso de Uso 1: Usuario Crea su Primera Orden

1. Usuario accede a http://localhost:3000
2. Ve la tabla con 20 órdenes existentes
3. Decide crear una nueva orden
4. Llena el formulario:
   - Cliente: 1
   - Producto: "Mouse Gaming"
   - Cantidad: 1
   - Precio: 85000
   - Estado: Pendiente
5. Click en "Crear Orden"
6. Ve notificación de éxito
7. La orden #21 aparece en la tabla
8. Usuario satisfecho ✅

### Caso de Uso 2: Usuario Comete un Error

1. Usuario accede a la aplicación
2. Intenta crear orden sin llenar todos los campos
3. Ve mensaje de error
4. Corrige los campos faltantes
5. Intenta con cliente ID 999 (no existe)
6. Ve error "Cliente no encontrado"
7. Corrige a cliente ID 1 (existe)
8. Orden se crea exitosamente ✅

### Caso de Uso 3: Usuario Revisa Órdenes Existentes

1. Usuario accede a la aplicación
2. Ve tabla con 20 órdenes
3. Nota diferentes estados: PENDING, COMPLETED, CANCELLED
4. Click en "Actualizar" para refrescar
5. Observa todos los detalles de cada orden
6. Usa paginación si hay más órdenes
7. Comprende el estado del sistema ✅

---

## 🐛 Problemas Comunes y Soluciones

### Problema 1: "No hay órdenes disponibles"

**Causa:** Order Service no está corriendo o no responde

**Solución:**
```bash
cd order-service
PORT=3002 bundle exec rails s -p 3002 -b 0.0.0.0
```

### Problema 2: "Error de base de datos"

**Causa:** PostgreSQL detenido o contraseña incorrecta

**Solución:**
```bash
sudo systemctl start postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"
```

### Problema 3: "Bundle command not found"

**Causa:** Bundler no instalado

**Solución:**
```bash
sudo gem install bundler --force
```

### Problema 4: "Rails command not found"

**Causa:** Gemas no instaladas

**Solución:**
```bash
cd customer-service  # o order-service
bundle config set --local path 'vendor/bundle'
bundle install
```

### Problema 5: "next command not found"

**Causa:** Dependencias de Node no instaladas

**Solución:**
```bash
cd frontend
npm install
```

---

## 📸 Screenshots Esperados

### Vista Principal
- Formulario de creación arriba
- Tabla de órdenes abajo
- Paginación al final

### Después de Crear Orden
- Notificación verde de éxito
- Nueva orden en la tabla
- Formulario limpio

### Errores de Validación
- Mensajes en rojo
- Campos resaltados
- Formulario sin enviar

---

## ✅ Conclusión

Si todas las pruebas pasan, el sistema está:
- ✅ Completamente funcional
- ✅ Listo para uso
- ✅ Sin errores críticos
- ✅ Con buena experiencia de usuario

**¡Sistema listo para producción! 🎉**
