## Examples

### Install Kubernetes dashboard (optional)
```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
--version 6.0.8 \
--create-namespace \
--namespace kubernetes-dashboard \
--set "extraArgs={--token-ttl=0, --enable-skip-login}" \
--set metrics-server.enabled=true \
--set "metrics-server.args={--kubelet-preferred-address-types=InternalIP, --kubelet-insecure-tls}" \
--set metricsScraper.enabled=true
kubectl apply -f charts/k8s-dashboard-admin-user.yaml
```

#### To get the token
```
kubectl get secret -n kubernetes-dashboard admin-user -o jsonpath="{.data.token}" | base64 -d
```

### Install Terraria servers (worlds)
```
helm install apple charts/terraria --set server.service.type=NodePort,server.service.nodePort=30001,image.terraria.tag=tshock-1.4.4.9,world.persistentVolume.enabled=false
helm install pear  charts/terraria --set server.service.type=NodePort,server.service.nodePort=30002,image.terraria.tag=tshock-1.4.4.9,world.persistentVolume.enabled=false,world.tileProvider=constileation
```

### Install Terre
Auto discovery is enabled by default in the same namespace, so the proxy will find the two terraria servers.
```
helm install proxy charts/terre --set proxy.service.nodePort=30000
```
**Note: Terre does currently not support Terraria 1.4.5.x yet.**
