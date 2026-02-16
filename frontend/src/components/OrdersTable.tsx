'use client';

import { useState, useEffect } from 'react';
import toast from 'react-hot-toast';

// Interface que coincide con la estructura real del backend
interface Order {
  id: number;
  customer_id: number;
  product_name: string;
  quantity: number;
  price: string; // El backend devuelve price como string (ej: "15000.0")
  status: string;
  created_at: string;
}

export default function OrdersTable({ refreshTrigger }: { refreshTrigger?: number }) {
  // Estados para paginación
  const [orders, setOrders] = useState<Order[]>([]); // Todas las órdenes
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1); // Página actual (comienza en 1)
  const ITEMS_PER_PAGE = 20; // Display 20 órdenes por página

  // Fetch todas las órdenes del backend
  const fetchOrders = async () => {
    try {
      setLoading(true);
      // Nota: El backend devuelve TODAS las órdenes en un array
      // En producción, usarías ?page=1&limit=20 params
      const response = await fetch('http://localhost:3002/orders', {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      });
      
      if (!response.ok) {
        throw new Error('Error al obtener las órdenes');
      }

      const data = await response.json();
      setOrders(Array.isArray(data) ? data : []);
      setCurrentPage(1); // Resetear a página 1 cuando se refetch
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Error desconocido');
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  // useEffect para auto-refetch cuando refreshTrigger cambia
  // refreshTrigger es un contador que se incrementa cuando se crea una orden
  useEffect(() => {
    fetchOrders();
  }, [refreshTrigger]);

  // Calcular variables de paginación
  const totalOrders = orders.length;
  const totalPages = Math.ceil(totalOrders / ITEMS_PER_PAGE);
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
  const endIndex = startIndex + ITEMS_PER_PAGE;
  const paginatedOrders = orders.slice(startIndex, endIndex); // Órdenes actuales para mostrar

  // Funciones de navegación
  const goToPreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
      // Auto-scroll a la tabla
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const goToNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: 'bg-yellow-100 text-yellow-800',
      confirmed: 'bg-blue-100 text-blue-800',
      shipped: 'bg-purple-100 text-purple-800',
      delivered: 'bg-green-100 text-green-800',
      cancelled: 'bg-red-100 text-red-800',
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  const getStatusLabel = (status: string) => {
    const labels: Record<string, string> = {
      pending: 'Pendiente',
      confirmed: 'Confirmada',
      shipped: 'Enviada',
      delivered: 'Entregada',
      cancelled: 'Cancelada',
    };
    return labels[status] || status;
  };

  if (loading) {
    return (
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">📋 Órdenes</h2>
        <div className="flex justify-center items-center h-40">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-800">📋 Órdenes</h2>
        <button
          onClick={fetchOrders}
          className="bg-gray-500 hover:bg-gray-600 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
        >
          🔄 Actualizar
        </button>
      </div>

      {orders.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No hay órdenes disponibles</p>
      ) : (
        <>
          {/* Tabla */}
          <div className="overflow-x-auto mb-6">
            <table className="min-w-full border-collapse">
              <thead>
                <tr className="bg-gray-100 border-b border-gray-300">
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">ID</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Cliente ID</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Producto</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Cantidad</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Precio</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Estado</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-gray-800">Fecha Creación</th>
                </tr>
              </thead>
              <tbody>
                {paginatedOrders.map((order) => (
                  <tr key={order.id} className="border-b border-gray-200 hover:bg-gray-50 transition">
                    <td className="px-6 py-4 text-sm text-gray-800 font-medium">{order.id}</td>
                    <td className="px-6 py-4 text-sm text-gray-800">{order.customer_id}</td>
                    <td className="px-6 py-4 text-sm text-gray-800">{order.product_name}</td>
                    <td className="px-6 py-4 text-sm text-gray-800 text-center">{order.quantity}</td>
                    <td className="px-6 py-4 text-sm text-gray-800 font-medium">
                      ${parseFloat(order.price).toFixed(2)}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${getStatusColor(order.status)}`}>
                        {getStatusLabel(order.status)}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-800">
                      {new Date(order.created_at).toLocaleDateString('es-ES')}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Controles de paginación */}
          <div className="flex items-center justify-between bg-gray-50 p-4 rounded-lg border border-gray-200">
            {/* Botón Anterior */}
            <button
              onClick={goToPreviousPage}
              disabled={currentPage === 1}
              className="bg-blue-500 hover:bg-blue-600 disabled:bg-gray-300 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
            >
              ← Anterior
            </button>

            {/* Información de página */}
            <div className="text-center text-gray-700 font-semibold">
              Página <span className="text-blue-600">{currentPage}</span> de{' '}
              <span className="text-blue-600">{totalPages}</span>
              <br />
              <span className="text-sm text-gray-600">
                Mostrando {startIndex + 1} a {Math.min(endIndex, totalOrders)} de {totalOrders} órdenes
              </span>
            </div>

            {/* Botón Siguiente */}
            <button
              onClick={goToNextPage}
              disabled={currentPage === totalPages}
              className="bg-blue-500 hover:bg-blue-600 disabled:bg-gray-300 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
            >
              Siguiente →
            </button>
          </div>
        </>
      )}
    </div>
  );
}
