$baseRegistryName = ""
$imageName = ""
$destRegistryName = ""

docker login $baseRegistryName.azurecr.io
# provide username and password

docker pull $baseRegistryName.azurecr.io/$imageName

docker tag $baseRegistryName.azurecr.io/$imageName $destRegistryName.azurecr.io/$destRegistryName/$imageName

docker login $destRegistryName.azurecr.io
# provide username and password

docker push $destRegistryName.azurecr.io/$destRegistryName/$imageName
