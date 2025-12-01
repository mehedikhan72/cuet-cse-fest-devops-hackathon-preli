#!/bin/bash
# Setup script for CI/CD pipeline
# Generates package-lock.json files if they don't exist

echo "Setting up project for CI/CD..."
echo ""

# Backend setup
echo "Setting up backend..."
if [ ! -f "backend/package-lock.json" ]; then
    echo "  Generating backend package-lock.json..."
    cd backend
    npm install
    cd ..
    echo "  ✓ Backend package-lock.json created"
else
    echo "  ✓ Backend package-lock.json already exists"
fi

# Gateway setup
echo "Setting up gateway..."
if [ ! -f "gateway/package-lock.json" ]; then
    echo "  Generating gateway package-lock.json..."
    cd gateway
    npm install
    cd ..
    echo "  ✓ Gateway package-lock.json created"
else
    echo "  ✓ Gateway package-lock.json already exists"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Commit the package-lock.json files:"
echo "   git add backend/package-lock.json gateway/package-lock.json"
echo "   git commit -m 'Add package-lock.json files for CI/CD'"
echo ""
echo "2. Configure GitHub Secrets (see CI-CD.md):"
echo "   - DOCKERHUB_USERNAME"
echo "   - DOCKERHUB_TOKEN"
echo ""
echo "3. Push to GitHub to trigger CI/CD pipeline:"
echo "   git push origin main"
