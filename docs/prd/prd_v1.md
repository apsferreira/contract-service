# PRD — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Status:** Aprovação pendente | **Owner:** Antonio Ferreira

---

## Síntese Dialógica

**PM:** Antonio, o contract-service é o P0 que ninguém quer admitir. Sem ele, cada produto que o IIT lança está tecnicamente em violação do CDC e exposto a litígios no juizado especial. O primeiro processo custa mais do que o desenvolvimento inteiro.

**Tech Lead:** A questão real é timing. Criar o serviço antes do Brio v1.0 atrasa o lançamento em ~1,5 semana. A decisão que recomendo: embutir no Brio com interface bem definida agora, migrar para serviço dedicado antes do segundo produto. O custo de migração cai 80% se definirmos a interface correta hoje.

**Backend:** O schema é o mesmo nos dois cenários — não há retrabalho no banco. O que muda é só onde o código roda. Com a interface `ContractService`, trocar de local para HTTP client é uma linha de injeção de dependência.

**QA:** Os testes P0 têm que passar antes do go-live, sem exceção. Especialmente o hash chain e o REVOKE no banco. Esse é o nosso argumento jurídico em caso de litígio — se o audit log não for demonstravelmente imutável, perdemos.

**Finance:** ROI da pergunta errada. Não é "quanto custa desenvolver?" — é "quanto custa NÃO ter?". Resposta: o primeiro litígio já cobre o desenvolvimento. E bloqueamos todos os produtos sem isso.

**Antonio decide:** ✅ Opção B com interface definida. Brio v1.0 com contrato embarcado, serviço dedicado no v1.5 antes do jiu-jitsu-academy.

---

## 1. Visão e Contexto

O **contract-service** é o componente responsável pela geração, apresentação, aceite e armazenamento de contratos digitais para todos os produtos do Instituto Itinerante de Tecnologia.

**Por que existe:**
- Todos os produtos IIT que cobram assinatura precisam de contrato válido (lei + CDC)
- Cada produto tem cláusulas diferentes — um serviço centralizado evita triplicar a lógica
- O aceite eletrônico simples (clique "Li e aceito") é válido pela Lei 14.063/2020 **desde que haja audit log robusto e imutável**

**Prioridade:** **P0** — sem contrato, o produto não pode ser lançado legalmente.

---

## 2. Produtos e Contratos

| Produto | Template | Cláusulas específicas |
|---------|---------|----------------------|
| Brio | `brio_v1` | Serviço digital, acesso, cancelamento |
| Jiu-Jitsu Academy | `jiu_jitsu_v1` | Risco físico, cláusula de imagem, planos |
| Food Marketplace | `food_marketplace_v1` | Plataforma intermediária, responsabilidade |
| Restaurant QR | `restaurant_qr_v1` | Licença SaaS, dados do cardápio |

---

## 3. Requisitos Funcionais

### RF-CTR-01: Geração de Contrato

**User Story:** Como sistema (checkout-service), quero gerar um contrato para um usuário em um produto específico, para que ele possa lê-lo e aceitar antes de pagar.

**Fluxo:**
1. checkout-service chama `POST /api/v1/contracts` com `product_type`, `user_id`, `variables`
2. contract-service carrega template ativo para o `product_type`
3. Renderiza HTML substituindo variáveis (nome, plano, preço, etc.)
4. Calcula `content_hash = SHA-256(rendered_html)`
5. Cria registro em `contracts` com `status=pending`, `expires_at = now + 1h`
6. Retorna `{ contract_id, content_html }` para exibição no frontend

**Critérios de aceite:**
- [ ] Contrato gerado com variáveis corretas
- [ ] `expires_at` = `created_at + 60 minutos`
- [ ] Template inativo → 404 "no_active_template"
- [ ] `product_type` inválido → 400

---

### RF-CTR-02: Aceite com Registro de Auditoria

**User Story:** Como usuário, quero clicar "Li e aceito" para confirmar o contrato e prosseguir com a contratação.

**Fluxo:**
1. Usuário clica "Li e aceito" no frontend
2. Frontend chama `POST /api/v1/contracts/:id/accept` com JWT
3. contract-service valida: usuário correto, contrato não expirado, não já aceito
4. Registra em `contract_signatures`:
   - `user_id`, `ip_address`, `user_agent`, `session_token_hash`
   - `content_hash` (SHA-256 do contrato exibido)
   - `prev_hash` (hash do registro anterior — hash chain)
   - `record_hash` (SHA-256 deste registro completo)
5. Atualiza `contracts.status = "accepted"`
6. Dispara geração de PDF em background
7. Retorna `{ signature_id, accepted_at, pdf_url_when_ready }`

**Critérios de aceite:**
- [ ] Todos os campos do audit log preenchidos
- [ ] Hash chain correto (prev_hash = record_hash do anterior)
- [ ] Contrato expirado → 410
- [ ] Usuário errado → 403
- [ ] Double-accept → 409
- [ ] Aceite anônimo → 401

---

### RF-CTR-03: Geração e Armazenamento de PDF

**User Story:** Como usuário, quero receber uma cópia PDF do contrato aceito para guardar.

**Fluxo:**
1. Após aceite, job background gera PDF via `fpdf`
2. PDF inclui: conteúdo do contrato, dados do aceite, IP, timestamp, SHA-256
3. Upload para MinIO: `contracts/{year}/{month}/{contract_id}/contract.pdf`
4. Atualiza `contracts.pdf_path` e `pdf_generated_at`
5. Download via presigned URL (expira em 1h) — endpoint autenticado

**Critérios de aceite:**
- [ ] PDF gerado após aceite (< 30s em condições normais)
- [ ] PDF contém nome, IP, timestamp, hash
- [ ] Download requer autenticação
- [ ] MinIO offline → aceite não falha (PDF gerado depois)

---

### RF-CTR-04: Versionamento de Templates

**User Story:** Como admin IIT, quero atualizar o contrato de um produto sem afetar aceites anteriores.

**Regras:**
- Apenas 1 template ativo por `product_type`
- Versão semver: `major.minor.patch`
- Versão `major` → `requires_re_acceptance = true` (usuários existentes precisam re-aceitar)
- Contratos já aceitos sempre referenciam a versão com que foram assinados

**Critérios de aceite:**
- [ ] Ativar novo template → contratos novos usam versão nova
- [ ] Contratos antigos continuam referenciando versão antiga
- [ ] Versão major ativa → sistema pede re-aceite para usuários existentes

---

### RF-CTR-05: Verificação de Integridade do Audit Log

**User Story:** Como admin IIT, quero verificar que o audit log de assinaturas não foi adulterado.

**Endpoint:** `GET /api/v1/admin/signatures/verify/:signature_id`

**Resposta:**
```json
{
  "valid": true,
  "chain_valid": true,
  "content_hash_valid": true,
  "checks": {
    "record_hash": "ok",
    "prev_hash": "ok",
    "content_matches_contract": "ok"
  }
}
```

**Critérios de aceite:**
- [ ] Registro íntegro → `valid: true`
- [ ] Registro adulterado (qualquer campo) → `valid: false` com `reason`
- [ ] Job de verificação periódica (cron diário) alerta se qualquer hash inválido

---

## 4. Requisitos Não-Funcionais

| Métrica | Target |
|---------|--------|
| POST /contracts (geração) | < 200ms P95 |
| POST /contracts/:id/accept | < 500ms P95 (inclui DB + hash) |
| Geração de PDF | < 30s P95 (background) |
| Download de PDF (presigned URL) | < 100ms P95 |
| Disponibilidade | 99,9% (P0 — sem contrato, sem checkout) |
| Retenção de contratos | 10 anos (prazo prescricional) |
| Audit log | Imutável por design (REVOKE + hash chain) |

---

## 5. Arquitetura

**Stack:** Go 1.23 + Fiber v2 | PostgreSQL (`contracts_db`) | MinIO (`contracts` bucket)
**Porta:** :3014
**Auth:** JWT via auth-service

**MVP (Brio v1.0):** Embarcado em `internal/contracts/` com interface `ContractService`
**v1.5:** Serviço dedicado, mesma interface via HTTP client

### Schema Central

```
contract_templates  → templates versionados por produto
contracts           → instâncias geradas por usuário/checkout
contract_signatures → audit log imutável (REVOKE + hash chain)
```

### Dependências

```
contract-service
  ← auth-service        : validação JWT
  ← checkout-service    : POST /contracts (gera); POST /accept (aceita)
  → MinIO               : armazena PDFs
  → PostgreSQL          : persiste tudo
```

---

## 6. MVP — Escopo

### Entra no MVP (Brio v1.0 embarcado)

- [x] Template HTML para Brio v1.0
- [x] Geração de contrato com variáveis substituídas
- [x] Endpoint de aceite com audit log completo
- [x] Hash chain no audit log
- [x] REVOKE UPDATE/DELETE em `contract_signatures`
- [x] Geração de PDF básico (fpdf)
- [x] Upload para MinIO
- [x] Integração hard com checkout-service (sem signature_id → sem checkout)
- [x] Testes P0 (suites 1, 2, 3 da analysis_qa.md)

### Fora do MVP

- ✗ Contrato dedicado para jiu-jitsu-academy (usa embarcado do Brio como base)
- ✗ SMS OTP no aceite → v1.5
- ✗ Endpoint de verificação de integridade (admin) → v1.5
- ✗ Re-aceite forçado para versões major → v1.5
- ✗ Âncora blockchain → v2.0

---

## 7. Roadmap

### v1.0 — Embarcado Brio (Q2 2026, 1,5 semana)
Template Brio · Geração + aceite · Audit log imutável · PDF básico · MinIO · Testes P0

### v1.5 — Serviço Dedicado (Q3 2026, 1,5 semana)
Scaffold contract-service · Migração dados · Templates jiu-jitsu + food + restaurant-qr · SMS OTP · Verificação de integridade · Re-aceite forçado

### v2.0 — Enterprise (Q4 2026)
DocuSign para B2B · Âncora blockchain · Download em lote · Painel de contratos para tenants

---

## 8. Riscos

| Risco | Prob. | Impacto | Mitigação |
|-------|-------|---------|-----------|
| MinIO offline no aceite | Baixa | Alto | Aceite não falha; PDF gerado em retry |
| Hash chain corrompido por bug | Baixa | Crítico | Testes de integridade em CI + cron diário |
| Usuário não lê o contrato | Alta | Baixo (legal) | "Li e aceito" + scroll obrigatório = proteção suficiente |
| Migração Brio → serviço cria downtime | Baixa | Alto | Feature flag + 48h de transição gradual |
| Template desatualizado em produção | Média | Alto | Pipeline de aprovação de versão (admin IIT) |

---

## 9. Checklist de Go-Live (MVP)

- [ ] Testes P0 (suites 1–3) passando 100%
- [ ] REVOKE verificado no banco (connection como app_user)
- [ ] Hash chain testado com 10+ registros consecutivos
- [ ] PDF gerado para o template Brio v1.0
- [ ] checkout-service rejeita checkout sem signature_id
- [ ] MinIO bucket `contracts` privado
- [ ] Logs JSON com `request_id` e `user_id`
- [ ] Aprovação explícita do Antonio

---

## 10. Próximas Ações

| # | Ação | Responsável | Prazo |
|---|------|-------------|-------|
| 1 | Definir interface `ContractService` em Go | @backend | Dia 1 |
| 2 | Migrations: contracts, templates, signatures | @backend | Dia 1–2 |
| 3 | Template HTML Brio v1.0 (revisar cláusulas) | Antonio | Dia 2 |
| 4 | Implementar `LocalContractService` (embedded) | @backend | Dia 2–4 |
| 5 | Geração de PDF com fpdf | @backend | Dia 4–5 |
| 6 | Endpoint de aceite + hash chain | @backend | Dia 5–6 |
| 7 | Integração checkout-service | @backend | Dia 6–7 |
| 8 | Testes P0 (suites 1, 2, 3) | @qa | Semana 2 |
| 9 | Revisão jurídica do template Brio | Antonio | Semana 2 |
| 10 | Aprovação Antonio → deploy | Antonio | Fim semana 2 |

