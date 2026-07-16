const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:4000/api";

export type AuthUser = {
  id: number;
  email: string;
  fullName: string;
  roles: string[];
};

export type LoginResponse = {
  user: AuthUser;
  token: string;
};

export async function apiRequest<T>(
  path: string,
  options: RequestInit = {},
  token?: string | null
): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options.headers ?? {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    }
  });

  if (!response.ok) {
    const body = await response.json().catch(() => null);
    throw new Error(body?.message ?? `Request failed with status ${response.status}`);
  }

  return response.json() as Promise<T>;
}
