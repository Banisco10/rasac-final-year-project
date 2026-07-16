export function parseCookies(cookieHeader?: string): Record<string, string> {
  const result: Record<string, string> = {};
  if (!cookieHeader) return result;
  for (const chunk of cookieHeader.split(';')) {
    const [name, ...rest] = chunk.trim().split('=');
    if (!name) continue;
    result[name] = decodeURIComponent(rest.join('='));
  }
  return result;
}

export function buildCookie(name: string, value: string, maxAgeSeconds?: number): string {
  const maxAgePart = maxAgeSeconds !== undefined ? `; Max-Age=${maxAgeSeconds}` : '';
  return `${name}=${encodeURIComponent(value)}; HttpOnly; Path=/${maxAgePart}; SameSite=Lax`;
}

