# Contract Service

Serviço de geração, apresentação e aceite de contratos digitais para todos os produtos do Instituto Itinerante de Tecnologia.

## Features

- ✅ Geração de contratos com templates versionados
- ✅ Substituição de variáveis dinâmicas (nome, plano, preço, etc.)
- ✅ Aceite com audit log imutável (hash chain SHA-256)
- ✅ REVOKE UPDATE/DELETE em `contract_signatures` (immutability by design)
- ✅ Validação de expiração (contratos expiram em 1 hora)
- ✅ JWT authentication
- ✅ OpenTelemetry + Prometheus metrics
- ✅ PostgreSQL + pgx/v5
- ✅ Framework: Fiber v2

## Stack

- **Go:** 1.24
- **Framework:** Fiber v2
- **Database:** PostgreSQL 16+
- **Auth:** JWT via auth-service
- **Telemetry:** OpenTelemetry + Prometheus

## Environment Variables

```bash
PORT=3014
DATABASE_URL=postgres://user:pass@localhost:5432/contracts_db
JWT_SECRET=your-secret-key
```

## API Endpoints

### Templates

```bash
POST   /api/v1/templates              # Create template
GET    /api/v1/templates              # List templates
GET    /api/v1/templates/:id          # Get template
PUT    /api/v1/templates/:id          # Update template
POST   /api/v1/templates/:id/activate # Activate template (deactivates others)
```

### Contracts

```bash
POST   /api/v1/contracts              # Generate contract
GET    /api/v1/contracts/:id          # Get contract
POST   /api/v1/contracts/:id/accept   # Accept contract (requires JWT)
GET    /api/v1/contracts              # List user contracts (requires JWT)
```

## Usage

### 1. Create a Template

```bash
curl -X POST http://localhost:3014/api/v1/templates \
  -H "Content-Type: application/json" \
  -d '{
    "product_type": "brio",
    "version": "1.0",
    "content_html": "<h1>Contrato de Serviço - {{product_name}}</h1><p>Cliente: {{user_name}}</p><p>Plano: {{plan_name}} - R$ {{price}}/mês</p>",
    "requires_re_acceptance": false
  }'
```

### 2. Activate Template

```bash
curl -X POST http://localhost:3014/api/v1/templates/{template_id}/activate
```

### 3. Generate Contract

```bash
curl -X POST http://localhost:3014/api/v1/contracts \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "product_type": "brio",
    "variables": {
      "product_name": "Brio - Agente de Atendimento AI",
      "user_name": "João Silva",
      "plan_name": "Pro",
      "price": "299"
    }
  }'
```

Response:
```json
{
  "contract_id": "...",
  "content_html": "<h1>Contrato de Serviço - Brio</h1>...",
  "expires_at": "2026-03-08T11:00:00Z"
}
```

### 4. Accept Contract

```bash
curl -X POST http://localhost:3014/api/v1/contracts/{contract_id}/accept \
  -H "Authorization: Bearer {jwt_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "ip_address": "192.168.1.100",
    "user_agent": "Mozilla/5.0...",
    "session_token_hash": "abc123..."
  }'
```

Response:
```json
{
  "signature_id": "...",
  "accepted_at": "2026-03-08T10:30:00Z",
  "pdf_url": null
}
```

## Database Schema

### contract_templates
- Templates versionados por `product_type`
- Apenas 1 template ativo por produto

### contracts
- Contratos gerados para usuários específicos
- Status: `pending`, `accepted`, `expired`, `revoked`
- Expiram em 1 hora se não aceitos

### contract_signatures
- Audit log **imutável** (REVOKE UPDATE/DELETE)
- Hash chain: cada registro aponta para o hash do anterior
- Campos: `content_hash`, `prev_hash`, `record_hash`

## Hash Chain Security

Cada assinatura contém:
- `content_hash`: SHA-256 do HTML renderizado do contrato
- `prev_hash`: `record_hash` da assinatura anterior (blockchain-like)
- `record_hash`: SHA-256 de todos os campos da assinatura atual

Isso garante:
1. Integridade: qualquer modificação quebra a cadeia
2. Imutabilidade: REVOKE no banco impede UPDATE/DELETE
3. Auditabilidade: pode verificar toda a cadeia desde o início

## Testing

```bash
go test ./... -v
```

Tests cover:
- ✅ Template rendering with variables
- ✅ SHA-256 hash calculation
- ✅ Hash chain integrity
- ✅ Contract expiration validation
- ✅ Authorization checks
- ✅ Double-accept prevention

## Build & Run

### Local
```bash
go run cmd/server/main.go
```

### Docker
```bash
docker build -t contract-service .
docker run -p 3014:3014 \
  -e DATABASE_URL="postgres://..." \
  -e JWT_SECRET="secret" \
  contract-service
```

### Migrations
```bash
psql $DATABASE_URL < migrations/001_create_contract_tables.sql
```

## Health Check

```bash
curl http://localhost:3014/health
# {"status":"ok","service":"contract-service"}
```

## Metrics

Prometheus metrics available at:
```
http://localhost:3014/metrics
```

## License

MIT © Instituto Itinerante de Tecnologia
