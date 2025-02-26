#!/bin/bash

# https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad

# Set the `errexit` option to make sure that
# if one command fails, all the script execution
# will also fail (see `man bash` for more 
# information on the options that you can set).
set -o errexit

main () {
    myNamespace=argocd
    NS=$(sudo kubectl get namespace $myNamespace --ignore-not-found);
    if [[ "$NS" ]]; then
        echo "Skipping creation of namespace $myNamespace - already exists";
    else
        echo "Creating namespace $myNamespace";
        sudo kubectl create namespace $myNamespace;
    fi;
    #kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sudo kubectl apply -k argocd
    while [[ $(sudo kubectl get pods --namespace argocd -l app.kubernetes.io/name=argocd-server -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]
    do 
        #echo "waiting for argocd-server pod" 
        sleep 1
    done
    sudo kubectl apply -f argocd/argocd-ingress-route.yaml
    #calicoctl  apply -f argocd/argocd-allow-egress.yaml --allow-version-mismatch
    sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    # show access path
    echo "https://kube.local/argocdèserver/login"
    # install argocli
    sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo chmod +x /usr/local/bin/argocd

}
main "$@"
