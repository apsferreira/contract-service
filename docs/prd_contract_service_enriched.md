# PRD — contract-service
**Versão:** 2.0-enriched | **Data:** 2026-03-03 | **Status:** Aprovado para execução
**Owner:** Antonio Ferreira (CEO/IIT) | **PM:** @pm | **Classificação:** Interno

---

## 1. Executive Summary + Veredito

O **contract-service** é o componente de infraestrutura jurídica do Instituto Itinerante de Tecnologia. Sua função: gerar, apresentar, registrar e armazenar contratos digitais com validade legal para todos os produtos IIT que cobram assinatura.

### Veredito: P0 inegociável

O contract-service não é feature — é requisito habilitador. Sem ele:

- Nenhum produto IIT pode ser lançado legalmente no mercado
- O IIT opera em violação direta do CDC (arts. 47, 49, 54) e fica exposto a litígios no Juizado Especial Cível
- Qualquer ambiguidade de cláusula beneficia o consumidor (CDC art. 47), não o IIT
- Ausência de base legal clara para coleta de dados = exposição à LGPD

**O ROI é calculado como custo de NÃO ter:** o primeiro litígio no juizado especial (R$ 2.000–10.000 + honorários) cobre integralmente o custo de desenvolvimento estimado em ~3 semanas (~R$ 8.000 custo de oportunidade de Antonio).

### Decisão arquitetural aprovada (ADR-001)

**Opção escolhida:** Embarcado no Brio v1.0, migrado para serviço dedicado no v1.5.

O código embarcado em `internal/contracts/` do Brio usa interface `ContractService` idêntica à que o serviço dedicado futuro vai expor. A troca no v1.5 é uma linha de injeção de dependência — sem reescrita de handlers, sem retrabalho de schema.

---

## 2. Papel no Ecossistema

O contract-service atua como **camada jurídica transversal** do IIT: todo produto que gera obrigação contratual com usuário final ou tenant (academia, restaurante) passa por ele.

### Posição na arquitetura

```
Usuário / Tenant
      │
      ▼
  checkout-service ──────────────► contract-service
  jiu-jitsu-academy ─────────────►   │
  food-marketplace ──────────────►   ├── PostgreSQL (contracts_db)
  restaurant-qr ─────────────────►   └── MinIO (bucket: contracts)
                                         │
                                    auth-service (validação JWT)
```

### Produtos e templates de contrato

| Produto | Template | Partes | Cláusulas específicas |
|---------|----------|--------|-----------------------|
| **Brio** | `brio_v1` | IIT + Usuário | Serviço digital, acesso, cancelamento, política de privacidade |
| **Jiu-Jitsu Academy** | `jiu_jitsu_v1` | Academia (tenant) + Aluno, mediado pelo IIT | Risco físico, cláusula de imagem, planos de matrícula, CDC art. 49 |
| **Food Marketplace** | `food_marketplace_v1` | IIT (plataforma) + Consumidor | Intermediação, responsabilidade do restaurante, cancelamento variável |
| **Restaurant QR** | `restaurant_qr_v1` | IIT (licenciante) + Restaurante (licenciado) | Licença SaaS, responsabilidade sobre dados de clientes do restaurante |

### Princípio de centralização

Um único serviço gerencia templates, geração, aceite, audit log e PDF para todos os produtos. Isso evita:
- Replicação da lógica jurídica em cada produto
- Divergências de versão de contrato entre produtos
- Audit logs fragmentados (impossível de auditar externamente)
- Multas distintas por produto em caso de não-conformidade LGPD

---

## 3. Dados e Métricas

*Driver principal: @finance — aceite digital auditável, validade jurídica comprovável, audit log imutável como ativo de defesa.*

### 3.1 Dados coletados e base legal (LGPD)

| Dado coletado | Categoria | Base legal (LGPD art. 7°) | Retenção |
|---------------|-----------|--------------------------|----------|
| Nome completo | Pessoal | V — execução de contrato | 10 anos |
| CPF | Pessoal | V — execução de contrato | 10 anos |
| E-mail | Pessoal | V — execução de contrato | 10 anos |
| IP do aceite | Identificação | V + IX — legítimo interesse | 10 anos |
| User-Agent | Técnico | IX — legítimo interesse | 10 anos |
| Timestamp do aceite (UTC ms) | Técnico | IX | 10 anos |
| Hash do JWT da sessão | Técnico | IX | 10 anos |
| SHA-256 do contrato exibido | Integridade | V | 10 anos |

**Prazo de retenção:** 10 anos — prazo prescricional civil (CC art. 205). Dados de contrato **não podem** ser apagados mesmo com solicitação de esquecimento (LGPD art. 16, I — obrigação legal prevalece).

### 3.2 Validade jurídica do aceite digital

O aceite eletrônico simples ("Li e aceito") é juridicamente defensável **desde que** o audit log capture:

```
CAMPOS OBRIGATÓRIOS (sem eles, o aceite é juridicamente frágil):
  1. user_id autenticado
  2. contract_version_id
  3. ip_address real do cliente
  4. user_agent
  5. timestamp UTC (precisão milissegundos)
  6. SHA-256 do contrato exibido (prova de qual versão foi apresentada)
  7. session_token_hash (prova de autenticação ativa no momento do aceite)
  8. hash chain (prev_hash → detecta adulteração retroativa)
  9. record_hash (SHA-256 do próprio registro)
```

Fundamento: STJ reconhece sistematicamente logs eletrônicos como prova (REsp 1.495.920/DF, AREsp 1.473.825/SP). **A imutabilidade é o diferencial** — um log alterável não tem valor probatório.

### 3.3 Modalidades de assinatura por faixa de valor

| Valor do contrato | Modalidade | Custo | Quando adotar |
|-------------------|-----------|-------|---------------|
| < R$ 100/mês | Clique simples + audit log | R$ 0 | MVP e além |
| R$ 100–500/mês | Clique + SMS OTP | R$ 0,05–0,10/SMS | v1.5 |
| > R$ 500/mês (B2C) | Clique + SMS OTP | idem | v1.5 |
| B2B (tenant) | DocuSign ou equivalente | ~R$ 150/mês para 300 docs | Quando tenant count > 20 |
| B2C geral | ❌ Certificado ICP-Brasil | R$ 150–300/cert/ano (usuário paga) | Inviável — não adotar |

### 3.4 Projeção de volume e infraestrutura

| Período | Produtos ativos | Contratos/mês | Acumulado | Storage MinIO |
|---------|----------------|--------------|-----------|---------------|
| Q2 2026 | Brio | 100 | 100 | 20 MB |
| Q3 2026 | Brio + Jiu-Jitsu | 300 | 700 | 140 MB |
| Q4 2026 | + Food Marketplace | 600 | 2.500 | 500 MB |
| Q1 2027 | + Restaurant QR | 1.000 | 5.500 | 1,1 GB |

**Custo de infraestrutura:** R$ 0 incremental até Q1 2027 (homelab existente: PostgreSQL shared-infra-01, MinIO shared-infra-01, K3s). Container contract-service: ~50 MB RAM, < 0,1 CPU.

---

## 4. Compliance Legal

*Driver principal: @legal — MP 2.200-2/2001, LGPD, Lei 14.063/2020.*

### 4.1 Hierarquia de assinaturas (Lei 14.063/2020)

| Tipo | Exige | Validade | Uso no IIT |
|------|-------|----------|-----------|
| **Simples** | Qualquer meio eletrônico de identificação | ✅ Plena para relações privadas (art. 6° § 1°) | ✅ MVP |
| **Avançada** | Chave criptográfica ligada ao signatário | ✅ Reforçada | Opcional v1.5 |
| **Qualificada** | Certificado ICP-Brasil (MP 2.200-2/2001) | ✅ Máxima | ❌ Desnecessário B2C |

**Conclusão legal:** O clique "Li e aceito" com audit log robusto é suficiente para 100% dos contratos B2C IIT no MVP e no horizonte de 18 meses.

### 4.2 Obrigações LGPD

1. **Finalidade** — Dados coletados no contrato são exclusivos para fins contratuais. Uso para marketing exige consentimento separado.
2. **Portabilidade** — Usuário pode solicitar cópia do PDF a qualquer momento via endpoint autenticado.
3. **Exclusão** — Proibida durante vigência e período prescricional (LGPD art. 16, I). Operador deve rejeitar solicitações de esquecimento que conflitem com obrigação legal.
4. **Retenção** — 10 anos (CC art. 205). Regra MinIO lifecycle: `--expiry-days 3650`.
5. **Responsabilidade de dados de terceiros** — No Restaurant QR, dados de clientes do restaurante são de responsabilidade do restaurante (tenant). Cláusula explícita no contrato `restaurant_qr_v1`.

### 4.3 CDC — Exposições mitigadas pelo contract-service

| Artigo CDC | Risco sem contrato | Mitigação |
|------------|-------------------|-----------|
| Art. 47 | Toda ambiguidade beneficia o consumidor | Template claro + versão registrada no aceite |
| Art. 49 | Sem prova de informação sobre direito de arrependimento (7 dias) | Cláusula obrigatória no template + audit log do aceite |
| Art. 54 | Cláusulas limitativas (cancelamento, multa, fidelidade) nulas se não destacadas | Template com destaque visual + hash de qual versão foi aceita |

### 4.4 Modelo de contrato por produto

**Brio:** Contrato de Prestação de Serviços — IIT + Usuário. Objeto: acesso à plataforma. Cláusulas: cancelamento, reembolso, privacidade. Foro: Salvador/BA.

**Jiu-Jitsu Academy:** Contrato de Matrícula — Academia (tenant) + Aluno, mediado pelo IIT. Inclui cláusula de risco físico (atividade de contato) e cláusula de imagem.

**Food Marketplace:** Termo de Uso — IIT como intermediária, não fornecedora do produto. Responsabilidade do produto é do restaurante.

**Restaurant QR:** Contrato de Licença SaaS — IIT licenciante + Restaurante licenciado. Dados de clientes do restaurante são de responsabilidade do restaurante (LGPD: controlador independente).

### 4.5 Versionamento de templates — regras

| Tipo de versão | Exemplo | requires_re_acceptance | Uso |
|----------------|---------|----------------------|-----|
| Patch | 1.0.0 → 1.0.1 | false | Correções ortográficas |
| Minor | 1.0.0 → 1.1.0 | false | Cláusulas não materiais |
| Major | 1.0.0 → 2.0.0 | **true** | Mudanças de preço, responsabilidade, cancelamento |

Apenas 1 template ativo por `product_type`. Contratos aceitos sempre referenciam a versão em vigor no momento do aceite.

---

## 5. Funcionalidades MVP P0 / P1 / P2

### P0 — Bloqueadores absolutos de go-live (Brio v1.0 embarcado)

| ID | Funcionalidade | Critério de conclusão |
|----|---------------|----------------------|
| P0-01 | Template HTML Brio v1.0 com variáveis | Cláusulas revisadas por Antonio; variáveis `{{user_name}}`, `{{cpf}}`, `{{plan_name}}`, `{{price}}`, `{{date}}` funcionando |
| P0-02 | `POST /contracts` — geração de contrato | Retorna `contract_id` + `content_html`; `expires_at = now + 1h`; template inativo → 404 |
| P0-03 | `POST /contracts/:id/accept` — aceite com audit log | Todos os 9 campos do audit log preenchidos; hash chain correto; REVOKE UPDATE/DELETE na tabela `contract_signatures` |
| P0-04 | Geração de PDF (fpdf) + upload MinIO | PDF com nome, IP, timestamp, SHA-256; upload para `contracts/{year}/{month}/{contract_id}/contract.pdf`; bucket privado |
| P0-05 | Hard dependency: checkout-service bloqueia sem `signature_id` | `POST checkout` sem `signature_id` válido → HTTP 422 `contract_not_accepted` |
| P0-06 | Testes P0 passando 100% | Suites QA 1 (aceite), 2 (PDF), 3 (imutabilidade) — sem exceções |
| P0-07 | Expiração de contrato (1h) | Aceite após `expires_at` → HTTP 410 `contract_expired` |
| P0-08 | Proteção anti-double-accept | Segunda chamada de aceite → HTTP 409 `contract_already_accepted` |

### P1 — contract-service dedicado (v1.5, antes de jiu-jitsu-academy ir ao ar)

| ID | Funcionalidade |
|----|---------------|
| P1-01 | Scaffold contract-service (Go + Fiber, porta :3014) |
| P1-02 | Migração de dados Brio → contracts_db |
| P1-03 | Troca `LocalContractService` → `RemoteContractService` no Brio (1 linha de injeção de dependência) |
| P1-04 | Templates para jiu-jitsu-academy, food-marketplace, restaurant-qr |
| P1-05 | Endpoint `GET /admin/signatures/verify/:id` (verificação de integridade do hash chain) |
| P1-06 | Re-aceite forçado em versões major (`requires_re_acceptance = true`) |
| P1-07 | SMS OTP no aceite para contratos > R$ 100/mês |
| P1-08 | `GET /users/:user_id/contracts` — histórico paginado |
| P1-09 | Comprovante simplificado em PDF (receipt.pdf) |
| P1-10 | Integração jiu-jitsu-academy ao contract-service |

### P2 — Enterprise / escala (v2.0, Q4 2026+)

| ID | Funcionalidade |
|----|---------------|
| P2-01 | DocuSign/SignNow para contratos B2B (tenants) quando tenant count > 20 |
| P2-02 | Âncora blockchain para audit log (timestamp.blockchain.notary.br ou similar) |
| P2-03 | Download em lote de contratos (admin) |
| P2-04 | Painel de contratos para tenants (academias, restaurantes) |
| P2-05 | Assinatura avançada com biometria (face match) para contratos > R$ 500/mês |
| P2-06 | Replicação do MinIO para S3-compatible externo (backup jurídico) |
| P2-07 | Integração com SERPRO/GOV.BR para verificação de CPF em tempo real |

---

## 6. KPIs e North Star

### North Star

> **"Todo contrato aceito é juridicamente defensável em litígio"**

Operacionalizado: `contract_signature_chain_integrity_ok = 100%` em verificação diária automatizada.

### KPIs primários

| KPI | Meta MVP | Meta v1.5 | Frequência |
|-----|----------|-----------|-----------|
| Taxa de aceite do contrato | > 90% dos checkouts que chegam à etapa contratual | > 92% | Semanal |
| Integridade do hash chain | 100% | 100% | Diária (cron) |
| PDF gerado em < 30s | > 98% | > 99% | Diária |
| Contratos com todos os campos de audit log | 100% | 100% | Diária |
| Disponibilidade do endpoint de aceite | 99,9% | 99,9% | Mensal |

### KPIs secundários

| KPI | Meta | Frequência |
|-----|------|-----------|
| P95 latência `POST /accept` | < 500ms | Semanal |
| P95 latência `POST /contracts` (geração) | < 200ms | Semanal |
| Taxa de contratos expirados antes do aceite | < 5% | Semanal |
| Taxa de erro em upload MinIO | < 0,1% | Diária |

### Métricas Prometheus (observabilidade)

```
contract_generated_total{product_type}
contract_accepted_total{product_type}
contract_rejected_total{product_type}
contract_expired_total{product_type}
contract_pdf_generation_duration_seconds{product_type}
contract_pdf_upload_errors_total
contract_signature_chain_integrity_ok  ← alerta crítico se false
```

**Alerta crítico:** `contract_signature_chain_integrity_ok = false` → notificação imediata (PagerDuty ou equivalente). Esse estado significa que o audit log foi adulterado — compromete toda a defesa jurídica.

---

## 7. Riscos Top 5

### Risco 1 — Hash chain corrompido por bug de implementação
**Probabilidade:** Baixa | **Impacto:** Crítico (comprometimento jurídico do audit log inteiro)
**Mitigação:**
- Testes determinísticos em CI (seed fixo → resultado sempre igual)
- Cron diário de verificação de integridade em todos os registros
- Alerta imediato se qualquer hash inválido detectado
- Revisão de código obrigatória na função de hash chain antes do go-live

### Risco 2 — MinIO indisponível no momento do aceite
**Probabilidade:** Baixa | **Impacto:** Alto (PDF não gerado, usuário não recebe comprovante)
**Mitigação:**
- Aceite **não falha** se MinIO estiver down: registra assinatura no banco, enfileira geração de PDF
- Job de background com retry exponencial
- Alerta de `contract_pdf_upload_errors_total` > 0
- PDF é evidência de suporte, não condição de validade do aceite

### Risco 3 — Migração de dados Brio → contracts_db (v1.5) introduz inconsistência
**Probabilidade:** Baixa | **Impacto:** Crítico (perda de audit log histórico = perda de prova jurídica)
**Mitigação:**
- Dry-run da migração em ambiente de staging antes de produção
- Manter Brio lendo do banco antigo por 48h com feature flag
- Verificação de integridade pós-migração: `SELECT COUNT(*)` e hash chain de amostra
- Rollback em < 5 minutos via feature flag

### Risco 4 — Template de contrato desatualizado em produção
**Probabilidade:** Média | **Impacto:** Alto (cláusulas inválidas = exposição jurídica)
**Mitigação:**
- Pipeline de aprovação: admin IIT ativa nova versão explicitamente
- Apenas 1 template ativo por `product_type` (restrição de banco)
- Changelog obrigatório (`change_summary`) ao publicar nova versão
- Antonio revisa cada template antes de ativação

### Risco 5 — Checkout-service avança sem signature_id (integração falha)
**Probabilidade:** Média (durante desenvolvimento) | **Impacto:** Crítico (produto lançado sem contrato = violação CDC)
**Mitigação:**
- Hard block no checkout-service: `signature_id` ausente ou inválido → HTTP 422, pagamento não processado
- Teste de integração P0 obrigatório (T4.1 da analysis_qa.md) — checkout sem aceite deve falhar
- Revisão de contrato de API entre os dois serviços antes da integração

---

## 8. Roadmap

### Brio v1.0 — Contract embarcado (Q2 2026, ~1,5 semana)

**Objetivo:** Legalizar o lançamento do Brio. Nenhum produto IIT pode ir ao ar sem isso.

| Semana | Entregáveis |
|--------|-------------|
| **Semana 1** | Schema SQL definitivo (contracts, templates, signatures) + migrations no Brio; `LocalContractService` com interface `ContractService`; template HTML Brio v1.0 (revisão Antonio); geração de PDF com fpdf |
| **Semana 2** | Endpoint de aceite + hash chain + REVOKE no banco; integração hard com checkout-service; upload PDF para MinIO (bucket privado); testes P0 (suites 1, 2, 3); revisão jurídica do template; aprovação Antonio → deploy |

**Entregável final:** Brio v1.0 em produção com contrato válido, audit log imutável e PDF gerado.

---

### contract-service dedicado v1.5 (Q3 2026, ~1,5 semana)

**Trigger:** jiu-jitsu-academy entra em desenvolvimento → migrar **antes** do lançamento.

| Semana | Entregáveis |
|--------|-------------|
| **Semana 1** | Scaffold contract-service (Go + Fiber, porta :3014); migrations (mesmo schema do Brio, zero retrabalho); migração dados `pg_dump` seletivo; todos os endpoints da API; testes de regressão |
| **Semana 2** | Troca `LocalContractService` → `RemoteContractService` no Brio; templates jiu-jitsu, food-marketplace, restaurant-qr; SMS OTP para contratos > R$100/mês; verificação de integridade admin; integração jiu-jitsu-academy; deploy com feature flag |

**Critério de migração:** qualquer um dos triggers a seguir dispara a migração antecipada:
- Segundo produto (jiu-jitsu-academy) entra em desenvolvimento
- `internal/contracts/` ultrapassa 500 linhas
- Necessidade de template diferente entre produtos

---

### v2.0 — Enterprise (Q4 2026+)

DocuSign para B2B · Âncora blockchain · Download em lote · Painel de tenants · Biometria para contratos de alto valor · Backup MinIO → S3 externo

---

## 9. Decisões Pendentes

| # | Decisão | Contexto | Opções | Prazo |
|---|---------|---------|--------|-------|
| **D1** | Revisão jurídica do template Brio v1.0 | Antonio precisa revisar o conteúdo legal do template antes do go-live. Não é dev — é análise de cláusulas. | Revisar internamente / Consultar advogado externo | Dia 2 do desenvolvimento |
| **D2** | SMS OTP no v1.5: provedor | Se SMS OTP for adotado no v1.5 para contratos > R$100/mês, qual provedor? Twilio (USD) vs Zenvia/Total Voice (BRL, menor latência BR) | Twilio / Zenvia / Total Voice | Antes de iniciar v1.5 |
| **D3** | DocuSign vs alternativa para B2B | Se tenant count > 20, qual plataforma de assinatura avançada? DocuSign (~USD 25/mês/300 env) vs D4Sign (BR, menor custo) vs SignNow | DocuSign / D4Sign / SignNow | Q3 2026 (antes de v2.0) |
| **D4** | Replicação do MinIO (backup jurídico) | PDFs são provas jurídicas. Homelab tem risco de falha física. Backup S3-compatible externo é necessário a partir de qual volume? | Wasabi (USD 6/TB/mês) / Backblaze B2 / AWS S3 IA | Antes de Q4 2026 ou 10.000 contratos acumulados |
| **D5** | Foro de eleição nos contratos | Template atual define Salvador/BA. Precisa de revisão se IIT operar em outros estados com tenants locais (academias em SP, RJ). | Manter Salvador/BA / Foro do domicílio do consumidor (CDC art. 101) | Antes de jiu-jitsu-academy em estados fora da Bahia |
| **D6** | Scroll obrigatório antes do aceite | UX: exigir que o usuário role até o final do contrato antes de habilitar o botão "Li e aceito"? Aumenta proteção jurídica (demonstra apresentação), mas adiciona fricção. | Scroll obrigatório / Checkbox + timer / Clique direto | Antes do frontend do Brio ser finalizado |

---

## Referências

- Lei 14.063/2020 — Assinaturas Eletrônicas
- Lei 13.709/2018 (LGPD) — arts. 7°, 16, 18
- MP 2.200-2/2001 — ICP-Brasil
- Código Civil — arts. 104, 107, 205, 206
- CDC — arts. 47, 49, 54
- STJ: REsp 1.495.920/DF; AREsp 1.473.825/SP (validade de logs eletrônicos)
- ADR-001: Contract embarcado vs. serviço dedicado (aprovado 2026-03-03)
- analysis_finance.md, analysis_legal.md, analysis_backend.md, analysis_qa.md, analysis_techlead.md (IIT, 2026-03-03)

---

*PRD gerado por @pm — IIT | 2026-03-03 | Consolidação de análises multidisciplinares (Finance + Legal + Backend + QA + Tech Lead)*
