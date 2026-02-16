# Development Notes

## Known Issues

### Critical
- [ ] Order validation loop when customer_exists? fails - hardcoded retry needed
- [ ] RabbitMQ connection pool exhausted under load (test with 100+ orders/sec)
- [ ] Seeds vuelven a crear clientes en cada bundle install (arreglar con proper idempotency)

### Medium
- [ ] Timestamp synchronization between services (different timezones)
- [ ] Missing order status validations (can set any string as status)
- [ ] Faraday timeout set to 5s pero Puma default max_threads = 2
- [ ] Frontend OrdersTable doesn't refresh on event updates (WebSocket needed)

### Low
- [ ] Faker generates duplicate addresses occasionally
- [ ] Log levels not configured per environment
- [ ] README.md tiene ejemplos CURL sin token Bearer

---

## Performance Opportunities

- [x] Moved CUSTOMER_SERVICE_URL to ENV
- [ ] Implement Redis caching for customer lookups (cache hit ratio target: 80%)
- [ ] Add database indices on (customer_id, created_at) for orders
- [ ] Connection pooling for Faraday (PgBouncer style)

---

## Next Sprint Tasks

- [ ] Agregar authentication (JWT o API keys)
- [ ] Implementar circuit breaker pattern (Resilience4j equivalent)
- [ ] Contract testing con PACT
- [ ] Datadog/NewRelic integration
- [ ] WebSocket para realtime order updates
- [ ] Kubernetes deployment manifests

---

## Testing Checklist (Before Deploy)

- [ ] RSpec suite coverage > 85%
  - Tests with Webmock for HTTP calls
  - Bunny mock for event publishing
  - FactoryBot for test data
- [ ] Load test: 500+ concurrent users
- [ ] Chaos engineering: simulate customer-service outage
- [ ] Database backup/restore procedure validated

---

## Deployment Blockers

1. Need secrets management (Sealed Secrets o Vault)
2. Need monitoring dashboard (Prometheus + Grafana)
3. Need log aggregation (ELK stack)
4. Database migration strategy for zero-downtime rollouts

---

## Feedback from QA (Feb 15, 2026)

- Order form doesn't validate negative quantities
- Customer ID field accepts letters (should be numeric only)
- Status field should be enum (PENDING, COMPLETED, FAILED)
- Response times spike when customer-service is slow
