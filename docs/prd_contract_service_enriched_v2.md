# PRD Enriquecido — contract-service v2.0
**Versão:** 2.0 | **Data:** 2026-03-03 | **Status:** Veredito Final | **Owner:** @pm (Antonio Ferreira)

---

## 1. Veredito do PM: GO

A cadeia de análise executada por todas as áreas (@data, @finance, @growth, @legal, @backend, @frontend, @devops, @ai, @qa, @support, @techlead) resultou em um alinhamento unânime e inequívoco. O `contract-service` não é apenas um requisito, mas uma peça fundamental de nossa infraestrutura de negócio, atuando como um escudo jurídico, uma ferramenta de mitigação de perdas financeiras e, inesperadamente, um potencializador da confiança e conversão.

A decisão está tomada: **o projeto está aprovado para implementação imediata**, seguindo o plano estratégico delineado pelo Tech Lead (ADR-001): embarcado no Brio v1.0 e extraído como serviço dedicado v1.5.

Este documento consolida as contribuições de todas as áreas e serve como a fonte final da verdade para o projeto.

---

## 2. Visão Estratégica e Justificativa de Negócio

O `contract-service` é o sistema centralizado responsável pela geração, aceite, armazenamento e auditoria de todos os contratos digitais nos produtos do ecossistema IIT.

-   **Por que existe? (O Problema)**
    -   **Risco Jurídico e Financeiro:** A ausência de um processo de contratação formal expõe a empresa a litígios, chargebacks e multas (LGPD, CDC). Conforme @finance, **o custo de 1 a 3 disputas evitadas paga todo o desenvolvimento**.
    -   **Confiança e Conversão:** Um processo de contratação pouco claro ou amador gera desconfiança no checkout, impactando negativamente a receita. Conforme @growth, um contrato claro é um **sinal de legitimidade e um diferencial de confiança**.
    -   **Escalabilidade:** Reimplementar a lógica de contratos em cada novo produto é ineficiente e propenso a inconsistências.

-   **O que ele faz? (A Solução)**
    -   Gera contratos dinâmicos a partir de templates versionados.
    -   Coleta um aceite digital juridicamente válido, embasado na Lei 14.063/2020.
    -   Armazena as evidências do aceite (IP, User Agent, Timestamp, Hash do conteúdo) em um **log de auditoria imutável**.
    -   Gera e armazena uma cópia em PDF do contrato para o cliente e para nossos registros.

-   **Qual o nosso objetivo principal? (A North Star Metric)**
    -   Conforme definido por @data, nosso sucesso é medido por: **100% de Contratos com Aceite Digital Juridicamente Válido e Auditável.**

---

## 3. Requisitos Consolidados

### 3.1. Requisitos de Dados e Jurídicos
-   **Cadeia de Custódia Digital:** A coleta dos seguintes dados no aceite é **obrigatória**: `account_id`, `ip_address`, `user_agent`, `accepted_at`, e `content_hash` (SHA-256 do HTML exato exibido).
-   **Imutabilidade:** O registro do aceite, uma vez escrito, não pode ser alterado. Isto será garantido por:
    1.  **Aplicação:** Lógica que previne `UPDATE` ou `DELETE`.
    2.  **Banco de Dados:** Uma `TRIGGER` no PostgreSQL que rejeita qualquer tentativa de `UPDATE` ou `DELETE` na tabela `contract_signatures`.
-   **Retenção:** Todos os contratos e registros de aceite devem ser mantidos por **10 anos**, conforme Código Civil Art. 205.
-   **LGPD:** Registros contratuais **não estão sujeitos ao "direito ao esquecimento"** e devem ser mantidos mesmo após a exclusão da conta do usuário, para cumprimento de obrigação legal (Art. 16 da LGPD).
-   **Cláusulas Mandatórias:** Todo contrato B2C deve conter as 11 cláusulas essenciais detalhadas por @legal, cobrindo objeto, preço, cancelamento, direito de arrependimento, etc.

### 3.2. Requisitos de Produto e UX
-   **Fluxo de Checkout:** O aceite do contrato é uma etapa **obrigatória e bloqueante** antes do pagamento.
-   **Modal de Contrato:** Será apresentado em um modal que exige **scroll obrigatório** até o final para habilitar o botão de aceite, reforçando a intenção do usuário.
-   **Comunicação:** O contrato será posicionado como um benefício de segurança para o cliente em toda a jornada (página de preços, checkout, email de boas-vindas).
-   **Acesso do Suporte:** A equipe de suporte terá acesso a um painel para consultar contratos e baixar os PDFs, capacitando-a a resolver disputas com base nos playbooks definidos.

### 3.3. Requisitos Técnicos e de Infraestrutura
-   **Idempotência:** O sistema deve impedir, em múltiplas camadas (lógica + constraint de DB), que um mesmo contrato seja aceito duas vezes.
-   **Armazenamento de PDF:** Os PDFs serão armazenados no MinIO em um bucket **privado**, com **Object Locking (modo Compliance)** e política de retenção de 10 anos ativada. O acesso se dará exclusivamente por presigned URLs.
-   **SLA e Disponibilidade:** Sendo um serviço Tier 1 (bloqueador de receita), o SLA é de **99.9%**. Será implantado com no mínimo 2 réplicas em K3s, com monitoramento e alertas robustos.
-   **Backup:** Rotinas de backup diárias e externas (off-site) serão implementadas tanto para o banco de dados PostgreSQL quanto para o bucket MinIO.
-   **Testes:** Cobertura de **100% de testes unitários e de integração** nos caminhos críticos de aceite é obrigatória e será imposta pelo pipeline de CI/CD.

---

## 4. Plano de Implementação (Roadmap)

A implementação seguirá a estratégia pragmática definida em **ADR-001**.

### v1.0 — Embarcado no Brio (Q2 2026)
-   **Escopo:** Implementar toda a lógica de negócio crítica como um módulo interno no Brio.
-   **Funcionalidades:** Geração, aceite, hash, log de auditoria, PDF, integração com checkout e proteções de banco (trigger).
-   **Objetivo:** Lançar o Brio v1.0 com total segurança jurídica sem o overhead de um novo microsserviço.

### v1.5 — Serviço Dedicado (Q3 2026)
-   **Escopo:** Extrair a lógica para um microsserviço `contract-service` dedicado.
-   **Funcionalidades:** Migrar dados, criar templates para novos produtos (Jiu-Jitsu, Food), adicionar verificação de integridade e re-aceite forçado.
-   **Objetivo:** Escalar a funcionalidade para todo o ecossistema IIT.

### v2.0+ — Plataforma Inteligente (Q4 2026 e além)
-   **Escopo:** Evoluir o serviço com funcionalidades de valor agregado.
-   **Funcionalidades (propostas por @ai):**
    -   Geração de cláusulas dinâmicas com IA (Gemini Flash) para contratos ultra-específicos.
    -   Detecção de abandono de contrato para acionar fluxos de recuperação de receita.
-   **Objetivo:** Transformar um centro de custo de conformidade em um ativo estratégico.

---

## 5. Checklist Final de Go-Live (Consolidado)

A autorização para o deploy em produção depende da conclusão de todos os itens abaixo.

-   [ ] **Jurídico:** Template final do contrato Brio v1.0 revisado e aprovado.
-   [ ] **Código:** Cobertura de 100% nos caminhos de aceite.
-   [ ] **Testes:** Suíte de regressão P0 (QA-CTR-001 a 007) passando na CI.
-   [ ] **Banco de Dados:** Trigger de imutabilidade `trg_prevent_signature_modification` ativa.
-   [ ] **Infraestrutura:** Bucket MinIO configurado com Object Locking (10 anos).
-   [ ] **Backup:** Rotinas de backup do DB e MinIO testadas.
-   [ ] **UX:** Scroll obrigatório implementado e funcionando.
-   [ ] **Integração:** Checkout efetivamente bloqueado sem `signature_id`.
-   [ ] **Operacional:** Time de suporte treinado nos playbooks.
-   [ ] **Aprovação:** Go/No-Go explícito do PM.
