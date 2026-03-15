-- Migration: 001_create_contract_tables.sql
-- Description: Create core tables for contract-service with hash chain audit log

-- Table: contract_templates
CREATE TABLE IF NOT EXISTS contract_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_type VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    content_html TEXT NOT NULL,
    requires_re_acceptance BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deactivated_at TIMESTAMP,
    UNIQUE(product_type, version)
);

CREATE INDEX idx_contract_templates_product_type_active ON contract_templates(product_type, is_active);

-- Table: contracts
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    product_type VARCHAR(255) NOT NULL,
    template_id UUID NOT NULL REFERENCES contract_templates(id),
    template_version VARCHAR(50) NOT NULL,
    content_html TEXT NOT NULL,
    content_hash VARCHAR(64) NOT NULL,
    variables JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    expires_at TIMESTAMP NOT NULL,
    pdf_path TEXT,
    pdf_generated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status CHECK (status IN ('pending', 'accepted', 'expired', 'revoked'))
);

CREATE INDEX idx_contracts_user_id ON contracts(user_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contracts_product_type ON contracts(product_type);
CREATE INDEX idx_contracts_template_id ON contracts(template_id);

-- Table: contract_signatures (IMMUTABLE — hash chain audit log)
CREATE TABLE IF NOT EXISTS contract_signatures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES contracts(id),
    user_id UUID NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NOT NULL,
    session_token_hash VARCHAR(64) NOT NULL,
    content_hash VARCHAR(64) NOT NULL,
    prev_hash VARCHAR(64),
    record_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contract_signatures_contract_id ON contract_signatures(contract_id);
CREATE INDEX idx_contract_signatures_user_id ON contract_signatures(user_id);
CREATE INDEX idx_contract_signatures_created_at ON contract_signatures(created_at);

-- SECURITY: REVOKE UPDATE/DELETE on contract_signatures to enforce immutability
-- This ensures the audit log cannot be tampered with
REVOKE UPDATE, DELETE ON contract_signatures FROM PUBLIC;

-- Update triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_contract_templates_updated_at
    BEFORE UPDATE ON contract_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
