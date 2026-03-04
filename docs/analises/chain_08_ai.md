# Análise de Aplicações de IA — contract-service v2
**Autor:** @ai
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira e de Backend

A plataforma `contract-service`, conforme definida por @data, @finance e @backend, é um sistema robusto de registro e verificação. A IA pode se construir sobre essa fundação para adicionar funcionalidades de alto valor que vão além do escopo inicial, transformando o serviço de um sistema passivo de registro para uma plataforma ativa e inteligente.

> "@data: O sucesso não é medido pelo volume, mas pela robustez e confiabilidade de cada transação individual." — _chain_01_data.md_

> "@finance: A ausência de um processo de contratação claro e transparente pode levar ao abandono do checkout, representando uma perda de receita direta e imediata." — _chain_02_finance.md_

> "@backend: A integração com o `checkout-service` deve ser binária e inflexível." — _chain_05_backend.md_

A IA pode contribuir para ambos os objetivos:
1.  **Aumentar a robustez** (@data) oferecendo contratos mais específicos e, portanto, juridicamente mais fortes para nichos de clientes.
2.  **Reduzir o abandono** (@finance) ao identificar proativamente a hesitação do cliente no aceite do contrato e permitir uma ação de recuperação.

---

## 2. Geração Automática de Cláusulas Customizadas (Pós-MVP)

Conforme o ecossistema IIT cresce para atender diferentes verticais (Jiu-Jitsu, Restaurantes, Eventos, etc.), a complexidade de manter templates de contrato para cada variação aumenta. A IA pode simplificar isso gerando cláusulas específicas sob demanda.

-   **Modelo Sugerido:** **Gemini 1.5 Flash**. A escolha é baseada em três fatores:
    1.  **Velocidade:** A latência é crucial. A geração de cláusulas não pode atrasar significativamente a exibição do contrato para o usuário. Flash é otimizado para respostas rápidas.
    2.  **Custo:** Modelos mais pesados teriam um custo proibitivo em escala. Flash oferece um excelente equilíbrio de performance por custo.
    3.  **Qualidade:** A tarefa de "completar" um contrato com base em parâmetros estruturados é bem definida e não exige a complexidade de modelos maiores.
-   **Fluxo de Implementação:**
    1.  O serviço (ex: `jiu-jitsu-academy`) enviaria ao `contract-service` não apenas os dados do cliente, but também metadados sobre o serviço específico. Ex: `{ "vertical": "martial_arts", "modality": "jiu-jitsu_kids", "requires_image_use_clause": true }`.
    2.  O `contract-service` teria um template base com "placeholders" para cláusulas dinâmicas.
    3.  Uma chamada para a API do Gemini Flash seria feita com um prompt estruturado, como:
        ```prompt
        Você é um assistente jurídico. Gere uma cláusula contratual para um contrato de prestação de serviços de uma academia de jiu-jitsu infantil. A cláusula deve tratar da autorização de uso de imagem dos alunos menores de idade em materiais de divulgação da academia, condicionada à autorização explícita dos pais ou responsáveis. A linguagem deve ser clara e direta.
        ```
    4.  A cláusula gerada pela IA seria inserida no template antes de ser renderizada e apresentada ao usuário.
-   **Mitigação de Risco:** As cláusulas geradas pela IA **devem passar por revisão jurídica antes de serem usadas em produção**. A IA atua como uma ferramenta de produtividade para criar a primeira versão, não como a autoridade final.

---

## 3. Detecção de Contratos Abandonados

Um contrato gerado mas não aceito dentro de um determinado período (ex: 24 horas) é um forte sinal de abandono de carrinho no estágio final do funil. Podemos usar isso para acionar alertas de recuperação.

-   **Mecanismo:** Um job agendado (cron) que roda a cada hora.
-   **Lógica:**
    ```sql
    SELECT contract_id, account_id, generated_at
    FROM contracts
    WHERE status = 'pending'
    AND generated_at < NOW() - INTERVAL '24 hours'
    AND generated_at > NOW() - INTERVAL '25 hours';
    ```
-   **Ação Desencadeada:** Para cada contrato encontrado, o sistema publicaria um evento na fila de mensagens.
-   **Evento:** `contract.abandoned`
-   **Exchange:** `contract.events`
-   **Payload:** `{ "contract_id": "...", "account_id": "..." }`
-   **Consumidor:** O `notification-service` consumiria este evento e poderia acionar um fluxo de recuperação, como o envio de um email ou WhatsApp para o cliente.
-   **Exemplo de Mensagem de Recuperação:** "Olá [Nome], vimos que você iniciou sua inscrição no Brio mas não finalizou. Ficou com alguma dúvida sobre nossos termos? Pode contar com a gente para esclarecer qualquer ponto. Clique aqui para retomar de onde parou."

Esta abordagem proativa transforma o `contract-service` de um simples requisito legal em uma ferramenta de engajamento e recuperação de receita, alinhando-se diretamente com o objetivo de @finance de reduzir perdas por abandono de checkout.
