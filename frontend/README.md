# Contract Service Admin Dashboard

Admin dashboard for managing the Instituto Itinerante contract service, providing legal template management, contract analytics, and hash chain audit capabilities.

## Features

### 🏠 Dashboard Overview
- **Key Metrics**: Total contracts, acceptance rate, active templates, pending acceptances
- **Recent Activity**: Latest contract generations and acceptances
- **Security Status**: Hash chain integrity verification
- **Trend Indicators**: Performance changes from previous periods

### 📊 Analytics
- **Acceptance Analytics**: Contract acceptance rates by product type
- **Time Analysis**: Distribution of acceptance times
- **Expiration Analysis**: Reasons for contract expirations with recommendations
- **Monthly Trends**: Contract activity trends (placeholder for charts)
- **Performance KPIs**: Acceptance rates, average acceptance time, uptime

### 📋 Contract Template Management
- **Legal Template Editor**: Rich HTML editor for contract templates
- **Version Control**: Template versioning with activation controls
- **Product Type Management**: Templates organized by product (Brio, Premium, Basic)
- **Re-acceptance Workflow**: Force re-acceptance for major template changes
- **Usage Analytics**: Template performance and acceptance rates
- **Variable System**: Dynamic placeholder support (`{{user_name}}`, `{{plan_name}}`, etc.)

### 🔒 Contract Management & Audit
- **Contract History**: Complete audit trail with hash chain verification
- **Status Tracking**: Real-time contract status (pending, accepted, expired, revoked)
- **Security Features**: SHA-256 hash verification and blockchain-like audit trail
- **PDF Management**: Automated PDF generation and download
- **User Activity**: IP tracking and acceptance timestamps
- **Export Capabilities**: Legal compliance export features

## Tech Stack

- **Frontend**: React 19.2 + TypeScript
- **Styling**: Tailwind CSS + shadcn/ui components
- **Icons**: Lucide React (with security-focused icons)
- **Routing**: React Router v6
- **Build Tool**: Vite

## Project Structure

```
contract-admin/
├── src/
│   ├── components/
│   │   ├── ui/           # shadcn/ui base components
│   │   └── Layout.tsx    # App layout with sidebar
│   ├── lib/
│   │   └── utils.ts      # Shared utilities
│   ├── pages/
│   │   ├── Dashboard.tsx # Main dashboard overview
│   │   ├── Analytics.tsx # Contract analytics
│   │   ├── Templates.tsx # Template management
│   │   └── Contracts.tsx # Contract audit log
│   └── App.tsx          # Main app with routing
├── public/              # Static assets
├── index.html          # HTML entry point
└── package.json        # Dependencies
```

## Data Models

### Contract
```typescript
interface Contract {
  id: string;
  user_id: string;
  product_type: string;
  template_id: string;
  template_version: string;
  content_html: string;
  content_hash: string; // SHA-256
  variables: Record<string, any>;
  status: 'pending' | 'accepted' | 'expired' | 'revoked';
  expires_at: string; // 1 hour from creation
  pdf_path?: string;
  pdf_generated_at?: string;
  created_at: string;
  updated_at: string;
}
```

### Contract Template
```typescript
interface ContractTemplate {
  id: string;
  product_type: string;
  version: string;
  content_html: string;
  requires_re_acceptance: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  deactivated_at?: string;
}
```

### Contract Signature (Hash Chain)
```typescript
interface ContractSignature {
  id: string;
  contract_id: string;
  user_id: string;
  ip_address: string;
  content_hash: string; // SHA-256 of contract content
  prev_hash: string;    // Hash of previous signature
  record_hash: string;  // SHA-256 of this record
  created_at: string;   // Immutable timestamp
}
```

## Security & Hash Chain

### Blockchain-like Audit Trail
- **Immutable Records**: Database-level REVOKE prevents UPDATE/DELETE
- **Hash Chain**: Each signature references previous signature hash
- **Content Verification**: SHA-256 hash of contract content
- **Integrity Checking**: Complete chain validation
- **Tamper Detection**: Any modification breaks the chain

### Hash Chain Verification
```
Signature 1: record_hash = SHA256(contract_id + user_id + ip + content_hash + prev_hash + timestamp)
Signature 2: prev_hash = Signature1.record_hash
Signature N: prev_hash = SignatureN-1.record_hash
```

## Key Features Implemented

### Dashboard Components
- [x] Contract metrics with trend indicators
- [x] Recent contract activity feed
- [x] Hash chain integrity status
- [x] Security verification dashboard

### Analytics Views
- [x] Acceptance rate analysis by product type
- [x] Time-to-accept distribution charts
- [x] Expiration analysis with recommendations
- [x] Monthly trend placeholders for data visualization
- [x] Performance KPI dashboard

### Template Management
- [x] Contract template grid with versioning
- [x] Active/inactive status filtering
- [x] Rich HTML editor wireframe
- [x] Variable system documentation
- [x] Re-acceptance workflow indicators
- [x] Usage statistics display

### Contract Audit
- [x] Complete contract history
- [x] Multi-criteria filtering (status, product type)
- [x] Hash verification display
- [x] Security status indicators
- [x] PDF management interface
- [x] Admin action controls

## Wireframes & UI Patterns

### Status System
- **Accepted**: Green with checkmark icon + hash chain icon
- **Expired**: Red with X icon
- **Pending**: Yellow with clock icon
- **Revoked**: Gray with alert icon

### Color Coding
- **Primary**: Green (#22c55e) - contract and security focus
- **Success**: Green (#10b981) - accepted contracts
- **Warning**: Yellow (#f59e0b) - pending/expiring contracts
- **Error**: Red (#ef4444) - expired/failed contracts
- **Security**: Blue (#3b82f6) - hash chain and verification

### Security Indicators
- **Hash Chain Intact**: Green shield icon
- **Content Verified**: Green checkmark
- **PDF Available**: Download icon
- **Immutable Record**: Lock icon

## Development Setup

```bash
# Navigate to project
cd /projects/admin-dashboards/contract-admin

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## API Integration Points

### Contract Service Endpoints
- `GET /api/v1/contracts` - List contracts with filtering
- `GET /api/v1/contracts/{id}` - Get contract details
- `POST /api/v1/contracts` - Generate new contract
- `POST /api/v1/contracts/{id}/accept` - Accept contract
- `GET /api/v1/templates` - List contract templates
- `POST /api/v1/templates` - Create template
- `PUT /api/v1/templates/{id}` - Update template
- `POST /api/v1/templates/{id}/activate` - Activate template
- `GET /api/v1/admin/signatures/verify/{id}` - Verify hash chain

### Expected Data Sources
- Real-time contract status from contract-service
- Template usage and acceptance analytics
- Hash chain integrity verification
- PDF generation status
- User acceptance patterns

## Legal & Compliance Features

### Template Management
- **Version Control**: Strict versioning for legal compliance
- **Activation Control**: Only one template per product can be active
- **Re-acceptance Triggers**: Force re-acceptance for major changes
- **Audit Trail**: Complete history of template modifications
- **Legal Review**: Workflow for template approval

### Contract Security
- **Immutable Signatures**: Database-level immutability
- **Hash Chain Integrity**: Blockchain-like verification
- **Content Verification**: SHA-256 hash matching
- **IP Tracking**: Acceptance location logging
- **Timestamp Integrity**: Immutable acceptance timing

## Future Enhancements

### Planned Features
- [ ] Rich HTML template editor with legal clause library
- [ ] Template diff/comparison tool for version changes
- [ ] Bulk contract operations (expire, export)
- [ ] Advanced hash chain visualization
- [ ] Legal compliance reporting
- [ ] Integration with e-signature providers
- [ ] Contract renewal automation
- [ ] Customer-facing contract portal integration

### Security Enhancements
- [ ] Multi-signature contract approvals
- [ ] Hardware security module (HSM) integration
- [ ] Advanced audit reporting
- [ ] Compliance dashboard (LGPD, GDPR)
- [ ] Legal hold functionality

### Technical Improvements
- [ ] Real-time WebSocket updates for contract status
- [ ] Advanced PDF template customization
- [ ] Contract template inheritance
- [ ] Automated legal review workflows
- [ ] Integration testing for hash chain integrity

## Integration with Backend

This dashboard integrates with the contract-service backend at `/projects/contract-service/`. The service provides:

- **Hash Chain Security**: Blockchain-like immutable audit trail
- **Template Management**: Versioned legal templates with activation controls
- **Contract Generation**: Dynamic contract rendering with variables
- **PDF Generation**: Automated PDF creation post-acceptance
- **Expiration Management**: 1-hour contract expiry with validation
- **JWT Authentication**: Secure user-specific contract access

## Deployment Considerations

- **Security First**: Enhanced security headers for legal compliance
- **Audit Logging**: Complete administrative action logging
- **Role-Based Access**: Admin vs. operator permission levels
- **Legal Compliance**: LGPD/GDPR compliance features
- **High Availability**: Zero-downtime deployment for contract availability
- **Backup Strategy**: Immutable record backup and recovery
- **Hash Chain Monitoring**: Real-time integrity monitoring

## Integration with Checkout Service

The contract admin dashboard supports integration with the checkout-service workflow:

1. **Pre-Payment Validation**: Checkout requires valid signature_id
2. **Contract Dependency**: Payment blocked until contract acceptance
3. **Webhook Integration**: Contract acceptance triggers checkout notification
4. **Revenue Protection**: Legal agreement before payment processing

This ensures legal compliance and revenue protection for the Instituto Itinerante platform.