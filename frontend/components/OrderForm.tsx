'use client';

import { useState } from 'react';
import toast from 'react-hot-toast';
import ClientSelector from './ClientSelector';

// Interface para tipar el estado del formulario
interface FormData {
  customer_id: string;
  product_name: string;
  quantity: string;
  price: string;
  status: string;
}

interface OrderFormProps {
  onOrderCreated?: () => void; // Callback después de crear orden exitosamente
}

/**
 * Componente OrderForm
 * 
 * Propósito: Formulario para crear nuevas órdenes
 * 
 * Estados (useState):
 * - formData: datos del formulario (controlled inputs)
 * - loading: indica si se está enviando el POST (para deshabilitar botón)
 * - error: mensaje de error si algo falla
 * 
 * Funcionalidades:
 * 1. Select de clientes (1-5) usando ClientSelector
 * 2. Campos: product_name, quantity, price
 * 3. Cálculo automático: monto total = quantity * price
 * 4. Select de estado
 * 5. Loading state durante POST
 * 6. Error handling
 * 7. Refetch de órdenes después de crear
 */
export default function OrderForm({ onOrderCreated }: OrderFormProps) {
  // Estado para los datos del formulario
  const [formData, setFormData] = useState<FormData>({
    customer_id: '',
    product_name: '',
    quantity: '',
    price: '',
    status: 'pending',
  });

  // Estado para loading (durante POST)
  const [loading, setLoading] = useState(false);

  // Estado para errores
  const [error, setError] = useState<string | null>(null);

  /**
   * Calcula el monto total en tiempo real
   * Fórmula: monto total = quantity * price
   */
  const calculateTotal = () => {
    const q = parseFloat(formData.quantity) || 0;
    const p = parseFloat(formData.price) || 0;
    return (q * p).toFixed(2);
  };

  /**
   * Maneja cambios en inputs de texto y select
   * Mantiene formData actualizado mientras el usuario escribe
   */
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
    // Limpia error cuando el usuario empieza a escribir
    if (error) setError(null);
  };

  /**
   * Maneja cambio de cliente desde ClientSelector
   */
  const handleClientChange = (clientId: string) => {
    setFormData((prev) => ({
      ...prev,
      customer_id: clientId,
    }));
    if (error) setError(null);
  };

  /**
   * Valida los datos antes de enviar
   */
  const validateForm = (): boolean => {
    if (!formData.customer_id) {
      setError('⚠️ Selecciona un cliente');
      return false;
    }
    if (!formData.product_name.trim()) {
      setError('⚠️ Ingresa nombre del producto');
      return false;
    }
    if (!formData.quantity || parseFloat(formData.quantity) <= 0) {
      setError('⚠️ Cantidad debe ser mayor a 0');
      return false;
    }
    if (!formData.price || parseFloat(formData.price) <= 0) {
      setError('⚠️ Precio debe ser mayor a 0');
      return false;
    }
    return true;
  };

  /**
   * Envía el formulario al backend
   * 1. Valida datos
   * 2. Hace POST a /orders con la estructura esperada
   * 3. Maneja loading y errores
   * 4. Limpia formulario si éxito
   * 5. Refetch de órdenes (callback)
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Válida antes de enviar
    if (!validateForm()) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // POST a /orders en order-service (puerto 3002)
      const response = await fetch('http://localhost:3002/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          order: {
            customer_id: parseInt(formData.customer_id),
            product_name: formData.product_name.trim(),
            quantity: parseInt(formData.quantity),
            price: parseFloat(formData.price),
            status: formData.status,
          },
        }),
      });

      // Maneja respuestas no exitosas
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(
          errorData.error || `Error: ${response.status} ${response.statusText}`
        );
      }

      // Éxito: limpia formulario y notifica
      const createdOrder = await response.json();
      toast.success(`✅ Orden #${createdOrder.id} creada exitosamente`);

      // Limpia el formulario
      setFormData({
        customer_id: '',
        product_name: '',
        quantity: '',
        price: '',
        status: 'pending',
      });

      // Notifica al padre para refetch de órdenes
      onOrderCreated?.();
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Error desconocido';
      setError(`❌ ${errorMsg}`);
      toast.error(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  const totalAmount = calculateTotal();

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-white p-8 rounded-lg shadow-md mb-8"
    >
      <h2 className="text-3xl font-bold mb-8 text-gray-800">
        🆕 Crear Nueva Orden
      </h2>

      {/* Muestra error si lo hay */}
      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Grid de campos */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {/* Campo 1: Selector de Cliente */}
        <div>
          <ClientSelector
            value={formData.customer_id}
            onChange={handleClientChange}
            disabled={loading}
          />
        </div>

        {/* Campo 2: Nombre del Producto */}
        <div>
          <label
            htmlFor="product_name"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Producto
          </label>
          <input
            type="text"
            id="product_name"
            name="product_name"
            value={formData.product_name}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
            placeholder="Ej: Laptop, Mouse, Teclado"
            required
          />
        </div>

        {/* Campo 3: Cantidad */}
        <div>
          <label
            htmlFor="quantity"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Cantidad
          </label>
          <input
            type="number"
            id="quantity"
            name="quantity"
            value={formData.quantity}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
            placeholder="0"
            min="1"
            step="1"
            required
          />
        </div>

        {/* Campo 4: Precio Unitario */}
        <div>
          <label
            htmlFor="price"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Precio Unitario
          </label>
          <input
            type="number"
            id="price"
            name="price"
            value={formData.price}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
            placeholder="0.00"
            min="0"
            step="0.01"
            required
          />
        </div>

        {/* Campo 5: Estado */}
        <div>
          <label
            htmlFor="status"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Estado
          </label>
          <select
            id="status"
            name="status"
            value={formData.status}
            onChange={handleChange}
            disabled={loading}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent appearance-none bg-white disabled:bg-gray-100 disabled:cursor-not-allowed cursor-pointer"
            style={{ backgroundImage: 'none' }}
          >
            <option value="pending">📋 Pendiente</option>
            <option value="confirmed">✅ Confirmada</option>
            <option value="shipped">📦 Enviada</option>
            <option value="delivered">🎉 Entregada</option>
            <option value="cancelled">❌ Cancelada</option>
          </select>
        </div>
      </div>

      {/* Resumen: Monto Total Calculado */}
      <div className="mb-8 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex justify-between items-center">
          <span className="text-gray-700 font-medium">Monto Total:</span>
          <span className="text-2xl font-bold text-blue-600">
            ${totalAmount}
          </span>
        </div>
        <p className="text-xs text-gray-600 mt-2">
          💡 Se calcula automáticamente: Cantidad × Precio
        </p>
      </div>

      {/* Botón Enviar */}
      <button
        type="submit"
        disabled={loading}
        className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-gray-400 text-white font-bold py-3 px-4 rounded-lg transition duration-200 flex items-center justify-center gap-2"
      >
        {loading ? (
          <>
            <span className="animate-spin">⏳</span>
            Creando orden...
          </>
        ) : (
          <>
            ✨ Crear Orden
          </>
        )}
      </button>
    </form>
  );
}
