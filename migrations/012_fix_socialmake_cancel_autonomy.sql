-- Fix: usuario tem autonomia para cancelar pelo painel, nao precisa enviar email.
-- Adiciona instrucao de cancelamento pelo painel antes da opcao de email.

UPDATE contract_templates
SET content_html = REPLACE(
    content_html,
    'enviar e-mail para <strong>suporte@institutoitinerante.com.br</strong> com assunto',
    'acesse o painel do SocialMake, va em <strong>Minha Assinatura</strong> e clique em <strong>Cancelar</strong>. O cancelamento e imediato, sem necessidade de contato. Alternativamente, envie e-mail para <strong>suporte@institutoitinerante.com.br</strong> com assunto'
)
WHERE product_type = 'socialmake';
