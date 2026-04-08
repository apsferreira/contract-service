-- Fix: remove "R$ " duplicado no template do contrato SocialMake.
-- A variável {{price}} já vem formatada como "R$ 39" do frontend (formatPrice).
-- O template tinha "R$ {{price}}" resultando em "R$ R$ 39".

UPDATE contract_templates
SET content_html = REPLACE(
    REPLACE(content_html, 'R$ {{price}}/mês', '{{price}}/mês'),
    'R$ {{price}}</strong>', '{{price}}</strong>'
)
WHERE product_type = 'socialmake';
