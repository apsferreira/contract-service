# Analysis Tech Lead — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Autor:** @techlead / IIT

---

## ADR-001: Contrato Embarcado no Brio v1.0 vs. Serviço Dedicado Desde o Início

**Status:** ACEITO
**Data:** 2026-03-03
**Decisores:** Antonio Ferreira (CEO), @techlead

---

### Contexto

O IIT precisa de contratos para legalizar a contratação desde o v1.0 do Brio. A questão é: devemos criar o contract-service como microserviço desde o início, ou embutir a lógica de contrato diretamente no Brio e migrar depois?

### Opções Avaliadas

#### Opção A: Contract-service dedicado desde o v1.0

**Prós:**
- Clean desde o início — sem débito técnico
- Outros produtos já nascem integrados (jiu-jitsu-academy, food-marketplace)
- Versionamento e audit log centralizados desde o dia 1
- Time de backend não precisa reimplementar a mesma lógica em cada produto

**Contras:**
- Mais trabalho antes do v1.0 do Brio
- Outro serviço para subir, monitorar, manter
- Overhead de chamada HTTP síncrona no checkout

**Estimativa:** +1,5 semanas antes do Brio v1.0

---

#### Opção B: Embarcado no Brio v1.0, migrar no v1.5

**Prós:**
- Brio v1.0 sai mais rápido
- Menos complexidade inicial (sem HTTP entre serviços)
- Prova de conceito — valida o modelo de contrato antes de generalizar

**Contras:**
- Código de contrato no Brio → reescrever 100% na migração
- Migrações de dados complexas: contracts do Brio DB → contracts_db
- Risco de inconsistência durante a migração
- jiu-jitsu-academy (previsto logo depois) precisará da mesma coisa — duplicação inevitável

**Estimativa de migração no v1.5:** +1 semana (esconder débito)

---

### Decisão: OPÇÃO B com Ressalva Estratégica

**Decisão:** Embutir no Brio v1.0, **mas com interface bem definida desde o início**.

**Ressalva crítica:** O código embarcado no Brio deve ser encapsulado num pacote `internal/contracts/` com interface idêntica à que o futuro serviço vai expor. Isso minimiza o custo de migração.

```go
// Brio v1.0 — interface definida agora, implementação local
type ContractService interface {
    GenerateContract(ctx context.Context, req GenerateRequest) (*Contract, error)
    PresentContract(ctx context.Context, contractID uuid.UUID) error
    AcceptContract(ctx context.Context, req AcceptRequest) (*Signature, error)
    GetUserContracts(ctx context.Context, userID uuid.UUID) ([]*Contract, error)
}

// v1.0: implementação local (embedded)
type LocalContractService struct { db *pgxpool.Pool; minio *minio.Client }

// v1.5: troca por HTTP client — Brio não muda uma linha de handler
type RemoteContractService struct { baseURL string; httpClient *http.Client }
```

**Por que não Opção A:** O Brio v1.0 é P0 para o IIT gerar receita. Cada semana de atraso tem custo real. A interface compartilhada mitiga 80% do custo de migração.

---

### Consequências

1. Brio v1.0 embarca contrato em `internal/contracts/`
2. Schema de dados do Brio inclui tabelas `contracts`, `contract_templates`, `contract_signatures` desde o início (mesmo schema que o futuro serviço usará)
3. No v1.5, criar contract-service, migrar dados via `pg_dump` seletivo, trocar `LocalContractService` por `RemoteContractService`
4. jiu-jitsu-academy e food-marketplace já nascem integrados ao contract-service dedicado

---

## Sequência de Implementação

### Fase 0 — Definição (Brio v1.0, antes do checkout)

**Semana 1:**
- [ ] Definir schema SQL definitivo (contracts, templates, signatures)
- [ ] Criar migrations no repo do Brio
- [ ] Implementar `LocalContractService` com interface
- [ ] Template HTML do contrato Brio v1.0
- [ ] Geração de PDF com fpdf
- [ ] Endpoint de aceite no Brio: `POST /internal/contracts/:id/accept`

**Semana 2:**
- [ ] Integrar ao checkout-service (hard block: sem signature_id → sem pagamento)
- [ ] Implementar audit log com hash chain
- [ ] Upload de PDF para MinIO
- [ ] Testes P0 (lista na analysis_qa.md)
- [ ] Aprovação do Antonio → release Brio v1.0

### Fase 1 — contract-service dedicado (v1.5)

**Semana 1:**
- [ ] Scaffold contract-service (Go + Fiber, mesma base do auth-service)
- [ ] Migrations (mesmo schema do Brio, sem alterações)
- [ ] Migração de dados: `pg_dump --table=contracts* brio_db | psql contracts_db`
- [ ] Implementar todos os endpoints da API

**Semana 2:**
- [ ] Trocar `LocalContractService` por `RemoteContractService` no Brio
- [ ] Testes de regressão (nenhum comportamento muda)
- [ ] jiu-jitsu-academy integra contract-service diretamente
- [ ] Deploy com feature flag (rollback em 5 minutos se necessário)

---

## Quando Migrar para Serviço Dedicado

**Trigger automático (qualquer um destes):**
1. Segundo produto (jiu-jitsu-academy) entra em desenvolvimento → migrar antes do lançamento
2. Time reporta que `internal/contracts/` está crescendo (>500 linhas) → refatorar
3. Necessidade de template diferente entre produtos → impossível sem serviço centralizado
4. Auditoria externa solicitada → serviço dedicado é mais fácil de auditar e isolar

**Meta:** migrar para serviço dedicado **antes de 3 produtos em produção**.

---

## Riscos Técnicos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Hash chain corrompido por bug | Baixa | Crítico | Testes de integridade automatizados em CI |
| PDF ilegível (encoding) | Média | Alto | Teste automatizado: gerar PDF + verificar tamanho > 0 |
| MinIO indisponível no aceite | Baixa | Alto | Aceite sem PDF → PDF gerado em background job |
| Migração de dados corrompida | Baixa | Crítico | Migrar em dry-run primeiro; manter Brio lendo do DB antigo por 48h |
| Contrato expirado (> 1h) | Alta | Médio | Frontend deve recarregar contrato se > 55min |

---

## Observabilidade

```
contract_generated_total{product_type}
contract_accepted_total{product_type}
contract_rejected_total{product_type}
contract_expired_total{product_type}
contract_pdf_generation_duration_seconds{product_type}
contract_pdf_upload_errors_total
contract_signature_chain_integrity_ok{bool}  -- verificação periódica (cron)
```

**Alerta crítico:** `contract_signature_chain_integrity_ok = false` → PagerDuty imediato.

