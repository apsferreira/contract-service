-- Migration: 009_update_socialmake_signature_block.sql
-- Description: Remove campos de assinatura digital do template pré-aceite SocialMake.
-- IP, hash e dispositivo são preenchidos pelo AcceptContract e inseridos como {{signature_block}}.
-- Remove "(assinatura eletrônica simples)" do texto jurídico.

UPDATE contract_templates
SET content_html = REPLACE(
    content_html,
    E'IP de origem: {{user_ip}} \u00b7 Dispositivo: {{user_agent}}<br>\n            Hash do documento (SHA-256): {{content_hash}}<br>\n            Hash anterior na cadeia: {{prev_hash}}<br>\n            <br>\n            Fundamenta\u00e7\u00e3o jur\u00eddica: MP 2.200-2/2001 (assinatura eletr\u00f4nica simples),',
    E'{{signature_block}}<br>\n            Fundamenta\u00e7\u00e3o jur\u00eddica: MP 2.200-2/2001,'
)
WHERE product_type = 'socialmake' AND version = '1.0.0';
