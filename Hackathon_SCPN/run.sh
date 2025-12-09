#!/bin/bash

echo "🚀 Starting Smart Career Path Navigator..."

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.10+"
    exit 1
fi

# Check Node
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Install Jac
echo "📦 Installing Jac..."
pip install jaclang

# Install Node modules
echo "📦 Installing dependencies..."
npm install

# Set environment variable
export GEMINI_API_KEY="AIzaSyCn-ckKABE_tNmzWLmsuVfT3R0gXb9a4TM"

# Start server
echo "✅ Starting server on http://localhost:8000"
echo "   Frontend: http://localhost:8000/page/app"
echo ""
jac serve app.jac
