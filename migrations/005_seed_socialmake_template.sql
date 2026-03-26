-- Migration: 005_seed_socialmake_template.sql
-- Description: Contrato de Assinatura SaaS — SocialMake
-- Autor: @legal (SOUL) · Data: 2026-03-26
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
    'socialmake',
    '1.0.0',
    '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contrato de Assinatura SaaS — SocialMake</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.7; max-width: 800px; margin: 0 auto; padding: 20px; color: #1a1a1a; }
        h1 { color: #1f2937; border-bottom: 3px solid #6366f1; padding-bottom: 12px; font-size: 1.6rem; }
        h2 { color: #374151; margin-top: 32px; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .destaque { background: #f0f4ff; border-left: 4px solid #6366f1; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .aviso { background: #fef2f2; border-left: 4px solid #ef4444; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .dados-info { background: #f0fdf4; border: 1px solid #86efac; padding: 15px; border-radius: 8px; margin: 16px 0; }
        table { width: 100%; border-collapse: collapse; margin: 16px 0; }
        th { background: #e0e7ff; padding: 10px; text-align: left; border: 1px solid #6366f1; font-size: 0.9rem; }
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
        <small style="font-size: 0.7em; color: #374151;">SocialMake — Automação Inteligente de Redes Sociais</small>
    </h1>

    <div class="destaque">
        <strong>Produto:</strong> SocialMake · <strong>Versão:</strong> 1.0.0<br>
        <strong>Contratante:</strong> {{user_name}} · <strong>Email:</strong> {{user_email}}<br>
        <strong>Plano:</strong> {{plan_name}} · <strong>Valor:</strong> R$ {{price}}/mês<br>
        <strong>Data da contratação:</strong> {{contract_date}}
    </div>

    <h2>1. Identificação das Partes</h2>
    <p>
        <strong>CONTRATADA:</strong> Instituto Itinerante de Tecnologia (doravante "IIT"),
        CNPJ nº 00.000.000/0001-00, com sede em Salvador/BA,
        e-mail: contato@institutoitinerante.com.br (doravante "Empresa").
    </p>
    <p>
        <strong>CONTRATANTE:</strong> {{user_name}}, portador(a) de {{user_document}},
        endereço de e-mail {{user_email}}, doravante denominado(a) "Usuário" ou "Cliente".
    </p>

    <h2>2. Objeto do Contrato</h2>
    <p>
        O presente contrato tem por objeto a prestação de serviços de automação de redes sociais através da plataforma
        <strong>SocialMake</strong>, um software como serviço (SaaS) que utiliza inteligência artificial para gerar conteúdo,
        agendar publicações e otimizar presença digital em redes sociais (LinkedIn, Instagram, Facebook).
    </p>

    <h2>3. Descrição do Serviço</h2>
    <p>
        O SocialMake fornece ao Contratante as seguintes funcionalidades no plano <strong>{{plan_name}}</strong>:
    </p>
    <ul>
        <li>Geração de copy (textos para publicações) com inteligência artificial</li>
        <li>Agendamento automático de publicações</li>
        <li>Integração nativa com LinkedIn, Instagram e Facebook (via OAuth)</li>
        <li>Dashboard de analytics e performance</li>
        <li>Biblioteca de templates personalizáveis</li>
        <li>Suporte por email (resposta em até 48h em dias úteis)</li>
    </ul>
    <div class="plano">
        <strong>Detalhes do Plano Contratado:</strong><br>
        Publicações/mês: {{plan_limit_posts}}<br>
        Contas de rede social: {{plan_limit_accounts}}<br>
        Integração com IA: {{plan_ai_enabled}}<br>
        Análise avançada: {{plan_analytics_level}}
    </div>

    <h2>4. Preço, Pagamento e Renovação Automática</h2>
    <p>
        O Contratante pagará o valor de <strong>R$ {{price}}</strong> ({{price_written}}) por mês,
        com renovação automática a cada período (mês/ano conforme plano).
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
        Conforme Art. 49 do Código de Defesa do Consumidor, o Contratante tem o direito de <strong>arrependimento no prazo de
        7 (sete) dias corridos</strong> a partir da data deste aceite, podendo solicitar o cancelamento imediato da assinatura
        com <strong>reembolso integral do valor pago</strong>, sem necessidade de justificativa.
    </p>
    <p>
        Para exercer este direito: enviar e-mail para <strong>suporte@institutoitinerante.com.br</strong> com assunto
        "ARREPENDIMENTO — SocialMake".
    </p>

    <h2>6. Cancelamento Após Período de Arrependimento</h2>
    <p>
        Após o período de 7 dias, o cancelamento pode ser feito a qualquer momento pela plataforma ou por e-mail.
        <strong>Não há multa rescisória.</strong> O acesso cessa ao final do ciclo de pagamento em curso.
    </p>

    <h2>7. Disponibilidade (SLA) e Suporte</h2>
    <p>
        A IIT se compromete com disponibilidade mínima de <strong>99% (noventa e nove por cento) por mês</strong>,
        calculada em tempo de funcionamento da API e dashboard.
    </p>
    <ul>
        <li><strong>Suporte por email:</strong> resposta em até 48 (quarenta e oito) horas em dias úteis</li>
        <li><strong>Manutenção programada:</strong> agendada com aviso mínimo de 24h via e-mail</li>
        <li><strong>Crédito por indisponibilidade:</strong> em caso de outage superior a 1%, crédito proporcional no próximo ciclo</li>
    </ul>

    <h2>8. Propriedade do Conteúdo</h2>
    <p>
        Toda a propriedade intelectual da <strong>plataforma SocialMake</strong> (software, código, design, templates,
        algoritmos de IA) permanece com a IIT. O Contratante recebe licença de uso pessoal, não transferível, limitado à
        duração do contrato.
    </p>
    <p>
        <strong>Conteúdo gerado:</strong> Posts, textos e materiais criados pelo Contratante na plataforma permanecem
        propriedade exclusiva do Contratante. A IIT obtém apenas a licença necessária para publicação e armazenamento
        enquanto o serviço estiver ativo.
    </p>

    <h2>9. Integração com Redes Sociais (OAuth)</h2>
    <p>
        O SocialMake utiliza autenticação OAuth 2.0 para integração segura com LinkedIn, Instagram e Facebook.
        O Contratante concorda que:
    </p>
    <ul>
        <li>Os tokens de acesso são armazenados de forma criptografada no banco de dados da IIT</li>
        <li>Os tokens não são compartilhados com terceiros sem consentimento expresso</li>
        <li>A IIT não possui acesso direto às contas das redes sociais do Contratante</li>
        <li>A revogação da integração removerá os tokens de acesso armazenados em até 24h</li>
    </ul>

    <h2>10. Dados Pessoais e LGPD</h2>

    <div class="dados-info">
        Conforme Lei 13.709/2018 (LGPD), o tratamento de dados pessoais é realizado com base na <strong>execução do contrato</strong>
        (Art. 7º, II) e <strong>legítimo interesse</strong> (Art. 7º, IX).
    </div>

    <table>
        <tr>
            <th>Dado Coletado</th>
            <th>Finalidade</th>
            <th>Base Legal</th>
            <th>Retenção</th>
        </tr>
        <tr>
            <td>Nome, email, documento</td>
            <td>Identificação, autenticação, contato</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa + 5 anos</td>
        </tr>
        <tr>
            <td>Dados de pagamento (processados via gateway)</td>
            <td>Cobrança da assinatura</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Conforme legislação tributária (5 anos)</td>
        </tr>
        <tr>
            <td>Tokens de acesso (LinkedIn/Instagram/Facebook)</td>
            <td>Integração e publicação nas redes sociais</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto integração ativa; 7 dias após revogação</td>
        </tr>
        <tr>
            <td>Posts, textos e dados de conteúdo</td>
            <td>Funcionalidade central: armazenamento e agendamento</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa; exportável até 15 dias após cancelamento</td>
        </tr>
        <tr>
            <td>Analytics (engagement, impressões)</td>
            <td>Relatórios de performance do Contratante</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa</td>
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

    <h2>11. Direitos do Titular de Dados (Art. 18 LGPD)</h2>
    <p>O Contratante possui os seguintes direitos, exercíveis via <strong>privacidade@institutoitinerante.com.br</strong>
    (resposta em até 15 dias úteis):</p>
    <ul>
        <li><strong>Acesso:</strong> obter cópia dos dados pessoais tratados</li>
        <li><strong>Correção:</strong> atualizar dados incompletos ou desatualizados</li>
        <li><strong>Eliminação:</strong> solicitar exclusão de dados (ressalvados dados de aceite contratual mantidos por lei)</li>
        <li><strong>Portabilidade:</strong> exportar posts, análises e metadados em formato JSON/CSV</li>
        <li><strong>Oposição:</strong> revogar consentimento para uso de dados de analytics</li>
    </ul>

    <h2>12. Exportação de Dados Pós-Cancelamento</h2>
    <p>
        Em caso de cancelamento da assinatura, o Contratante terá <strong>15 (quinze) dias</strong> para exportar seus dados
        (posts agendados, histórico, configurações) através da plataforma. Após este período, os dados serão excluídos permanentemente.
    </p>

    <h2>13. Limitação de Responsabilidade</h2>
    <p>
        A IIT <strong>não se responsabiliza</strong> por:
    </p>
    <ul>
        <li>Alterações, descontinuação ou limitações nas APIs de LinkedIn, Instagram ou Facebook (controladas pelos proprietários das plataformas)</li>
        <li>Decisões de rejeição, shadowban ou remoção de conteúdo pelas redes sociais (políticas e moderação das plataformas)</li>
        <li>Interrupções causadas por terceiros (ISPs, provedores de cloud, redes de CDN)</li>
        <li>Uso indevido da plataforma pelo Contratante (violação de termos das redes sociais, spam, etc.)</li>
        <li>Danos indiretos, lucros cessantes, danos morais (ressalvado o direito do consumidor conforme CDC)</li>
    </ul>

    <h2>14. Segurança e Conformidade</h2>
    <p>
        A IIT implementa as seguintes medidas técnicas e organizacionais:
    </p>
    <ul>
        <li>Transmissão de dados via HTTPS/TLS 1.3</li>
        <li>Criptografia de tokens de acesso em repouso</li>
        <li>Autenticação via OAuth 2.0 (não armazenamento de senhas)</li>
        <li>Infraestrutura em rede privada (Kubernetes, VLAN segregada)</li>
        <li>Backup diário dos dados do Contratante</li>
        <li>Logs de auditoria imutáveis com hash chain</li>
    </ul>

    <h2>15. Compartilhamento de Dados com Terceiros</h2>
    <p>A IIT <strong>não comercializa dados pessoais</strong>. Compartilhamento ocorre apenas para:</p>
    <ul>
        <li><strong>Redes sociais (LinkedIn/Instagram/Facebook):</strong> conforme solicitação do Contratante via OAuth</li>
        <li><strong>Provedores de IA:</strong> dados minimizados para geração de sugestões (sem PII quando possível)</li>
        <li><strong>Gateway de pagamento:</strong> processamento de cobranças (Stripe/PagSeguro/etc.)</li>
        <li><strong>Resend:</strong> e-mail transacional de notificações</li>
        <li><strong>Cloudflare:</strong> CDN e proteção de rede (dados de tráfego)</li>
        <li><strong>Autoridades legais:</strong> quando exigido por lei ou ordem judicial</li>
    </ul>

    <h2>16. Vigência e Denúncia</h2>
    <p>
        Este contrato tem vigência por período indeterminado (mês a mês ou anualmente conforme plano).
        <strong>Cancelamento imediato:</strong> O Contratante pode cancelar a qualquer momento pela plataforma ou e-mail.
        <strong>Cancelamento pela IIT:</strong> A IIT pode encerrar a conta por violação grave dos termos (spam, conteúdo ilícito, etc.),
        com aviso prévio de 30 dias, exceto por ilicitude comprovada.
    </p>

    <h2>17. Alterações do Contrato</h2>
    <p>
        A IIT poderá atualizar este Termo com aviso prévio de <strong>30 (trinta) dias</strong> por e-mail.
        Alterações substanciais ao escopo de tratamento de dados exigirão novo aceite eletrônico.
    </p>

    <h2>18. Contato — Encarregado de Dados (DPO)</h2>
    <p>
        Para exercer direitos de dados, esclarecer dúvidas ou reportar problemas:<br>
        <strong>E-mail:</strong> privacidade@institutoitinerante.com.br<br>
        <strong>Suporte técnico:</strong> suporte@institutoitinerante.com.br<br>
        <strong>Endereço:</strong> Salvador, BA — Brasil
    </p>

    <h2>19. Foro Competente</h2>
    <p>
        Fica eleito o foro da Comarca de <strong>Salvador/BA</strong> para dirimir questões oriundas deste Contrato,
        ressalvado ao Contratante (consumidor) o direito de optar pelo foro de seu domicílio, conforme Art. 101, I do CDC.
    </p>

    <div class="aviso">
        <strong>Declaração do Contratante:</strong> Ao aceitar este termo, o Contratante declara ter lido e compreendido
        todas as cláusulas, concordando expressamente com os termos de prestação do serviço SocialMake, tratamento de dados
        conforme LGPD, e reconhecendo ter 18 (dezoito) anos ou mais.
    </div>

    <div class="assinatura">
        <p>
            <strong>CONTRATANTE:</strong> {{user_name}}<br>
            <strong>Documento:</strong> {{user_document}}<br>
            <strong>E-mail:</strong> {{user_email}}
        </p>
        <p>
            <strong>CONTRATADA:</strong> Instituto Itinerante de Tecnologia<br>
            <strong>CNPJ:</strong> 00.000.000/0001-00<br>
            <strong>E-mail:</strong> contato@institutoitinerante.com.br
        </p>
        <p style="margin-top: 28px; font-style: italic; color: #6b7280; font-size: 0.9rem;">
            Aceite eletrônico realizado em {{acceptance_date}} às {{acceptance_time}}<br>
            IP de origem: {{user_ip}} · Dispositivo: {{user_agent}}<br>
            Hash do documento (SHA-256): {{content_hash}}<br>
            Hash anterior na cadeia: {{prev_hash}}<br>
            <br>
            Fundamentação jurídica: MP 2.200-2/2001 (assinatura eletrônica simples),<br>
            Lei 14.063/2020, Lei 13.709/2018 (LGPD), CDC Art. 49
        </p>
    </div>

    <div class="rodape">
        Documento gerado automaticamente pelo contract-service v1.0.0.<br>
        Este contrato possui validade jurídica nos termos da Lei 14.063/2020.<br>
        Versão do template: socialmake-1.0.0 · Instituto Itinerante de Tecnologia © {{contract_year}}
    </div>

</body>
</html>',
    false,
    true
) ON CONFLICT (product_type, version) DO NOTHING;
