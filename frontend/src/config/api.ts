const LOCAL_API_BASE = "http://localhost:8000"
const KANBAN_API_BASE = "http://api.kanbanboard.com.tr"

const isLocalHost = (hostname: string) =>
  hostname === "localhost" ||
  hostname === "127.0.0.1" ||
  hostname === "0.0.0.0"

export const getApiBaseUrl = () => {
  const configuredUrl = import.meta.env.VITE_API_URL?.trim()
  if (configuredUrl) return configuredUrl.replace(/\/$/, "")

  if (isLocalHost(window.location.hostname)) {
    return LOCAL_API_BASE
  }

  return KANBAN_API_BASE
}
