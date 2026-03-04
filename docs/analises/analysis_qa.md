# Analysis QA — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Autor:** @qa / IIT

---

## Testes P0 — Obrigatórios para Go-Live

**Definição P0:** falha nestes testes = produto não pode ser lançado.

---

## SUITE 1 — Validade do Aceite

### T1.1 — Aceite autenticado registra todos os campos obrigatórios

```
Pré-condição: contrato criado (status=pending), usuário autenticado
Ação: POST /api/v1/contracts/:id/accept com JWT válido
Resultado esperado:
  - HTTP 200
  - contract_signatures criado com:
    - user_id = id do usuário do JWT
    - ip_address = IP real do cliente (não 127.0.0.1 em prod)
    - user_agent = header do request
    - session_token_hash = SHA-256(JWT)
    - content_hash = SHA-256(contracts.content_rendered)
    - accepted_at = agora (diferença < 5s)
    - record_hash != null
  - contracts.status = "accepted"
```

### T1.2 — Aceite anônimo rejeitado

```
Ação: POST /api/v1/contracts/:id/accept sem Authorization header
Resultado esperado: HTTP 401 { "error": "unauthorized" }
Nenhum registro em contract_signatures
```

### T1.3 — Aceite de contrato de outro usuário rejeitado

```
Pré-condição: contrato criado para user_id = A
Ação: POST /api/v1/contracts/:id/accept com JWT do usuário B
Resultado esperado: HTTP 403 { "error": "forbidden" }
```

### T1.4 — Aceite de contrato expirado rejeitado

```
Pré-condição: contrato com presented_at = agora - 2 horas (> expires_at)
Ação: POST /api/v1/contracts/:id/accept
Resultado esperado: HTTP 410 { "error": "contract_expired" }
```

### T1.5 — Double-accept rejeitado (idempotência)

```
Pré-condição: contrato já aceito (status=accepted)
Ação: POST /api/v1/contracts/:id/accept novamente
Resultado esperado: HTTP 409 { "error": "contract_already_accepted" }
Nenhum novo registro em contract_signatures
```

### T1.6 — Conteúdo do contrato não pode ser alterado após aceite

```
Pré-condição: contrato aceito; content_hash registrado na assinatura
Ação: tentar UPDATE contracts SET content_rendered = '...' WHERE id = :id (via SQL direto)
Resultado esperado:
  - UPDATE pode acontecer no banco (sem trigger)
  - MAS: verificação de integridade detecta discrepância
  - GET /admin/signatures/verify/:sig_id retorna { "valid": false, "reason": "content_hash_mismatch" }
```

### T1.7 — Hash chain íntegro após 3 aceites consecutivos

```
Ação: criar e aceitar 3 contratos em sequência
Resultado esperado:
  - sig[0].prev_hash = null
  - sig[1].prev_hash = sig[0].record_hash
  - sig[2].prev_hash = sig[1].record_hash
  - GET /admin/signatures/verify/:sig_id válido para todos os 3
```

---

## SUITE 2 — PDF Gerado Corretamente

### T2.1 — PDF gerado após aceite

```
Ação: aceitar contrato
Resultado esperado:
  - contracts.pdf_path != null
  - contracts.pdf_generated_at != null
  - HEAD {pdf_path no MinIO} → HTTP 200 (arquivo existe)
  - tamanho do arquivo > 10KB (PDF não vazio)
```

### T2.2 — PDF contém dados do usuário e timestamp do aceite

```
Ação: aceitar contrato; baixar PDF; extrair texto
Resultado esperado: PDF contém:
  - Nome do usuário
  - IP do aceite
  - Timestamp do aceite
  - Hash SHA-256 do contrato
  - Nome do produto/plano
```

### T2.3 — PDF acessível apenas via presigned URL autenticada

```
Ação: acessar MinIO path diretamente sem presigned URL
Resultado esperado: HTTP 403 (bucket privado)
Ação: GET /api/v1/contracts/:id/download com JWT válido
Resultado esperado: { "url": "https://minio.../presigned..." } com expiração 1h
```

### T2.4 — PDF correto para cada product_type

```
Para cada product_type (brio, jiu_jitsu_academy, food_marketplace, restaurant_qr):
  - Criar contrato com template do produto
  - Aceitar
  - Verificar que PDF usa template correto (header, cláusulas específicas)
```

### T2.5 — PDF gerado mesmo com MinIO temporariamente indisponível

```
Pré-condição: MinIO simulado como DOWN durante aceite
Ação: POST /api/v1/contracts/:id/accept
Resultado esperado:
  - HTTP 200 (aceite registrado)
  - contracts.status = "accepted"
  - contract_signatures criado (audit log não falha)
  - contracts.pdf_path = null (PDF pendente)
  - Job de background gera PDF quando MinIO voltar
  - Alerta/log emitido: "PDF generation failed, scheduled retry"
```

---

## SUITE 3 — Audit Log Imutável

### T3.1 — DELETE na tabela contract_signatures rejeitado pela aplicação

```
Ação: chamar DELETE /api/v1/admin/signatures/:id (endpoint não deve existir)
Resultado esperado: HTTP 404 (rota não existe)
```

### T3.2 — DELETE direto no banco rejeitado por REVOKE

```
Pré-condição: conectar ao banco como app_user
Ação: DELETE FROM contract_signatures WHERE id = '...'
Resultado esperado: ERROR: permission denied for table contract_signatures
```

### T3.3 — UPDATE direto no banco rejeitado por REVOKE

```
Pré-condição: conectar ao banco como app_user
Ação: UPDATE contract_signatures SET user_id = '...' WHERE id = '...'
Resultado esperado: ERROR: permission denied for table contract_signatures
```

### T3.4 — Verificação de integridade do hash chain via endpoint admin

```
Ação: GET /api/v1/admin/signatures/verify/:signature_id
Resultado esperado (registro íntegro):
  { "valid": true, "chain_valid": true, "content_hash_valid": true }

Pré-condição adulteração (banco manipulado como superuser):
  UPDATE contract_signatures SET ip_address = '1.2.3.4' (como superuser, bypassa REVOKE)
Ação: GET /api/v1/admin/signatures/verify/:signature_id
Resultado esperado: { "valid": false, "reason": "record_hash_mismatch" }
```

### T3.5 — Contrato aceito aparece no histórico do usuário e não pode ser removido

```
Ação: GET /api/v1/users/:user_id/contracts após aceite
Resultado esperado: contrato aparece com status=accepted
Ação: tentar DELETE /api/v1/users/:user_id/contracts/:id
Resultado esperado: HTTP 404 ou 405 (endpoint não existe)
```

---

## SUITE 4 — Integração Checkout

### T4.1 — Checkout bloqueado sem signature_id

```
Pré-condição: checkout-service configurado para validar contract
Ação: tentar avançar checkout sem aceite de contrato
Resultado esperado: checkout-service retorna HTTP 422 "contract_not_accepted"
```

### T4.2 — Checkout liberado com signature_id válido

```
Ação: aceitar contrato → usar signature_id no checkout
Resultado esperado: checkout avança normalmente
```

---

## SUITE 5 — Versionamento de Templates

### T5.1 — Contrato gerado usa template ativo

```
Pré-condição: 2 templates para product_type "brio" (v1.0 inativo, v1.1 ativo)
Ação: POST /api/v1/contracts { product_type: "brio" }
Resultado esperado: contracts.template_id = template v1.1
```

### T5.2 — Usuário re-aceita contrato quando requires_re_acceptance = true

```
Pré-condição: usuário aceitou v1.0; admin ativa v2.0 com requires_re_acceptance=true
Ação: usuário tenta usar produto
Resultado esperado: sistema exige novo aceite (retorna 403 com "contract_re_acceptance_required")
```

---

## Critérios de Coverage

| Categoria | Coverage mínima |
|-----------|----------------|
| Handlers HTTP | 90% |
| Service layer (business logic) | 95% |
| Audit log / hash chain | 100% |
| PDF generation | 80% (testar output, não renderização visual) |
| Integration tests | Todos os P0 acima |

---

## Ferramentas

- **Unit tests:** `testing` nativo Go + `testify`
- **Integration:** Docker Compose com PostgreSQL + MinIO reais (não mocks)
- **PDF validation:** `pdfcpu` CLI para extrair texto e validar estrutura
- **Hash chain:** teste determinístico (seed fixo → resultado sempre igual)
- **Permission test:** conexão direta ao banco com `app_user` (não superuser)

