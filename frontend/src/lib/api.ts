import { getToken, clearToken } from './auth'

const BASE_URL = (import.meta.env?.VITE_API_URL as string) || '/api/v1'

function headers(): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' }
  const jwt = getToken()
  if (jwt) {
    h['Authorization'] = `Bearer ${jwt}`
  }
  return h
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...init,
    headers: { ...headers(), ...init?.headers },
  })
  if (!res.ok) {
    if (res.status === 401) {
      clearToken()
      window.location.href = '/login'
      throw new Error('Sessao expirada')
    }
    const body = await res.json().catch(() => ({}))
    throw new Error((body as { error?: string }).error || `HTTP ${res.status}`)
  }
  if (res.status === 204) return undefined as unknown as T
  return res.json() as Promise<T>
}

// ── Types ──────────────────────────────────────────────────────────

export interface Contract {
  id: string
  user_id: string
  product_type: string
  template_id: string
  variables: Record<string, string>
  content_html: string
  content_hash: string
  status: 'pending' | 'accepted' | 'expired' | 'revoked'
  accepted_at?: string
  ip_address?: string
  user_agent?: string
  expires_at?: string
  created_at: string
  updated_at: string
}

export interface Template {
  id: string
  product_type: string
  version: string
  content_html: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface ContractListResponse {
  contracts: Contract[]
  total: number
}

// ── API ────────────────────────────────────────────────────────────

export const contractsApi = {
  list: (params?: { product_type?: string; status?: string; limit?: number; offset?: number }) => {
    const q = new URLSearchParams()
    if (params?.product_type) q.set('product_type', params.product_type)
    if (params?.status) q.set('status', params.status)
    if (params?.limit) q.set('limit', String(params.limit))
    if (params?.offset) q.set('offset', String(params.offset))
    const qs = q.toString()
    return request<ContractListResponse>(`/contracts${qs ? `?${qs}` : ''}`)
  },

  getById: (id: string) => request<Contract>(`/contracts/${id}`),
}

export const templatesApi = {
  list: () => request<Template[]>('/templates'),
  getById: (id: string) => request<Template>(`/templates/${id}`),
}
