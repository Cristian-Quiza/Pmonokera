# Architecture Decision Log

## ADR-001: Event-Driven Microservices

**Status:** In Progress

**Context:**
- Necesidad de desacoplar customer-service y order-service
- Mantener consistencia eventual en orders_count

**Decision:**
- RabbitMQ para pub/sub de eventos
- HTTP para sincronous inter-service calls

**Trade-offs:**
- ✓ Mejor escalabilidad
- ✗ Mayor complejidad operacional
- ✗ DEBUG más difícil

**pending:**
- [ ] Implementar dead letter queue para órdenes fallidas
- [ ] Agregar idempotency keys en publicación de eventos
- [ ] Metricas de latencia en Bunny/Faraday
- [ ] Datadog APM instrumentation

---

## ADR-002: API Authentication Strategy

**Status:** Not Started

**Context:**
- Servicios actualmente sin autenticación
- Necesario para producción

**Options:**
1. JWT con RS256
2. OAuth2 + API keys
3. mTLS entre servicios

**Pending decision:** Evaluar con el equipo

---

## Performance Issues

- [ ] N+1 queries en orders index (add eager loading)
- [ ] Customer service DNS lookup cada request (pooling)
- [ ] Seeds generan únicas de 10 clientes (expandir a 1000+)
- [ ] Sin índices en customer_id de orders

---

## Test Coverage

- [ ] Integration tests con Webmock para Faraday
- [ ] Bunny event publishing tests
- [ ] Load testing para propagación de eventos
- [ ] Contract testing entre ser vicios (PACT)
