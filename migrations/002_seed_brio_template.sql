-- Migration: 002_seed_brio_template.sql
-- Description: Seed initial template for Brio product

INSERT INTO contract_templates (
    id,
    product_type,
    version,
    content_html,
    requires_re_acceptance,
    is_active
) VALUES (
    gen_random_uuid(),
    'brio',
    '1.0.0',
    '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contrato de Serviço - Brio</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; }
        .info { background: #f4f4f4; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .signature { margin-top: 50px; border-top: 2px solid #ddd; padding-top: 20px; }
    </style>
</head>
<body>
    <h1>Contrato de Prestação de Serviços Digitais</h1>
    
    <div class="info">
        <strong>Produto:</strong> {{product_name}}<br>
        <strong>Cliente:</strong> {{user_name}}<br>
        <strong>Email:</strong> {{user_email}}<br>
        <strong>Plano:</strong> {{plan_name}}<br>
        <strong>Valor:</strong> R$ {{price}}/mês<br>
        <strong>Data:</strong> {{contract_date}}
    </div>

    <h2>1. Objeto do Contrato</h2>
    <p>
        O presente contrato tem por objeto a prestação de serviços digitais pela plataforma <strong>Brio</strong>,
        um agente de atendimento alimentado por inteligência artificial, desenvolvido e operado pelo 
        <strong>Instituto Itinerante de Tecnologia</strong>.
    </p>

    <h2>2. Serviços Prestados</h2>
    <p>
        O CONTRATANTE terá acesso aos seguintes recursos do plano <strong>{{plan_name}}</strong>:
    </p>
    <ul>
        <li>Atendimento automatizado via IA</li>
        <li>Integração com plataformas de mensageria</li>
        <li>Dashboard de métricas e analytics</li>
        <li>Suporte técnico via canal de atendimento</li>
    </ul>

    <h2>3. Valor e Forma de Pagamento</h2>
    <p>
        O CONTRATANTE pagará mensalmente o valor de <strong>R$ {{price}}</strong> ({{price_written}}),
        com vencimento no dia <strong>{{billing_day}}</strong> de cada mês.
    </p>

    <h2>4. Vigência e Renovação</h2>
    <p>
        Este contrato terá vigência por prazo indeterminado, renovando-se automaticamente a cada ciclo
        de cobrança (mensal ou anual, conforme o plano contratado).
    </p>

    <h2>5. Cancelamento</h2>
    <p>
        O CONTRATANTE pode cancelar sua assinatura a qualquer momento, sem multa, fidelidade ou penalidade.
        O cancelamento pode ser feito diretamente pela plataforma ou por e-mail para
        <strong>suporte@institutoitinerante.com.br</strong>. O acesso continua até o fim do ciclo de
        pagamento vigente.
    </p>

    <h2>6. Direito de Arrependimento (CDC Art. 49)</h2>
    <p>
        Em caso de arrependimento dentro de <strong>7 (sete) dias corridos</strong> da contratação, o valor pago
        será integralmente reembolsado de forma automática ao meio de pagamento original, conforme Art. 49 do CDC.
        Para exercer este direito: <strong>suporte@institutoitinerante.com.br</strong>.
    </p>

    <h2>7. Proteção de Dados (LGPD — Lei 13.709/2018)</h2>

    <h3>7.1. Base Legal</h3>
    <p>
        O tratamento de dados pessoais é realizado com base no <strong>consentimento do titular</strong>
        (Art. 7º, I da LGPD) e na <strong>execução contratual</strong> (Art. 7º, V da LGPD).
    </p>

    <h3>7.2. Dados Coletados e Finalidade</h3>
    <ul>
        <li><strong>Nome, e-mail, CPF/CNPJ:</strong> identificação, autenticação, faturamento e emissão de NFS-e</li>
        <li><strong>Dados de uso da plataforma:</strong> prestação do serviço, métricas de qualidade, comunicação</li>
        <li><strong>Dados de pagamento:</strong> processados via gateway (Stripe/PagSeguro) — o IIT não armazena dados de cartão</li>
        <li><strong>Endereço IP e User-Agent:</strong> segurança e prevenção a fraudes</li>
    </ul>

    <h3>7.3. Compartilhamento com Terceiros</h3>
    <p>O IIT <strong>não vende dados pessoais</strong>. Compartilhamento ocorre apenas com operadores/processadores:</p>
    <ul>
        <li><strong>Stripe/PagSeguro:</strong> processamento de pagamentos</li>
        <li><strong>Resend:</strong> e-mail transacional</li>
        <li><strong>Cloudflare:</strong> CDN e proteção de rede</li>
        <li><strong>Provedores de IA:</strong> dados minimizados para funcionalidades inteligentes</li>
        <li><strong>Autoridades legais:</strong> quando exigido por lei ou ordem judicial</li>
    </ul>

    <h3>7.4. Retenção de Dados</h3>
    <ul>
        <li><strong>Dados de uso:</strong> 6 meses após cancelamento</li>
        <li><strong>Dados fiscais (NFS-e, pagamentos):</strong> 5 anos conforme CTN Art. 174</li>
        <li><strong>Registro de aceite contratual:</strong> 10 anos (imutável, obrigação legal)</li>
    </ul>

    <h3>7.5. Direitos do Titular (Art. 18 LGPD)</h3>
    <p>O CONTRATANTE pode exercer os seguintes direitos via <strong>dpo@institutoitinerante.com.br</strong>:</p>
    <ul>
        <li><strong>Acesso:</strong> obter cópia dos dados pessoais tratados</li>
        <li><strong>Correção:</strong> atualizar dados incompletos ou desatualizados</li>
        <li><strong>Exclusão:</strong> solicitar eliminação dos dados (ressalvadas obrigações legais de retenção)</li>
        <li><strong>Portabilidade:</strong> exportação dos dados em formato estruturado (JSON/CSV)</li>
    </ul>

    <h3>7.6. Anonimização</h3>
    <p>
        Após a exclusão dos dados pessoais, dados de analytics serão anonimizados e poderão ser mantidos
        para fins estatísticos agregados, sem possibilidade de reidentificação do titular.
    </p>

    <h2>8. Disponibilidade (SLA)</h2>
    <p>
        O IIT se compromete com disponibilidade mínima de <strong>99,5% (noventa e nove vírgula cinco por cento)
        por mês</strong>, calculada em tempo de funcionamento da API e dashboard.
    </p>
    <ul>
        <li><strong>Janela de manutenção programada:</strong> domingos, das 02h às 06h (horário de Brasília)</li>
        <li><strong>Suporte por e-mail:</strong> resposta em até 48 (quarenta e oito) horas úteis</li>
        <li><strong>Crédito por violação:</strong> em caso de indisponibilidade superior a 0,5% no mês,
            o CONTRATANTE terá direito a crédito proporcional no próximo ciclo de cobrança</li>
    </ul>

    <h2>9. Propriedade Intelectual</h2>
    <p>
        Todo o software, algoritmos e materiais fornecidos permanecem propriedade exclusiva do
        <strong>Instituto Itinerante de Tecnologia</strong>. O CONTRATANTE recebe apenas licença de uso
        enquanto o contrato estiver ativo.
    </p>

    <h2>10. Limitação de Responsabilidade</h2>
    <p>
        O CONTRATADO não se responsabiliza por:
    </p>
    <ul>
        <li>Interrupções causadas por terceiros (provedores de internet, serviços de cloud)</li>
        <li>Uso indevido da plataforma pelo CONTRATANTE</li>
        <li>Danos indiretos, lucros cessantes ou danos morais</li>
    </ul>

    <h2>11. Foro</h2>
    <p>
        Fica eleito o foro da Comarca de <strong>Salvador/BA</strong> para dirimir quaisquer questões 
        oriundas deste contrato.
    </p>

    <div class="signature">
        <p>
            <strong>CONTRATANTE:</strong> {{user_name}}<br>
            <strong>CPF/CNPJ:</strong> {{user_document}}<br>
            <strong>Email:</strong> {{user_email}}
        </p>
        <p>
            <strong>CONTRATADA:</strong> Instituto Itinerante de Tecnologia<br>
            <strong>CNPJ:</strong> 64.826.421/0001-59<br>
            <strong>Email:</strong> contato@institutoitinerante.com.br
        </p>
        <p style="margin-top: 30px;">
            <em>
                Aceite eletrônico realizado em {{acceptance_date}} às {{acceptance_time}}<br>
                IP: {{user_ip}}<br>
                SHA-256: {{content_hash}}
            </em>
        </p>
    </div>
</body>
</html>',
    false,
    true
) ON CONFLICT (product_type, version) DO NOTHING;
