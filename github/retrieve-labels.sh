#!/bin/bash

# User who is running the action, e.g. "user=kittykat"
user=
# Use access tokens to access GitHub
token=
# GitHub organisation or user, e.g. "org=kittykat"
org=
# GitHub repository name, e.g. "repo=shared-scripts"
repo=

# this is the contents of a page past the last real page:
emptypage='[
]'

# loop indefinitely
page=0
while true; do
  page=$((page + 1))

  # minor improvement: use a variable, not a file.
  # also, you don't need to echo variables, just use them
  result=$(curl \
    -u "$user:$token" \
    -s \
    "https://api.github.com/repos/$org/$repo/labels?per_page=100&page=$page")

  # if the result is empty, break out of the inner loop
  [ "$result" = "$emptypage" ] && break

  echo "$result" > ${repo}-labels${page}.json
  
  [ "$page" != 1 ] && \
    jq -s '[.[][]]' ${repo}-labels$((page - 1)).json ${repo}-labels${page}.json > tmp.json && \
    rm ${repo}-labels$((page - 1)).json && \
    mv tmp.json ${repo}-labels${page}.json

done

mv ${repo}-labels$((page - 1)).json ${org}-${repo}-incoming.json
mlr --ijson --ocsv cat ${org}-${repo}-incoming.json > ${org}-${repo}.csv
rm ${org}-${repo}-incoming.json

# Next steps:
# 1. Edit the CSV
# 2. Run 'mlr --icsv --ojson cat org-repo.csv > org-repo-incoming.json
# 3. Run 'jq . -s org-repo-incoming.json > org-repo.json
# 4. Run the push-labels.sh script
