"""
Explicit uvicorn launcher that bypasses FastAPI CLI auto-discovery.
Uses uvicorn.Server + Config directly to prevent any CLI interception.
"""
import uvicorn
import asyncio


def main():
    # Import the Socket.IO wrapped app directly
    from app.main import app

    config = uvicorn.Config(
        app=app,
        host="0.0.0.0",
        port=8000,
        log_level="info",
    )
    server = uvicorn.Server(config)
    server.run()


if __name__ == "__main__":
    main()
