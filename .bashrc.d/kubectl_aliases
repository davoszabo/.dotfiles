alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kgpo='kubectl get pods'
alias wkgpo='watch kubectl get pods'
alias kgns='kubectl get namespaces'
alias kgno='kubectl get nodes -o wide'
alias kgc='kubectl config get-contexts'

kcns() {
    kubectl config set-context --current --namespace="$1"
}

kex() {
    kubectl exec -it $1 -- bash
}

kto() {
    kubectl taint nodes $1 node.kubernetes.io/out-of-service:NoSchedule
}

kuto() {
    kubectl taint nodes $1 node.kubernetes.io/out-of-service-
}

