#!/bin/bash

# SportsTalent AI Setup Script
# This script sets up the development environment for the SportsTalent AI platform

set -e  # Exit on any error

echo "🏃‍♂️ SportsTalent AI - Development Environment Setup"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported OS
check_os() {
    print_status "Checking operating system..."
    case "$(uname -s)" in
        Darwin*) OS="macOS" ;;
        Linux*)  OS="Linux" ;;
        *) 
            print_error "Unsupported operating system. Please use macOS or Linux."
            exit 1 ;;
    esac
    print_success "Running on $OS"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed."
        print_status "Please install Python 3.9+ from https://python.org"
        exit 1
    fi
    
    python_version=$(python3 --version | cut -d' ' -f2)
    print_success "Python $python_version found"
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is required but not installed."
        exit 1
    fi
    print_success "pip3 found"
    
    # Check Flutter (optional for backend-only development)
    if command -v flutter &> /dev/null; then
        flutter_version=$(flutter --version | head -n 1)
        print_success "Flutter found: $flutter_version"
    else
        print_warning "Flutter not found. Mobile app development will not be available."
        print_status "Install Flutter from https://flutter.dev/docs/get-started/install"
    fi
    
    # Check Node.js (for potential web features)
    if command -v node &> /dev/null; then
        node_version=$(node --version)
        print_success "Node.js found: $node_version"
    else
        print_warning "Node.js not found. Web features may not be available."
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        exit 1
    fi
    print_success "Git found"
}

# Setup backend environment
setup_backend() {
    print_status "Setting up FastAPI backend..."
    
    cd backend
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    # Install requirements (with fallback for network issues)
    print_status "Installing Python dependencies..."
    if ! pip install -r requirements.txt; then
        print_warning "Failed to install all dependencies. Installing core packages..."
        pip install fastapi uvicorn python-multipart pydantic pydantic-settings
        print_warning "Some advanced features may not work without all dependencies."
    fi
    
    # Create necessary directories
    mkdir -p logs
    mkdir -p uploads
    mkdir -p models
    
    print_success "Backend setup completed"
    cd ..
}

# Setup Flutter app
setup_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter not available. Skipping Flutter setup."
        return
    fi
    
    print_status "Setting up Flutter mobile app..."
    
    cd flutter_app
    
    # Get Flutter dependencies
    print_status "Installing Flutter dependencies..."
    if flutter pub get; then
        print_success "Flutter dependencies installed"
    else
        print_error "Failed to install Flutter dependencies"
        cd ..
        return
    fi
    
    # Generate code (for JSON serialization)
    print_status "Generating code..."
    if flutter packages pub run build_runner build --delete-conflicting-outputs; then
        print_success "Code generation completed"
    else
        print_warning "Code generation failed. Some features may not work."
    fi
    
    print_success "Flutter app setup completed"
    cd ..
}

# Setup cloud infrastructure
setup_cloud() {
    print_status "Setting up cloud infrastructure..."
    
    # Create Firebase configuration
    cd cloud/firebase
    
    if [ ! -f "firebase-config.json" ]; then
        print_warning "Firebase configuration not found."
        print_status "Please add your Firebase configuration files:"
        print_status "  1. firebase-config.json"
        print_status "  2. service-account-key.json"
        print_status "Visit https://console.firebase.google.com to get these files."
    fi
    
    cd ../..
    print_success "Cloud infrastructure setup completed"
}

# Setup ML models directory
setup_ml_models() {
    print_status "Setting up ML models..."
    
    cd ml_models
    
    # Create necessary directories
    mkdir -p pose_analysis/models
    mkdir -p talent_scoring/models
    mkdir -p training/data
    mkdir -p training/logs
    mkdir -p training/metrics
    
    # Create placeholder model files
    echo "# Placeholder for pose estimation model" > pose_analysis/pose_estimation_model.tflite
    echo "# Placeholder for talent scoring model" > talent_scoring/talent_scoring_model.pkl
    
    print_success "ML models directory setup completed"
    cd ..
}

# Setup development tools
setup_dev_tools() {
    print_status "Setting up development tools..."
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_status "Created .env file from template. Please update with your values."
    fi
    
    # Setup Git hooks (optional)
    if [ -d ".git" ]; then
        print_status "Setting up Git hooks..."
        # You could add pre-commit hooks here
        print_success "Git hooks setup completed"
    fi
    
    print_success "Development tools setup completed"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Test backend
    cd backend
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        if python -c "from app.main import app; print('Backend imports working')" 2>/dev/null; then
            print_success "Backend verification passed"
        else
            print_warning "Backend verification failed - some imports may not work"
        fi
        deactivate
    fi
    cd ..
    
    # Test Flutter
    if command -v flutter &> /dev/null; then
        cd flutter_app
        if flutter doctor --android-licenses >/dev/null 2>&1 || true; then
            flutter doctor | head -10
            print_success "Flutter verification completed"
        fi
        cd ..
    fi
    
    print_success "Installation verification completed"
}

# Main setup function
main() {
    check_os
    check_prerequisites
    
    setup_backend
    setup_flutter
    setup_cloud
    setup_ml_models
    setup_dev_tools
    
    verify_installation
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Update .env file with your configuration"
    echo "2. Add Firebase configuration files in cloud/firebase/"
    echo "3. Start the backend: cd backend && source venv/bin/activate && uvicorn app.main:app --reload"
    if command -v flutter &> /dev/null; then
        echo "4. Run the Flutter app: cd flutter_app && flutter run"
    fi
    echo ""
    echo "For more information, see the README.md file."
    echo "Happy coding! 🚀"
}

# Run setup
main