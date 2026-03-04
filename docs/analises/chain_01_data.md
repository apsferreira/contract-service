# Análise de Dados — contract-service v2
**Autor:** @data
**Data:** 2026-03-03

---

## 1. North Star Metric (NSM)

A Métrica de Estrela do Norte para o serviço de contratos é a **validade jurídica e a integridade de 100% dos contratos aceitos**.

> **NSM: 100% de Contratos com Aceite Digital Juridicamente Válido e Auditável.**

Isso significa que cada contrato aceito deve ter um registro de auditoria completo, imutável e verificável que possa ser defendido em uma disputa legal. O sucesso não é medido pelo volume, mas pela robustez e confiabilidade de cada transação individual.

---

## 2. Métricas de Suporte

Para monitorar a saúde e a eficiência do serviço, acompanharemos as seguintes métricas:

| Métrica | Descrição | Importância | Ferramenta |
|---|---|---|---|
| **Taxa de Aceite no Checkout** | `% de contratos gerados que são aceitos`. Uma taxa baixa pode indicar problemas de UX (texto confuso, modal intrusivo) ou performance. | Alta | Grafana (via eventos) |
| **Tempo Médio para Aceite** | `(accepted_at - generated_at)`. Tempo que o usuário leva para ler e aceitar. Picos podem indicar lentidão na UI ou hesitação do usuário. | Média | Prometheus |
| **Versão de Template Ativa** | Acompanhar qual versão (`template_id` + `version`) está sendo usada para novos contratos. Essencial para rastrear o impacto de alterações. | Alta | SQL Dashboard |
| **Taxa de Falha na Geração de PDF** | `% de aceites onde a geração de PDF em background falha`. Deve ser próximo de zero. | Média | Logs (Promtail + Loki) |

---

## 3. Modelo de Dados Essencial (Desde o Dia 1)

Para garantir a auditabilidade e a análise futura, a seguinte estrutura de dados é **não negociável** e deve estar presente desde o primeiro dia.

**Tabela: `contracts`**
| Coluna | Tipo | Descrição |
|---|---|---|
| `contract_id` | `UUID` | Chave primária. Identificador único do contrato gerado. |
| `account_id` | `UUID` | ID do usuário que está aceitando o contrato (FK para `customer-service`). |
| `template_id` | `UUID` | ID do template usado para gerar este contrato. |
| `version` | `VARCHAR` | Versão exata do template no momento da geração (ex: "1.2.0"). |
| `status` | `VARCHAR` | `pending`, `accepted`, `rejected`, `expired`. |
| `generated_at`| `TIMESTAMPTZ` | Timestamp exato de quando o contrato foi gerado. |
| `accepted_at` | `TIMESTAMPTZ` | Timestamp do aceite (NULL se não aceito). |
| `ip_address` | `INET` | Endereço IP do usuário no momento do aceite. |
| `user_agent` | `TEXT` | User Agent do navegador/dispositivo do usuário. |
| `content_hash`| `TEXT` | **SHA-256 do conteúdo HTML exato** que foi exibido ao usuário. |
| `pdf_url` | `TEXT` | URL para o PDF armazenado no MinIO (pode ser preenchido async). |
| `expires_at` | `TIMESTAMPTZ`| Timestamp de expiração do aceite. |

---

## 4. Eventos para Rastreamento

A emissão de eventos é crucial para o monitoramento em tempo real e para desacoplar as ações de outros serviços (como notificações).

| Evento | Exchange | Payload Mínimo |
|---|---|---|
| **`contract.generated`** | `contract.events` | `contract_id`, `account_id`, `template_id`, `version`, `generated_at` |
| **`contract.accepted`** | `contract.events` | `contract_id`, `account_id`, `accepted_at`, `ip_address`, `content_hash` |
| **`contract.rejected`** | `contract.events` | `contract_id`, `account_id`, `reason` (e.g., "expired", "user_action") |
| **`contract.pdf.generated`** | `contract.events` | `contract_id`, `pdf_url`, `generated_at` |

---

## 5. Informações Críticas para Outras Áreas

### Para @finance:
- **Auditabilidade é tudo:** O `content_hash` junto com o `account_id` e `accepted_at` é a nossa prova de que um usuário específico aceitou um texto específico em um momento específico. Isso é o que nos protege de chargebacks indevidos e disputas de "não contratei".
- **Retenção de dados:** Esses registros de aceite não são dados comuns de aplicação. Eles são evidências. A retenção deve ser de longo prazo (mínimo de 10 anos, a ser validado pelo @legal) e o armazenamento imutável.

### Para @legal:
- **Cadeia de custódia digital:** A combinação de `ip_address`, `user_agent`, `accepted_at` e `content_hash` forma a base da nossa cadeia de custódia. Precisamos garantir que esses dados sejam coletados de forma precisa e armazenados de forma segura.
- **Imutabilidade do registro:** É fundamental que o registro de aceite, uma vez escrito, não possa ser alterado. Qualquer sistema que permita um `UPDATE` em um registro de aceite é juridicamente falho. O hash do conteúdo (`content_hash`) garante a integridade do *que* foi aceito.
