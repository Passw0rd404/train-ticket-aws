export async function onRequest({ request, env }) {
  const origin = env.API_ORIGIN || "https://api.abdullahsameh.tech";
  const url = new URL(request.url);
  const target = new URL(url.pathname + url.search, origin);
  return fetch(new Request(target, request));
}
