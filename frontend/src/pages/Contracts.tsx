import { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/card';
import { FileText, Search, AlertTriangle } from 'lucide-react';
import { contractsApi } from '../lib/api';
import type { Contract } from '../lib/api';

const STATUS_LABELS: Record<string, { label: string; cls: string }> = {
  accepted: { label: 'Aceito', cls: 'bg-green-100 text-green-700' },
  pending: { label: 'Pendente', cls: 'bg-amber-100 text-amber-700' },
  expired: { label: 'Expirado', cls: 'bg-red-100 text-red-600' },
  revoked: { label: 'Revogado', cls: 'bg-gray-100 text-gray-600' },
};

export function Contracts() {
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterProduct, setFilterProduct] = useState('');
  const [selectedContract, setSelectedContract] = useState<Contract | null>(null);

  useEffect(() => {
    setLoading(true);
    contractsApi
      .list({
        status: filterStatus || undefined,
        product_type: filterProduct || undefined,
        limit: 50,
      })
      .then((data) => setContracts(data.contracts ?? []))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [filterStatus, filterProduct]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Contratos</h1>
        <p className="mt-2 text-gray-600">Todos os contratos registrados</p>
      </div>

      <div className="flex flex-wrap gap-3">
        <select
          value={filterStatus}
          onChange={(e) => setFilterStatus(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500"
        >
          <option value="">Todos os status</option>
          <option value="accepted">Aceitos</option>
          <option value="pending">Pendentes</option>
          <option value="expired">Expirados</option>
          <option value="revoked">Revogados</option>
        </select>
        <select
          value={filterProduct}
          onChange={(e) => setFilterProduct(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500"
        >
          <option value="">Todos os produtos</option>
          <option value="socialmake">SocialMake</option>
          <option value="brio">Brio</option>
          <option value="libri">Libri</option>
          <option value="nitro">Nitro</option>
        </select>
      </div>

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          <AlertTriangle className="inline w-4 h-4 mr-2" />
          {error}
        </div>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="w-6 h-6 border-2 border-gray-200 border-t-indigo-600 rounded-full animate-spin" />
        </div>
      ) : contracts.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <Search className="w-10 h-10 text-gray-300 mb-3" />
          <p className="text-gray-500">Nenhum contrato encontrado.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {contracts.map((c) => {
            const status = STATUS_LABELS[c.status] ?? { label: c.status, cls: 'bg-gray-100 text-gray-600' };
            return (
              <Card key={c.id} className="cursor-pointer hover:shadow-md transition-shadow" onClick={() => setSelectedContract(c)}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <FileText className="w-5 h-5 text-indigo-500 shrink-0" />
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          {c.variables?.user_name || c.user_id}
                        </p>
                        <p className="text-xs text-gray-400">
                          {c.product_type} · {c.variables?.plan_name || '-'} · {new Date(c.created_at).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                    </div>
                    <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${status.cls}`}>
                      {status.label}
                    </span>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      {selectedContract && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40" onClick={() => setSelectedContract(null)}>
          <div className="w-full max-w-2xl bg-white rounded-2xl shadow-xl max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Contrato - {selectedContract.variables?.user_name || selectedContract.user_id}
                </h2>
                <p className="text-xs text-gray-400">
                  {selectedContract.product_type} · {selectedContract.id}
                </p>
              </div>
              <button onClick={() => setSelectedContract(null)} className="text-gray-400 hover:text-gray-600 text-lg">x</button>
            </div>
            <div className="px-6 py-4 space-y-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-gray-400 text-xs">Status</p>
                  <p className="font-medium">{STATUS_LABELS[selectedContract.status]?.label ?? selectedContract.status}</p>
                </div>
                <div>
                  <p className="text-gray-400 text-xs">Plano</p>
                  <p className="font-medium">{selectedContract.variables?.plan_name || '-'}</p>
                </div>
                <div>
                  <p className="text-gray-400 text-xs">Preco</p>
                  <p className="font-medium">{selectedContract.variables?.price ? `R$ ${selectedContract.variables.price}` : '-'}</p>
                </div>
                <div>
                  <p className="text-gray-400 text-xs">Criado em</p>
                  <p className="font-medium">{new Date(selectedContract.created_at).toLocaleString('pt-BR')}</p>
                </div>
                {selectedContract.accepted_at && (
                  <div>
                    <p className="text-gray-400 text-xs">Aceito em</p>
                    <p className="font-medium">{new Date(selectedContract.accepted_at).toLocaleString('pt-BR')}</p>
                  </div>
                )}
                <div>
                  <p className="text-gray-400 text-xs">Email</p>
                  <p className="font-medium">{selectedContract.variables?.user_email || '-'}</p>
                </div>
              </div>

              {selectedContract.content_html && (
                <div>
                  <p className="text-xs text-gray-400 mb-2">Preview do Contrato</p>
                  <div
                    className="border border-gray-200 rounded-lg p-4 max-h-60 overflow-y-auto text-xs bg-gray-50"
                    dangerouslySetInnerHTML={{ __html: selectedContract.content_html }}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
