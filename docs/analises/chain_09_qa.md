# Análise de Quality Assurance (QA) — contract-service v2
**Autor:** @qa
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira, Backend e IA

A função de QA é garantir que as implementações técnicas atendam rigorosamente aos requisitos definidos, especialmente quando a margem de erro é zero. O `contract-service` é um sistema onde um bug não é apenas um inconveniente, mas uma falha que pode invalidar nosso alicerce jurídico e financeiro.

> "@data: A Métrica de Estrela do Norte para o serviço de contratos é a **validade jurídica e a integridade de 100% dos contratos aceitos**." — _chain_01_data.md_

> "@finance: O serviço se paga integralmente com **1 a 3 disputas evitadas**." — _chain_02_finance.md_

> "@backend: A idempotência será garantida por uma combinação de verificação de estado e constraints de banco de dados. (...) O `content_hash` será o hash do **corpo HTML renderizado completo**." — _chain_05_backend.md_

> "@ai: As cláusulas geradas pela IA **devem passar por revisão jurídica antes de serem usadas em produção**." — _chain_08_ai.md_

A estratégia de QA é, portanto, de **tolerância zero para defeitos nos caminhos críticos**. Nosso objetivo é validar que cada aceite é único, íntegro, irrefutável e vinculado ao conteúdo correto. Um único contrato inválido representa 100% de falha para aquela transação.

---

## 2. Cobertura de Teste: 100% nos Caminhos de Aceite

Dada a sensibilidade jurídica do serviço, a política de cobertura de testes para os fluxos de aceite de contrato é **não negociável: 100% de cobertura de código (unitária e de integração).**

-   **Definição de "Caminho de Aceite":** Compreende o código responsável por:
    1.  Gerar o contrato (`POST /contracts`).
    2.  Calcular o `content_hash`.
    3.  Processar o aceite (`POST /contracts/:id/accept`).
    4.  Gravar o registro na tabela `contract_signatures`.
    5.  Verificar o status para evitar double-accept.
-   **Justificativa:** Diferente de outros serviços, onde um bug pode causar um erro 500 ou um dado incorreto, um bug aqui pode ter implicações legais e financeiras duradouras. Não podemos nos dar ao luxo de ter um caminho não testado. A CI (Continuous Integration) será configurada para **bloquear o merge** de qualquer Pull Request que reduza a cobertura de testes nesses pacotes específicos abaixo de 100%.

---

## 3. Casos de Teste Críticos (Suíte de Regressão P0)

A seguinte suíte de testes deve ser executada antes de qualquer deploy em produção. A falha em qualquer um desses testes deve ser um bloqueador de release.

### Teste de Integridade e Idempotência
| ID do Teste | Cenário | Passos de Execução | Resultado Esperado |
|---|---|---|---|
| **QA-CTR-001**| **Happy Path:** Aceite bem-sucedido | 1. Gerar contrato. <br> 2. Chamar endpoint de aceite. | HTTP 200. Registro criado em `contract_signatures` com todos os dados corretos. Status do contrato mudou para `accepted`. |
| **QA-CTR-002**| **Double-Accept (Race Condition):** Tentativa de aceitar o mesmo contrato duas vezes em paralelo. | 1. Gerar contrato. <br> 2. Disparar duas chamadas de aceite para o mesmo `contract_id` simultaneamente. | Uma chamada retorna HTTP 200, a outra retorna HTTP 409 (Conflict). Apenas UM registro é criado no banco de dados. |
| **QA-CTR-003**| **Double-Accept (Sequencial):** Tentativa de aceitar um contrato já aceito. | 1. Gerar e aceitar um contrato. <br> 2. Chamar o endpoint de aceite novamente com o mesmo `contract_id`. | HTTP 409 (Conflict). Nenhum novo registro é criado. |
| **QA-CTR-004**| **Aceite de Contrato Expirado:** | 1. Gerar contrato. <br> 2. Aguardar o tempo de expiração. <br> 3. Tentar aceitar. | HTTP 410 (Gone). |

### Teste de Validade dos Dados
| ID do Teste | Cenário | Passos de Execução | Resultado Esperado |
|---|---|---|---|
| **QA-CTR-005**| **Validação de Hash:** O hash do conteúdo é consistente. | 1. Gerar contrato, armazenar o HTML retornado e o `content_hash`. <br> 2. Re-calcular o SHA-256 do HTML armazenado. | O hash re-calculado deve ser **idêntico** ao `content_hash` retornado pela API. |
| **QA-CTR-006**| **Dados no PDF:** O PDF gerado contém os dados corretos da assinatura. | 1. Gerar e aceitar um contrato. <br> 2. Baixar o PDF gerado. <br> 3. Extrair o texto do PDF. | O texto do PDF deve conter o nome do cliente, IP, timestamp do aceite e o `content_hash` que correspondem exatamente aos dados registrados no banco. |
| **QA-CTR-007**| **Dados Incorretos no Input:** Tentar gerar contrato com variáveis faltando. | 1. Chamar `POST /contracts` com um payload onde falta uma variável obrigatória para o template (ex: `nome_cliente`). | HTTP 400 (Bad Request) com uma mensagem de erro clara sobre a variável ausente. |

A automação desses cenários é prioritária. Eles devem rodar como parte do pipeline de CI/CD para garantir que nenhuma regressão seja introduzida.
