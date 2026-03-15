# Análise do Tech Lead e Decisões de Arquitetura — contract-service v2
**Autor:** @techlead
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira, Backend, IA e QA

O papel do Tech Lead é sintetizar os requisitos de todas as áreas em uma arquitetura coesa, pragmática e que equilibre velocidade de entrega com robustez de longo prazo. As análises anteriores confirmam a criticidade do serviço e informam as decisões técnicas finais.

> "@data: A Métrica de Estrela do Norte (...) é a **validade jurídica e a integridade de 100% dos contratos aceitos**." — _chain_01_data.md_

> "@finance: O serviço se paga integralmente com **1 a 3 disputas evitadas**." — _chain_02_finance.md_

> "@backend: A arquitetura não pode ter pontos de falha que comprometam a cadeia de custódia digital." — _chain_05_backend.md_

> "@ai: A plataforma `contract-service` (...) é um sistema robusto de registro e verificação. A IA pode se construir sobre essa fundação para adicionar funcionalidades de alto valor." — _chain_08_ai.md_

> "@qa: A política de cobertura de testes para os fluxos de aceite de contrato é **não negociável: 100% de cobertura de código**." — _chain_09_qa.md_

A mensagem consolidada é clara: o sistema deve ser **irrefutável**, **economicamente justificável**, **tecnicamente robusto**, **extensível** e **rigorosamente testado**. As decisões a seguir são projetadas para atender a esses cinco pilares.

---

## 2. ADR-001: Serviço Embarcado (v1.0) vs. Dedicado (v1.5)

**Contexto:** O PRD do `contract-service` estabelece a necessidade de ter a funcionalidade de contratos para o lançamento do Brio v1.0, mas também prevê a necessidade de um serviço compartilhado para futuros produtos do ecossistema IIT.

**Decisão:** **O `contract-service` será implementado inicialmente como um módulo interno (embarcado) dentro do monorepo do Brio v1.0, mas por trás de uma interface Go (`ContractService`). Será extraído para um microsserviço dedicado antes do lançamento do segundo produto que necessite de contratos (provavelmente `jiu-jitsu-academy`).**

**Justificativa:**
-   **Velocidade para o MVP:** Implementar como um módulo interno elimina o overhead de criar um novo repositório, pipeline de CI/CD e infraestrutura de deploy (K3s, etc.) apenas para o MVP, permitindo que o time foque 100% na lógica de negócio e cumpra o prazo de lançamento do Brio.
-   **Baixo Custo de Migração:** Ao codificar toda a lógica por trás de uma interface bem definida (ex: `type ContractService interface { Generate(...) ...; Accept(...) ... }`), a implementação inicial (`LocalContractService`) que opera diretamente no banco de dados pode ser trocada no futuro por uma `RemoteContractService` que faz chamadas HTTP para o serviço dedicado. A mudança no Brio será mínima, limitada à injeção de dependência.
-   **Risco Reduzido:** Desenvolver e testar a lógica de negócio crítica em um ambiente controlado (o próprio Brio) é mais simples e rápido. A extração para um microsserviço se torna primariamente um desafio de infraestrutura, não de lógica, que pode ser abordado quando o time tiver mais banda.

---

## 3. Imutabilidade Forçada via Trigger de Banco de Dados

Embora a aplicação deva impedir alterações em registros de assinatura, uma camada de defesa no banco de dados garante a imutabilidade mesmo em caso de bug na aplicação ou acesso manual indevido.

**Mecanismo:** Além dos `REVOKE` na role do usuário da aplicação, uma `TRIGGER` será criada na tabela `contract_signatures`.

**Implementação (PostgreSQL):**
```sql
-- 1. Criar a função da trigger
CREATE OR REPLACE FUNCTION prevent_signature_modification()
RETURNS TRIGGER AS $$
BEGIN
    -- Impede qualquer tentativa de UPDATE ou DELETE na tabela
    RAISE EXCEPTION 'Modificação de registros de assinatura de contrato é permanentemente proibida.';
END;
$$ LANGUAGE plpgsql;

-- 2. Associar a trigger à tabela
CREATE TRIGGER trg_prevent_signature_modification
BEFORE UPDATE OR DELETE ON contract_signatures
FOR EACH ROW EXECUTE FUNCTION prevent_signature_modification();
```
Esta trigger atua como a última linha de defesa, garantindo que um registro, uma vez escrito, não possa ser alterado ou removido por ninguém, a menos que a trigger seja explicitamente desabilitada por um superusuário, um ato que por si só já seria registrado nos logs de auditoria do banco.

---

## 4. Checklist Final de Go-Live

Esta lista consolida os pontos críticos de todas as análises e deve ser verificada antes do deploy em produção do Brio v1.0.

-   **[ ] Código & Testes:**
    -   [ ] Cobertura de 100% nos pacotes de geração e aceite de contrato.
    -   [ ] Suíte de regressão P0 (QA-CTR-001 a 007) 100% automatizada e passando no pipeline de CI.
    -   [ ] `ContractService` interface definida e implementada.
-   **[ ] Banco de Dados:**
    -   [ ] Migrations para as tabelas `contracts`, `contract_templates`, `contract_signatures` aplicadas.
    -   [ ] A `TRIGGER` de imutabilidade `trg_prevent_signature_modification` está ativa na tabela `contract_signatures`.
    -   [ ] A role do usuário da aplicação possui apenas permissões `SELECT`, `INSERT` na tabela `contract_signatures` (verificado via teste de conexão com a role).
-   **[ ] Infraestrutura & DevOps:**
    -   [ ] Bucket `contracts` no MinIO está criado, é privado e com Object Locking (modo Compliance) ativado para 10 anos.
    -   [ ] A rotina de backup para o `contracts_db` (Postgres) e para o bucket `contracts` (MinIO) está configurada e testada.
-   **[ ] Frontend & UX:**
    -   [ ] O modal de contrato exige scroll até o final para habilitar o botão de aceite.
    -   [ ] O fluxo de checkout bloqueia o pagamento até que um `signature_id` seja recebido do aceite do contrato.
-   **[ ] Legal & Suporte:**
    -   [ ] O template HTML final do contrato do Brio v1.0 foi revisado e aprovado pelo jurídico.
    -   [ ] A equipe de suporte foi treinada nos playbooks e sabe como acessar o histórico de contratos no painel admin.
-   **[ ] Aprovação Final:**
    -   [ ] Go/No-Go explícito do PM (@Antonio).
