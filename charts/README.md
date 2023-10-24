## Examples

### Install Kubernetes dashboard (optional)
```
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard --set "web.containers.args={--enable-skip-login}"
kubectl apply -f k8s-dashboard-admin-user.yaml
```

#### To get the token
```
kubectl get secret -n kubernetes-dashboard admin-user -o jsonpath="{.data.token}" | base64 -d
```

### Install Terraria servers (worlds)
```
helm install apple charts/terraria --set server.service.type=NodePort,server.service.nodePort=30001,image.terraria.tag=tshock-1.4.4.9,world.persistentVolume.enabled=false
helm install pear  charts/terraria --set server.service.type=NodePort,server.service.nodePort=30002,image.terraria.tag=tshock-1.4.4.9,world.persistentVolume.enabled=false
```

### Install Terre
Auto discovery is enabled by default in the same namespace, so the proxy will find the two terraria servers.
```
helm install proxy charts/terre --set proxy.service.nodePort=30000
```
