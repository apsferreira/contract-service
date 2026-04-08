-- LEG-09: Corrigir base legal Art. 7º, II → Art. 7º, V (execução de contrato)
-- LEG-07: Corrigir retenção 15 dias → 30 dias
-- LEG-08: Corrigir retenção de logs IP 90 dias → 180 dias (Marco Civil Art. 15)

UPDATE contract_templates
SET content_html = REPLACE(
    REPLACE(
        REPLACE(content_html, 'Art. 7º, II (contrato)', 'Art. 7º, V (contrato)'),
        'exportável até 15 dias após cancelamento', 'exportável até 30 dias após cancelamento'
    ),
    '<td>90 dias</td>', '<td>180 dias</td>'
)
WHERE product_type = 'socialmake';
