#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
set -u
BRANCH=$(echo "$TRAVIS_BRANCH" | awk '{print tolower($0)}')
BRANCH_PATH="preview/$TRAVIS_BRANCH"
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch origin gh-pages
git checkout gh-pages
rm -rf "${BRANCH_PATH}"
mkdir -p "${BRANCH_PATH}"
mv docs "${BRANCH_PATH}"
git status
if [[ -n "$(git status --porcelain "${BRANCH_PATH}")" && ${TRAVIS_PULL_REQUEST} == "false" ]]; then
  openssl aes-256-cbc -K $encrypted_f356a5c69655_key -iv $encrypted_f356a5c69655_iv -in github_deploy_key.enc -out github_deploy_key -d
  eval "$(ssh-agent)"
  chmod 600 github_deploy_key
  ssh-add github_deploy_key
  bash scripts/create-table-of-contents.sh
  bash scripts/remove-docs-for-deleted-branches.sh
  git add preview
  git add index.md
  git commit -m "Docs changed for "${TRAVIS_BRANCH}""
  git push git@github.com:"${TRAVIS_REPO_SLUG}" gh-pages
else
  echo "No changes"
fi
