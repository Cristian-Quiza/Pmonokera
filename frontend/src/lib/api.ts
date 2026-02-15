/**
 * Cliente API para order-service (localhost:3000) y customer-service (localhost:3001).
 */

const ORDER_API = process.env.NEXT_PUBLIC_ORDER_API_URL || "http://localhost:3000";
const CUSTOMER_API = process.env.NEXT_PUBLIC_CUSTOMER_API_URL || "http://localhost:3001";

export interface Order {
  id: number;
  customer_id: number;
  product_name: string;
  quantity: number;
  price: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface Customer {
  customer_name: string;
  address: string;
  orders_count: number;
}

export interface OrderCreateInput {
  customer_id: number;
  product_name: string;
  quantity: number;
  price: number;
  status: string;
}

export async function fetchOrders(customerId: number, page = 1, limit = 20): Promise<Order[]> {
  const res = await fetch(`${ORDER_API}/orders?customer_id=${customerId}`, { cache: "no-store" });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  const all: Order[] = await res.json();
  const start = (page - 1) * limit;
  return all.slice(start, start + limit);
}

export async function fetchOrdersCount(customerId: number): Promise<number> {
  const res = await fetch(`${ORDER_API}/orders?customer_id=${customerId}`, { cache: "no-store" });
  if (!res.ok) return 0;
  const all: Order[] = await res.json();
  return all.length;
}

export async function createOrder(data: OrderCreateInput): Promise<Order> {
  const res = await fetch(`${ORDER_API}/orders`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ order: data }),
  });
  const json = await res.json();
  if (!res.ok) throw new Error(json.error || json.errors?.join(", ") || `Error ${res.status}`);
  return json;
}

export async function fetchCustomer(id: number): Promise<Customer> {
  const res = await fetch(`${CUSTOMER_API}/customers/${id}`, { cache: "no-store" });
  if (!res.ok) throw new Error(`Cliente no encontrado`);
  return res.json();
}

export const CUSTOMER_IDS = [1, 2, 3, 4, 5] as const;
