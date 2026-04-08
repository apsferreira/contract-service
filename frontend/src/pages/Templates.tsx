import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/card';
import { FileText, AlertTriangle } from 'lucide-react';
import { templatesApi } from '../lib/api';
import type { Template } from '../lib/api';

export function Templates() {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState<Template | null>(null);

  useEffect(() => {
    templatesApi
      .list()
      .then((data) => setTemplates(data ?? []))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="w-6 h-6 border-2 border-gray-200 border-t-indigo-600 rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Templates</h1>
        <p className="mt-2 text-gray-600">Templates de contrato disponveis</p>
      </div>

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          <AlertTriangle className="inline w-4 h-4 mr-2" />
          {error}
        </div>
      )}

      {templates.length === 0 ? (
        <p className="text-gray-400 text-center py-12">Nenhum template encontrado.</p>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {templates.map((t) => (
            <Card
              key={t.id}
              className="cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => setSelectedTemplate(t)}
            >
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <FileText className="w-5 h-5 text-indigo-500" />
                    <CardTitle className="text-base">{t.product_type}</CardTitle>
                  </div>
                  <span
                    className={`text-xs font-medium px-2 py-1 rounded-full ${
                      t.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                    }`}
                  >
                    {t.is_active ? 'Ativo' : 'Inativo'}
                  </span>
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-xs text-gray-400 space-y-1">
                  <p>Versao: {t.version}</p>
                  <p>Criado: {new Date(t.created_at).toLocaleDateString('pt-BR')}</p>
                  <p>Atualizado: {new Date(t.updated_at).toLocaleDateString('pt-BR')}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {selectedTemplate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40" onClick={() => setSelectedTemplate(null)}>
          <div className="w-full max-w-3xl bg-white rounded-2xl shadow-xl max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Template: {selectedTemplate.product_type}
                </h2>
                <p className="text-xs text-gray-400">
                  v{selectedTemplate.version} · {selectedTemplate.is_active ? 'Ativo' : 'Inativo'}
                </p>
              </div>
              <button onClick={() => setSelectedTemplate(null)} className="text-gray-400 hover:text-gray-600 text-lg">x</button>
            </div>
            <div className="px-6 py-4">
              <div
                className="border border-gray-200 rounded-lg p-4 text-xs bg-gray-50 prose prose-xs max-w-none"
                dangerouslySetInnerHTML={{ __html: selectedTemplate.content_html }}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
