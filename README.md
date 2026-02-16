# P-Monokera: Prueba Técnica - Sistema de Gestión de Órdenes con Microservicios

Arquitectura de **microservicios event-driven** desarrollada con Ruby on Rails 8, PostgreSQL, RabbitMQ y Next.js. Implementa APIs REST, comunicación inter-servicios vía HTTP, publicación/consumo de eventos, y consistencia eventual. Incluye pruebas RSpec exhaustivas con FactoryBot, mocks de Faraday/Bunny y cobertura de casos unitarios e integración.

---

## 📋 Tabla de Contenidos

1. [Arquitectura](#arquitectura)
2. [Requisitos Técnicos](#requisitos-técnicos)
3. [Instalación](#instalación)
4. [Configuración](#configuración)
5. [Ejecución](#ejecución)
6. [APIs](#apis)
7. [Pruebas (RSpec)](#pruebas-rspec)
8. [Frontend (Next.js)](#frontend-nextjs)
9. [Diseño y Patrones](#diseño-y-patrones)

---

## Arquitectura

### Microservicios

```
┌──────────────────────────────────────────────────────────┐
│                    Frontend (Next.js)                    │
│                     localhost:3000                       │
└──────────┬───────────────────────────────────┬───────────┘
           │ HTTP GET /customers/:id           │ HTTP GET/POST /orders
           │ (customer-service)                │ (order-service)
           ↓                                    ↓
┌────────────────────────────┐    ┌──────────────────────────┐
│  Customer-Service          │    │  Order-Service           │
│  (Rails 8.1.2)             │    │  (Rails 8.1.2)           │
│  localhost:3001            │    │  localhost:3002          │
├────────────────────────────┤    ├──────────────────────────┤
│ DB: PostgreSQL             │    │ DB: PostgreSQL           │
│ - Customers                │    │ - Orders                 │
│ - name, address            │    │ - customer_id, product.. │
│ - orders_count             │    │ - quantity, price, status│
│                            │    │                          │
│ GET /customers/:id         │    │ GET /orders              │
│     → JSON response        │    │ POST /orders             │
│                            │    │ GET /orders?customer_id  │
└────────────────────────────┘    └──────────┬───────────────┘
           ↑                                  │
           └──────────┬───────────────────────┘
                      │ RabbitMQ Events
                      │ (order.created)
                      ↓
            127.0.0.1:5672 (RabbitMQ)
```

### Flujo de Eventos

1. **Frontend** → POST `/orders` a order-service
2. **Order-Service** valida cliente con HTTP GET a customer-service
3. **Order-Service** crea orden en BD
4. **Order-Service** publica evento `order.created` en RabbitMQ
5. **Customer-Service** consume evento y actualiza `orders_count`

---

## Requisitos Técnicos

### Software Instalado

- **Ruby**: 3.4
- **Rails**: 8.1.2
- **Node.js**: 20+
- **PostgreSQL**: 14+
- **RabbitMQ**: 4.2.3
- **Git**

### Verificar Instalación

```bash
ruby --version          # Ruby 3.4
rails --version         # Rails 8.1.2
node --version          # Node.js 20+
psql --version          # PostgreSQL 14+
rabbitmq-server -v      # RabbitMQ 4.2.3
```

---

## Instalación

### 1. Clonar Repositorio

```bash
git clone https://github.com/Cristian-Quiza/Pmonokera.git
cd PruebaInetum
```

### 2. Instalar Dependencias

#### Customer-Service
```bash
cd customer-service
bundle install
```

#### Order-Service
```bash
cd order-service
bundle install
```

#### Frontend
```bash
cd frontend
npm install --legacy-peer-deps
```

### 3. Preparar Bases de Datos

#### Customer-Service
```bash
cd customer-service
rails db:create db:migrate db:seed
```

#### Order-Service
```bash
cd order-service
rails db:create db:migrate db:seed
```

---

## Configuración

### Variables de Entorno

No se requieren en desarrollo. Rails usa valores por defecto:
- **Puertos**: customer-service=3001, order-service=3002, frontend=3000
- **BD**: PostgreSQL local (development/test)
- **RabbitMQ**: localhost:5672

### RabbitMQ

Asegurar que RabbitMQ esté corriendo:
```bash
# Windows (instancia de servicio)
Start-Service -Name RabbitMQ

# O ejecutar directamente
"C:\Program Files\RabbitMQ Server\rabbitmq_server-4.2.3\sbin\rabbitmq-server.bat"

# Linux/Mac
brew services start rabbitmq
```

Verificar:
```bash
netstat -ano | findstr ":5672"  # Windows
lsof -i :5672                   # Linux/Mac
```

---

## Ejecución

### Opción 1: Tres Terminales Separadas

**Terminal 1: Customer-Service**
```bash
cd customer-service
$env:PORT=3001
bundle exec rails s
```

**Terminal 2: Order-Service**
```bash
cd order-service
$env:PORT=3002
bundle exec rails s
```

**Terminal 3: Frontend**
```bash
cd frontend
npm run dev
# O: yarn dev
```

Acceder a: **http://localhost:3000**

### Opción 2: Railway/Docker (Opcional)

```bash
docker-compose up
```

---

## APIs

### Customer-Service (`localhost:3001`)

#### GET /customers/:id
Obtener información del cliente

**Request:**
```bash
GET /customers/1
```

**Response (200 OK):**
```json
{
  "customer_name": "Juan Pérez",
  "address": "Calle Principal 123, Medellín",
  "orders_count": 3
}
```

**Response (404 Not Found):**
```json
{
  "error": "Cliente no encontrado"
}
```

**Validaciones:**
- ID debe existir en BD
- Devuelve JSON con: customer_name, address, orders_count

---

### Order-Service (`localhost:3002`)

#### GET /orders
Listar todas las órdenes

**Request:**
```bash
GET /orders
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "customer_id": 1,
    "product_name": "Café Juan Valdez",
    "quantity": 2,
    "price": "15000.0",
    "status": "pending",
    "created_at": "2026-02-15T10:30:00.000Z"
  }
]
```

#### GET /orders?customer_id=X
Filtrar órdenes por customer_id

**Request:**
```bash
GET /orders?customer_id=1
```

**Response:** Array de órdenes del cliente 1

#### POST /orders
Crear nueva orden

**Request:**
```bash
POST /orders
Content-Type: application/json

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

**Response (201 Created):**
```json
{
  "id": 5,
  "customer_id": 1,
  "product_name": "Teclado Mecánico",
  "quantity": 3,
  "price": "20000.0",
  "status": "pending",
  "created_at": "2026-02-15T11:45:00.000Z"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Cliente 9999 no encontrado en customer-service"
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "errors": [
    "Product name can't be blank",
    "Quantity must be greater than 0"
  ]
}
```

**Validaciones:**
- `customer_id`: Requerido, debe existir en customer-service
- `product_name`: Requerido, string > 0 caracteres
- `quantity`: Requerido, entero > 0
- `price`: Requerido, decimal > 0
- `status`: Opcional, default="pending"

---

## Pruebas (RSpec)

### Configuración

Las pruebas están configuradas con:
- **FactoryBot**: fixtures dinámicas
- **RSpec-Rails**: framework de testing
- **Faraday Mocks**: mockear llamadas HTTP
- **Transactional Fixtures**: rollback automático entre tests

### Customer-Service: 11 Pruebas

#### Modelo Customer (`spec/models/customer_spec.rb`)

```ruby
# Prueba 1-2: Validaciones de presencia
- name es requerido
- address es requerido

# Prueba 3: Validación exitosa
- es válido cuando name y address están presentes

# Prueba 4-5: Atributos
- tiene orders_count default de 0
- guarda correctamente en BD

# Prueba 6: JSON
- serializa correctamente a JSON
```

**¿Por qué cubre requisitos?**
- Valida que BD solo acepta customers con name + address
- Verifica orders_count comienza en 0
- Asegura persistencia en BD

#### Requests Customers (`spec/requests/customers_spec.rb`)

```ruby
# Prueba 1: GET exitoso
- devuelve cliente con customer_name, address, orders_count

# Prueba 2: GET no existent
- retorna 404 si cliente no existe

# Prueba 3-5: Validaciones de JSON
- tiene estructura JSON correcta
- orders_count es un número entero
- maneja múltiples clientes correctamente
```

**¿Por qué cubre requisitos?**
- Valida endpoint GET /customers/:id devuelve JSON correcto
- Valida 404 si cliente no existe
- Verifica estructura y tipos de datos

**Ejecutar:**
```bash
cd customer-service
rspec spec/models/customer_spec.rb spec/requests/customers_spec.rb --format doc
```

**Output:**
```
Customer
  validations
    ✓ valida que name es requerido
    ✓ valida que address es requerido
    ✓ es válido cuando name y address están presentes
  attributes
    ✓ tiene orders_count default de 0
    ✓ guarda correctamente en BD
  #as_json
    ✓ serializa correctamente a JSON

Customers API
  GET /customers/:id
    ✓ devuelve cliente con customer_name, address, orders_count
    ✓ retorna 404 si cliente no existe
    ✓ tiene estructura JSON correcta
    ✓ orders_count es un número entero
    ✓ maneja múltiples clientes correctamente

Finished in 1.03 seconds
11 examples, 0 failures ✅
```

---

### Order-Service: 20 Pruebas

#### Modelo Order (`spec/models/order_spec.rb`)

```ruby
# Prueba 1-6: Validaciones
- customer_id es requerido
- product_name es requerido
- quantity es mayor a 0
- rechaza quantity negativo
- price es mayor a 0
- es válida cuando todos los campos son correctos

# Prueba 7-9: Atributos
- guarda correctamente en BD
- tiene status por defecto pending
- registra created_at automáticamente

# Prueba 10: JSON
- serializa correctamente a JSON
```

**¿Por qué cubre requisitos?**
- Valida presencia de campos obligatorios
- Valida numericality (>0) para quantity y price
- Verifica status default y timestamps

#### Requests Orders (`spec/requests/orders_spec.rb`)

```ruby
# POST /orders (5 pruebas)
- crea orden si cliente existe (mockea Faraday 200) ✅
- retorna 404 si cliente NO existe (mockea Faraday 404) ✅
- valida que customer_id es requerido ✅
- persiste todos los parámetros correctamente ✅
- retorna JSON de la orden creada ✅

# GET /orders (5 pruebas)
- retorna todas las órdenes
- filtra órdenes por customer_id
- retorna array vacío si no hay órdenes
- retorna array vacío si customer no tiene órdenes
- serializa correctamente en JSON
```

**Mocks Faraday:**
```ruby
# Mock: Cliente EXISTE (HTTP 200)
allow_any_instance_of(Faraday::Connection)
  .to receive(:get).and_return(double(status: 200))

# Mock: Cliente NO EXISTE (HTTP 404)
allow_any_instance_of(Faraday::Connection)
  .to receive(:get).and_return(double(status: 404))
```

**¿Por qué cubre requisitos?**
- Valida POST sin depender de customer-service real (mock)
- Valida que devuelve 404 si cliente no existe
- Valida parametros requeridos
- Valida GET con y sin filtros

**Ejecutar:**
```bash
cd order-service
rspec spec/models/order_spec.rb spec/requests/orders_spec.rb --format doc
```

**Output:**
```
Order
  validations
    ✓ valida que customer_id es requerido
    ✓ valida que product_name es requerido
    ✓ valida que quantity es mayor a 0
    ✓ rechaza quantity negativo
    ✓ valida que price es mayor a 0
    ✓ es válida cuando todos los campos son correctos
  attributes
    ✓ guarda correctamente en BD
    ✓ tiene status por defecto pending si no se especifica
    ✓ registra created_at automáticamente
  #as_json
    ✓ serializa correctamente a JSON

Orders API
  POST /orders
    ✓ crea orden si cliente existe en customer-service
    ✓ retorna 404 si cliente no existe en customer-service
    ✓ valida que customer_id es requerido
    ✓ persiste todos los parámetros correctamente
    ✓ retorna JSON de la orden creada
  GET /orders
    ✓ retorna todas las órdenes
    ✓ filtra órdenes por customer_id
    ✓ retorna array vacío si no hay órdenes
    ✓ retorna array vacío si customer no tiene órdenes
    ✓ serializa correctamente en JSON

Finished in 1.21 seconds
20 examples, 0 failures ✅
```

### Cobertura de Requisitos

| Requisito | Test | Servicio | Estado |
|-----------|------|----------|--------|
| GET /customers/:id devuelve JSON | ✅ devuelve cliente... | customer-service | PASS |
| 404 si cliente no existe | ✅ retorna 404 si... | customer-service | PASS |
| Validar name, address (required) | ✅ valida que name/address es requerido | customer-service | PASS |
| orders_count default 0 | ✅ tiene orders_count default de 0 | customer-service | PASS |
| POST /orders crea orden | ✅ crea orden si cliente existe | order-service | PASS |
| POST valida customer_id existe | ✅ mockea Faraday 200/404 | order-service | PASS |
| Validar presence customer_id | ✅ customer_id es requerido | order-service | PASS |
| Validar quantity > 0 | ✅ quantity es mayor a 0 | order-service | PASS |
| Validar price > 0 | ✅ price es mayor a 0 | order-service | PASS |
| GET /orders con filtro | ✅ filtra órdenes por customer_id | order-service | PASS |

---

## Frontend (Next.js)

### Estructura

```
frontend/
├── app/
│   ├── layout.tsx        # Root layout con suppressHydrationWarning
│   └── page.tsx          # Home (importa OrderForm + OrdersTable)
├── src/
│   ├── components/
│   │   ├── OrderForm.tsx       # Formulario crear orden (¿)
│   │   └── OrdersTable.tsx    # Tabla paginada (✅)
├── components/
│   ├── OrderForm.tsx       # Alternativa raíz
│   └── OrdersTable.tsx    # Alternativa raíz
└── package.json
```

### Componentes

#### OrderForm.tsx
- ✅ Select cliente (IDs 1-5)
- ✅ Campos: product_name, quantity, price, status
- ✅ Cálculo auto: monto_total = quantity × price
- ✅ Validación de presencia
- ✅ POST a http://localhost:3002/orders
- ✅ Toast success/error
- ✅ Loading state desactiva form

#### OrdersTable.tsx
- ✅ GET http://localhost:3002/orders
- ✅ Tabla: ID | Cliente | Producto | Cantidad | Precio | Estado | Fecha
- ✅ Paginación: 20 por página
- ✅ Botones: ← Anterior | Siguiente →
- ✅ Muestra: Página X de Y
- ✅ Auto-refetch cuando se crea orden (refreshTrigger prop)

### Ejecutar Frontend

```bash
cd frontend
npm run dev         # Development con hot-reload
npm run build       # Build para producción
npm start           # Ejecutar build
```

Acceder: **http://localhost:3000**

### Requisitos Completados

- ✅ Vista paginada GET /orders?customer_id=XX (20 resultados/página)
- ✅ Vista/formulario creación POST /orders
- ✅ Integración con ambas APIs
- ✅ Componentes React con useState/useEffect
- ✅ TypeScript para type safety
- ✅ Tailwind CSS para estilos
- ✅ Toast notifications
- ✅ Loading y error states
- ✅ Código comentado en español

---

## Scripts de Migración y Seeds para la Base de Datos

Los microservicios usan PostgreSQL con bases de datos separadas. A continuación se detallan las migraciones y seeds necesarias para preparar el entorno.

### 1. Customer Service (customer-service)

**Migración principal**  
Archivo: `db/migrate/20260214101139_create_customers.rb`

```ruby
# db/migrate/20260214101139_create_customers.rb
class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.integer :orders_count, default: 0, null: false

      t.timestamps
    end
  end
end

## Diseño y Patrones

### Rails Patterns

**Customer-Service:**
- RESTful API (GET /customers/:id)
- JSON serialization (as_json)
- Model validations (presence)
- Thin controllers, fat models

**Order-Service:**
- RESTful API (GET/POST /orders)
- Model validations (presence, numericality)
- HTTP client integration (Faraday)
- Event publishing (RabbitMQ)
- Error handling & logging

### React Patterns

**Controlled Components:**
- OrderForm: state en componente
- ClientSelector: props-driven (controlled por padre)

**Hooks:**
- `useState`: form data, pagination, loading
- `useEffect`: fetch on mount + dependency arrays

**API Integration:**
- Fetch nativo (no axios/swr)
- Error handling con try/catch
- Loading states durante requests

### Testing Patterns

**FactoryBot:**
```ruby
create(:customer, name: 'Test')  # Crea y persiste en BD
build(:order, quantity: 5)        # Crea sin persistir
```

**Mocking:**
```ruby
allow_any_instance_of(Faraday::Connection)
  .to receive(:get).and_return(double(status: 200))
```

**RSpec Matchers:**
```ruby
expect(response).to have_http_status(:ok)
expect(json['name']).to eq('Juan')
expect(order.valid?).to be_truthy
```

---

## Troubleshooting

### "Faraday ConnectFailed" al POST /orders
**Causa:** Customer-service no está corriendo o port 3001 es incorrecto
**Solución:**
```bash
# Terminal 1
cd customer-service
$env:PORT=3001
bundle exec rails s
```

### "No hay órdenes disponibles" en tabla
**Causa:** API no devuelve datos o filter está mal
**Solución:**
```bash
# Verificar manualmente
curl http://localhost:3002/orders
curl http://localhost:3002/orders?customer_id=1
```

### RSpec tests fallan con "undefined method 'create'"
**Causa:** FactoryBot no está require en rails_helper
**Solución:** Revisar que `require 'factory_bot_rails'` está en `spec/rails_helper.rb` y  `config.include FactoryBot::Syntax::Methods` está en RSpec.configure

### "Column price does not exist" en migrations
**Causa:** Falta ejecutar migrations
**Solución:**
```bash
# Customer-service
cd customer-service
rails db:migrate

# Order-service
cd order-service
rails db:migrate
```

---

## Recursos

- [Rails Guides](https://guides.rubyonrails.org/)
- [RSpec Rails](https://rspec.info/features/8-0/rspec-rails)
- [FactoryBot](https://github.com/thoughtbot/factory_bot/wiki)
- [Next.js Docs](https://nextjs.org/docs)
- [React Docs](https://react.dev/)
- [RabbitMQ](https://www.rabbitmq.com/)

---

## Licencia

MIT

---

**Última actualización:** Febrero 15, 2026
**Autor:** Cristian Quiza (Prueba Técnica Monokera)
