"""
FastAPI backend application for SportsTalent AI platform.
Provides endpoints for video upload, pose analysis, and talent assessment.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
import uvicorn
from contextlib import asynccontextmanager

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.logging import setup_logging


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager for startup/shutdown events."""
    # Startup
    setup_logging()
    print("🚀 SportsTalent AI Backend Starting...")
    
    # Initialize services here
    # await initialize_services()
    
    yield
    
    # Shutdown
    print("⏹️ SportsTalent AI Backend Shutting down...")


def create_application() -> FastAPI:
    """Create and configure the FastAPI application."""
    
    app = FastAPI(
        title="SportsTalent AI API",
        description="AI-powered mobile sports talent assessment platform backend",
        version="1.0.0",
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
        lifespan=lifespan,
    )

    # Add middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_HOSTS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.ALLOWED_HOSTS,
    )

    # Include API router
    app.include_router(api_router, prefix="/api")

    @app.get("/")
    async def root():
        """Root endpoint for health check."""
        return {
            "message": "SportsTalent AI Backend API",
            "version": "1.0.0",
            "status": "healthy"
        }

    @app.get("/health")
    async def health_check():
        """Health check endpoint."""
        return {"status": "healthy", "service": "sportsTalent-ai-backend"}

    return app


app = create_application()

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level="info" if settings.DEBUG else "warning",
    )