# Delete all docker images matching a pattern
docker rmi -f $(docker images | grep <pattern> | tr -s ' ' | cut -d ' ' -f 3)
