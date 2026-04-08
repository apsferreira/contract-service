import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/card';
import { FileSignature, FileText, CheckCircle, Clock, AlertTriangle } from 'lucide-react';
import { contractsApi, templatesApi } from '../lib/api';
import type { Contract, Template } from '../lib/api';

export function Dashboard() {
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [templates, setTemplates] = useState<Template[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([
      contractsApi.list({ limit: 100 }),
      templatesApi.list(),
    ])
      .then(([cData, tData]) => {
        setContracts(cData.contracts ?? []);
        setTemplates(tData ?? []);
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const totalContracts = contracts.length;
  const accepted = contracts.filter((c) => c.status === 'accepted').length;
  const pending = contracts.filter((c) => c.status === 'pending').length;
  const expired = contracts.filter((c) => c.status === 'expired').length;
  const acceptanceRate = totalContracts > 0 ? ((accepted / totalContracts) * 100).toFixed(1) : '0';
  const activeTemplates = templates.filter((t) => t.is_active).length;

  const recentContracts = [...contracts]
    .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    .slice(0, 5);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="w-6 h-6 border-2 border-gray-200 border-t-indigo-600 rounded-full animate-spin" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
        <AlertTriangle className="inline w-4 h-4 mr-2" />
        Erro ao carregar dados: {error}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">Visao geral do servico de contratos</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-500">Total de Contratos</CardTitle>
            <FileSignature className="h-4 w-4 text-gray-400" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{totalContracts}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-500">Taxa de Aceite</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{acceptanceRate}%</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-500">Pendentes</CardTitle>
            <Clock className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{pending}</div>
            {expired > 0 && <p className="text-xs text-red-500 mt-1">{expired} expirado(s)</p>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-500">Templates Ativos</CardTitle>
            <FileText className="h-4 w-4 text-indigo-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{activeTemplates}</div>
            <p className="text-xs text-gray-400 mt-1">{templates.length} total</p>
          </CardContent>
        </Card>
      </div>

      {/* Recent contracts */}
      <Card>
        <CardHeader>
          <CardTitle>Contratos Recentes</CardTitle>
        </CardHeader>
        <CardContent>
          {recentContracts.length === 0 ? (
            <p className="text-sm text-gray-400 py-4 text-center">Nenhum contrato encontrado.</p>
          ) : (
            <div className="space-y-3">
              {recentContracts.map((c) => (
                <div key={c.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {c.variables?.user_name || c.user_id}
                    </p>
                    <p className="text-xs text-gray-400">
                      {c.product_type} · {new Date(c.created_at).toLocaleDateString('pt-BR')}
                    </p>
                  </div>
                  <span
                    className={`text-xs font-medium px-2 py-1 rounded-full ${
                      c.status === 'accepted'
                        ? 'bg-green-100 text-green-700'
                        : c.status === 'pending'
                        ? 'bg-amber-100 text-amber-700'
                        : c.status === 'expired'
                        ? 'bg-red-100 text-red-600'
                        : 'bg-gray-100 text-gray-600'
                    }`}
                  >
                    {c.status === 'accepted' ? 'Aceito' : c.status === 'pending' ? 'Pendente' : c.status === 'expired' ? 'Expirado' : c.status}
                  </span>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
