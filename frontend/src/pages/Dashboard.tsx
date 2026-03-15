import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/card';
import {
  FileSignature,
  FileText,
  CheckCircle,
  Clock,
  Shield
} from 'lucide-react';

export function Dashboard() {
  // Mock data - would come from API
  const stats = {
    totalContracts: 2847,
    acceptanceRate: 94.2,
    activeTemplates: 8,
    pendingAcceptance: 23,
    expiredContracts: 5,
    averageAcceptanceTime: '2.3 hours',
  };

  const recentContracts = [
    {
      id: '1',
      user_id: 'user-123',
      product_type: 'brio',
      template_version: '1.2',
      status: 'accepted',
      created_at: '2026-03-15T08:30:00Z',
      expires_at: '2026-03-15T09:30:00Z',
      accepted_at: '2026-03-15T08:45:00Z',
    },
    {
      id: '2', 
      user_id: 'user-456',
      product_type: 'premium',
      template_version: '2.0',
      status: 'pending',
      created_at: '2026-03-15T08:25:00Z',
      expires_at: '2026-03-15T09:25:00Z',
    },
    {
      id: '3',
      user_id: 'user-789',
      product_type: 'brio',
      template_version: '1.2', 
      status: 'expired',
      created_at: '2026-03-15T07:00:00Z',
      expires_at: '2026-03-15T08:00:00Z',
    }
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Overview of contract service performance and activity
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Contracts
            </CardTitle>
            <FileSignature className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalContracts.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">↗ +8%</span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Acceptance Rate
            </CardTitle>
            <CheckCircle className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.acceptanceRate}%</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">↗ +2.1%</span> from last week
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Active Templates
            </CardTitle>
            <FileText className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.activeTemplates}</div>
            <p className="text-xs text-muted-foreground">
              2 updated this week
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Pending Acceptance
            </CardTitle>
            <Clock className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.pendingAcceptance}</div>
            <p className="text-xs text-muted-foreground">
              Avg: {stats.averageAcceptanceTime}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Contract Activity</CardTitle>
          <CardDescription>
            Latest contract generations and acceptances
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {recentContracts.map((contract) => (
              <div key={contract.id} className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex items-center space-x-4">
                  <div className="flex-shrink-0">
                    <FileSignature className="h-5 w-5 text-green-600" />
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {contract.product_type.charAt(0).toUpperCase() + contract.product_type.slice(1)} Contract
                    </p>
                    <p className="text-sm text-gray-500">
                      User: {contract.user_id} • Version: {contract.template_version}
                    </p>
                    <p className="text-xs text-gray-400">
                      Expires: {new Date(contract.expires_at).toLocaleString()}
                    </p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    contract.status === 'accepted'
                      ? 'bg-green-100 text-green-800'
                      : contract.status === 'expired'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {contract.status}
                  </span>
                  <span className="text-sm text-gray-500">
                    {new Date(contract.created_at).toLocaleTimeString()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Security & Integrity Status */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Shield className="mr-2 h-5 w-5 text-green-600" />
            Hash Chain Integrity
          </CardTitle>
          <CardDescription>
            Blockchain-like audit trail verification status
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center p-4 border rounded bg-green-50">
              <CheckCircle className="h-8 w-8 text-green-600 mx-auto mb-2" />
              <p className="text-2xl font-bold text-green-700">100%</p>
              <p className="text-sm text-green-600">Hash Chain Intact</p>
            </div>
            <div className="text-center p-4 border rounded">
              <Shield className="h-8 w-8 text-blue-600 mx-auto mb-2" />
              <p className="text-2xl font-bold">SHA-256</p>
              <p className="text-sm text-gray-600">Encryption Standard</p>
            </div>
            <div className="text-center p-4 border rounded">
              <FileSignature className="h-8 w-8 text-purple-600 mx-auto mb-2" />
              <p className="text-2xl font-bold">2,847</p>
              <p className="text-sm text-gray-600">Signed Contracts</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}