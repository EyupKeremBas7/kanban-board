import { useEffect, useState } from "react"
import { io, Socket } from "socket.io-client"
import { OpenAPI } from "../client"

export const useSocket = () => {
  const [socket, setSocket] = useState<Socket | null>(null)

  useEffect(() => {
    // API URL'inden /api/v1 kısmını temizle (Socket.IO root'da çalışır)
    const baseUrl = (OpenAPI.BASE || window.location.origin).replace(/\/api\/v1\/?$/, "")
    const token = localStorage.getItem("access_token")

    const newSocket = io(baseUrl, {
      auth: {
        token: token,
      },
      transports: ["websocket", "polling"],
    })

    newSocket.on("connect", () => {
      console.log("Frontend Socket.IO: Connected to", baseUrl)
      setSocket(newSocket)
    })

    newSocket.on("disconnect", () => {
      console.log("Frontend Socket.IO: Disconnected")
      setSocket(null)
    })

    newSocket.on("connect_error", (error) => {
      console.error("Frontend Socket.IO: Connect Error", error)
    })

    return () => {
      newSocket.disconnect()
    }
  }, [])

  return socket
}
