export const API_BASE_URL =
  process.env.NEXT_PUBLIC_COSMOKIT_API_URL ?? "http://localhost:8091";

export type ApiResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

export async function postJSON<T>(
  path: string,
  body: unknown,
): Promise<ApiResult<T>> {
  try {
    const res = await fetch(`${API_BASE_URL}${path}`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify(body),
    });
    const text = await res.text();
    const parsed = text ? (JSON.parse(text) as Record<string, unknown>) : {};
    if (!res.ok) {
      const message =
        typeof parsed.error === "string" ? parsed.error : `request failed (${res.status})`;
      return { ok: false, error: message };
    }
    return { ok: true, data: parsed as T };
  } catch (err) {
    const message = err instanceof Error ? err.message : "network error";
    return { ok: false, error: message };
  }
}
