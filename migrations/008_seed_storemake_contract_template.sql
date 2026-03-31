-- Migration: 008_seed_storemake_contract_template.sql
-- Description: Contrato de Assinatura SaaS — StoreMake (Vitrine Digital para PMEs)
-- Autor: @legal (SOUL) · Data: 2026-03-31
-- Fundamentação: Lei 13.709/2018 (LGPD), Lei 14.063/2020, CDC Art. 49, MP 2.200-2/2001

INSERT INTO contract_templates (
    id,
    product_type,
    version,
    content_html,
    requires_re_acceptance,
    is_active
) VALUES (
    gen_random_uuid(),
    'storemake',
    '1.0.0',
    '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contrato de Assinatura SaaS — StoreMake</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.7; max-width: 800px; margin: 0 auto; padding: 20px; color: #1a1a1a; }
        h1 { color: #1f2937; border-bottom: 3px solid #8b5cf6; padding-bottom: 12px; font-size: 1.6rem; }
        h2 { color: #374151; margin-top: 32px; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .destaque { background: #faf5ff; border-left: 4px solid #8b5cf6; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .aviso { background: #fef2f2; border-left: 4px solid #ef4444; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .dados-info { background: #f0fdf4; border: 1px solid #86efac; padding: 15px; border-radius: 8px; margin: 16px 0; }
        table { width: 100%; border-collapse: collapse; margin: 16px 0; }
        th { background: #ede9fe; padding: 10px; text-align: left; border: 1px solid #8b5cf6; font-size: 0.9rem; }
        td { padding: 10px; border: 1px solid #e5e7eb; font-size: 0.9rem; vertical-align: top; }
        .plano { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; margin: 16px 0; }
        .assinatura { margin-top: 50px; border-top: 2px solid #e5e7eb; padding-top: 24px; }
        ul { padding-left: 24px; }
        li { margin-bottom: 6px; }
        .rodape { font-size: 0.8rem; color: #6b7280; margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 16px; }
    </style>
</head>
<body>

    <h1>Contrato de Assinatura e Serviços SaaS<br>
        <small style="font-size: 0.7em; color: #374151;">StoreMake — Vitrine Digital para PMEs e Autônomos</small>
    </h1>

    <div class="destaque">
        <strong>Produto:</strong> StoreMake · <strong>Versão:</strong> 1.0.0<br>
        <strong>Contratante (Empresa):</strong> {{business_name}}<br>
        <strong>CNPJ/CPF:</strong> {{business_cnpj}} · <strong>Email:</strong> {{user_email}}<br>
        <strong>Plano:</strong> {{plan_name}} · <strong>Valor:</strong> R$ {{plan_price}}/mês<br>
        <strong>Data da contratação:</strong> {{contract_date}}
    </div>

    <h2>1. Identificação das Partes</h2>
    <p>
        <strong>CONTRATADA:</strong> Instituto Itinerante de Tecnologia (doravante "IIT"),
        CNPJ nº 64.826.421/0001-59, com sede em Salvador/BA,
        e-mail: contato@institutoitinerante.com.br (doravante "Empresa").
    </p>
    <p>
        <strong>CONTRATANTE:</strong> {{business_name}}, portador(a) de {{business_cnpj}},
        representado(a) por {{user_name}} (CPF {{user_cpf}}), endereço de e-mail {{user_email}},
        doravante denominado(a) "Lojista" ou "Cliente".
    </p>

    <h2>2. Objeto do Contrato</h2>
    <p>
        O presente contrato tem por objeto a prestação de serviços de vitrine digital (e-commerce) através da plataforma
        <strong>StoreMake</strong>, um software como serviço (SaaS) que permite pequenas e médias empresas, autônomos e empreendedores
        criar, gerenciar e vender produtos em um catálogo digital, com integração de pagamentos, carrinho de compras e gestão de pedidos.
    </p>

    <h2>3. Descrição do Serviço</h2>
    <p>
        O StoreMake fornece ao Contratante as seguintes funcionalidades no plano <strong>{{plan_name}}</strong>:
    </p>
    <ul>
        <li>Criação de catálogo digital com upload ilimitado ou limitado de produtos (conforme plano)</li>
        <li>Personalização de design da loja (temas, cores, logotipo)</li>
        <li>Carrinho de compras com cálculo automático de frete</li>
        <li>Integração com gateways de pagamento (Asaas, Stripe)</li>
        <li>Gestão de pedidos, clientes e histórico de vendas</li>
        <li>Dashboard com relatórios de vendas e analytics</li>
        <li>Integração com redes sociais para divulgação</li>
        <li>Domínio personalizado (loja.storlemake.com.br ou domínio próprio)</li>
        <li>Suporte por email (resposta em até 48h em dias úteis)</li>
    </ul>
    <div class="plano">
        <strong>Detalhes do Plano Contratado:</strong><br>
        Produtos na loja: {{plan_limit_products}}<br>
        Transações por mês: {{plan_limit_transactions}}<br>
        Espaço de armazenamento: {{plan_storage_gb}}GB<br>
        Integrações disponíveis: {{plan_integrations}}
    </div>

    <h2>4. Preço, Pagamento e Renovação Automática</h2>
    <p>
        O Contratante pagará o valor de <strong>R$ {{plan_price}}</strong> por mês,
        com renovação automática a cada período (mês/ano conforme plano).
    </p>
    <p>
        <strong>Planos disponíveis:</strong>
    </p>
    <ul>
        <li><strong>Starter:</strong> R$ 49,00/mês — até 50 produtos, até 100 pedidos/mês, domínio compartilhado</li>
        <li><strong>Pro:</strong> R$ 99,00/mês — até 500 produtos, até 1.000 pedidos/mês, domínio personalizado, analytics avançado</li>
        <li><strong>Enterprise:</strong> R$ 249,00/mês — produtos ilimitados, pedidos ilimitados, suporte prioritário 24/7, integrações customizadas</li>
    </ul>
    <p>
        <strong>Formas de Pagamento:</strong> PIX, cartão de crédito e débito automático,
        processados via gateway Asaas. Fatura/NFS-e emitida automaticamente conforme legislação.
    </p>
    <p>
        <strong>Taxas de Transação:</strong> Além da assinatura mensal, o Contratante pagará taxa por transação
        (% sobre o valor da venda) conforme tabela de preços da plataforma Asaas. O IIT é apenas intermediária
        na transferência de fundos — os valores vão diretamente para a conta bancária do Lojista.
    </p>
    <p>
        <strong>Reajuste de Preços:</strong> O preço anual será reajustado de acordo com o Índice Nacional de Preços ao Consumidor Amplo (IPCA),
        com antecedência mínima de <strong>30 (trinta) dias</strong> por comunicação via e-mail.
    </p>
    <p>
        <strong>Cancelamento da Renovação:</strong> O Contratante poderá cancelar a renovação automática a qualquer momento
        pela plataforma, com efeito imediato. O acesso continua até o fim do período de cobrança vigente.
    </p>

    <h2>5. Direito de Arrependimento (CDC Art. 49)</h2>
    <p>
        Em caso de arrependimento dentro de <strong>7 (sete) dias corridos</strong> da contratação, o valor pago
        será integralmente reembolsado de forma automática ao meio de pagamento original, conforme Art. 49 do CDC.
        Para exercer este direito: <strong>suporte@institutoitinerante.com.br</strong>.
    </p>
    <p>
        <strong>Reembolso Pro-Rata:</strong> Após o período de arrependimento, em caso de cancelamento da assinatura,
        o Contratante terá direito a reembolso proporcional dos dias não utilizados, processado em até 7 (sete) dias úteis.
    </p>

    <h2>6. Cancelamento</h2>
    <p>
        O CONTRATANTE pode cancelar sua assinatura a qualquer momento, sem multa, fidelidade ou penalidade.
        O cancelamento pode ser feito pela plataforma ou por e-mail para
        <strong>suporte@institutoitinerante.com.br</strong>.
        O acesso continua até o fim do ciclo de pagamento vigente.
    </p>
    <p>
        <strong>Exportação de Dados Pós-Cancelamento:</strong> O Contratante terá <strong>30 (trinta) dias</strong> para
        exportar dados de sua loja (catálogo, pedidos, clientes) em formato estruturado (CSV, JSON). Após este período,
        os dados serão excluídos permanentemente da plataforma.
    </p>

    <h2>7. Disponibilidade (SLA) e Suporte</h2>
    <p>
        A IIT se compromete com disponibilidade mínima de <strong>99,5% (noventa e nove vírgula cinco por cento)
        por mês</strong>, calculada em tempo de funcionamento da loja e gateway de pagamentos.
    </p>
    <ul>
        <li><strong>Janela de manutenção programada:</strong> domingos, das 02h às 06h (horário de Brasília)</li>
        <li><strong>Suporte por e-mail:</strong> resposta em até 48 (quarenta e oito) horas úteis (planos Starter/Pro) ou 4 horas (Enterprise)</li>
        <li><strong>Crédito por violação:</strong> em caso de indisponibilidade superior a 0,5% no mês,
            o Contratante terá direito a crédito proporcional no próximo ciclo de cobrança</li>
    </ul>

    <h2>8. Propriedade do Conteúdo</h2>
    <p>
        Toda a propriedade intelectual da <strong>plataforma StoreMake</strong> (software, código, design, temas,
        integrações, algoritmos) permanece com a IIT. O Contratante recebe licença de uso não exclusiva, não transferível,
        limitada à duração do contrato.
    </p>
    <p>
        <strong>Conteúdo do Lojista:</strong> Produtos, imagens, descrições, catálogos, dados de clientes e pedidos
        criados pelo Contratante permanecem propriedade exclusiva do Contratante. A IIT obtém apenas a licença necessária
        para armazenamento, processamento, apresentação e análise enquanto o serviço estiver ativo.
    </p>
    <p>
        <strong>Domínio Personalizado:</strong> Se o Contratante usar domínio próprio (ex: loja.com.br), ele permanece
        propriedade do Contratante. Caso use domínio StoreMake (loja.storemake.com.br), este será desativado após
        cancelamento, com período de transição de 30 dias.
    </p>

    <h2>9. Responsabilidade Fiscal e Emissão de NFS-e</h2>
    <p>
        O Contratante é responsável pela:
    </p>
    <ul>
        <li>Categoria fiscal de sua atividade (Simples Nacional, Lucro Presumido, etc.)</li>
        <li>Emissão de NFS-e pelos serviços prestados (no caso de lojistas prestadores de serviço)</li>
        <li>Obrigações tributárias estaduais e municipais</li>
        <li>Conformidade com legislação de proteção ao consumidor (CDC)</li>
    </ul>
    <p>
        A StoreMake <strong>não emite NFS-e</strong> — apenas intermediária de pagamento. O Contratante deverá emitir
        RPA (Recibo de Pagamento Autônomo) ou NFS-e diretamente junto à prefeitura, se aplicável.
    </p>
    <p>
        <strong>Relatórios Fiscais:</strong> A IIT disponibiliza relatórios mensais detalhados de vendas, que podem
        ser utilizados como base para apuração de impostos. Para conformidade LGPD/LGDT, relatórios são mantidos por 10 anos.
    </p>

    <h2>10. Integração com Gateways de Pagamento</h2>
    <p>
        O StoreMake integra-se com Asaas, Stripe e outros gateways de pagamento. O Contratante concorda que:
    </p>
    <ul>
        <li>Dados de pagamento de clientes são processados pelos gateways (PCI-DSS compliant) — o IIT não acessa esses dados</li>
        <li>Taxas de processamento são cobradas pelos gateways, deduzidas automaticamente do valor da venda</li>
        <li>O IIT facilita apenas a integração — responsabilidade de cobrança é do gateway</li>
        <li>Disputas de pagamento (chargeback, contestação) são geridas pelo gateway, conforme suas políticas</li>
    </ul>

    <h2>11. Conteúdo da Loja e Compliance</h2>
    <p>
        O Contratante declara que:
    </p>
    <ul>
        <li>Todos os produtos oferecidos são legalmente comercializáveis no Brasil</li>
        <li>Possui autorização legal para vender tais produtos (licenças, certificações, quando aplicável)</li>
        <li>As descrições de produtos são verídicas e não contêm conteúdo enganoso</li>
        <li>Cumpre com legislação de defesa do consumidor (CDC, LGPD, código de telecomunicações, etc.)</li>
    </ul>
    <p>
        A IIT se reserva o direito de <strong>suspender ou remover produtos</strong> que violem lei brasileira
        (drogas, armas, conteúdo sexual infantil, falsificações, etc.), com aviso prévio de 48 horas,
        exceto em casos de risco imediato à segurança ou ilicitude manifesta.
    </p>

    <h2>12. Dados Pessoais e LGPD</h2>

    <div class="dados-info">
        Conforme Lei 13.709/2018 (LGPD), o tratamento de dados pessoais é realizado com base no <strong>consentimento do titular</strong>
        (Art. 7º, I) e na <strong>execução contratual</strong> (Art. 7º, V).
    </div>

    <table>
        <tr>
            <th>Dado Coletado</th>
            <th>Finalidade</th>
            <th>Base Legal</th>
            <th>Retenção</th>
        </tr>
        <tr>
            <td>Nome, email, CPF/CNPJ (Lojista)</td>
            <td>Identificação, autenticação, contato, emissão de NFS-e</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa + 10 anos (obrigação fiscal)</td>
        </tr>
        <tr>
            <td>Dados de pagamento (processados via gateway)</td>
            <td>Cobrança da assinatura</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Conforme legislação tributária (5 anos)</td>
        </tr>
        <tr>
            <td>Dados de clientes da loja (nome, email, endereço)</td>
            <td>Processamento de pedidos, entrega, suporte pós-venda</td>
            <td>Art. 7º, II (contrato) — o Lojista é controlador de dados</td>
            <td>Conforme política de privacidade do Lojista + obrigações legais (mínimo 5 anos)</td>
        </tr>
        <tr>
            <td>Catálogo de produtos, imagens, descrições</td>
            <td>Funcionalidade central: armazenamento e exposição</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa; exportável até 30 dias após cancelamento</td>
        </tr>
        <tr>
            <td>Histórico de vendas e pedidos</td>
            <td>Analytics de vendas, conformidade fiscal</td>
            <td>Art. 7º, II (contrato)</td>
            <td>10 anos (obrigação fiscal — CTN Art. 174)</td>
        </tr>
        <tr>
            <td>Endereço IP, User-Agent, logs de acesso</td>
            <td>Segurança, prevenção a fraudes, auditoria</td>
            <td>Art. 7º, IX (legítimo interesse)</td>
            <td>90 dias</td>
        </tr>
        <tr>
            <td>Registro deste aceite (IP, hash, timestamp)</td>
            <td>Prova jurídica da contratação e consentimento</td>
            <td>Art. 16, I (obrigação legal)</td>
            <td><strong>10 anos (imutável)</strong></td>
        </tr>
    </table>

    <h2>13. Responsabilidade pelo Tratamento de Dados de Clientes</h2>
    <p>
        O Contratante é <strong>controlador de dados</strong> dos clientes de sua loja. A IIT atua como
        <strong>operadora de dados</strong>, conforme DPA anexado a este Contrato.
    </p>
    <p>
        O Contratante é responsável por:
    </p>
    <ul>
        <li>Obter consentimento dos clientes para coleta de dados (conforme LGPD Art. 7º, I)</li>
        <li>Informar sobre tratamento de dados em sua política de privacidade</li>
        <li>Responder a requisições de direitos de dados (acesso, exclusão, portabilidade)</li>
        <li>Notificar à ANPD sobre incidentes de segurança em até 72 horas</li>
    </ul>

    <h2>14. Direitos do Titular de Dados (Art. 18 LGPD)</h2>
    <p>O Contratante possui os seguintes direitos, exercíveis via <strong>dpo@institutoitinerante.com.br</strong>
    (resposta em até 15 dias úteis):</p>
    <ul>
        <li><strong>Acesso:</strong> obter cópia dos dados pessoais tratados</li>
        <li><strong>Correção:</strong> atualizar dados incompletos ou desatualizados</li>
        <li><strong>Exclusão:</strong> solicitar eliminação de dados (ressalvados dados de aceite contratual e obrigações legais)</li>
        <li><strong>Portabilidade:</strong> exportar catálogo, vendas e metadados em formato JSON/CSV</li>
        <li><strong>Oposição:</strong> revogar consentimento para uso de dados em analytics</li>
    </ul>

    <h3>14.1. Retenção de Dados</h3>
    <ul>
        <li><strong>Dados de uso da plataforma:</strong> 6 meses após cancelamento</li>
        <li><strong>Dados fiscais (vendas, NFS-e, pagamentos):</strong> 10 anos (CTN Art. 174)</li>
        <li><strong>Registro de aceite contratual:</strong> 10 anos (imutável, obrigação legal)</li>
    </ul>

    <h3>14.2. Anonimização</h3>
    <p>
        Após a exclusão dos dados pessoais, dados de vendas e analytics (sem associação ao usuário) serão <strong>anonimizados</strong>
        e poderão ser mantidos para fins estatísticos agregados, sem possibilidade de reidentificação do titular.
    </p>

    <h2>15. Limitação de Responsabilidade</h2>
    <p>
        A IIT <strong>não se responsabiliza</strong> por:
    </p>
    <ul>
        <li>Alterações ou descontinuação de funcionalidades de gateways de pagamento (Asaas, Stripe)</li>
        <li>Falhas nos gateways de pagamento (charged-back, recusa de transação, limite de conta)</li>
        <li>Interrupções causadas por terceiros (ISPs, provedores de cloud, ataques DDoS legítimos à plataforma)</li>
        <li>Conformidade fiscal do Lojista (é responsabilidade do Lojista estar em dia com impostos)</li>
        <li>Danos causados por conteúdo ilícito publicado pelo Lojista</li>
        <li>Danos indiretos, lucros cessantes, danos morais (ressalvado o direito do consumidor conforme CDC)</li>
    </ul>

    <h2>16. Segurança e Conformidade</h2>
    <p>
        A IIT implementa as seguintes medidas técnicas e organizacionais:
    </p>
    <ul>
        <li>Transmissão de dados via HTTPS/TLS 1.3</li>
        <li>Criptografia de dados em repouso (AES-256)</li>
        <li>Autenticação via OAuth 2.0 (não armazenamento de senhas em texto claro)</li>
        <li>Infraestrutura em rede privada (Kubernetes, VLAN segregada)</li>
        <li>Backup diário dos dados do Contratante</li>
        <li>Logs de auditoria imutáveis com hash chain</li>
        <li>WAF (Web Application Firewall) contra ataques conhecidos (OWASP Top 10)</li>
    </ul>

    <h2>17. Compartilhamento de Dados com Terceiros</h2>
    <p>A IIT <strong>não comercializa dados pessoais</strong>. Compartilhamento ocorre apenas para:</p>
    <ul>
        <li><strong>Gateways de pagamento (Asaas/Stripe):</strong> dados mínimos necessários para processamento de transações</li>
        <li><strong>Resend:</strong> e-mail transacional de notificações de pedidos</li>
        <li><strong>Cloudflare:</strong> CDN e proteção de rede (dados de tráfego anônimos)</li>
        <li><strong>Autoridades legais:</strong> quando exigido por lei ou ordem judicial</li>
    </ul>

    <h2>18. Vigência e Denúncia</h2>
    <p>
        Este contrato tem vigência por período indeterminado (mês a mês ou anualmente conforme plano).
        <strong>Cancelamento imediato:</strong> O Contratante pode cancelar a qualquer momento pela plataforma ou e-mail.
        <strong>Cancelamento pela IIT:</strong> A IIT pode encerrar a conta por violação grave dos termos
        (venda de produtos ilícitos, conteúdo ofensivo, abuso da plataforma), com aviso prévio de 30 dias,
        exceto por ilicitude comprovada ou risco de segurança.
    </p>

    <h2>19. Alterações do Contrato</h2>
    <p>
        A IIT poderá atualizar este Termo com aviso prévio de <strong>30 (trinta) dias</strong> por e-mail.
        Alterações substanciais ao escopo de tratamento de dados ou modelo de negócio exigirão novo aceite eletrônico.
    </p>

    <h2>20. Contato — Encarregado de Dados (DPO)</h2>
    <p>
        Para exercer direitos de dados, esclarecer dúvidas ou reportar problemas:<br>
        <strong>E-mail DPO:</strong> dpo@institutoitinerante.com.br<br>
        <strong>Suporte técnico:</strong> suporte@institutoitinerante.com.br<br>
        <strong>Faturamento:</strong> billing@institutoitinerante.com.br<br>
        <strong>Endereço:</strong> Salvador, BA — Brasil
    </p>

    <h2>21. Foro Competente</h2>
    <p>
        Fica eleito o foro da Comarca de <strong>Salvador/BA</strong> para dirimir questões oriundas deste Contrato,
        ressalvado ao Contratante (consumidor/PME) o direito de optar pelo foro de seu domicílio, conforme Art. 101, I do CDC.
    </p>

    <div class="aviso">
        <strong>Declaração do Contratante:</strong> Ao aceitar este termo, o Contratante/Lojista declara ter lido e compreendido
        todas as cláusulas, concordando expressamente com os termos de prestação do serviço StoreMake, tratamento de dados
        conforme LGPD, conformidade fiscal e compliance com legislação brasileira, e reconhecendo ter 18 (dezoito) anos ou mais
        ou ser representante legal autorizado da empresa.
    </div>

    <div class="assinatura">
        <p>
            <strong>CONTRATANTE (Lojista):</strong> {{business_name}}<br>
            <strong>CNPJ/CPF:</strong> {{business_cnpj}}<br>
            <strong>Representante:</strong> {{user_name}} (CPF {{user_cpf}})<br>
            <strong>E-mail:</strong> {{user_email}}
        </p>
        <p>
            <strong>CONTRATADA:</strong> Instituto Itinerante de Tecnologia<br>
            <strong>CNPJ:</strong> 64.826.421/0001-59<br>
            <strong>Inscrição Municipal:</strong> 01.066.635/001-19<br>
            <strong>E-mail:</strong> contato@institutoitinerante.com.br
        </p>
        <p style="margin-top: 28px; font-style: italic; color: #6b7280; font-size: 0.9rem;">
            Aceite eletrônico realizado em {{acceptance_date}} às {{acceptance_time}}<br>
            IP de origem: {{user_ip}} · Dispositivo: {{user_agent}}<br>
            Hash do documento (SHA-256): {{content_hash}}<br>
            Hash anterior na cadeia: {{prev_hash}}<br>
            <br>
            Fundamentação jurídica: MP 2.200-2/2001 (assinatura eletrônica simples),<br>
            Lei 14.063/2020, Lei 13.709/2018 (LGPD), Lei 12.965/2014 (Marco Civil),<br>
            CDC Art. 49, CTN Art. 174 (obrigações fiscais)
        </p>
    </div>

    <div class="rodape">
        Documento gerado automaticamente pelo contract-service v1.0.0.<br>
        Este contrato possui validade jurídica nos termos da Lei 14.063/2020.<br>
        Versão do template: storemake-1.0.0 · Instituto Itinerante de Tecnologia © {{contract_year}}
    </div>

</body>
</html>',
    false,
    true
) ON CONFLICT (product_type, version) DO NOTHING;
