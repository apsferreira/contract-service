import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/card';
import { Button } from '@/components/button';
import {
  BarChart3,
  FileSignature,
  Clock,
  Calendar,
  Filter,
  AlertTriangle,
  CheckCircle
} from 'lucide-react';

export function Analytics() {
  // Mock data for contract analytics
  const metrics = {
    acceptanceRates: [
      { product_type: 'brio', rate: 96.8, contracts: 450 },
      { product_type: 'premium', rate: 94.2, contracts: 230 },
      { product_type: 'basic', rate: 98.1, contracts: 120 },
    ],
    timeToAccept: [
      { timeRange: '0-1h', count: 180, percentage: 60 },
      { timeRange: '1-6h', count: 90, percentage: 30 },
      { timeRange: '6-24h', count: 24, percentage: 8 },
      { timeRange: '24h+', count: 6, percentage: 2 },
    ],
    expirationAnalysis: [
      { reason: 'User never opened', count: 25, percentage: 45.5 },
      { reason: 'Opened but not accepted', count: 15, percentage: 27.3 },
      { reason: 'Technical issues', count: 8, percentage: 14.5 },
      { reason: 'Customer changed mind', count: 7, percentage: 12.7 },
    ],
    monthlyTrends: [
      { month: 'Jan', generated: 320, accepted: 298, expired: 15 },
      { month: 'Feb', generated: 380, accepted: 356, expired: 18 },
      { month: 'Mar', generated: 450, accepted: 425, expired: 12 },
    ]
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Contract Analytics</h1>
          <p className="mt-2 text-gray-600">
            Performance insights and acceptance analytics
          </p>
        </div>
        <div className="flex space-x-3">
          <Button variant="outline" size="sm">
            <Calendar className="mr-2 h-4 w-4" />
            Last 30 days
          </Button>
          <Button variant="outline" size="sm">
            <Filter className="mr-2 h-4 w-4" />
            Filter
          </Button>
        </div>
      </div>

      {/* Key Performance Indicators */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Avg Acceptance Rate
            </CardTitle>
            <CheckCircle className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">96.4%</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">↗ +2.1%</span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Avg Time to Accept
            </CardTitle>
            <Clock className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">2.3h</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">↘ -15min</span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Expiration Rate
            </CardTitle>
            <AlertTriangle className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">3.6%</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">↘ -0.8%</span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Re-acceptance Required
            </CardTitle>
            <FileSignature className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">45</div>
            <p className="text-xs text-muted-foreground">
              Due to template updates
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Acceptance Rates by Product */}
        <Card>
          <CardHeader>
            <CardTitle>Acceptance Rates by Product</CardTitle>
            <CardDescription>
              Contract acceptance rates across different product types
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {metrics.acceptanceRates.map((product, index) => (
                <div key={index} className="flex items-center justify-between p-3 border rounded">
                  <div>
                    <p className="font-medium text-sm capitalize">{product.product_type}</p>
                    <p className="text-xs text-gray-500">{product.contracts} contracts</p>
                  </div>
                  <div className="flex items-center space-x-3">
                    <div className="w-20 bg-gray-200 rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full ${
                          product.rate >= 96 ? 'bg-green-500' : 
                          product.rate >= 90 ? 'bg-yellow-500' : 'bg-red-500'
                        }`}
                        style={{ width: `${product.rate}%` }}
                      />
                    </div>
                    <span className={`text-sm font-medium ${
                      product.rate >= 96 ? 'text-green-600' : 
                      product.rate >= 90 ? 'text-yellow-600' : 'text-red-600'
                    }`}>
                      {product.rate}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Time to Accept Distribution */}
        <Card>
          <CardHeader>
            <CardTitle>Time to Accept Distribution</CardTitle>
            <CardDescription>
              How quickly users accept contracts after generation
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {metrics.timeToAccept.map((timeSlot, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex-1">
                    <p className="text-sm font-medium">{timeSlot.timeRange}</p>
                    <div className="mt-1 bg-gray-200 rounded-full h-2">
                      <div 
                        className="bg-blue-500 h-2 rounded-full"
                        style={{ width: `${timeSlot.percentage}%` }}
                      />
                    </div>
                  </div>
                  <div className="ml-4 text-right">
                    <p className="text-sm font-medium">{timeSlot.count}</p>
                    <p className="text-xs text-gray-500">{timeSlot.percentage}%</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Monthly Trends Chart Placeholder */}
      <Card>
        <CardHeader>
          <CardTitle>Monthly Contract Trends</CardTitle>
          <CardDescription>
            Contract generation, acceptance, and expiration trends
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded border-2 border-dashed border-gray-300">
            <div className="text-center">
              <BarChart3 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-sm text-gray-500">Chart component would go here</p>
              <p className="text-xs text-gray-400 mt-2">
                Line chart showing monthly trends in contract activity
              </p>
            </div>
          </div>
          {/* Simple data display for wireframe */}
          <div className="mt-4 grid grid-cols-3 gap-4 text-sm">
            {metrics.monthlyTrends.map((month, index) => (
              <div key={index} className="text-center p-3 border rounded">
                <p className="font-medium text-gray-700 mb-2">{month.month} 2026</p>
                <div className="space-y-1">
                  <div className="text-blue-600">📝 {month.generated} generated</div>
                  <div className="text-green-600">✅ {month.accepted} accepted</div>
                  <div className="text-red-600">⏰ {month.expired} expired</div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Expiration Analysis */}
      <Card>
        <CardHeader>
          <CardTitle>Contract Expiration Analysis</CardTitle>
          <CardDescription>
            Common reasons why contracts expire without acceptance
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              {metrics.expirationAnalysis.map((reason, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex-1">
                    <p className="text-sm font-medium">{reason.reason}</p>
                    <div className="mt-1 bg-gray-200 rounded-full h-2">
                      <div 
                        className="bg-red-500 h-2 rounded-full"
                        style={{ width: `${reason.percentage}%` }}
                      />
                    </div>
                  </div>
                  <div className="ml-4 text-right">
                    <p className="text-sm font-medium">{reason.count}</p>
                    <p className="text-xs text-gray-500">{reason.percentage}%</p>
                  </div>
                </div>
              ))}
            </div>
            
            <div className="border rounded p-4 bg-orange-50">
              <h4 className="font-medium text-orange-800 mb-2">Optimization Recommendations</h4>
              <ul className="text-sm text-orange-700 space-y-1">
                <li>• Send reminder emails at 50% expiry time</li>
                <li>• Simplify contract language for better comprehension</li>
                <li>• Add progress indicators to guide users</li>
                <li>• Extend expiry time for complex contracts</li>
                <li>• Implement auto-save for partial acceptances</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}