#!/usr/bin/env bash
set -euo pipefail

root_dir="$(git rev-parse --show-toplevel)"
cd "$root_dir"

remote="${RELEASE_REMOTE:-upstream}"
branch="${RELEASE_BRANCH:-master}"
version_file="lib/version.rb"

die() {
  printf 'release: %s\n' "$*" >&2
  exit 1
}

[[ "$(git branch --show-current)" == "$branch" ]] || die "run this from the $branch branch"
git diff --quiet || die "working tree has tracked changes"
git diff --cached --quiet || die "index has staged changes"

other_untracked="$(git ls-files --others --exclude-standard | grep -vx 'release.sh' || true)"
[[ -z "$other_untracked" ]] || die "working tree has untracked files besides release.sh"

git remote get-url "$remote" >/dev/null 2>&1 || die "Git remote '$remote' is not configured"
git fetch "$remote" "$branch" --tags
remote_branch="refs/remotes/$remote/$branch"
git show-ref --verify --quiet "$remote_branch" || die "remote branch $remote/$branch was not fetched"
git merge-base --is-ancestor "$remote_branch" HEAD || die "local $branch must be based on $remote/$branch before release"

current_version="$(ruby -e '
  text = File.read(ARGV.fetch(0))
  matches = text.scan(/^  VERSION = '\''(\d+\.\d+\.\d+)'\''$/)
  abort "expected one numeric X.Y.Z version in #{ARGV.fetch(0)}" unless matches.length == 1
  puts matches.first.first
' "$version_file")"
next_version="$(ruby -e '
  match = ARGV.fetch(0).match(/\A(\d+)\.(\d+)\.(\d+)\z/) or abort "invalid version"
  puts "#{match[1]}.#{Integer(match[2], 10) + 1}.0"
' "$current_version")"

if git show-ref --verify --quiet "refs/tags/$next_version"; then
  die "tag $next_version already exists"
fi

build_dir="$(mktemp -d "${TMPDIR:-/tmp}/ruby-newt-release.XXXXXX")"
artifact="$build_dir/newt-$next_version.gem"
bumped=0
committed=0

cleanup() {
  result=$?
  if (( bumped && ! committed )); then
    git restore --source=HEAD --staged --worktree -- "$version_file" >/dev/null 2>&1 || true
  fi
  if (( result == 0 )); then
    rm -rf -- "$build_dir"
  else
    printf 'release: build artifact (if created) remains at %s\n' "$artifact" >&2
  fi
  exit "$result"
}
trap cleanup EXIT

ruby - "$version_file" "$current_version" "$next_version" <<'RUBY'
path, current, next_version = ARGV
text = File.read(path)
old_line = "  VERSION = '#{current}'"
new_line = "  VERSION = '#{next_version}'"
abort "could not find expected version line in #{path}" unless text.lines.count { |line| line.chomp == old_line } == 1
File.write(path, text.sub(old_line, new_line))
RUBY
bumped=1
printf 'Releasing newt %s (minor bump from %s)\n' "$next_version" "$current_version"

bundle exec rake clobber
bundle exec rake test
gem build newt.gemspec --output "$artifact"

if [[ "${RELEASE_DRY_RUN:-0}" == 1 ]]; then
  printf 'Tests and gem build passed; dry run skipped commit, tag, and publish steps.\n'
  exit 0
fi

git add -- "$version_file"
git commit -m "Version $next_version"
committed=1
git tag "$next_version"
git push "$remote" "HEAD:refs/heads/$branch" "refs/tags/$next_version:refs/tags/$next_version"
gem push "$artifact"

printf 'Released newt %s\n' "$next_version"
