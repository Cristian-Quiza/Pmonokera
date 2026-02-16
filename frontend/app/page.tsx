'use client';

import { useState } from 'react';
import OrderForm from '@/components/OrderForm';
import OrdersTable from '@/components/OrdersTable';

export default function Home() {
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const handleOrderCreated = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-6xl mx-auto">
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Sistema de Órdenes</h1>
          <p className="text-lg text-gray-600">Gestiona tus órdenes de forma eficiente</p>
        </div>

        <OrderForm onOrderCreated={handleOrderCreated} />
        <OrdersTable refreshTrigger={refreshTrigger} />
      </div>
    </div>
  );
}
