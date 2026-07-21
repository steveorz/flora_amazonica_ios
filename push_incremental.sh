#!/bin/bash
# Remove everything from the git index without deleting files
git rm -r --cached .

# Add only small swift files
git add flora_amazonica_ios/**/*.swift
git commit -m "Add swift files"
env -u GITHUB_TOKEN git push origin main

# Add xcodeproj
git add flora_amazonica_ios/**/*.xcodeproj
git commit -m "Add project files"
env -u GITHUB_TOKEN git push origin main

# Add backend code except node_modules (which is gitignored)
git add FloraAmazonica-BackendAPI
git commit -m "Add backend API"
env -u GITHUB_TOKEN git push origin main

# Add frontend code except node_modules
git add FloraAmazonica-FrontendWeb
git commit -m "Add frontend web"
env -u GITHUB_TOKEN git push origin main

# Add everything else
git add .
git commit -m "Add remaining files"
env -u GITHUB_TOKEN git push origin main
