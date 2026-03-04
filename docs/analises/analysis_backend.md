# Analysis Backend — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Autor:** @backend / IIT

---

## 1. Schema de Banco de Dados

### Tabelas principais

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Templates de contratos por produto e versão
CREATE TABLE contract_templates (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_type          VARCHAR(50) NOT NULL,
    -- valores: 'brio', 'jiu_jitsu_academy', 'food_marketplace', 'restaurant_qr', 'generic'
    version               VARCHAR(20) NOT NULL,        -- semver: "1.0.0"
    version_major         INTEGER NOT NULL,
    version_minor         INTEGER NOT NULL,
    version_patch         INTEGER NOT NULL,
    content_html          TEXT NOT NULL,               -- template com variáveis {{name}}, {{plan}}, etc.
    content_hash          CHAR(64) NOT NULL,            -- SHA-256 de content_html
    is_active             BOOLEAN NOT NULL DEFAULT false,
    requires_re_acceptance BOOLEAN NOT NULL DEFAULT false,
    change_summary        TEXT,
    effective_date        TIMESTAMPTZ NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by            UUID NOT NULL,               -- admin IIT
    UNIQUE (product_type, version)
);

CREATE INDEX idx_templates_product_active
    ON contract_templates(product_type, is_active)
    WHERE is_active = true;

-- Contratos gerados por instância (por checkout/matrícula)
CREATE TABLE contracts (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id           UUID NOT NULL REFERENCES contract_templates(id),
    tenant_id             UUID,                        -- null para produtos próprios IIT
    user_id               UUID NOT NULL,
    product_type          VARCHAR(50) NOT NULL,
    product_id            UUID,                        -- item/plano específico
    checkout_id           UUID,                        -- referência ao checkout-service
    status                VARCHAR(20) NOT NULL DEFAULT 'pending',
    -- pending → presented → accepted | rejected | expired
    content_rendered      TEXT NOT NULL,               -- HTML com variáveis substituídas
    content_hash          CHAR(64) NOT NULL,            -- SHA-256 do content_rendered
    pdf_path              TEXT,                        -- MinIO path após aceite
    pdf_generated_at      TIMESTAMPTZ,
    presented_at          TIMESTAMPTZ,                 -- quando foi exibido ao usuário
    expires_at            TIMESTAMPTZ,                 -- validade do contrato apresentado (1h)
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contracts_user ON contracts(user_id, created_at DESC);
CREATE INDEX idx_contracts_checkout ON contracts(checkout_id) WHERE checkout_id IS NOT NULL;
CREATE INDEX idx_contracts_tenant ON contracts(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_contracts_status ON contracts(status) WHERE status = 'pending';

-- Audit log de assinaturas (IMUTÁVEL)
CREATE TABLE contract_signatures (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id           UUID NOT NULL REFERENCES contracts(id),
    template_id           UUID NOT NULL REFERENCES contract_templates(id),
    user_id               UUID NOT NULL,
    accepted_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address            INET NOT NULL,
    user_agent            TEXT NOT NULL,
    session_token_hash    CHAR(64) NOT NULL,
    content_hash          CHAR(64) NOT NULL,
    pdf_path              TEXT,
    prev_hash             CHAR(64),                    -- hash chain
    record_hash           CHAR(64) NOT NULL            -- SHA-256 deste registro
    -- SEM updated_at, SEM deleted_at
);

-- Imutabilidade garantida por REVOKE
REVOKE UPDATE, DELETE ON contract_signatures FROM app_user;

CREATE INDEX idx_signatures_contract ON contract_signatures(contract_id);
CREATE INDEX idx_signatures_user ON contract_signatures(user_id, accepted_at DESC);
```

---

## 2. Geração de PDF

### Biblioteca Go recomendada

**`github.com/go-pdf/fpdf`** — pura Go, sem CGO, madura.

Alternativa: **`github.com/chromedp/chromedp`** (HTML → PDF via headless Chrome) — mais fiel ao template visual, mas requer Chrome no container (imagem maior ~300MB).

**Recomendação MVP:** `fpdf` para simplicidade e imagem Docker leve.
**Recomendação v1.5:** `chromedp` para contratos com design visual (logos, tabelas complexas).

### Fluxo de geração

```
1. Carregar template ativo para product_type
2. Substituir variáveis: {{user_name}}, {{cpf}}, {{plan_name}}, {{price}}, {{date}}, {{ip}}, etc.
3. Calcular SHA-256 do conteúdo renderizado
4. Gerar PDF (fpdf):
   - Cabeçalho: logo IIT + product_type
   - Corpo: conteúdo do contrato
   - Rodapé: "Aceito eletronicamente em [timestamp] por [email] — IP [ip]"
   - Marca d'água: "CÓPIA DIGITAL — SHA-256: [hash]"
5. Upload MinIO → contracts/{year}/{month}/{contract_id}/contract.pdf
6. Atualizar contracts.pdf_path e contracts.pdf_generated_at
```

### Template HTML com variáveis

```html
<h1>Contrato de Prestação de Serviços — {{product_name}}</h1>
<p><strong>Contratante:</strong> {{user_name}}, CPF {{user_cpf}}</p>
<p><strong>Plano:</strong> {{plan_name}} — R$ {{price_formatted}}/{{billing_frequency}}</p>
<!-- ... cláusulas ... -->
<hr/>
<p>Aceito eletronicamente em <strong>{{accepted_at}}</strong><br/>
IP: {{ip_address}} | Dispositivo: {{device_info}}</p>
```

---

## 3. Armazenamento MinIO

### Estrutura de buckets

```
Bucket: contracts
  contracts/{year}/{month}/{contract_id}/contract.pdf
  contracts/{year}/{month}/{contract_id}/receipt.pdf   (comprovante simplificado — v1.5)

Política de acesso: PRIVATE
URLs geradas com presigned URL (expiração: 1 hora para download pontual)
```

### Retenção

- **Regra:** manter por mínimo 10 anos (prazo prescricional civil)
- **Lifecycle MinIO:** `mc ilm add contracts --expiry-days 3650`
- **Backup:** replicar para S3-compatible externo (v1.5) — risco de perda de prova jurídica

### Tamanho estimado

- PDF médio: ~200KB por contrato
- 1.000 contratos/mês × 200KB = 200MB/mês
- 10 anos = ~24GB — custo praticamente zero no homelab

---

## 4. Endpoints da API

```
# Gerenciamento de templates (admin IIT)
GET    /api/v1/contract-templates                         → listar templates
POST   /api/v1/contract-templates                         → criar template
GET    /api/v1/contract-templates/:id                     → detalhe
PATCH  /api/v1/contract-templates/:id/activate            → ativar versão
GET    /api/v1/contract-templates/active/:product_type    → template ativo por produto

# Contratos (integração checkout / matrícula)
POST   /api/v1/contracts                                  → gerar contrato (checkout-service)
GET    /api/v1/contracts/:id                              → detalhe do contrato
GET    /api/v1/contracts/:id/download                     → presigned URL do PDF

# Aceite (chamado pelo frontend no checkout)
POST   /api/v1/contracts/:id/accept                       → registrar aceite + gerar PDF
POST   /api/v1/contracts/:id/reject                       → registrar rejeição

# Histórico do usuário
GET    /api/v1/users/:user_id/contracts                   → contratos do usuário (paginado)
GET    /api/v1/users/:user_id/contracts/:id/download      → download com auth

# Audit (admin)
GET    /api/v1/admin/signatures/:contract_id              → audit log de uma assinatura
GET    /api/v1/admin/signatures/verify/:signature_id      → verificar integridade do hash chain
```

### Payload do endpoint de aceite

```json
// POST /api/v1/contracts/:id/accept
// Headers: Authorization: Bearer <jwt>
// Body: {} (vazio — dados vêm do JWT + request context)

// Response 200:
{
  "signature_id": "uuid",
  "contract_id": "uuid",
  "accepted_at": "2026-03-03T08:30:00Z",
  "pdf_url": "https://minio.../presigned-url",
  "content_hash": "sha256hex"
}

// Erros:
// 404: contrato não encontrado
// 409: contrato já aceito
// 410: contrato expirado (passou 1h desde presented_at)
// 401: usuário não autenticado
// 403: contrato pertence a outro usuário
```

---

## 5. Integração com checkout-service

### Fluxo de integração

```
checkout-service                     contract-service
      │                                     │
      │── POST /api/v1/contracts ──────────►│ (cria contrato com status=pending)
      │◄─ { contract_id, content_html } ────│
      │                                     │
      │ (apresenta contrato ao usuário)      │
      │── PATCH /contracts/:id/presented ──►│ (marca presented_at)
      │                                     │
      │ (usuário clica "Li e aceito")        │
      │── POST /contracts/:id/accept ───────►│ (registra aceite, gera PDF)
      │◄─ { signature_id, pdf_url } ─────────│
      │                                     │
      │ (prossegue com pagamento)            │
```

### Validação no checkout

O checkout-service **NÃO deve prosseguir** para pagamento sem `signature_id` válido retornado pelo contract-service. Isso é uma hard dependency — P0.

### Payload de criação de contrato

```json
// POST /api/v1/contracts (chamado pelo checkout-service com X-Service-Token)
{
  "product_type": "jiu_jitsu_academy",
  "product_id": "uuid-do-plano",
  "user_id": "uuid-do-usuario",
  "tenant_id": "uuid-da-academia",
  "checkout_id": "uuid-do-checkout",
  "variables": {
    "user_name": "João Silva",
    "user_cpf": "123.456.789-00",
    "plan_name": "Plano Mensal",
    "price_formatted": "199,00",
    "billing_frequency": "mês"
  }
}
```

---

## 6. Porta e Variáveis de Ambiente

```env
PORT=3014
ENV=development
SERVICE_NAME=contract-service

DATABASE_URL=postgres://postgres:postgres@shared-postgres:5432/contracts_db?sslmode=disable

MINIO_ENDPOINT=shared-minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=contracts
MINIO_USE_SSL=false

AUTH_SERVICE_URL=http://auth-service:3010
JWT_SECRET=...

CONTRACT_EXPIRY_MINUTES=60
PDF_GENERATOR=fpdf
SERVICE_TOKEN=...  # para chamadas M2M do checkout-service
```

**Porta recomendada: :3014** (auth=3010, customer=3011, notification=3012, catalog=3013, contract=3014)

