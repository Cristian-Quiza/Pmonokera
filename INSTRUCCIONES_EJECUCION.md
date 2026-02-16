# 🚀 Instrucciones de Ejecución - Sistema P-Monokera

## ✅ Estado Actual del Proyecto

**Todos los servicios están funcionando correctamente:**
- ✅ Frontend (Next.js) en http://localhost:3000
- ✅ Customer Service (Rails) en http://localhost:3001
- ✅ Order Service (Rails) en http://localhost:3002
- ✅ PostgreSQL configurado y corriendo
- ✅ Bases de datos creadas y migradas
- ✅ Datos de prueba cargados (10 clientes, 20 órdenes)

---

## 📋 Requisitos Previos

- Ruby 3.2+
- Rails 8.1.2
- Node.js 20+
- PostgreSQL 14+
- Bundler instalado

---

## 🔧 Configuración Inicial (Ya Completada)

### 1. PostgreSQL
```bash
# Iniciar PostgreSQL
sudo systemctl start postgresql

# Configurar contraseña del usuario postgres
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"
```

### 2. Instalar Dependencias

#### Customer Service
```bash
cd customer-service
bundle config set --local path 'vendor/bundle'
bundle install
```

#### Order Service
```bash
cd order-service
bundle config set --local path 'vendor/bundle'
bundle install
```

#### Frontend
```bash
cd frontend
npm install
```

### 3. Crear y Migrar Bases de Datos

#### Customer Service
```bash
cd customer-service
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

#### Order Service
```bash
cd order-service
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

---

## 🚀 Cómo Ejecutar el Proyecto

### Opción 1: Tres Terminales Separadas (Recomendado)

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

### Opción 2: Script de Inicio Automático

Crear un archivo `start_all.sh`:
```bash
#!/bin/bash

# Asegurarse de que PostgreSQL esté corriendo
sudo systemctl start postgresql

# Iniciar Customer Service en background
cd customer-service
PORT=3001 bundle exec rails s -p 3001 -b 0.0.0.0 &
CUSTOMER_PID=$!

# Iniciar Order Service en background
cd ../order-service
PORT=3002 bundle exec rails s -p 3002 -b 0.0.0.0 &
ORDER_PID=$!

# Iniciar Frontend
cd ../frontend
npm run dev

# Guardar PIDs para poder detenerlos después
echo "Customer Service PID: $CUSTOMER_PID"
echo "Order Service PID: $ORDER_PID"
```

---

## 🧪 Verificar que Todo Funciona

### 1. Customer Service (Puerto 3001)
```bash
# Obtener información de un cliente
curl http://localhost:3001/customers/1

# Respuesta esperada:
# {
#   "customer_name": "Nombre del Cliente",
#   "address": "Dirección del Cliente",
#   "orders_count": 8
# }
```

### 2. Order Service (Puerto 3002)
```bash
# Listar todas las órdenes
curl http://localhost:3002/orders

# Listar órdenes de un cliente específico
curl http://localhost:3002/orders?customer_id=1

# Respuesta esperada: Array de órdenes con id, customer_id, product_name, quantity, price, status
```

### 3. Frontend (Puerto 3000)
Abrir en el navegador: http://localhost:3000

Deberías ver:
- ✅ Formulario para crear nuevas órdenes
- ✅ Tabla con las órdenes existentes
- ✅ Paginación funcional
- ✅ Interfaz en español con diseño moderno

---

## 🗄️ Estructura de las Bases de Datos

### customer_service_development
**Tabla: customers**
- `id` - Primary Key
- `name` - Nombre del cliente (required)
- `address` - Dirección (required)
- `orders_count` - Contador de órdenes (default: 0)
- `created_at` - Timestamp
- `updated_at` - Timestamp

**Datos de prueba:** 10 clientes creados

### order_service_development
**Tabla: orders**
- `id` - Primary Key
- `customer_id` - ID del cliente
- `product_name` - Nombre del producto (required)
- `quantity` - Cantidad (required, > 0)
- `price` - Precio (required, > 0)
- `status` - Estado (pending, confirmed, shipped, delivered, cancelled)
- `created_at` - Timestamp
- `updated_at` - Timestamp

**Datos de prueba:** 20 órdenes creadas

---

## 📊 Endpoints de las APIs

### Customer Service API (localhost:3001)

#### GET /customers/:id
Obtiene información de un cliente específico.

**Ejemplo:**
```bash
GET http://localhost:3001/customers/1
```

**Respuesta (200 OK):**
```json
{
  "customer_name": "Juan Pérez",
  "address": "Calle Principal 123, Medellín",
  "orders_count": 5
}
```

**Respuesta (404 Not Found):**
```json
{
  "error": "Cliente no encontrado"
}
```

---

### Order Service API (localhost:3002)

#### GET /orders
Lista todas las órdenes o filtra por customer_id.

**Parámetros opcionales:**
- `customer_id` - Filtra órdenes por cliente

**Ejemplo:**
```bash
GET http://localhost:3002/orders
GET http://localhost:3002/orders?customer_id=1
```

**Respuesta (200 OK):**
```json
[
  {
    "id": 1,
    "customer_id": 1,
    "product_name": "Café Juan Valdez",
    "quantity": 2,
    "price": "15000.0",
    "status": "PENDING",
    "created_at": "2026-02-16T10:30:00.000Z"
  }
]
```

#### POST /orders
Crea una nueva orden.

**Body (JSON):**
```json
{
  "order": {
    "customer_id": 1,
    "product_name": "Teclado Mecánico",
    "quantity": 3,
    "price": 20000,
    "status": "pending"
  }
}
```

**Respuesta (201 Created):**
```json
{
  "id": 21,
  "customer_id": 1,
  "product_name": "Teclado Mecánico",
  "quantity": 3,
  "price": "20000.0",
  "status": "pending",
  "created_at": "2026-02-16T11:45:00.000Z"
}
```

**Respuesta (404 Not Found):**
```json
{
  "error": "Cliente 9999 no encontrado en customer-service"
}
```

**Validaciones:**
- `customer_id` - Requerido, debe existir en customer-service
- `product_name` - Requerido, string no vacío
- `quantity` - Requerido, entero > 0
- `price` - Requerido, decimal > 0
- `status` - Opcional, default="pending"

---

## 🛠️ Solución de Problemas

### PostgreSQL no está corriendo
```bash
sudo systemctl start postgresql
sudo systemctl status postgresql
```

### Error de conexión a la base de datos
```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql

# Verificar que la contraseña esté configurada
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"

# Recrear las bases de datos si es necesario
cd customer-service
bundle exec rails db:drop db:create db:migrate db:seed

cd ../order-service
bundle exec rails db:drop db:create db:migrate db:seed
```

### Bundle no encontrado
```bash
sudo gem install bundler --force
which bundle  # Debería mostrar /usr/local/bin/bundle
```

### Gemas no instaladas
```bash
cd customer-service
bundle config set --local path 'vendor/bundle'
bundle install

cd ../order-service
bundle config set --local path 'vendor/bundle'
bundle install
```

### Puerto ya en uso
```bash
# Encontrar el proceso usando el puerto
lsof -i :3001
lsof -i :3002
lsof -i :3000

# Matar el proceso
kill -9 <PID>
```

### Frontend no se conecta a las APIs
Verificar que:
1. Customer Service esté corriendo en puerto 3001
2. Order Service esté corriendo en puerto 3002
3. Los servicios estén escuchando en 0.0.0.0 (no solo en localhost)

---

## 📝 Notas Adicionales

### Configuración de Desarrollo
- Los servicios backend usan PostgreSQL local
- Las credenciales están en `config/database.yml` de cada servicio
- Usuario: `postgres`
- Contraseña: `Junio.2021`
- Host: `localhost`
- Puerto: `5432`

### Datos de Prueba
- 10 clientes generados con Faker
- 20 órdenes distribuidas entre los clientes
- Los datos se regeneran cada vez que se ejecuta `db:seed`

### Arquitectura
- **Frontend:** Next.js 16 con TypeScript y Tailwind CSS
- **Backend:** Rails 8.1.2 con PostgreSQL
- **Comunicación:** REST APIs con JSON
- **Patrón:** Microservicios con bases de datos separadas

---

## 🎯 Siguientes Pasos (Opcional)

1. **RabbitMQ:** Implementar eventos para actualizar orders_count automáticamente
2. **Autenticación:** Agregar JWT o similar
3. **Pruebas:** Ejecutar `rspec` en cada servicio backend
4. **Docker:** Containerizar todos los servicios
5. **CI/CD:** Configurar GitHub Actions

---

## 📞 Soporte

Si encuentras algún problema:
1. Verifica que PostgreSQL esté corriendo
2. Verifica que todas las dependencias estén instaladas
3. Revisa los logs de cada servicio en la terminal
4. Consulta el README.md principal del proyecto

---

**Última actualización:** 16 de Febrero, 2026
**Estado:** ✅ Proyecto completamente funcional
