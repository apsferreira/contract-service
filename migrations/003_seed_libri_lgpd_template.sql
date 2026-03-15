-- Migration: 003_seed_libri_lgpd_template.sql
-- Description: Termo de Consentimento LGPD — Libri (My Library)
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
    'libri',
    '1.0.0',
    '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termo de Consentimento e Política de Privacidade — Libri</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.7; max-width: 800px; margin: 0 auto; padding: 20px; color: #1a1a1a; }
        h1 { color: #92400e; border-bottom: 3px solid #f59e0b; padding-bottom: 12px; font-size: 1.6rem; }
        h2 { color: #78350f; margin-top: 32px; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 0.05em; }
        h3 { color: #1a1a1a; margin-top: 20px; font-size: 1rem; }
        .destaque { background: #fffbeb; border-left: 4px solid #f59e0b; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .aviso { background: #fef2f2; border-left: 4px solid #ef4444; padding: 16px 20px; border-radius: 0 8px 8px 0; margin: 20px 0; }
        .dados-info { background: #f0fdf4; border: 1px solid #86efac; padding: 15px; border-radius: 8px; margin: 16px 0; }
        table { width: 100%; border-collapse: collapse; margin: 16px 0; }
        th { background: #fef3c7; padding: 10px; text-align: left; border: 1px solid #d97706; font-size: 0.9rem; }
        td { padding: 10px; border: 1px solid #e5e7eb; font-size: 0.9rem; vertical-align: top; }
        .assinatura { margin-top: 50px; border-top: 2px solid #e5e7eb; padding-top: 24px; }
        ul { padding-left: 24px; }
        li { margin-bottom: 6px; }
        .rodape { font-size: 0.8rem; color: #6b7280; margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 16px; }
    </style>
</head>
<body>

    <h1>Termo de Consentimento e Uso de Dados<br>
        <small style="font-size: 0.7em; color: #78350f;">Libri — Plataforma de Gestão de Biblioteca Pessoal</small>
    </h1>

    <div class="destaque">
        <strong>Produto:</strong> Libri (My Library) · <strong>Versão:</strong> 1.0.0<br>
        <strong>Usuário:</strong> {{user_name}} · <strong>Email:</strong> {{user_email}}<br>
        <strong>Data do aceite:</strong> {{contract_date}}
    </div>

    <h2>1. Identificação das Partes</h2>
    <p>
        <strong>CONTROLADORA DE DADOS:</strong> Instituto Itinerante de Tecnologia (doravante "IIT"),
        CNPJ nº 00.000.000/0001-00, com sede em Salvador/BA,
        e-mail: contato@institutoitinerante.com.br.
    </p>
    <p>
        <strong>TITULAR DOS DADOS:</strong> {{user_name}}, portador(a) do e-mail {{user_email}},
        doravante denominado(a) "Usuário".
    </p>

    <h2>2. Descrição do Serviço</h2>
    <p>
        O <strong>Libri</strong> é uma plataforma gratuita de gestão de biblioteca pessoal que permite ao Usuário
        catalogar, organizar e acompanhar suas leituras. O serviço inclui:
    </p>
    <ul>
        <li>Cadastro e organização de livros por status (lendo, já li, quero ler)</li>
        <li>Registro de notas, impressões e avaliações pessoais</li>
        <li>Perfil público opcional (configurável pelo próprio usuário)</li>
        <li>Integração com ISBN para busca de metadados de livros</li>
        <li>Exportação da biblioteca pessoal</li>
    </ul>
    <p>O serviço é prestado de forma <strong>gratuita</strong>, sem cobrança ao Usuário.</p>

    <h2>3. Dados Pessoais Coletados e Finalidade</h2>

    <div class="dados-info">
        Conforme o Art. 7º da LGPD, o tratamento de dados pessoais é realizado com base no
        <strong>consentimento do titular</strong> (Art. 7º, I) e no <strong>legítimo interesse</strong>
        do controlador para prestação do serviço (Art. 7º, IX).
    </div>

    <table>
        <tr>
            <th>Dado Coletado</th>
            <th>Finalidade</th>
            <th>Base Legal (LGPD)</th>
            <th>Retenção</th>
        </tr>
        <tr>
            <td>Nome completo</td>
            <td>Identificação na plataforma e perfil público (se habilitado)</td>
            <td>Art. 7º, I (consentimento)</td>
            <td>Enquanto conta ativa + 5 anos</td>
        </tr>
        <tr>
            <td>Endereço de e-mail</td>
            <td>Autenticação (OTP), comunicações do serviço</td>
            <td>Art. 7º, II (contrato)</td>
            <td>Enquanto conta ativa + 5 anos</td>
        </tr>
        <tr>
            <td>Lista de livros e metadados</td>
            <td>Funcionalidade principal do serviço</td>
            <td>Art. 7º, II (execução de contrato)</td>
            <td>Enquanto conta ativa</td>
        </tr>
        <tr>
            <td>Notas e impressões pessoais</td>
            <td>Funcionalidade de anotações; exibição no perfil público se habilitado</td>
            <td>Art. 7º, I (consentimento explícito)</td>
            <td>Até solicitação de exclusão</td>
        </tr>
        <tr>
            <td>Endereço IP e User-Agent</td>
            <td>Segurança, prevenção a fraudes, logs de acesso</td>
            <td>Art. 7º, IX (legítimo interesse)</td>
            <td>90 dias</td>
        </tr>
        <tr>
            <td>Registro deste aceite (IP, hash, timestamp)</td>
            <td>Prova jurídica do consentimento</td>
            <td>Art. 16, I (obrigação legal)</td>
            <td><strong>10 anos (imutável)</strong></td>
        </tr>
    </table>

    <h2>4. Perfil Público — Consentimento Específico</h2>
    <p>
        O Libri oferece a opção de criar um <strong>perfil público</strong> acessível por qualquer pessoa
        via URL única (ex: libri.institutoitinerante.com.br/u/seu-slug). Esta funcionalidade:
    </p>
    <ul>
        <li>É <strong>desabilitada por padrão</strong> — o Usuário deve ativá-la conscientemente</li>
        <li>Permite configurar granularmente o que é exibido (livros lendo, já lidos, na fila, impressões)</li>
        <li>Pode ser <strong>desabilitada a qualquer momento</strong> nas configurações do perfil</li>
        <li>Não exibe o e-mail do Usuário em nenhuma circunstância</li>
    </ul>
    <div class="aviso">
        <strong>⚠ Atenção:</strong> Ao habilitar o perfil público e a exibição de impressões/notas,
        o Usuário consente expressamente que essas informações sejam acessíveis publicamente.
        Este consentimento pode ser revogado a qualquer momento nas configurações.
    </div>

    <h2>5. Compartilhamento de Dados com Terceiros</h2>
    <p>O IIT <strong>não vende, aluga ou comercializa</strong> dados pessoais. O compartilhamento
    ocorre apenas nos seguintes casos:</p>
    <ul>
        <li><strong>Open Library / Google Books API:</strong> consulta de metadados por ISBN (dados do livro, não do usuário)</li>
        <li><strong>Resend (serviço de e-mail transacional):</strong> envio de código OTP de autenticação</li>
        <li><strong>Cloudflare:</strong> proteção de rede e CDN (dados de rede, não conteúdo)</li>
        <li><strong>Autoridades legais:</strong> quando exigido por ordem judicial ou obrigação legal</li>
    </ul>

    <h2>6. Segurança dos Dados</h2>
    <p>O IIT adota as seguintes medidas técnicas e organizacionais:</p>
    <ul>
        <li>Autenticação por código OTP de uso único (sem senha armazenada)</li>
        <li>Transmissão exclusivamente via HTTPS/TLS 1.3</li>
        <li>Banco de dados PostgreSQL com acesso restrito por credenciais segregadas</li>
        <li>Infraestrutura em rede privada (Kubernetes/VLAN segmentada)</li>
        <li>Logs de auditoria imutáveis para registros de aceite contratual</li>
    </ul>

    <h2>7. Direitos do Titular dos Dados (Art. 18 da LGPD)</h2>
    <p>O Usuário possui os seguintes direitos, exercíveis a qualquer momento via
    contato@institutoitinerante.com.br:</p>
    <ul>
        <li><strong>Acesso:</strong> obter cópia dos dados pessoais tratados</li>
        <li><strong>Correção:</strong> atualizar dados incompletos ou desatualizados</li>
        <li><strong>Eliminação:</strong> solicitar exclusão dos dados (observada a exceção do Art. 16, I — dados transacionais e de aceite são mantidos por obrigação legal por 10 anos)</li>
        <li><strong>Portabilidade:</strong> exportar a biblioteca pessoal em formato CSV/JSON</li>
        <li><strong>Revogação do consentimento:</strong> desabilitar o perfil público ou excluir a conta</li>
        <li><strong>Informação:</strong> saber com quem os dados foram compartilhados</li>
    </ul>

    <h2>8. Prazo de Vigência e Cancelamento</h2>
    <p>
        O serviço Libri é prestado por prazo <strong>indeterminado</strong>. O Usuário pode
        encerrar sua conta a qualquer momento através das configurações da plataforma,
        sem ônus ou penalidade.
    </p>
    <p>
        Em caso de encerramento da conta: os dados de livros, notas e perfil serão excluídos
        em até <strong>30 dias</strong>. O registro deste aceite e os logs de auditoria serão
        mantidos por <strong>10 anos</strong> conforme obrigação legal (LGPD, Art. 16, I;
        Código Civil, Art. 205).
    </p>

    <h2>9. Direito de Arrependimento</h2>
    <p>
        Conforme o Art. 49 do Código de Defesa do Consumidor, o Usuário tem o prazo de
        <strong>7 (sete) dias corridos</strong>, a contar da data deste aceite, para desistir
        da contratação do serviço e solicitar a exclusão imediata de todos os dados,
        sem qualquer ônus.
    </p>

    <h2>10. Contato do Encarregado de Dados (DPO)</h2>
    <p>
        Para exercer seus direitos ou esclarecer dúvidas sobre o tratamento de dados:<br>
        <strong>E-mail:</strong> privacidade@institutoitinerante.com.br<br>
        <strong>Endereço:</strong> Salvador, BA — Brasil
    </p>

    <h2>11. Alterações neste Termo</h2>
    <p>
        O IIT poderá atualizar este Termo. Alterações substanciais serão comunicadas por e-mail
        com antecedência mínima de 15 dias, e um novo aceite será solicitado caso as mudanças
        ampliem o escopo do tratamento de dados.
    </p>

    <h2>12. Foro</h2>
    <p>
        Fica eleito o foro da Comarca de <strong>Salvador/BA</strong> para dirimir quaisquer
        questões oriundas deste Termo, conforme Art. 101, I do CDC (foro do domicílio do consumidor
        também é válido, a critério do Usuário).
    </p>

    <div class="assinatura">
        <p>
            <strong>TITULAR:</strong> {{user_name}}<br>
            <strong>E-mail:</strong> {{user_email}}
        </p>
        <p>
            <strong>CONTROLADORA:</strong> Instituto Itinerante de Tecnologia<br>
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
        Este aceite possui validade jurídica nos termos da Lei 14.063/2020 (assinatura eletrônica simples).<br>
        Versão do template: libri-1.0.0 · Instituto Itinerante de Tecnologia © {{contract_year}}
    </div>

</body>
</html>',
    false,
    true
) ON CONFLICT (product_type, version) DO NOTHING;
