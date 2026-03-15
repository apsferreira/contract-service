-- Migration: 004_seed_nitro_lgpd_template.sql
-- Description: Termo de Consentimento LGPD — Nitro (Focus Hub)
-- Autor: @legal · Data: 2026-03-15
-- Fundamentação: Lei 13.709/2018 (LGPD), Lei 14.063/2020, CDC Art. 49

INSERT INTO contract_templates (
    id,
    product_type,
    version,
    content_html,
    requires_re_acceptance,
    is_active
) VALUES (
    gen_random_uuid(),
    'nitro',
    '1.0.0',
    '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termo de Consentimento e Política de Privacidade — Nitro</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.7; max-width: 800px; margin: 0 auto; padding: 20px; color: #1a1a1a; }
        h1 { color: #1e3a5f; border-bottom: 3px solid #3b82f6; padding-bottom: 12px; font-size: 1.6rem; }
        h2 { color: #1e3a5f; margin-top: 32px; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .destaque { background: #eff6ff; border-left: 4px solid #3b82f6; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .aviso { background: #fef2f2; border-left: 4px solid #ef4444; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .dados-info { background: #f0fdf4; border: 1px solid #86efac; padding: 15px; border-radius: 8px; margin: 16px 0; }
        table { width: 100%; border-collapse: collapse; margin: 16px 0; }
        th { background: #dbeafe; padding: 10px; text-align: left; border: 1px solid #3b82f6; font-size: 0.9rem; }
        td { padding: 10px; border: 1px solid #e5e7eb; font-size: 0.9rem; vertical-align: top; }
        .plano { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; margin: 16px 0; }
        .assinatura { margin-top: 50px; border-top: 2px solid #e5e7eb; padding-top: 24px; }
        ul { padding-left: 24px; }
        li { margin-bottom: 6px; }
        .rodape { font-size: 0.8rem; color: #6b7280; margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 16px; }
    </style>
</head>
<body>

    <h1>Termo de Consentimento, Uso de Dados e Prestação de Serviços<br>
        <small style="font-size: 0.7em; color: #1e3a5f;">Nitro — Plataforma de Produtividade com IA</small>
    </h1>

    <div class="destaque">
        <strong>Produto:</strong> Nitro (Focus Hub) · <strong>Versão:</strong> 1.0.0<br>
        <strong>Usuário:</strong> {{user_name}} · <strong>Email:</strong> {{user_email}}<br>
        <strong>Plano:</strong> {{plan_name}} · <strong>Valor:</strong> {{price}}<br>
        <strong>Data do aceite:</strong> {{contract_date}}
    </div>

    <h2>1. Identificação das Partes</h2>
    <p>
        <strong>CONTROLADORA E CONTRATADA:</strong> Instituto Itinerante de Tecnologia (doravante "IIT"),
        CNPJ nº 00.000.000/0001-00, com sede em Salvador/BA,
        e-mail: contato@institutoitinerante.com.br.
    </p>
    <p>
        <strong>TITULAR DOS DADOS E CONTRATANTE:</strong> {{user_name}}, portador(a) do e-mail {{user_email}},
        doravante denominado(a) "Usuário".
    </p>

    <h2>2. Descrição do Serviço</h2>
    <p>
        O <strong>Nitro</strong> é uma plataforma de produtividade pessoal com inteligência artificial que
        oferece ao Usuário ferramentas para gestão de foco, tarefas, projetos e revisão diária.
        O serviço inclui:
    </p>
    <ul>
        <li>Gestão de tarefas e projetos com IA assistente</li>
        <li>Sessões de foco com rastreamento (Pomodoro e variantes)</li>
        <li>Revisão diária e semanal inteligente</li>
        <li>Gamificação e conquistas de produtividade</li>
        <li>Relatórios e análises de desempenho pessoal</li>
        <li>Integração com IA para sugestões e automações (planos específicos)</li>
    </ul>

    <div class="plano">
        <strong>Plano contratado:</strong> {{plan_name}}<br>
        <strong>Funcionalidades incluídas:</strong> {{plan_features}}<br>
        <strong>Valor:</strong> {{price}} ({{billing_period}})<br>
        <strong>Forma de pagamento:</strong> {{payment_method}}
    </div>

    <h2>3. Dados Pessoais Coletados e Finalidade</h2>

    <div class="dados-info">
        O tratamento de dados é realizado com base no <strong>consentimento</strong> (Art. 7º, I da LGPD),
        na <strong>execução do contrato</strong> (Art. 7º, II) e no <strong>legítimo interesse</strong>
        para melhoria do serviço (Art. 7º, IX), conforme detalhado abaixo.
    </div>

    <table>
        <tr>
            <th>Dado Coletado</th>
            <th>Finalidade</th>
            <th>Base Legal (LGPD)</th>
            <th>Retenção</th>
        </tr>
        <tr>
            <td>Nome e e-mail</td>
            <td>Identificação, autenticação e comunicações</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa + 5 anos</td>
        </tr>
        <tr>
            <td>Tarefas, projetos e notas</td>
            <td>Funcionalidade central do serviço</td>
            <td>Art. 7º, II (execução de contrato)</td>
            <td>Enquanto conta ativa</td>
        </tr>
        <tr>
            <td>Dados de sessões de foco (horários, duração)</td>
            <td>Relatórios de produtividade, gamificação</td>
            <td>Art. 7º, II (execução de contrato)</td>
            <td>Enquanto conta ativa + 2 anos</td>
        </tr>
        <tr>
            <td>Interações com IA (prompts e respostas)</td>
            <td>Melhorar sugestões personalizadas; NÃO usados para treinar modelos</td>
            <td>Art. 7º, I (consentimento)</td>
            <td>90 dias após interação</td>
        </tr>
        <tr>
            <td>Dados de pagamento</td>
            <td>Processamento da assinatura (via gateway — IIT não armazena cartão)</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Conforme legislação tributária (5 anos)</td>
        </tr>
        <tr>
            <td>Endereço IP e User-Agent</td>
            <td>Segurança, prevenção a fraudes</td>
            <td>Art. 7º, IX (legítimo interesse)</td>
            <td>90 dias</td>
        </tr>
        <tr>
            <td>Registro deste aceite (IP, hash, timestamp)</td>
            <td>Prova jurídica do consentimento e da contratação</td>
            <td>Art. 16, I (obrigação legal)</td>
            <td><strong>10 anos (imutável)</strong></td>
        </tr>
    </table>

    <h2>4. Uso de Inteligência Artificial</h2>
    <p>O Nitro utiliza modelos de IA para fornecer sugestões personalizadas. O Usuário declara estar
    ciente de que:</p>
    <ul>
        <li>O conteúdo das tarefas e contexto de trabalho é processado por modelos de IA para gerar sugestões</li>
        <li>Os dados <strong>não são usados para treinar modelos externos</strong> de terceiros</li>
        <li>As sugestões da IA são auxiliares e não substituem o julgamento do Usuário</li>
        <li>O Usuário pode desativar funcionalidades de IA nas configurações a qualquer momento</li>
    </ul>

    <h2>5. Preço, Pagamento e Renovação</h2>
    <p>
        O Usuário pagará o valor de <strong>{{price}}</strong> ({{price_written}}) por {{billing_period}},
        com renovação automática. O cancelamento da renovação deve ser feito com antecedência mínima de
        <strong>24 horas</strong> antes do próximo ciclo de cobrança.
    </p>
    <p>
        O IIT reserva-se o direito de reajustar os preços, notificando o Usuário com antecedência mínima
        de <strong>30 dias</strong> por e-mail.
    </p>

    <h2>6. Direito de Arrependimento</h2>
    <p>
        Conforme o Art. 49 do Código de Defesa do Consumidor, o Usuário tem <strong>7 (sete) dias corridos</strong>
        a partir desta data para desistir da contratação, com direito a reembolso integral, sem necessidade
        de justificativa. Para exercer este direito: contato@institutoitinerante.com.br.
    </p>

    <h2>7. Cancelamento após 7 dias</h2>
    <p>
        Após o período de arrependimento, o cancelamento pode ser feito a qualquer momento pela plataforma.
        O acesso continua até o fim do ciclo de pagamento vigente. <strong>Não há multa rescisória.</strong>
        Valores já pagos não são reembolsados proporcionalmente, exceto em caso de falha comprovada do serviço.
    </p>

    <h2>8. Disponibilidade (SLA)</h2>
    <p>
        O IIT se compromete com disponibilidade mínima de <strong>99% mensal</strong>.
        Em caso de indisponibilidade superior a 1% no mês, o Usuário terá direito a crédito proporcional.
        Manutenções programadas serão informadas com antecedência mínima de 24 horas.
    </p>

    <h2>9. Compartilhamento de Dados com Terceiros</h2>
    <p>O IIT <strong>não vende dados pessoais</strong>. Compartilhamento ocorre apenas com:</p>
    <ul>
        <li><strong>Provedores de IA</strong> (para processamento de sugestões — dados minimizados, sem PII quando possível)</li>
        <li><strong>Gateway de pagamento</strong> (processamento de cobranças)</li>
        <li><strong>Resend</strong> (e-mail transacional para autenticação OTP)</li>
        <li><strong>Cloudflare</strong> (CDN e segurança de rede)</li>
        <li><strong>Autoridades legais</strong> (quando exigido por lei)</li>
    </ul>

    <h2>10. Segurança dos Dados</h2>
    <ul>
        <li>Autenticação por OTP de uso único (sem senha armazenada)</li>
        <li>Transmissão via HTTPS/TLS 1.3</li>
        <li>Banco de dados com credenciais segregadas por serviço</li>
        <li>Infraestrutura em rede privada (Kubernetes/VLAN segmentada)</li>
        <li>Registros de aceite imutáveis com hash chain (REVOKE UPDATE/DELETE na tabela de assinaturas)</li>
    </ul>

    <h2>11. Direitos do Titular dos Dados (Art. 18 da LGPD)</h2>
    <ul>
        <li><strong>Acesso e cópia</strong> dos dados pessoais</li>
        <li><strong>Correção</strong> de dados desatualizados</li>
        <li><strong>Eliminação</strong> (ressalvados dados de aceite contratual mantidos por obrigação legal)</li>
        <li><strong>Portabilidade</strong> (exportação de tarefas e histórico em JSON/CSV)</li>
        <li><strong>Oposição</strong> ao tratamento baseado em legítimo interesse</li>
        <li><strong>Revogação do consentimento</strong> para funcionalidades de IA</li>
    </ul>
    <p>Solicitações via: privacidade@institutoitinerante.com.br (resposta em até 15 dias úteis)</p>

    <h2>12. Propriedade Intelectual</h2>
    <p>
        O software Nitro, seus algoritmos, design e conteúdo são propriedade exclusiva do IIT.
        O Usuário recebe licença de uso pessoal, intransferível, enquanto o contrato estiver ativo.
        O conteúdo criado pelo Usuário na plataforma (tarefas, notas) permanece de propriedade do Usuário.
    </p>

    <h2>13. Limitação de Responsabilidade</h2>
    <p>O IIT não se responsabiliza por:</p>
    <ul>
        <li>Interrupções causadas por terceiros (ISP, provedores de cloud, gateways)</li>
        <li>Decisões tomadas com base em sugestões da IA</li>
        <li>Danos indiretos, lucros cessantes (ressalvado o disposto no CDC)</li>
        <li>Perda de dados por falha do Usuário (ex: exclusão voluntária de conta)</li>
    </ul>

    <h2>14. Foro</h2>
    <p>
        Fica eleito o foro da Comarca de <strong>Salvador/BA</strong>, ressalvando ao Usuário consumidor
        o direito de optar pelo foro de seu domicílio, conforme Art. 101, I do CDC.
    </p>

    <div class="aviso">
        <strong>Declaração do Usuário:</strong> Ao aceitar este termo, o Usuário declara ter lido e
        compreendido todas as cláusulas, concordando expressamente com o tratamento de dados e as
        condições de prestação do serviço Nitro.
    </div>

    <div class="assinatura">
        <p>
            <strong>CONTRATANTE/TITULAR:</strong> {{user_name}}<br>
            <strong>E-mail:</strong> {{user_email}}<br>
            <strong>Documento:</strong> {{user_document}}
        </p>
        <p>
            <strong>CONTRATADA/CONTROLADORA:</strong> Instituto Itinerante de Tecnologia<br>
            <strong>CNPJ:</strong> 00.000.000/0001-00<br>
            <strong>E-mail:</strong> contato@institutoitinerante.com.br
        </p>
        <p style="margin-top: 28px; font-style: italic; color: #6b7280; font-size: 0.9rem;">
            Aceite eletrônico realizado em {{acceptance_date}} às {{acceptance_time}}<br>
            IP de origem: {{user_ip}} · Dispositivo: {{user_agent}}<br>
            Hash do documento (SHA-256): {{content_hash}}<br>
            Hash anterior na cadeia: {{prev_hash}}
        </p>
    </div>

    <div class="rodape">
        Documento gerado automaticamente pelo contract-service v1.0.0.<br>
        Validade jurídica nos termos da Lei 14.063/2020 (assinatura eletrônica simples).<br>
        Versão do template: nitro-1.0.0 · Instituto Itinerante de Tecnologia © {{contract_year}}
    </div>

</body>
</html>',
    false,
    true
) ON CONFLICT (product_type, version) DO NOTHING;
