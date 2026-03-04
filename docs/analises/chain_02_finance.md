# Análise Financeira e de Risco — contract-service v2
**Autor:** @finance
**Data:** 2026-03-03

---

## 1. Alinhamento com a Perspectiva de Dados

A análise de @data serve como a fundação para a nossa avaliação de risco e retorno.

> "Para @finance: Auditabilidade é tudo: O `content_hash` junto com o `account_id` e `accepted_at` é a nossa prova de que um usuário específico aceitou um texto específico em um momento específico. Isso é o que nos protege de chargebacks indevidos e disputas de 'não contratei'. Esses registros de aceite não são dados comuns de aplicação. Eles são evidências."
> — _chain_01_data.md_

Este ponto é o cerne da justificativa financeira para este serviço. Cada contrato não auditável representa um passivo contingente. A implementação, portanto, não é um centro de custo, mas uma ferramenta de mitigação de perdas.

---

## 2. Análise de Retorno sobre Investimento (ROI)

A análise de ROI para o `contract-service` não é sobre gerar nova receita, mas sobre **prevenir perdas catastróficas**. O cálculo é uma comparação direta entre o custo de desenvolvimento e o custo de um único evento adverso.

**Custo do Investimento (Desenvolvimento):**
- **Estimativa de Tempo:** ~3 semanas-homem (conforme PRD, incluindo backend, QA e integração).
- **Custo Aproximado:** Considerando o custo de oportunidade e salários da equipe, estimamos um custo de desenvolvimento na ordem de **R$ 25.000 a R$ 35.000**.

**Custo da Inação (Risco):**
- **Custo de 1 Litígio em Juizado Especial:** A experiência de mercado mostra que a defesa em um processo de Juizado Especial Cível (JEC), mesmo com vitória, incorre em custos.
  - **Honorários Advocatícios:** R$ 2.000 - R$ 5.000
  - **Acordo (em caso de risco de perda):** R$ 1.000 - R$ 5.000
  - **Custo Total por Litígio:** Varia de **R$ 2.000 a R$ 10.000**.

**Conclusão do ROI:**
O serviço se paga integralmente com **1 a 3 disputas evitadas**. Considerando o volume de transações planejado para os produtos do IIT, a ocorrência de ao menos uma disputa no primeiro ano sem um sistema de contratos robusto é estatisticamente quase certa. O `contract-service` não é um "nice-to-have"; é um seguro obrigatório com ROI positivo a partir do primeiro sinistro evitado.

---

## 3. Impacto Financeiro de Contratos Mal Gerenciados

A ausência ou má gestão de contratos digitais abre vetores de perda financeira direta que vão além do litígio.

| Risco | Descrição do Impacto Financeiro |
|---|---|
| **Chargeback por "Não Reconhecimento"** | Um cliente contesta uma cobrança no cartão de crédito alegando não ter contratado o serviço. Sem um contrato assinado com `ip_address` e `timestamp`, a disputa é frequentemente perdida, resultando na **reversão forçada do pagamento + multa da adquirente**. |
| **Reembolso Forçado via Procon/Consumidor.gov** | Reclamações em órgãos de defesa do consumidor onde a empresa não pode provar os termos aceitos pelo cliente geralmente terminam em determinação de **reembolso integral**, mesmo que o serviço tenha sido utilizado. |
| **Multa por Violação da LGPD** | A LGPD exige uma base legal clara para o tratamento de dados. O contrato é essa base. A ausência dele para justificar o armazenamento de dados do cliente para a prestação de um serviço pode ser interpretada como tratamento irregular, sujeito a **multas que podem chegar a 2% do faturamento**. |
| **Perda de Receita por Insegurança** | A ausência de um processo de contratação claro e transparente pode levar ao abandono do checkout, representando uma **perda de receita direta e imediata**. Um cliente que não se sente seguro não converte. |

Em resumo, a falta deste serviço não apenas expõe a empresa a custos reativos (processos, multas), mas também corrói a receita proativamente (abandono de carrinho, chargebacks). A implementação é uma decisão financeiramente sólida e defensiva.
