# Analysis Legal — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Autor:** @pm / IIT

---

## 1. Base Jurídica

### Lei 14.063/2020 — Assinaturas Eletrônicas

A Lei 14.063/2020 regulamenta o uso de assinaturas eletrônicas em interações com entidades públicas e privadas no Brasil. Para o contexto IIT (relações privadas B2C), o **art. 6° § 1°** é central:

> "As partes podem convencionar o uso de qualquer tipo de assinatura eletrônica nas suas relações jurídicas."

Isso significa que o clique "Li e aceito os termos" é juridicamente válido **desde que haja evidências robustas do ato**, sem necessidade de certificado ICP-Brasil em contratos privados B2C.

**Hierarquia de assinaturas segundo a lei:**

| Tipo | Exige | Uso no IIT |
|------|-------|------------|
| Simples | Qualquer meio eletrônico de identificação | ✅ MVP — clique com IP + timestamp |
| Avançada | Chave criptográfica ligada ao signatário | v1.5 opcional |
| Qualificada | Certificado ICP-Brasil | ❌ Desnecessário para B2C |

**Conclusão:** O IIT pode operar com assinatura eletrônica simples (clique) no MVP e incrementar segurança jurídica em versões futuras sem obrigação legal imediata.

---

## 2. LGPD — Dados Pessoais nos Contratos

### Dados coletados no ato da assinatura

| Dado | Categoria | Base legal (LGPD) |
|------|-----------|-------------------|
| Nome completo | Pessoal | Art. 7°, V — execução de contrato |
| CPF | Pessoal sensível | Art. 7°, V — execução de contrato |
| E-mail | Pessoal | Art. 7°, V — execução de contrato |
| IP do aceite | Pessoal (identificação) | Art. 7°, V — legítimo interesse |
| User-Agent | Técnico | Art. 7°, IX — legítimo interesse |
| Timestamp do aceite | Técnico | Art. 7°, IX — legítimo interesse |

### Obrigações LGPD

1. **Retenção:** Dados de contrato devem ser retidos pelo prazo prescricional (CC art. 205 = 10 anos para ações pessoais; art. 206 § 5° = 5 anos para relações de consumo). Recomendação: **10 anos**.
2. **Portabilidade:** O usuário pode solicitar cópia do contrato assinado a qualquer momento — o PDF no MinIO deve ser acessível via endpoint autenticado.
3. **Exclusão:** Dado de contrato NÃO pode ser apagado durante vigência ou período de prescrição, mesmo com solicitação de esquecimento (prevalece obrigação legal sobre direito de exclusão — LGPD art. 16, I).
4. **Finalidade:** Dados coletados exclusivamente para fins contratuais — não usar para marketing sem consentimento separado.

---

## 3. Validade Jurídica do Clique "Li e Aceito"

### Elementos que constituem prova do aceite

Para o aceite eletrônico simples ser juridicamente defensável em eventual litígio:

```
EVIDÊNCIAS OBRIGATÓRIAS (gravar no audit log):
  1. user_id autenticado (não aceite anônimo)
  2. contract_version_id (qual versão do contrato foi aceita)
  3. ip_address do cliente
  4. user_agent do navegador/app
  5. timestamp UTC com precisão de milissegundos
  6. checksum SHA-256 do conteúdo do contrato na época
  7. session_token_hash (prova de autenticação ativa)

EVIDÊNCIAS RECOMENDADAS (adiciona robustez):
  8. geolocation (lat/lng — apenas com consentimento explícito)
  9. screenshot do contrato exibido (raro, complexo — v2.0)
```

### Presunção de veracidade

O STJ tem reconhecido sistematicamente a validade de logs eletrônicos como prova (REsp 1.495.920/DF, AREsp 1.473.825/SP). A imutabilidade do audit log é o principal diferencial — um log que pode ser alterado não tem valor probatório.

---

## 4. Modelo de Contrato por Produto

### Brio (produto embarcado inicial)

```
Contrato de Prestação de Serviços — Brio
Partes: IIT (prestador) + Usuário (contratante)
Objeto: acesso à plataforma de [descrever serviço]
Vigência: indeterminada / mensal / anual
Cancelamento: X dias de antecedência
Política de reembolso: [específica por produto]
Cláusula de privacidade: remete à Política de Privacidade IIT
Foro: Salvador/BA
```

### Jiu-Jitsu Academy

```
Contrato de Matrícula — Academia de Jiu-Jitsu
Partes: Academia (prestador) + Aluno (contratante) — mediado pelo IIT
Objeto: acesso às aulas conforme plano escolhido
Plano: [membership_plan.name] — R$[price_cents/100]/[frequency]
Cláusula de risco físico: atividade esportiva de contato
Cláusula de imagem: uso de fotos/vídeos nas instalações
Cancelamento: 30 dias / sem fidelidade (conforme plano)
CDC aplicável: art. 49 (arrependimento 7 dias se contratado online)
```

### Food Marketplace

```
Termo de Uso — Food Marketplace IIT
Partes: IIT (plataforma) + Usuário (consumidor)
Objeto: intermediação de pedidos (IIT não é fornecedor do produto)
Responsabilidade: limitada à plataforma; restaurante responsável pelo produto
CDC: aplicável ao restaurante como fornecedor direto
Política de cancelamento: variável por restaurante
```

### Restaurant QR

```
Contrato de Licença — Restaurant QR
Partes: IIT (licenciante) + Restaurante (licenciado)
Objeto: licença de uso da plataforma de cardápio digital
Vigência: mensal
Dados: IIT acessa dados de menu do restaurante para exibição
LGPD: dados de clientes do restaurante são responsabilidade do restaurante
```

---

## 5. Versionamento Obrigatório de Contratos

### Por que versionar?

- Contrato pode ser atualizado (ex: mudança de política, novo preço, atualização legal)
- Usuário deve aceitar a versão vigente no momento da contratação
- Em litígio, deve-se provar qual versão estava em vigor e qual foi aceita

### Modelo de versionamento

```
contract_template (tabela)
  id: uuid
  product_type: enum (brio, jiu_jitsu_academy, food_marketplace, restaurant_qr)
  version: string (semver: "1.0.0", "1.1.0", "2.0.0")
  content_html: text (conteúdo renderizável)
  content_hash: char(64) SHA-256 do content_html
  is_active: boolean (apenas 1 ativo por product_type)
  requires_re_acceptance: boolean (mudanças materiais exigem re-aceite)
  change_summary: text (para o usuário entender o que mudou)
  effective_date: timestamptz (quando entra em vigor)
  created_at: timestamptz
  created_by: uuid (admin que publicou)
```

**Regra de negócio:**
- Versão patch (1.0.0 → 1.0.1): correções ortográficas, `requires_re_acceptance = false`
- Versão minor (1.0.0 → 1.1.0): adição de cláusulas não materiais, `requires_re_acceptance = false`
- Versão major (1.0.0 → 2.0.0): mudanças materiais (preço, responsabilidade, cancelamento), `requires_re_acceptance = true`

---

## 6. Audit Log de Assinaturas — Imutabilidade

### Requisito de imutabilidade

O audit log de assinaturas **nunca pode ser alterado ou excluído** — nem por admin IIT. Isso é juridicamente crítico.

### Estratégia técnica de imutabilidade

**Opção 1 (MVP):** Tabela append-only + REVOKE UPDATE/DELETE
```sql
-- Remover permissão de UPDATE e DELETE da tabela
REVOKE UPDATE, DELETE ON contract_signatures FROM app_user;
-- Apenas INSERT é permitido pela aplicação
```

**Opção 2 (v1.5):** Hash chain (cada registro contém hash do anterior)
```
signature[n].prev_hash = SHA-256(signature[n-1].full_record)
```
Permite detectar qualquer adulteração retroativa.

**Opção 3 (v2.0):** Âncora em blockchain (timestamp.blockchain.notary.br ou similar)

**Recomendação IIT:** MVP com Opção 1 + Opção 2 desde o início (custo zero de implementação, valor jurídico alto).

### Campos do audit log

```sql
CREATE TABLE contract_signatures (
  id                  UUID PRIMARY KEY,
  contract_id         UUID NOT NULL,          -- contrato gerado
  template_version_id UUID NOT NULL,          -- versão do template aceita
  user_id             UUID NOT NULL,
  accepted_at         TIMESTAMPTZ NOT NULL,   -- timestamp UTC do clique
  ip_address          INET NOT NULL,
  user_agent          TEXT NOT NULL,
  session_token_hash  CHAR(64) NOT NULL,      -- SHA-256 do JWT
  content_hash        CHAR(64) NOT NULL,      -- SHA-256 do contrato exibido
  pdf_path            TEXT,                   -- caminho no MinIO
  prev_hash           CHAR(64),               -- hash chain
  record_hash         CHAR(64) NOT NULL       -- SHA-256 do próprio registro
  -- SEM updated_at, SEM deleted_at — imutável
);

REVOKE UPDATE, DELETE ON contract_signatures FROM app_user;
```

---

## 7. Referências Legais

- Lei 14.063/2020 — Assinaturas Eletrônicas
- Lei 13.709/2018 (LGPD) — arts. 7°, 16, 18
- Código Civil — arts. 104, 107, 205, 206
- CDC — arts. 49, 54
- STJ: REsp 1.495.920/DF (validade de logs eletrônicos)
- ITI (Instituto Nacional de Tecnologia da Informação) — Resolução 4/2020

