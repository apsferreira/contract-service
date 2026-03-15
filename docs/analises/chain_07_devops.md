# Análise de DevOps e SRE — contract-service v2
**Autor:** @devops
**Data:** 2026-03-03

---

## 1. Alinhamento com as Perspectivas de Dados, Financeira e de Backend

A perspectiva de DevOps traduz os requisitos de negócio, legais e de aplicação em políticas de infraestrutura, armazenamento e confiabilidade. A integridade e a disponibilidade do `contract-service` são críticas e a infraestrutura deve refletir isso.

> "@data: Retenção de dados: Esses registros de aceite não são dados comuns de aplicação. Eles são evidências. A retenção deve ser de longo prazo (mínimo de 10 anos...)." — _chain_01_data.md_

> "@finance: O `contract-service` não é um "nice-to-have"; é um seguro obrigatório com ROI positivo a partir do primeiro sinistro evitado." — _chain_02_finance.md_

> "@backend: A geração de PDF é um processo *atômico mas não crítico* para o aceite. Se o MinIO estiver offline ou a geração falhar, o aceite não será revertido." — _chain_05_backend.md_

As diretrizes são claras:
1.  **Durabilidade e Retenção:** Os dados (PDFs e registros de DB) são evidências legais e devem ser preservados a longo prazo, de forma imutável.
2.  **Alta Disponibilidade:** O serviço é um bloqueador do checkout, o que o torna um componente de Tier 1 em termos de criticidade de disponibilidade.
3.  **Resiliência a Falhas:** A arquitetura da aplicação (separação do aceite e geração de PDF) permite que a infraestrutura trate a falha de componentes (como o MinIO) sem derrubar o fluxo de receita.

---

## 2. Configuração do Bucket MinIO para Contratos

O armazenamento de objetos (PDFs dos contratos) é uma peça central da cadeia de custódia.

-   **Bucket:** Um novo bucket chamado `contracts` será criado no nosso cluster MinIO (`shared-minio`).
-   **Política de Acesso:** O bucket será **privado**. O acesso público será negado em nível de bucket. Todo o acesso aos objetos será feito exclusivamente através de *presigned URLs* geradas pelo `contract-service`, com um tempo de expiração curto (ex: 5 minutos).
-   **Imutabilidade e Retenção (Object Locking):**
    -   Ativaremos o **Object Locking** no bucket `contracts` no modo **Compliance**.
    -   Uma política de retenção padrão de **10 anos (3650 dias)** será aplicada a todos os objetos enviados para este bucket.
    -   **Modo Compliance:** Uma vez que um objeto é escrito e sua retenção definida, ele **não pode ser sobrescrito ou excluído por nenhum usuário**, incluindo o usuário root, até que o período de retenção expire. Isso satisfaz o requisito de imutabilidade de @legal e @data no nível de infraestrutura.

---

## 3. Estratégia de Backup Externo

A retenção no MinIO protege contra exclusão acidental ou maliciosa, mas não contra falha de hardware ou desastre no datacenter. Portanto, um backup externo é mandatório.

-   **Backup do Banco de Dados (PostgreSQL):**
    -   O `contracts_db` será incluído em nossa rotina de backups diários do PostgreSQL, utilizando `pg_dump`.
    -   Os dumps serão armazenados localmente e replicados para um **storage offline/externo** (ex: Backblaze B2 ou similar) com uma política de retenção de 10 anos para os snapshots anuais.
-   **Backup do Armazenamento de Objetos (MinIO):**
    -   Usaremos o comando `mc mirror` para replicar o bucket `contracts` para um bucket correspondente no mesmo provedor de storage externo.
    -   Esta replicação ocorrerá **diariamente (D-1)**.
    -   Isso garante que, em caso de perda total do cluster MinIO, possamos restaurar todos os PDFs de contratos a partir de um backup externo e re-associá-los aos registros no banco de dados.

---

## 4. Implicações do SLA de 99.9%

Um SLA de 99.9% permite aproximadamente 8.76 horas de downtime por ano. Dado que o `contract-service` é um pré-requisito para todo o faturamento da empresa, ele deve ser tratado como uma aplicação de missão crítica.

-   **Deployment Strategy:** A aplicação será implantada no nosso cluster K3s com um mínimo de **2 réplicas** (`replicas: 2`) distribuídas entre diferentes nós de trabalho para garantir a disponibilidade durante atualizações (rolling updates) ou falha de um único nó.
-   **Monitoramento e Alertas:**
    -   **Prometheus:** Métricas de latência (P95, P99) para os endpoints `/accept` e `/contracts`, e taxa de erro (HTTP 5xx) serão coletadas.
    -   **Alertmanager:** Um alerta será configurado para disparar para a equipe de plantão se a taxa de erro exceder 1% por mais de 5 minutos ou se a latência P99 do endpoint de aceite ultrapassar 1000ms.
-   **Health Checks:** `Liveness` e `Readiness` probes serão configurados no K3s. O readiness probe verificará a conectividade com o PostgreSQL (`contracts_db`), garantindo que o tráfego não seja enviado para uma pod que não consiga acessar seu banco de dados.

A arquitetura de backend, que dissocia o aceite da geração de PDF, é um ponto chave para a confiabilidade. Isso significa que uma falha no MinIO não causará um alerta de downtime para o serviço principal, apenas um aumento na fila de "PDFs a gerar", que pode ser tratado com menor urgência.
