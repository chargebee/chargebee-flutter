printf "\e[33;1m%s\e[0m\n" '=== Flutter Formatter ==='

function validateFormatting() {
  dartfiles=$(git diff --name-only origin/main HEAD | grep '.dart')
  if [ -z "$dartfiles" ]; then
    printf "\e[33;1m%s\e[0m\n" "No dart files specified to be formatted : ${dartfiles}"
    return 0
  fi
  unformatted=$(flutter format --dry-run --set-exit-if-changed $dartfiles)
  zerofilechanged=$(flutter format --dry-run --set-exit-if-changed $dartfiles | grep '(0 changed)')
  if [ -z "$zerofilechanged" ]; then
    [ -z "$unformatted" ] && return 0
    echo >&2 "$unformatted"
    echo >&2 "Dart files must be formatted with flutter format. Please run:"
    for fn in $dartfiles; do
      echo >&2 " flutter format $PWD/$fn"
    done

    return 1
  else
    echo >&2 "Files not changed!"
    return 0
  fi
}

validateFormatting || fail=yes

[ -z "$fail" ] || exit 1

exit 0