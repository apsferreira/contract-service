import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/card';
import { Button } from '@/components/button';
import {
  Plus,
  Search,
  Edit,
  Trash2,
  Eye,
  Copy,
  CheckCircle,
  AlertTriangle,
  Code
} from 'lucide-react';
import { formatDate } from '@/lib/utils';

export function Templates() {
  const [selectedStatus, setSelectedStatus] = useState<'all' | 'active' | 'inactive'>('all');

  // Mock contract templates data
  const templates = [
    {
      id: '1',
      product_type: 'brio',
      version: '1.2',
      content_html: '<div class="contract">...</div>',
      requires_re_acceptance: false,
      is_active: true,
      created_at: '2026-03-10T10:00:00Z',
      updated_at: '2026-03-10T10:00:00Z',
      deactivated_at: null,
      usage_count: 450,
      acceptance_rate: 96.8
    },
    {
      id: '2',
      product_type: 'premium',
      version: '2.0',
      content_html: '<div class="premium-contract">...</div>',
      requires_re_acceptance: true,
      is_active: true,
      created_at: '2026-03-08T15:30:00Z',
      updated_at: '2026-03-12T09:15:00Z',
      deactivated_at: null,
      usage_count: 230,
      acceptance_rate: 94.2
    },
    {
      id: '3',
      product_type: 'brio',
      version: '1.1',
      content_html: '<div class="legacy-contract">...</div>',
      requires_re_acceptance: false,
      is_active: false,
      created_at: '2026-02-15T14:20:00Z',
      updated_at: '2026-03-10T10:00:00Z',
      deactivated_at: '2026-03-10T10:00:00Z',
      usage_count: 1200,
      acceptance_rate: 89.5
    },
    {
      id: '4',
      product_type: 'basic',
      version: '1.0',
      content_html: '<div class="basic-contract">...</div>',
      requires_re_acceptance: false,
      is_active: true,
      created_at: '2026-03-01T11:45:00Z',
      updated_at: '2026-03-01T11:45:00Z',
      deactivated_at: null,
      usage_count: 120,
      acceptance_rate: 98.1
    }
  ];

  const filteredTemplates = selectedStatus === 'all' 
    ? templates 
    : selectedStatus === 'active'
    ? templates.filter(t => t.is_active)
    : templates.filter(t => !t.is_active);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Contract Templates</h1>
          <p className="mt-2 text-gray-600">
            Manage legal contract templates with versioning
          </p>
        </div>
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Create Template
        </Button>
      </div>

      {/* Filters */}
      <div className="flex space-x-4 items-center">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <input
            type="text"
            placeholder="Search templates by product type or version..."
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-green-500"
          />
        </div>
        <div className="flex space-x-2">
          <Button 
            variant={selectedStatus === 'all' ? 'default' : 'outline'}
            size="sm"
            onClick={() => setSelectedStatus('all')}
          >
            All Templates
          </Button>
          <Button 
            variant={selectedStatus === 'active' ? 'default' : 'outline'}
            size="sm"
            onClick={() => setSelectedStatus('active')}
          >
            <CheckCircle className="mr-2 h-4 w-4" />
            Active
          </Button>
          <Button 
            variant={selectedStatus === 'inactive' ? 'default' : 'outline'}
            size="sm"
            onClick={() => setSelectedStatus('inactive')}
          >
            <AlertTriangle className="mr-2 h-4 w-4" />
            Inactive
          </Button>
        </div>
      </div>

      {/* Templates Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredTemplates.map((template) => (
          <Card key={template.id} className={`hover:shadow-lg transition-shadow ${
            !template.is_active ? 'opacity-75 border-gray-300' : ''
          }`}>
            <CardHeader>
              <div className="flex items-start justify-between">
                <div>
                  <CardTitle className="text-lg capitalize">
                    {template.product_type} Contract
                  </CardTitle>
                  <CardDescription className="flex items-center space-x-2">
                    <span>Version {template.version}</span>
                    {template.is_active ? (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs bg-green-100 text-green-800">
                        <CheckCircle className="mr-1 h-3 w-3" />
                        Active
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs bg-gray-100 text-gray-800">
                        Inactive
                      </span>
                    )}
                  </CardDescription>
                </div>
                <div className="flex space-x-1">
                  <Button variant="ghost" size="sm">
                    <Eye className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Code className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Copy className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Edit className="h-4 w-4" />
                  </Button>
                  {!template.is_active && (
                    <Button variant="ghost" size="sm">
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  )}
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <p className="text-gray-600">Usage Count</p>
                    <p className="font-semibold">{template.usage_count}</p>
                  </div>
                  <div>
                    <p className="text-gray-600">Acceptance Rate</p>
                    <p className="font-semibold text-green-600">{template.acceptance_rate}%</p>
                  </div>
                </div>
                
                {template.requires_re_acceptance && (
                  <div className="flex items-center p-2 bg-yellow-50 border border-yellow-200 rounded text-sm">
                    <AlertTriangle className="h-4 w-4 text-yellow-600 mr-2" />
                    <span className="text-yellow-800">Requires re-acceptance</span>
                  </div>
                )}

                <div className="text-sm text-gray-500">
                  <p>Created: {formatDate(template.created_at)}</p>
                  <p>Updated: {formatDate(template.updated_at)}</p>
                  {template.deactivated_at && (
                    <p>Deactivated: {formatDate(template.deactivated_at)}</p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Template Editor Wireframe */}
      <Card className="border-green-200 bg-green-50">
        <CardHeader>
          <CardTitle className="text-green-800">Contract Template Editor (Wireframe)</CardTitle>
          <CardDescription>
            Rich editor for creating and managing legal contract templates
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div className="space-y-2">
                <h4 className="font-medium">Form Fields:</h4>
                <ul className="space-y-1 text-gray-600">
                  <li>• Product Type (dropdown)</li>
                  <li>• Version (auto-increment)</li>
                  <li>• Content HTML (rich text editor)</li>
                  <li>• Re-acceptance Required (checkbox)</li>
                  <li>• Activation Controls</li>
                </ul>
              </div>
              <div className="space-y-2">
                <h4 className="font-medium">Features:</h4>
                <ul className="space-y-1 text-gray-600">
                  <li>• Variable placeholder insertion</li>
                  <li>• HTML code editor with syntax highlighting</li>
                  <li>• Contract preview with sample data</li>
                  <li>• Version comparison tool</li>
                  <li>• Legal compliance checker</li>
                </ul>
              </div>
              <div className="space-y-2">
                <h4 className="font-medium">Variables Available:</h4>
                <ul className="space-y-1 text-gray-600 font-mono text-xs">
                  <li>• {'{{user_name}}'}</li>
                  <li>• {'{{plan_name}}'}</li>
                  <li>• {'{{price}}'}</li>
                  <li>• {'{{start_date}}'}</li>
                  <li>• {'{{company_name}}'}</li>
                </ul>
              </div>
              <div className="space-y-2">
                <h4 className="font-medium">Actions:</h4>
                <ul className="space-y-1 text-gray-600">
                  <li>• Save as draft</li>
                  <li>• Activate template (deactivates others)</li>
                  <li>• Export as PDF/HTML</li>
                  <li>• Clone to new version</li>
                  <li>• Audit trail view</li>
                </ul>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}