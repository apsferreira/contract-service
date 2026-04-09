-- ANU-07: Adicionar suporte a periodo de cobranca (mensal/anual) no template SocialMake
-- A variavel {{billing_period}} sera preenchida pelo frontend ao criar o contrato

-- Adicionar clausula de compromisso anual no template existente
UPDATE contract_templates
SET content_html = REPLACE(
    content_html,
    'O cancelamento e imediato, sem necessidade de contato.',
    'O cancelamento e imediato, sem necessidade de contato. Para planos anuais, o cancelamento encerra a renovacao ao final do periodo contratado — nao ha cobranca proporcional nem reembolso do periodo restante.'
)
WHERE product_type = 'socialmake';
