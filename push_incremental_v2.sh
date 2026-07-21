#!/bin/bash
set -e

echo "Starting incremental push..."

# Unstage everything
git reset

# Add all files
git add .

# Unstage large files (wildcards for git reset)
git reset -- \*.mp4 \*.png \*.jpg \*.jpeg \*.svg \*.ico || true

if ! git diff --cached --quiet; then
  echo "Committing source files..."
  git commit -m "Add source code files"
  env -u GITHUB_TOKEN git push origin main
fi

push_pattern() {
  local pattern=$1
  local msg=$2
  
  echo "Looking for pattern: $pattern"
  # Find files matching pattern that are untracked or modified
  local files=$(git ls-files -o -m | grep -E "$pattern" || true)
  
  if [ -n "$files" ]; then
    echo "$files" | tr '\n' '\0' | xargs -0 git add
    if ! git diff --cached --quiet; then
      echo "Committing $msg..."
      git commit -m "$msg"
      env -u GITHUB_TOKEN git push origin main
    fi
  fi
}

push_pattern '\.(svg|ico)$' "Add vector and icon files"
push_pattern '\.png$' "Add PNG images"
push_pattern '\.(jpg|jpeg)$' "Add JPG images"

# Push videos one by one
videos=$(git ls-files -o -m | grep -E '\.mp4$' || true)
if [ -n "$videos" ]; then
  echo "$videos" | while read -r video; do
    echo "Adding video: $video"
    git add "$video"
    git commit -m "Add video: $(basename "$video")"
    env -u GITHUB_TOKEN git push origin main
  done
fi

echo "Done!"
