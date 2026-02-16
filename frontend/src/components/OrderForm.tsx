'use client';

import { useState } from 'react';
import toast from 'react-hot-toast';

// Interface del formulario - con todos los campos requeridos por el backend
interface OrderFormData {
  customer_id: string;
  product_name: string;
  quantity: string;
  price: string;
  status: string;
}

export default function OrderForm({ onOrderCreated }: { onOrderCreated?: () => void }) {
  const [loading, setLoading] = useState(false);
  // Estado del formulario - estados para cada campo
  const [formData, setFormData] = useState<OrderFormData>({
    customer_id: '',
    product_name: '',
    quantity: '',
    price: '',
    status: 'pending',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  // Función que valida específicamente cada campo del formulario
  const validateForm = (): string[] => {
    const errors: string[] = [];
    
    if (!formData.customer_id) errors.push('Cliente es requerido');
    if (!formData.product_name) errors.push('Nombre del producto es requerido');
    if (!formData.quantity || parseInt(formData.quantity) <= 0) errors.push('Cantidad debe ser > 0');
    if (!formData.price || parseFloat(formData.price) <= 0) errors.push('Precio debe ser > 0');
    
    return errors;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validar todos los campos
    const errors = validateForm();
    if (errors.length > 0) {
      toast.error(errors.join(', '));
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('http://localhost:3002/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          order: {
            customer_id: parseInt(formData.customer_id),
            product_name: formData.product_name,
            quantity: parseInt(formData.quantity),
            price: parseFloat(formData.price),
            status: formData.status,
          },
        }),
      });

      if (!response.ok) {
        throw new Error('Error al crear la orden');
      }

      toast.success('✅ Orden creada exitosamente');
      // Limpiar formulario después de crear exitosamente
      setFormData({ customer_id: '', product_name: '', quantity: '', price: '', status: 'pending' });
      onOrderCreated?.();
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md mb-8">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Crear Nueva Orden</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        {/* Cliente */}
        <div>
          <label htmlFor="customer_id" className="block text-sm font-medium text-gray-700 mb-2">
            Cliente
          </label>
          <input
            type="number"
            id="customer_id"
            name="customer_id"
            value={formData.customer_id}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
            placeholder="Ej: 1, 2, 3, 4 o 5"
            min="1"
            max="5"
          />
        </div>

        {/* Producto */}
        <div>
          <label htmlFor="product_name" className="block text-sm font-medium text-gray-700 mb-2">
            Nombre del Producto
          </label>
          <input
            type="text"
            id="product_name"
            name="product_name"
            value={formData.product_name}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
            placeholder="Ej: Café, Teclado, iPhone..."
          />
        </div>

        {/* Cantidad */}
        <div>
          <label htmlFor="quantity" className="block text-sm font-medium text-gray-700 mb-2">
            Cantidad
          </label>
          <input
            type="number"
            id="quantity"
            name="quantity"
            value={formData.quantity}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
            placeholder="Ej: 1, 2, 3..."
            min="1"
          />
        </div>

        {/* Precio */}
        <div>
          <label htmlFor="price" className="block text-sm font-medium text-gray-700 mb-2">
            Precio Unitario
          </label>
          <input
            type="number"
            id="price"
            name="price"
            value={formData.price}
            onChange={handleChange}
            disabled={loading}
            step="0.01"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
            placeholder="0.00"
            min="0"
          />
        </div>

        {/* Estado */}
        <div className="md:col-span-2">
          <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-2">
            Estado
          </label>
          <select
            id="status"
            name="status"
            value={formData.status}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          >
            <option value="pending">⏳ Pendiente</option>
            <option value="confirmed">✅ Confirmada</option>
            <option value="shipped">🚚 Enviada</option>
            <option value="delivered">📦 Entregada</option>
            <option value="cancelled">❌ Cancelada</option>
          </select>
        </div>
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-gray-400 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
      >
        {loading ? '⏳ Creando orden...' : '➕ Crear Orden'}
      </button>
    </form>
  );
}
