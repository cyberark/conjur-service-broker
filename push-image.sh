TAG="${1:-$(< VERSION)-$(git rev-parse --short HEAD)}"

SOURCE_IMAGE='conjur-service-broker'
INTERNAL_IMAGE='registry.tld/conjurinc/conjur-service-broker'

function main() {
  echo "TAG = $TAG"

  tag_and_push $INTERNAL_IMAGE $TAG
  tag_and_push $INTERNAL_IMAGE_NEW $TAG

  if [ "$BRANCH_NAME" = "master" ]; then
    local latest_tag='latest'
    local stable_tag="$(< VERSION)-stable"

    echo "TAG = $stable_tag, stable image"

    tag_and_push $INTERNAL_IMAGE $latest_tag
    tag_and_push $INTERNAL_IMAGE $stable_tag      
  fi
}

function tag_and_push() {
  local image="$1"
  local tag="$2"

  docker tag "$SOURCE_IMAGE" "$image:$tag"
  docker push "$image:$tag"
}

main
