#!/usr/bin/env bash
set -e

echo "========================================================"
echo "Running Oloz Verification Suite (Analyze + Tests)"
echo "========================================================"

echo ""
echo "[1/2] Running Flutter Analyze..."
flutter analyze

echo ""
echo "[2/2] Running Flutter Tests..."
flutter test

echo ""
echo "========================================================"
echo "[SUCCESS] Oloz build and verification completed cleanly!"
echo "========================================================"

