import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { 
  Search, 
  Filter, 
  FileSignature,
  RefreshCw,
  AlertCircle,
  CheckCircle,
  Clock,
  XCircle,
  Eye,
  Download,
  Shield,
  Hash
} from 'lucide-react';
import { getStatusColor, formatDate } from '@/lib/utils';

export function Contracts() {
  const [selectedStatus, setSelectedStatus] = useState<'all' | 'pending' | 'accepted' | 'expired' | 'revoked'>('all');
  const [selectedProduct, setSelectedProduct] = useState<'all' | 'brio' | 'premium' | 'basic'>('all');

  // Mock contracts data
  const contracts = [
    {
      id: '1',
      user_id: 'user-123',
      product_type: 'brio',
      template_id: 'template-1',
      template_version: '1.2',
      content_hash: 'sha256:abc123...',
      variables: { user_name: 'João Silva', plan_name: 'Brio Premium', price: 'R$ 299/mês' },
      status: 'accepted',
      expires_at: '2026-03-15T09:30:00Z',
      pdf_path: '/contracts/user-123-brio-v1.2.pdf',
      pdf_generated_at: '2026-03-15T08:45:30Z',
      created_at: '2026-03-15T08:30:00Z',
      updated_at: '2026-03-15T08:45:30Z',
      acceptance_ip: '192.168.1.100',
      signature_hash: 'sha256:def456...'
    },
    {
      id: '2',
      user_id: 'user-456',
      product_type: 'premium',
      template_id: 'template-2',
      template_version: '2.0',
      content_hash: 'sha256:ghi789...',
      variables: { user_name: 'Maria Santos', plan_name: 'Premium Pro', price: 'R$ 599/mês' },
      status: 'pending',
      expires_at: '2026-03-15T09:25:00Z',
      pdf_path: null,
      pdf_generated_at: null,
      created_at: '2026-03-15T08:25:00Z',
      updated_at: '2026-03-15T08:25:00Z',
      acceptance_ip: null,
      signature_hash: null
    },
    {
      id: '3',
      user_id: 'user-789',
      product_type: 'brio',
      template_id: 'template-1',
      template_version: '1.1',
      content_hash: 'sha256:jkl012...',
      variables: { user_name: 'Pedro Costa', plan_name: 'Brio Basic', price: 'R$ 199/mês' },
      status: 'expired',
      expires_at: '2026-03-15T08:00:00Z',
      pdf_path: null,
      pdf_generated_at: null,
      created_at: '2026-03-15T07:00:00Z',
      updated_at: '2026-03-15T08:00:00Z',
      acceptance_ip: null,
      signature_hash: null
    },
    {
      id: '4',
      user_id: 'user-012',
      product_type: 'basic',
      template_id: 'template-3',
      template_version: '1.0',
      content_hash: 'sha256:mno345...',
      variables: { user_name: 'Ana Oliveira', plan_name: 'Basic Plan', price: 'R$ 99/mês' },
      status: 'accepted',
      expires_at: '2026-03-15T10:15:00Z',
      pdf_path: '/contracts/user-012-basic-v1.0.pdf',
      pdf_generated_at: '2026-03-15T09:20:15Z',
      created_at: '2026-03-15T09:15:00Z',
      updated_at: '2026-03-15T09:20:15Z',
      acceptance_ip: '10.0.0.50',
      signature_hash: 'sha256:pqr678...'
    }
  ];

  const filteredContracts = contracts.filter(c => {
    if (selectedStatus !== 'all' && c.status !== selectedStatus) return false;
    if (selectedProduct !== 'all' && c.product_type !== selectedProduct) return false;
    return true;
  });

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'accepted':
        return <CheckCircle className="h-4 w-4 text-green-600" />;
      case 'expired':
        return <XCircle className="h-4 w-4 text-red-600" />;
      case 'pending':
        return <Clock className="h-4 w-4 text-yellow-600" />;
      case 'revoked':
        return <AlertCircle className="h-4 w-4 text-gray-600" />;
      default:
        return <AlertCircle className="h-4 w-4 text-gray-600" />;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Contracts</h1>
          <p className="mt-2 text-gray-600">
            Contract management and audit trail
          </p>
        </div>
        <div className="flex space-x-3">
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
          <Button variant="outline">
            <RefreshCw className="mr-2 h-4 w-4" />
            Refresh
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="space-y-4">
            <div className="flex space-x-4 items-center">
              <div className="flex-1 relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <input
                  type="text"
                  placeholder="Search by user ID, contract ID, or content..."
                  className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
              </div>
              <Button variant="outline" size="sm">
                <Filter className="mr-2 h-4 w-4" />
                Advanced Filter
              </Button>
            </div>

            <div className="flex flex-wrap gap-4">
              {/* Status Filter */}
              <div className="flex space-x-2">
                <span className="text-sm font-medium text-gray-700 py-2">Status:</span>
                {['all', 'pending', 'accepted', 'expired', 'revoked'].map((status) => (
                  <Button
                    key={status}
                    variant={selectedStatus === status ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setSelectedStatus(status as any)}
                  >
                    {status === 'all' ? 'All' : status.charAt(0).toUpperCase() + status.slice(1)}
                  </Button>
                ))}
              </div>

              {/* Product Filter */}
              <div className="flex space-x-2">
                <span className="text-sm font-medium text-gray-700 py-2">Product:</span>
                {['all', 'brio', 'premium', 'basic'].map((product) => (
                  <Button
                    key={product}
                    variant={selectedProduct === product ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setSelectedProduct(product as any)}
                  >
                    {product === 'all' ? 'All Products' : product.charAt(0).toUpperCase() + product.slice(1)}
                  </Button>
                ))}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Contracts List */}
      <Card>
        <CardHeader>
          <CardTitle>Contract History</CardTitle>
          <CardDescription>
            {filteredContracts.length} contracts found
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {filteredContracts.map((contract) => (
              <div 
                key={contract.id} 
                className="flex items-start justify-between p-6 border rounded-lg hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-start space-x-4 flex-1">
                  <div className="flex-shrink-0 mt-1">
                    <FileSignature className="h-6 w-6 text-green-600" />
                  </div>
                  
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-3">
                      <h3 className="font-medium text-gray-900">
                        {contract.product_type.charAt(0).toUpperCase() + contract.product_type.slice(1)} Contract
                      </h3>
                      {getStatusIcon(contract.status)}
                      <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(contract.status)}`}>
                        {contract.status}
                      </span>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm mb-3">
                      <div>
                        <p className="text-gray-600">User</p>
                        <p className="font-mono">{contract.user_id}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Template Version</p>
                        <p className="font-medium">{contract.template_version}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Variables</p>
                        <p className="truncate">{contract.variables.user_name} • {contract.variables.plan_name}</p>
                      </div>
                    </div>

                    {contract.status === 'accepted' && (
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm mb-3 p-3 bg-green-50 border border-green-200 rounded">
                        <div>
                          <p className="text-green-700 font-medium">Acceptance Details</p>
                          <p className="text-green-600">IP: {contract.acceptance_ip}</p>
                          {contract.pdf_path && (
                            <p className="text-green-600">PDF: Generated</p>
                          )}
                        </div>
                        <div>
                          <p className="text-green-700 font-medium flex items-center">
                            <Shield className="mr-1 h-4 w-4" />
                            Hash Chain
                          </p>
                          <p className="text-green-600 font-mono text-xs">
                            {contract.signature_hash?.substring(0, 20)}...
                          </p>
                        </div>
                      </div>
                    )}

                    <div className="flex items-center space-x-4 text-sm text-gray-500">
                      <div className="flex items-center">
                        <Hash className="mr-1 h-4 w-4" />
                        <span className="font-mono text-xs">{contract.content_hash.substring(0, 16)}...</span>
                      </div>
                      <div>
                        Created: {formatDate(contract.created_at)}
                      </div>
                      <div>
                        Expires: {formatDate(contract.expires_at)}
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex items-center space-x-2 ml-4">
                  <Button variant="ghost" size="sm">
                    <Eye className="h-4 w-4" />
                  </Button>
                  {contract.pdf_path && (
                    <Button variant="ghost" size="sm">
                      <Download className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Pagination Placeholder */}
          <div className="mt-6 flex items-center justify-between">
            <p className="text-sm text-gray-600">
              Showing 1-{filteredContracts.length} of {contracts.length} contracts
            </p>
            <div className="flex space-x-2">
              <Button variant="outline" size="sm" disabled>Previous</Button>
              <Button variant="outline" size="sm" disabled>Next</Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Contract Details Modal Wireframe */}
      <Card className="border-green-200 bg-green-50">
        <CardHeader>
          <CardTitle className="text-green-800">Contract Details Modal (Wireframe)</CardTitle>
          <CardDescription>
            Detailed view when clicking on a contract
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div className="space-y-2">
              <h4 className="font-medium">Basic Info:</h4>
              <ul className="space-y-1 text-gray-600">
                <li>• Full contract HTML content</li>
                <li>• Template variables rendered</li>
                <li>• Hash chain verification</li>
                <li>• Acceptance timeline</li>
                <li>• PDF download link (if generated)</li>
              </ul>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Security Features:</h4>
              <ul className="space-y-1 text-gray-600">
                <li>• Content hash verification</li>
                <li>• Signature hash validation</li>
                <li>• Previous hash reference</li>
                <li>• Immutability guarantee</li>
                <li>• Audit trail integrity check</li>
              </ul>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Actions Available:</h4>
              <ul className="space-y-1 text-gray-600">
                <li>• View rendered contract</li>
                <li>• Download PDF</li>
                <li>• Export contract data</li>
                <li>• Verify hash chain</li>
                <li>• View acceptance details</li>
              </ul>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Admin Actions:</h4>
              <ul className="space-y-1 text-gray-600">
                <li>• Mark as revoked (admin only)</li>
                <li>• Regenerate PDF</li>
                <li>• Force expiry extension</li>
                <li>• Export for legal review</li>
                <li>• Hash chain audit report</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}