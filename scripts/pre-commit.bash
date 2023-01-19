# Flutter formatter
printf "\e[33;1m%s\e[0m\n" '=== Running Flutter Formatter ==='

hasNewFilesFormatted=$(git diff --name-only)
flutter format $hasNewFilesFormatted
if [ -n "$hasNewFilesFormatted" ]; then
    git add .
    printf "\e[33;1m%s\e[0m\n" 'Formmated files added to git stage'
fi
printf "\e[33;1m%s\e[0m\n" 'Finished running Flutter Formatter'
printf '%s\n' "${avar}"

# Flutter Analyzer
printf "\e[33;1m%s\e[0m\n" '=== Running Flutter analyzer ==='
flutter analyze
if [ $? -ne 0 ]; then
  printf "\e[31;1m%s\e[0m\n" '=== Flutter analyzer error ==='
  pop_stash_files
  exit 1
fi
printf "\e[33;1m%s\e[0m\n" 'Finished running Flutter analyzer'
printf '%s\n' "${avar}"