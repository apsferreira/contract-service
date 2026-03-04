# Análise de Frontend e Experiência do Usuário — contract-service v2
**Autor:** @frontend
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira e de Backend

A interface do usuário é a etapa final e mais visível de um processo complexo. O trabalho do frontend é apresentar os resultados das análises anteriores de forma clara, segura e com o mínimo de atrito, garantindo que os requisitos técnicos sejam atendidos sem prejudicar a conversão.

> "@data: Acompanharemos a **Taxa de Aceite no Checkout** (`% de contratos gerados que são aceitos`). Uma taxa baixa pode indicar problemas de UX (texto confuso, modal intrusivo) ou performance." — _chain_01_data.md_

> "@finance: A ausência de um processo de contratação claro e transparente pode levar ao **abandono do checkout**, representando uma perda de receita direta e imediata." — _chain_02_finance.md_

> "@backend: O `checkout-service` **NÃO DEVE** iniciar um processo de pagamento (...) se não tiver recebido um `signature_id` válido do `contract-service`." — _chain_05_backend.md_

A diretriz para o frontend é clara: devemos implementar um fluxo de aceite de contrato que seja **obrigatório** (conforme @backend), **confiável** (para satisfazer @data e @finance) e, acima de tudo, **fluido e transparente** para não causar o abandono do checkout. A experiência do usuário deve transmitir segurança, não burocracia.

---

## 2. Modal de Contrato no Checkout

A apresentação do contrato acontecerá dentro de um modal na etapa final do checkout, antes da confirmação do pagamento.

**Fluxo de Componentes (React):**
1.  O componente `CheckoutPage` obtém o `contract_html` do `contract-service` via uma chamada da API do BFF (Backend-for-Frontend).
2.  Ao clicar em "Prosseguir para Pagamento", o estado do `CheckoutPage` é atualizado para exibir um componente `ContractModal`.
3.  O `ContractModal` recebe o `contract_html` como prop e o renderiza dentro de um `div` com `dangerouslySetInnerHTML`. O HTML será sanitizado no BFF para prevenir ataques XSS.
4.  O modal conterá uma área de scroll para o conteúdo do contrato e um botão "Li e Aceito os Termos" desabilitado por padrão.

**A Questão do Scroll Obrigatório:**
-   **Problema:** Como podemos garantir que o usuário teve a oportunidade de ler o contrato? Forçar o scroll até o final é uma prática comum.
-   **Implementação:** Um `event listener` no `div` de conteúdo do contrato detectará o evento `onScroll`. Quando a posição do scroll (`scrollTop + clientHeight`) for igual ou maior que a altura total do conteúdo (`scrollHeight`), o estado do botão "Li e Aceito" será alterado para habilitado.
-   **Decisão a ser Documentada (ADR):** **Adotaremos o scroll obrigatório.**
    -   **Justificativa:** Embora possa adicionar um pequeno atrito (o ato de rolar a página), o benefício jurídico e a mitigação de disputas futuras ("Eu não vi essa cláusula") superam o risco de abandono. Isso reforça a validade do aceite, alinhando-se com a North Star Metric de @data de ter contratos 100% auditáveis e defensáveis. A ação explícita do usuário de rolar até o final é mais uma evidência a nosso favor.

**Tratamento de Estado e API:**
-   O botão "Li e Aceito" dispara a chamada `POST /contracts/:id/accept`.
-   Enquanto a chamada está em andamento, o botão exibirá um estado de "loading" para evitar cliques duplos.
-   **Sucesso:** O modal é fechado, a UI do checkout avança para a etapa final de pagamento, agora com o `signature_id` necessário em mãos.
-   **Erro:** Uma mensagem de erro clara é exibida dentro do modal (ex: "Não foi possível registrar seu aceite. Por favor, tente novamente."). O usuário não sai do fluxo de checkout.

---

## 3. Tela de Histórico de Contratos (Admin Panel)

O painel de administração do Brio (e futuramente dos outros produtos) precisará de uma interface para que o time de Suporte e o time Jurídico possam consultar os contratos aceitos.

**Localização:** Admin Panel > Clientes > [Selecionar Cliente] > Aba "Contratos"

**Funcionalidades:**
-   **Listagem:** A tela exibirá uma lista de todos os contratos associados àquele `account_id`.
-   **Colunas da Tabela:**
    -   `Data do Aceite` (`accepted_at`)
    -   `Produto` (resolvido a partir do `template_id`)
    -   `Versão` (`version`)
    -   `Status` (`status`)
    -   `Endereço IP` (`ip_address`)
    -   `Ações`
-   **Ações Disponíveis:**
    -   **Baixar PDF:** Um botão que fará uma chamada ao backend para obter uma *presigned URL* do MinIO e iniciará o download do PDF do contrato. Esta é a funcionalidade principal.
    -   **Ver Detalhes:** (v1.5) Um modal que exibe todos os metadados da assinatura, incluindo o `user_agent` e os hashes (`content_hash`, `record_hash`).

Esta interface de "apenas leitura" é crucial para dar autonomia ao time de Suporte em casos de disputa de clientes, reduzindo a carga sobre a equipe de engenharia para buscar manualmente essas informações no banco de dados.
