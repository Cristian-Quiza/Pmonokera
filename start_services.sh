#!/bin/bash

# Script para iniciar todos los servicios del proyecto P-Monokera

echo "🚀 Iniciando servicios de P-Monokera..."
echo ""

# Asegurar que PostgreSQL esté corriendo
echo "1️⃣ Iniciando PostgreSQL..."
sudo systemctl start postgresql
sleep 2
if sudo systemctl is-active --quiet postgresql; then
    echo "   ✅ PostgreSQL está corriendo"
else
    echo "   ❌ Error: PostgreSQL no se pudo iniciar"
    exit 1
fi
echo ""

# Asegurar que las bases de datos existan
echo "2️⃣ Verificando bases de datos..."
cd /home/runner/work/Pmonokera/Pmonokera/customer-service
if ! PGPASSWORD='Junio.2021' psql -h 127.0.0.1 -U postgres -d customer_service_development -c "SELECT 1" > /dev/null 2>&1; then
    echo "   📦 Creando base de datos customer-service..."
    bundle exec rails db:create db:migrate db:seed
fi

cd /home/runner/work/Pmonokera/Pmonokera/order-service
if ! PGPASSWORD='Junio.2021' psql -h 127.0.0.1 -U postgres -d order_service_development -c "SELECT 1" > /dev/null 2>&1; then
    echo "   📦 Creando base de datos order-service..."
    bundle exec rails db:create db:migrate db:seed
fi
echo "   ✅ Bases de datos listas"
echo ""

# Iniciar Customer Service
echo "3️⃣ Iniciando Customer Service (puerto 3001)..."
cd /home/runner/work/Pmonokera/Pmonokera/customer-service
PORT=3001 bundle exec rails s -p 3001 -b 0.0.0.0 > /tmp/customer-service.log 2>&1 &
CUSTOMER_PID=$!
echo $CUSTOMER_PID > /tmp/customer-service.pid
echo "   ✅ Customer Service iniciado (PID: $CUSTOMER_PID)"
echo "   📄 Logs: /tmp/customer-service.log"
echo ""

# Iniciar Order Service
echo "4️⃣ Iniciando Order Service (puerto 3002)..."
cd /home/runner/work/Pmonokera/Pmonokera/order-service
PORT=3002 bundle exec rails s -p 3002 -b 0.0.0.0 > /tmp/order-service.log 2>&1 &
ORDER_PID=$!
echo $ORDER_PID > /tmp/order-service.pid
echo "   ✅ Order Service iniciado (PID: $ORDER_PID)"
echo "   📄 Logs: /tmp/order-service.log"
echo ""

# Iniciar Frontend
echo "5️⃣ Iniciando Frontend (puerto 3000)..."
cd /home/runner/work/Pmonokera/Pmonokera/frontend
npm run dev > /tmp/frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > /tmp/frontend.pid
echo "   ✅ Frontend iniciado (PID: $FRONTEND_PID)"
echo "   📄 Logs: /tmp/frontend.log"
echo ""

echo "⏳ Esperando que los servicios se inicialicen (30 segundos)..."
sleep 30
echo ""

# Verificar que los servicios estén respondiendo
echo "🔍 Verificando servicios..."
echo ""

# Verificar Customer Service
if curl -s http://localhost:3001/customers/1 > /dev/null 2>&1; then
    echo "   ✅ Customer Service (http://localhost:3001) - FUNCIONANDO"
else
    echo "   ⚠️  Customer Service - NO RESPONDE (revisar logs)"
fi

# Verificar Order Service
if curl -s http://localhost:3002/orders > /dev/null 2>&1; then
    echo "   ✅ Order Service (http://localhost:3002) - FUNCIONANDO"
else
    echo "   ⚠️  Order Service - NO RESPONDE (revisar logs)"
fi

# Verificar Frontend
if curl -s http://localhost:3000 | grep -q "Sistema de Órdenes" 2>&1; then
    echo "   ✅ Frontend (http://localhost:3000) - FUNCIONANDO"
else
    echo "   ⚠️  Frontend - NO RESPONDE (revisar logs)"
fi

echo ""
echo "🎉 ¡Servicios iniciados!"
echo ""
echo "📱 URLs:"
echo "   - Frontend: http://localhost:3000"
echo "   - Customer Service API: http://localhost:3001"
echo "   - Order Service API: http://localhost:3002"
echo ""
echo "🛑 Para detener todos los servicios, ejecuta:"
echo "   ./stop_services.sh"
echo ""
echo "📋 PIDs guardados en:"
echo "   - Customer Service: /tmp/customer-service.pid"
echo "   - Order Service: /tmp/order-service.pid"
echo "   - Frontend: /tmp/frontend.pid"
