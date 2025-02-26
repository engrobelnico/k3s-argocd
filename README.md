# deploy argocd on K3S

kubectl port-forward svc/argocd-server -n argocd 8080:8085

kctl apply -f   argocd/argocd-ingress-route.yaml
https://kube.local/argocd-server/login


argocd login kube.local:443 --grpc-web-root-path /argocd-server --insecure  --username admin --password


