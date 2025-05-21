#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Please provide a version number (e.g., 0.0.1)"
    exit 1
fi

VERSION=$1

# Update version in Package.swift
sed -i '' "s/version: \".*\"/version: \"$VERSION\"/" Package.swift

# Update version in README.md
sed -i '' "s/from: \".*\"/from: \"$VERSION\"/" README.md

# Create git tag
git add Package.swift README.md
git commit -m "Bump version to $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"
git push origin main
git push origin "v$VERSION"

echo "Released version $VERSION" 