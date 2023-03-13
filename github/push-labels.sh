#!/bin/bash

# User who is running the action, e.g. "user=kittykat"
user=
# Use access tokens to access GitHub
token=
# GitHub organisation or user, e.g. "org=kittykat"
org=
# GitHub repository name, e.g. "repo=shared-scripts"
repo=

# from https://docs.github.com/en/rest/reference/issues#update-a-label--code-samples
# -X is request method (from API)
# -H is header
# -d is data

update_name()
{
  url=$1
  new_name=$2
  hex=$3
  curl -X PATCH \
  -u "$user:$token" \
  -H "Accept: application/vnd.github.v3+json" \
  "$url" \
  -d "{\"new_name\":\"$new_name\",\"color\":\"$hex\"}"
}

update_colour()
{
  url=$1
  hex=$2
  curl \
  -X PATCH \
  -u "$user:$token" \
  -H "Accept: application/vnd.github.v3+json" \
  "$url" \
  -d "{\"color\":\"$hex\"}"
}


# Get URL, new name if there is one and colour
content=$(jq -c '.[]|{link: .url, new_label: .new_name, colour: .color}' < ${org}-${repo}.json)

IFS=$'\n'
for row in $content; do
  link=$(echo $row|jq -r .link)
  new_name=$(echo $row|jq -r .new_label)
  colour=$(echo $row|jq -r .colour)

echo "The three things that are returned: "$link","$new_name","$colour""

# "x${new_name}" = "x" is the correct test
# ${new_name} = "xnull" is in case there's a typo in the csv 
  if [ "x${new_name}" = "x" ] ||  [ "x${new_name}" = "xnull" ]
  then
    echo "Run 'update_colour $link $colour'"
    update_colour "$link" $colour
  else
    echo "Run 'update_name $link $new_name $colour'"
    update_name "$link" "$new_name" $colour
  fi
done
