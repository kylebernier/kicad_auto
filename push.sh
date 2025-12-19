# Only push container if there are no file changes
if [[ -z "$(git status -s)" ]]; then
    # Build the container
    docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t ghcr.io/kylebernier/kicad_auto:latest .
    # Get the git hash
    GIT_HASH=`git rev-parse --short HEAD`
    # Get the kicad version
    KICAD_VERSION=`docker run --rm ghcr.io/kylebernier/kicad_auto:latest kicad_version.py`
    # Creates tags
    docker tag ghcr.io/kylebernier/kicad_auto:latest ghcr.io/kylebernier/kicad_auto:${KICAD_VERSION}-${GIT_HASH}
    docker tag ghcr.io/kylebernier/kicad_auto:latest ghcr.io/kylebernier/kicad_auto:${KICAD_VERSION}
    # Push tags
    docker push ghcr.io/kylebernier/kicad_auto:${KICAD_VERSION}-${GIT_HASH}
    docker push ghcr.io/kylebernier/kicad_auto:${KICAD_VERSION}
    docker push ghcr.io/kylebernier/kicad_auto:latest
else
    echo "Commit changes before pushing."
fi
