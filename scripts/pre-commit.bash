# Flutter formatter
printf "\e[33;1m%s\e[0m\n" '=== Running Flutter Formatter ==='

stagedFilesFormat=$(git diff --name-only --staged | grep '.dart')
flutter format $stagedFilesFormat

stagedFiles=$(git diff --name-only --staged)
printf "\e[33;1m%s\e[0m\n" "stagedFiles List : ${stagedFiles}"

if [ -n "$stagedFiles" ]; then
    git add $stagedFiles.
    printf "\e[33;1m%s\e[0m\n" 'Formmated files added to git stage'
fi
printf "\e[33;1m%s\e[0m\n" 'Finished running Flutter Formatter'
printf '%s\n' "${avar}"
