# Análise de Backend e Arquitetura — contract-service v2
**Autor:** @backend
**Data:** 2026-03-03

---

## 1. Construindo sobre as Definições de Dados, Finanças e Jurídico

As análises anteriores fornecem um conjunto claro e coeso de requisitos que a implementação de backend deve satisfazer. Nossa arquitetura será projetada para garantir a conformidade e a robustez exigidas.

> "@data: O sucesso não é medido pelo volume, mas pela robustez e confiabilidade de cada transação individual. (...) É fundamental que o registro de aceite, uma vez escrito, não possa ser alterado." — _chain_01_data.md_

> "@finance: O serviço se paga integralmente com **1 a 3 disputas evitadas**." — _chain_02_finance.md_

> "@legal: A validade do nosso aceite se materializa pela coleta de evidências que, em conjunto, identificam o signatário e o ato de forma inequívoca. (...) A imutabilidade é o pilar da validade jurídica." — _chain_04_legal.md_

O direcionamento é inequívoco: a implementação de backend deve priorizar a **integridade, imutabilidade e auditabilidade** dos dados. A arquitetura não pode ter pontos de falha que comprometam a cadeia de custódia digital. A seguir, detalhamos as decisões técnicas para atender a esses requisitos.

---

## 2. Geração de PDF Dinâmico e Armazenamento

A geração do PDF é um requisito de negócio e jurídico para fornecer ao cliente uma cópia do contrato.

-   **Tecnologia:** Usaremos a biblioteca `go-fpdf` em Go. Ela é leve, não possui dependências externas (como CGO ou binários headless de browser) e é performática o suficiente para ser executada em uma goroutine background.
-   **Processo:**
    1.  Após o aceite bem-sucedido (`contract.accepted`), uma goroutine será disparada.
    2.  Esta goroutine receberá o `contract_id` e buscará o conteúdo HTML do contrato e os dados da assinatura (IP, timestamp, hash, nome do cliente, etc.).
    3.  O `go-fpdf` montará o documento, adicionando um cabeçalho/rodapé claro com os metadados da assinatura.
    4.  O PDF resultante será carregado para o bucket `contracts` no MinIO.
-   **Caminho do Objeto:** `/{tenant_id}/{year}/{month}/{contract_id}.pdf`. Usar o `tenant_id` na estrutura de pastas garante o isolamento dos dados no nível de armazenamento.
-   **Falhas:** A geração de PDF é um processo *atômico mas não crítico* para o aceite. Se o MinIO estiver offline ou a geração falhar, o aceite não será revertido. A falha será logada e um mecanismo de *retry* (por exemplo, via uma fila de "trabalhos mortos" ou um cron job que busca por PDFs pendentes) garantirá a execução posterior.

---

## 3. Hashing e Integridade do Conteúdo (SHA-256)

Este é o pilar técnico da validade jurídica.

-   **Algoritmo:** **SHA-256**. É o padrão da indústria, seguro e sem colisões conhecidas para este caso de uso.
-   **O que é "hasheado":** O `content_hash` será o hash do **corpo HTML renderizado completo**, *exatamente como foi enviado para o frontend*. Isso inclui todas as tags, espaços em branco e dados do cliente interpolados. Isso garante que estamos assinando o que o usuário viu.
-   **Onde é calculado:** O hash é calculado no backend, no momento da geração do contrato (`POST /contracts`), antes de ser salvo no banco e antes de o HTML ser enviado na resposta.
-   **Validação no Aceite:** No momento do aceite (`POST /contracts/:id/accept`), o backend deve re-calcular o hash do template original com as variáveis salvas e comparar com o `content_hash` armazenado. Isso previne qualquer race condition ou adulteração entre a geração e o aceite.

---

## 4. Bloqueio de Checkout (Hard Block)

A integração com o `checkout-service` deve ser binária e inflexível.

-   **Regra:** O `checkout-service` **NÃO DEVE** iniciar um processo de pagamento (criar cobrança no Asaas) se não tiver recebido um `signature_id` válido do `contract-service`.
-   **Fluxo de Integração:**
    1.  Frontend/BFF chama `POST /contracts/:id/accept`.
    2.  `contract-service` processa o aceite e retorna `{ "signature_id": "uuid-..." }`.
    3.  Frontend/BFF então chama o `checkout-service` para criar o pagamento, incluindo o `signature_id` no payload.
    4.  `checkout-service` trata `signature_id` como um campo obrigatório. Se ausente, retorna `400 Bad Request` com a mensagem "Aceite de contrato pendente".

---

## 5. Prevenção de Double-Accept (Idempotência)

Um usuário não pode, sob nenhuma circunstância, aceitar o mesmo contrato duas vezes. Isso poderia criar ambiguidades jurídicas e registros de auditoria conflitantes.

-   **Mecanismo:** A idempotência será garantida por uma combinação de verificação de estado e constraints de banco de dados.
-   **Na Lógica da Aplicação:** O handler de `POST /contracts/:id/accept` deve, como primeira ação, verificar o `status` do contrato no banco. Se o status for diferente de `pending`, a requisição deve ser rejeitada imediatamente com um status `409 Conflict`.
-   **Na Camada de Dados:** Para proteção contra race conditions, uma `UNIQUE constraint` deve ser aplicada no banco de dados na tabela `contract_signatures` na coluna `contract_id`. Qualquer tentativa de inserir um segundo registro para o mesmo `contract_id` resultará em uma violação de constraint, que a aplicação tratará retornando um `409 Conflict`.

Esta abordagem em duas camadas (lógica e dados) garante que, mesmo sob alta concorrência, a integridade do sistema seja mantida e nenhum aceite duplicado seja registrado.
