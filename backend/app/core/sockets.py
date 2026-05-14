import socketio
from fastapi import FastAPI
from app.core.config import settings

class SocketManager:
    """
    Manages the Socket.IO server and its integration with FastAPI.
    """
    sio = socketio.AsyncServer(
        async_mode='asgi',
        cors_allowed_origins='*',
        logger=True,
        engineio_logger=True,
        monitor_clients=True
    )
    _loop = None

    @classmethod
    def set_loop(cls, loop):
        cls._loop = loop

    @classmethod
    def get_asgi_app(cls, other_asgi_app: FastAPI):
        return socketio.ASGIApp(cls.sio, other_asgi_app)

    @classmethod
    async def emit(cls, event: str, data: dict, room: str = None):
        """Emit an event to all connected clients or a specific room."""
        try:
            await cls.sio.emit(event, data, room=room)
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Socket.IO Emit Error: {e}")

# Socket.IO Event Handlers
@SocketManager.sio.event
async def connect(sid, environ, auth):
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Socket.IO: Connection attempt from SID: {sid}")
    logger.info(f"Socket.IO: Auth data: {auth}")
    logger.info(f"Socket.IO: Environ: {environ.get('HTTP_ORIGIN', 'No Origin')}")
    return True

@SocketManager.sio.event
async def disconnect(sid):
    print(f"Socket.IO: Client disconnected: {sid}")

@SocketManager.sio.on('join_board')
async def join_board(sid, board_id):
    await SocketManager.sio.enter_room(sid, f"board_{board_id}")
    print(f"Socket.IO: Client {sid} joined room board_{board_id}")

@SocketManager.sio.on('leave_board')
async def leave_board(sid, board_id):
    await SocketManager.sio.leave_room(sid, f"board_{board_id}")
    print(f"Socket.IO: Client {sid} left room board_{board_id}")
