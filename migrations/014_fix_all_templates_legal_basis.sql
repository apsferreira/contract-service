-- BKL-017: Corrigir base legal Art. 7º, II → Art. 7º, V em TODOS os templates
-- A migration 010 corrigiu apenas socialmake; esta corrige libri, nitro, storemake e LGPD templates
-- Art. 7º, II = obrigação legal (incorreto para contratos de serviço)
-- Art. 7º, V = execução de contrato (correto)

UPDATE contract_templates
SET content_html = REPLACE(
    REPLACE(content_html, 'Art. 7º, II (contrato)', 'Art. 7º, V (contrato)'),
    'Art. 7º, II (execução de contrato)', 'Art. 7º, V (execução de contrato)'
)
WHERE product_type IN ('libri', 'nitro', 'storemake', 'libri_lgpd', 'nitro_lgpd')
  AND content_html LIKE '%Art. 7º, II%';
