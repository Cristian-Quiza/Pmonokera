'use client';

import React from 'react';

interface ClientSelectorProps {
  value: string;
  onChange: (clientId: string) => void;
  disabled?: boolean;
}

/**
 * ClientSelector Component
 * 
 * Propósito: Componente reutilizable para seleccionar un cliente
 * 
 * Props:
 * - value: ID del cliente seleccionado (string)
 * - onChange: Callback cuando cambia la selección
 * - disabled: Si está deshabilitado (durante loading)
 * 
 * Nota: En desarrollo mostramos IDs 1-5 hardcodeados
 * En producción, estos deberían venir del backend (GET /customers)
 */
export default function ClientSelector({
  value,
  onChange,
  disabled = false,
}: ClientSelectorProps) {
  return (
    <div>
      <label
        htmlFor="customer_id"
        className="block text-sm font-medium text-gray-700 mb-2"
      >
        Cliente
      </label>
      <select
        id="customer_id"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent appearance-none bg-white disabled:bg-gray-100 disabled:cursor-not-allowed cursor-pointer"
        style={{ backgroundImage: 'none' }}
        required
      >
        <option value="">-- Selecciona un cliente --</option>
        <option value="1">👤 Cliente #1 - Inetum Corp</option>
        <option value="2">👤 Cliente #2 - TechHub</option>
        <option value="3">👤 Cliente #3 - Digital Solutions</option>
        <option value="4">👤 Cliente #4 - CloudFirst</option>
        <option value="5">👤 Cliente #5 - NextGen Labs</option>
      </select>
    </div>
  );
}
