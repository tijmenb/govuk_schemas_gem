#!/bin/bash

set -e

REPO_NAME=${REPO_NAME:-"alphagov/govuk_schemas_gem"}
CONTEXT_MESSAGE=${CONTEXT_MESSAGE:-"default"}
GH_STATUS_GIT_COMMIT=${SCHEMA_GIT_COMMIT:-${GIT_COMMIT}}

function github_status {
  REPO_NAME="$1"
  STATUS="$2"
  MESSAGE="$3"
  gh-status "$REPO_NAME" "$GH_STATUS_GIT_COMMIT" "$STATUS" -d "Build #${BUILD_NUMBER} ${MESSAGE}" -u "$BUILD_URL" -c "$CONTEXT_MESSAGE" >/dev/null
}

function error_handler {
  trap - ERR # disable error trap to avoid recursion
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  github_status "$REPO_NAME" error "errored on Jenkins"
  exit "${code}"
}

trap 'error_handler ${LINENO}' ERR
github_status "$REPO_NAME" pending "is running on Jenkins"

# Cleanup anything left from previous test runs
git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

echo "Running ruby linter"
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec govuk-lint-ruby \
  --format html --out rubocop-${GIT_COMMIT}.html \
  --format clang

# Clone govuk-content-schemas depedency for contract tests
rm -rf /tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git /tmp/govuk-content-schemas
(
 cd /tmp/govuk-content-schemas
 git checkout ${SCHEMA_GIT_COMMIT:-"master"}
)
export GOVUK_CONTENT_SCHEMAS_PATH=/tmp/govuk-content-schemas

# Bundle and run tests against multiple ruby versions
for version in 2.3.1; do
  rm -f Gemfile.lock
  export RBENV_VERSION=$version
  echo "Running tests under ruby $version"
  bundle install --path "${HOME}/bundles/${JOB_NAME}"
  if ! bundle exec rake ${TEST_TASK:-"default"}; then
    github_status "$REPO_NAME" failure "failed on Jenkins"
    exit 1
  fi
done
unset RBENV_VERSION

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle install --path "${HOME}/bundles/${JOB_NAME}"
  bundle exec rake publish_gem --trace
fi

github_status "$REPO_NAME" success "succeeded on Jenkins"
