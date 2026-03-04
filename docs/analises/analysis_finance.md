# Analysis Finance — contract-service
**Versão:** 1.0 | **Data:** 2026-03-03 | **Autor:** @pm / IIT

---

## 1. Custo de Desenvolvimento

### Estimativa de Esforço

| Fase | Atividade | Dias dev |
|------|-----------|----------|
| Contrato embarcado Brio v1.0 | Schema + LocalContractService + PDF + endpoint aceite | 5 dias |
| Testes P0 | Validação do aceite, PDF, audit log | 2 dias |
| **Subtotal Fase 0** | | **7 dias (~1,5 semana)** |
| Contract-service dedicado v1.5 | Scaffold + migrations + todos endpoints | 5 dias |
| Migração de dados Brio → contracts_db | Migração + testes regressão + feature flag | 2 dias |
| Integração jiu-jitsu-academy | | 1 dia |
| **Subtotal Fase 1** | | **8 dias (~1,5 semana)** |
| **Total** | | **~3 semanas** |

### Custo de Oportunidade

Antonio é o principal desenvolvedor do IIT. 3 semanas de backend equivalem a ~3 semanas que **não** estão sendo usadas para avançar em jiu-jitsu-academy ou attend-agent.

**Mas:** sem contrato, o produto não pode ser lançado legalmente. Não é optativo.

---

## 2. Custo de Infraestrutura

### Homelab (custo atual: R$0 incremental)

| Componente | Já existe? | Custo adicional |
|-----------|-----------|-----------------|
| PostgreSQL (shared-infra-01) | ✅ | R$0 |
| MinIO (shared-infra-01) | ✅ | R$0 |
| K3s cluster | ✅ | R$0 |
| container contract-service | Novo | ~50MB RAM, <0,1 CPU — R$0 |

**Storage MinIO:**
- 200KB/contrato × 1.000 contratos/mês = 200MB/mês
- Em 10 anos = ~24GB → custo no homelab: R$0

**Custo total de infra:** **R$0** até escalar para VPS externa.

---

## 3. Risco de NÃO Ter Contrato

### Análise de Risco Legal

**Cenário:** IIT opera sem contrato formalizado.

| Risco | Probabilidade | Impacto Financeiro Estimado |
|-------|--------------|----------------------------|
| Usuário solicita reembolso sem base contratual | Alta | R$500–R$2.000 por caso (CDC art. 49) |
| Usuário questiona renovação automática | Alta | R$1.000–R$5.000 (PROCON + juizado) |
| Ação no juizado especial cível | Média (após 10+ usuários) | R$2.000–R$10.000 + honorários |
| Penalidade ANPD por ausência de base legal clara | Baixa (MVP) | R$50M (cap legal) — improvável no estágio atual |
| Dano reputacional | Alta se divulgado | Imensurável |

**Conclusão:** O primeiro litígio no juizado especial cível custa mais do que as 3 semanas de desenvolvimento do contract-service. É um investimento com ROI negativo em não fazer.

### CDC — Principais Exposições Sem Contrato

```
Art. 47: "As cláusulas contratuais serão interpretadas de maneira mais favorável ao consumidor."
→ Sem contrato escrito, qualquer ambiguidade beneficia o usuário (não o IIT).

Art. 49: Direito de arrependimento em 7 dias para contratos à distância.
→ Sem contrato, IIT não tem como documentar que informou o usuário sobre esse direito.

Art. 54: Contratos de adesão precisam de clareza e destaque em cláusulas limitativas.
→ Cláusulas de cancelamento, fidelidade e multa são nulas se não documentadas.
```

---

## 4. Assinatura Digital Certificada vs. Clique Simples

### Comparativo de Opções

| Modalidade | Validade Legal | Custo | Fricção UX | Recomendação |
|-----------|---------------|-------|------------|--------------|
| Clique "Li e aceito" (simples) | ✅ Lei 14.063/2020 art. 6° | R$0 | Mínima | ✅ MVP |
| DocuSign / SignNow | ✅ ICP-Brasil nível 1 | USD 10–25/mês (300 envelopes) | Baixa | v1.5 para contratos B2B |
| Certificado A1/A3 ICP-Brasil | ✅ Máxima validade | R$150–300/certificado/ano (usuário paga) | Alta | ❌ B2C inviável |
| Autenticação biométrica | ✅ Forte evidência | Custo de integração + LGPD complexo | Média | v2.0 se necessário |
| SMS OTP no aceite | ✅ Evidência adicional | R$0,05–0,10/SMS | Baixa | Considerar v1.5 |

### Análise de Custo-Benefício

**Clique Simples (MVP):**
- Custo: R$0
- Validade: suficiente para B2C por Lei 14.063/2020
- Risco residual: baixo se audit log for robusto
- **Recomendação: adotar no MVP**

**DocuSign/SignNow (v1.5, contratos B2B):**
- Custo: ~R$150/mês (300 contratos/mês)
- Quando faz sentido: contratos com academias (tenant) e restaurantes (tenant) — B2B
- Para B2C (usuário final): manter clique simples
- **Recomendação: avaliar quando tenant count > 20**

**SMS OTP como fator adicional:**
- Custo: R$50–200/mês (estimado 1.000–2.000 novos contratos/mês em 6 meses)
- Benefício: evidência adicional difícil de repudiar ("eu nunca assinei")
- **Recomendação: adicionar no v1.5 para contratos de valor > R$500/ano**

### Threshold de Valor por Modalidade

```
Contrato < R$100/mês  → Clique simples suficiente
Contrato R$100–500/mês → Clique simples + SMS OTP (v1.5)
Contrato > R$500/mês  → Avaliar assinatura avançada (B2B)
Contrato B2B (tenant)  → DocuSign ou equivalente
```

---

## 5. Projeção de Contratos Gerados

| Período | Produto | Contratos/mês | Total acumulado |
|---------|---------|--------------|-----------------|
| Q2 2026 | Brio | 100 | 100 |
| Q3 2026 | Brio + Jiu-Jitsu | 300 | 700 |
| Q4 2026 | + Food Marketplace | 600 | 2.500 |
| Q1 2027 | + Restaurant QR | 1.000 | 5.500 |

**Custo de armazenamento em Q1 2027:** ~1,1GB (5.500 × 200KB) → R$0 no homelab.
**Custo de infraestrutura do contrato-service:** R$0 incremental.

---

## 6. ROI do contract-service

```
Investimento:
  3 semanas de desenvolvimento → custo de oportunidade ~R$8.000 (tempo de Antonio)

Retorno:
  Evita o primeiro litígio (R$2.000–R$10.000)
  Habilita lançamento legal de todos os produtos IIT
  Evita multa PROCON/ANPD
  Aumenta confiança do usuário (NPS)
  Base para B2B escalável (contratos com tenants)

ROI estimado: Primeiro litígio evitado paga o desenvolvimento inteiro.
              Sem contract-service, nenhum produto pode ser lançado legalmente.
```

**Veredicto:** Não é um custo — é um requisito habilitador. O ROI é calculado como "custo de NÃO fazer".

