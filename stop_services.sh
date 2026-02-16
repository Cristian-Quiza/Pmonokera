#!/bin/bash

# Script para detener todos los servicios del proyecto P-Monokera

echo "🛑 Deteniendo servicios de P-Monokera..."
echo ""

# Detener Customer Service
if [ -f /tmp/customer-service.pid ]; then
    CUSTOMER_PID=$(cat /tmp/customer-service.pid)
    if ps -p $CUSTOMER_PID > /dev/null 2>&1; then
        echo "   🛑 Deteniendo Customer Service (PID: $CUSTOMER_PID)..."
        kill $CUSTOMER_PID
        rm /tmp/customer-service.pid
        echo "   ✅ Customer Service detenido"
    else
        echo "   ℹ️  Customer Service no está corriendo"
        rm /tmp/customer-service.pid
    fi
else
    echo "   ℹ️  No se encontró PID de Customer Service"
fi
echo ""

# Detener Order Service
if [ -f /tmp/order-service.pid ]; then
    ORDER_PID=$(cat /tmp/order-service.pid)
    if ps -p $ORDER_PID > /dev/null 2>&1; then
        echo "   🛑 Deteniendo Order Service (PID: $ORDER_PID)..."
        kill $ORDER_PID
        rm /tmp/order-service.pid
        echo "   ✅ Order Service detenido"
    else
        echo "   ℹ️  Order Service no está corriendo"
        rm /tmp/order-service.pid
    fi
else
    echo "   ℹ️  No se encontró PID de Order Service"
fi
echo ""

# Detener Frontend
if [ -f /tmp/frontend.pid ]; then
    FRONTEND_PID=$(cat /tmp/frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "   🛑 Deteniendo Frontend (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
        rm /tmp/frontend.pid
        echo "   ✅ Frontend detenido"
    else
        echo "   ℹ️  Frontend no está corriendo"
        rm /tmp/frontend.pid
    fi
else
    echo "   ℹ️  No se encontró PID de Frontend"
fi
echo ""

# Limpiar procesos huérfanos si existen
echo "🧹 Limpiando procesos huérfanos..."
pkill -f "rails s" 2>/dev/null && echo "   ✅ Procesos Rails limpiados" || echo "   ℹ️  No hay procesos Rails huérfanos"
pkill -f "next dev" 2>/dev/null && echo "   ✅ Procesos Next.js limpiados" || echo "   ℹ️  No hay procesos Next.js huérfanos"
echo ""

echo "✅ Todos los servicios han sido detenidos"
echo ""
echo "💡 Para volver a iniciar los servicios, ejecuta:"
echo "   ./start_services.sh"
