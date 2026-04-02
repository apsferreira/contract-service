-- Migration: 009_update_socialmake_signature_block.sql
-- Description: Remove campos informativos pré-aceite do template SocialMake.
-- Substitui textos descritivos por {{signature_block}} preenchido no AcceptContract.
-- Remove "(assinatura eletrônica simples)" do texto jurídico.
-- Aplicada manualmente em produção em 2026-04-02.

-- Passo 1: Substitui "IP de origem e dispositivo serão registrados..." por {{signature_block}}
UPDATE contract_templates
SET content_html = REPLACE(
    content_html,
    'IP de origem e dispositivo serão registrados automaticamente ao aceitar<br>',
    '{{signature_block}}<br>'
)
WHERE product_type = 'socialmake' AND version = '1.0.0';

-- Passo 2: Remove "(assinatura eletrônica simples)"
UPDATE contract_templates
SET content_html = REPLACE(
    content_html,
    'Fundamentação jurídica: MP 2.200-2/2001 (assinatura eletrônica simples),',
    'Fundamentação jurídica: MP 2.200-2/2001,'
)
WHERE product_type = 'socialmake' AND version = '1.0.0';

-- Passo 3: Remove linhas de hash descritivas (regex para ignorar whitespace)
UPDATE contract_templates
SET content_html = regexp_replace(
    content_html,
    'Hash do documento será calculado automaticamente<br>\s+Hash da cadeia será vinculado automaticamente<br>\s+<br>\s+',
    '',
    'g'
)
WHERE product_type = 'socialmake' AND version = '1.0.0';
