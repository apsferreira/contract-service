import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, ArrowRight, Loader2 } from 'lucide-react';
import { setToken } from '../lib/auth';

const AUTH_API = (import.meta.env?.VITE_AUTH_SERVICE_URL as string) || 'https://auth.institutoitinerante.com.br';

export function Login() {
  const navigate = useNavigate();
  const [step, setStep] = useState<'email' | 'otp'>('email');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleRequestOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch(`${AUTH_API}/auth/request-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim(), product: 'contracts' }),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { error?: string }).error || 'Erro ao enviar codigo');
      }
      setStep('otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao enviar codigo');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch(`${AUTH_API}/auth/verify-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim(), code: otp.trim() }),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { error?: string }).error || 'Codigo invalido');
      }
      const data = await res.json() as { token?: string };
      if (!data.token) throw new Error('Token nao recebido');
      setToken(data.token);
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao verificar codigo');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-14 h-14 rounded-2xl bg-green-600 flex items-center justify-center mx-auto mb-4">
            <Shield className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-xl font-bold text-gray-900">Contract Admin</h1>
          <p className="text-sm text-gray-500 mt-1">Gestao de contratos · Instituto Itinerante</p>
        </div>

        {/* Form */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
          {step === 'email' ? (
            <form onSubmit={handleRequestOTP} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="seu@email.com"
                  required
                  autoFocus
                  className="w-full px-4 py-3 rounded-xl border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 py-3 bg-green-600 text-white rounded-xl text-sm font-semibold hover:bg-green-700 disabled:opacity-50 transition-colors"
              >
                {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <ArrowRight className="w-4 h-4" />}
                Enviar codigo de acesso
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyOTP} className="space-y-4">
              <p className="text-sm text-gray-500 text-center">
                Enviamos um codigo para <strong className="text-gray-900">{email}</strong>
              </p>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Codigo</label>
                <input
                  type="text"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  placeholder="000000"
                  required
                  autoFocus
                  maxLength={6}
                  className="w-full px-4 py-3 rounded-xl border border-gray-300 text-sm text-center tracking-widest font-mono text-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 py-3 bg-green-600 text-white rounded-xl text-sm font-semibold hover:bg-green-700 disabled:opacity-50 transition-colors"
              >
                {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : null}
                Entrar
              </button>
              <button
                type="button"
                onClick={() => { setStep('email'); setOtp(''); setError(''); }}
                className="w-full text-sm text-gray-500 hover:text-gray-700"
              >
                Usar outro email
              </button>
            </form>
          )}

          {error && (
            <p className="mt-3 text-xs text-red-600 text-center bg-red-50 rounded-lg px-3 py-2">{error}</p>
          )}
        </div>
      </div>
    </div>
  );
}
