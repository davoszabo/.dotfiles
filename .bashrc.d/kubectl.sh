export KUBE_EDITOR=nvim

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

alias kc='kubectx'
kctx_old() {
  # Get the list of contexts
  ctxs=($(kubectl config get-contexts -o name))

  # Prompt the user to select a context
  echo "Select a Kubernetes context:"
  select ctx in "${ctxs[@]}"; do
    if [[ -n "$ctx" ]]; then
      # Switch to the selected context
      kubectl config use-context "$ctx"
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done
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

