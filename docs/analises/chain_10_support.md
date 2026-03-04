# Análise de Suporte ao Cliente — contract-service v2
**Autor:** @support
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira e de QA

A equipe de suporte está na linha de frente, lidando diretamente com as consequências das decisões de produto e engenharia. Para o `contract-service`, o suporte precisa de ferramentas e informações claras para resolver disputas de forma rápida e definitiva, protegendo a empresa e ajudando o cliente.

> "@data: O `content_hash` junto com o `account_id` e `accepted_at` é a nossa prova de que um usuário específico aceitou um texto específico em um momento específico." — _chain_01_data.md_

> "@finance: O serviço se paga integralmente com **1 a 3 disputas evitadas**." — _chain_02_finance.md_

> "@qa: O texto do PDF deve conter o nome do cliente, IP, timestamp do aceite e o `content_hash` que correspondem exatamente aos dados registrados no banco." — _chain_09_qa.md_

Nosso objetivo no suporte é utilizar as "evidências" que @data especificou, que @qa validou, para "evitar as disputas" que @finance precificou. As ferramentas (como o painel admin) e os playbooks abaixo são projetados para traduzir os dados robustos do sistema em respostas claras e assertivas para o cliente.

---

## 2. Playbooks de Atendimento

Estes são os procedimentos padrão para lidar com os cenários mais prováveis relacionados a contratos. A equipe deve segui-los para garantir consistência e segurança.

### Playbook 1: Cliente alega "Eu não assinei este contrato / Não contratei este serviço."

Este é o cenário de maior risco, geralmente associado a um pedido de chargeback. O objetivo é apresentar as evidências de forma clara e profissional.

**Passos:**
1.  **Acalme e Escute:** Comece com empatia. "Entendo sua preocupação e vou verificar os registros do nosso sistema para esclarecer o que aconteceu."
2.  **Localize o Contrato:** No Admin Panel, navegue até o perfil do cliente e abra a aba "Contratos". Localize o contrato em questão pela data.
3.  **Baixe o PDF:** Use a ação "Baixar PDF" para obter a cópia exata do contrato que foi aceito.
4.  **Verifique os Dados de Auditoria:** Na tela (ou no modal "Ver Detalhes"), confirme os seguintes pontos:
    -   Data e Hora do Aceite (`accepted_at`)
    -   Endereço de IP (`ip_address`)
    -   Dispositivo (`user_agent`)
5.  **Comunique de Forma Factual:** Responda ao cliente com as evidências.
    -   **Script Sugerido:** "Obrigado por aguardar. Verifiquei nossos registros e consta que o contrato para o serviço [Nome do Produto] foi aceito em [Data] às [Hora], a partir do endereço de IP [Endereço IP], utilizando um [Dispositivo/Navegador]. Estou anexando a este email a cópia em PDF do contrato que foi aceito para sua referência. Você reconhece este acesso?"
6.  **Escalone se Necessário:** Se o cliente continuar a negar veementemente (possível caso de fraude/conta roubada), não discuta. Escalone o ticket para o time Jurídico/Financeiro com todas as evidências coletadas, informando ao cliente que uma análise mais aprofundada será feita. **Nunca prometa um reembolso neste estágio.**

### Playbook 2: Cliente informa "Meu contrato foi gerado com dados errados."

Isso pode acontecer se os dados cadastrais do cliente estiverem incorretos no `customer-service` no momento da geração.

**Passos:**
1.  **Peça Detalhes:** "Agradeço por nos informar. Poderia me dizer exatamente qual informação está incorreta no seu contrato?"
2.  **Verifique a Fonte:** Acesse o perfil do cliente no `customer-service` e verifique se os dados lá refletem o erro.
3.  **Corrija a Causa Raiz:** Ajude o cliente a corrigir seus dados cadastrais primeiro. "Vejo que o [dado, ex: seu sobrenome] estava incorreto em seu perfil. Já ajustei para você."
4.  **Gere um Novo Contrato (Se Crítico):**
    -   **Avaliação:** O erro é crítico (ex: CPF/CNPJ errado) ou menor (ex: um erro de digitação no nome)?
    -   **Se Crítico:** A funcionalidade de "regerar contrato" pode não existir no MVP. O procedimento padrão é: o cliente precisa cancelar a assinatura atual (com reembolso se aplicável) e assinar novamente com os dados corretos. Escalone para o Nível 2 se for necessário um procedimento manual no backend para invalidar o contrato antigo e gerar um novo.
    -   **Se Menor:** "Agradeço por nos avisar. Corrigimos seu cadastro. O contrato original permanece válido pois os demais dados de identificação são suficientes, mas a correção garante que futuras cobranças e comunicações estarão corretas."
5.  **Documente o Incidente:** Registre o ocorrido no ticket para que a equipe de produto possa medir a frequência deste problema.

### Playbook 3: Cliente solicita "Poderiam me reenviar uma cópia do meu contrato?"

Este é um cenário simples e de baixo risco, que serve para reforçar a confiança do cliente.

**Passos:**
1.  **Atenda Prontamente:** "Claro, com certeza!"
2.  **Localize e Baixe:** No Admin Panel, vá ao perfil do cliente, aba "Contratos".
3.  **Baixe o PDF:** Clique na ação "Baixar PDF" para o contrato mais recente (ou o que ele especificar, se houver mais de um).
4.  **Envie ao Cliente:** Anexe o PDF à resposta do ticket/email.
    -   **Script Sugerido:** "Aqui está a cópia do seu contrato de serviço, conforme solicitado. Ele também fica disponível para download a qualquer momento no seu painel de usuário [se a funcionalidade existir no futuro]. Se precisar de mais alguma coisa, é só avisar!"

Ter um processo rápido e eficiente para essas solicitações demonstra organização e transparência, melhorando a percepção do cliente sobre a empresa.
