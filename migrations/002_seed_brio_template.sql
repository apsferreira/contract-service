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
        Este contrato terá vigência de 12 (doze) meses a partir da data de aceite, renovando-se automaticamente
        por períodos sucessivos de igual duração, salvo manifestação contrária de qualquer das partes com 
        antecedência mínima de 30 (trinta) dias.
    </p>

    <h2>5. Cancelamento</h2>
    <p>
        O CONTRATANTE poderá cancelar o serviço a qualquer momento através da plataforma, com efeito imediato.
        Não há multa rescisória. Valores já pagos não são reembolsáveis proporcionalmente.
    </p>

    <h2>6. Propriedade Intelectual</h2>
    <p>
        Todo o software, algoritmos e materiais fornecidos permanecem propriedade exclusiva do 
        <strong>Instituto Itinerante de Tecnologia</strong>. O CONTRATANTE recebe apenas licença de uso
        enquanto o contrato estiver ativo.
    </p>

    <h2>7. Proteção de Dados (LGPD)</h2>
    <p>
        As partes declaram estar cientes da Lei Geral de Proteção de Dados (Lei 13.709/2018). 
        O tratamento de dados pessoais será realizado conforme nossa Política de Privacidade,
        disponível em <strong>{{privacy_policy_url}}</strong>.
    </p>

    <h2>8. Limitação de Responsabilidade</h2>
    <p>
        O CONTRATADO não se responsabiliza por:
    </p>
    <ul>
        <li>Interrupções causadas por terceiros (provedores de internet, serviços de cloud)</li>
        <li>Uso indevido da plataforma pelo CONTRATANTE</li>
        <li>Danos indiretos, lucros cessantes ou danos morais</li>
    </ul>

    <h2>9. Foro</h2>
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
            <strong>CNPJ:</strong> 00.000.000/0001-00<br>
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
