# ---- DevOps Aliases & Functions ----
# Helper: check if a command exists (used to avoid broken aliases)
_has() { command -v "$1" >/dev/null 2>&1; }

# Custom
alias tfdocs='terraform-docs markdown table --output-file README.md --output-mode inject .'
alias tfdocs-m='terraform-docs markdown table --output-file README.md --output-mode inject . --lockfile=false'

# --- Git ---
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch -vv'
alias gcm="git commit -malias"
alias gcm="git commit -m"

# --- Terraform ---
_has terraform && {
  alias tf='terraform'
  alias tfi='terraform init'
  alias tfv='terraform validate'
  alias tff='terraform fmt -recursive'
  alias tfp='terraform plan'
  alias tfa='terraform apply'
  alias tfd='terraform destroy'
  alias tfs='terraform state list'
  alias tft='terraform test'
}

# --- Docker / Compose ---
_has docker && {
  alias d='docker'
  alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias di='docker images'
  alias dlogs='docker logs -f --tail=200'
  alias dex='docker exec -it'
  alias drm='docker rm -f'
  alias drmi='docker rmi'
}
_has docker && docker compose version >/dev/null 2>&1 && {
  alias dc='docker compose'
  alias dcu='docker compose up -d'
  alias dcd='docker compose down'
  alias dcb='docker compose build'
  alias dcl='docker compose logs -f --tail=200'
}

# --- Kubernetes (kubectl, kubectx/kubens, k9s optional) ---
_has kubectl && {
  alias k='kubectl'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kdel='kubectl delete'
  alias kga='kubectl get all'
  alias kgp='kubectl get pods'
  alias kgpw='kubectl get pods -o wide'
  alias kgn='kubectl get nodes -o wide'
  alias kl='kubectl logs'
  alias klf='kubectl logs -f --tail=200'
  alias ke='kubectl edit'
  alias kx='kubectl exec -it'

  # Quick namespace/context helpers
  kns() { kubectl config set-context --current --namespace="$1"; }
  kctx() { kubectl config use-context "$1"; }
  kpods() { kubectl get pods -n "${1:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}"; }

  # Tail logs for a pod by prefix (optional namespace as $2)
  klogp() {
    local ns="${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}"
    local pod
    pod="$(kubectl get pods -n "$ns" --no-headers | awk '/^'"$1"'/ {print $1; exit}')"
    [ -n "$pod" ] && kubectl logs -f -n "$ns" --tail=200 "$pod" || echo "Pod mit Präfix '$1' nicht gefunden (Namespace: $ns)"
  }
}
#_has kubectx && alias kctx='kubectx'
_has kubens && alias kns='kubens'
_has k9s && alias k9='k9s'

# --- Helm ---
_has helm && {
  alias h='helm'
  alias hls='helm ls -A'
  alias hi='helm install'
  alias hu='helm upgrade'
  alias huc='helm upgrade --install'
  alias hdiff='helm diff upgrade --allow-unreleased'  # benötigt plugin 'helm-diff'
}

# --- Azure CLI / Kubelogin (optional) ---
_has az && {
  alias azl='az login'
  alias aksget='az aks get-credentials --overwrite-existing --name'
  # usage: aksctx <resource-group> <aks-name>
  aksctx() { az aks get-credentials -g "$1" -n "$2" --overwrite-existing; }
}

# --- Terragrunt ---
_has terragrunt && {
   alias tg='terragrunt'
}

# --- Kubectx ---
#_has kubectx && {
#alias kx="kubectx"
#}


# --- General QoL ---
alias please='sudo $(fc -ln -1)'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# Reload shell config quickly
alias src='source ~/.bashrc && echo "reloaded ~/.bashrc"'

# Script for delete all Git Branches other than Main
git_prune_to_main() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  git stash push -u -m "auto-prune-$(date +%s)" || return 1
  git checkout main || return 1
  git pull || return 1
  git branch --format '%(refname:short)' \
    | grep -v '^main$' \
    | xargs -r git branch -D
}

alias gptm='git_prune_to_main'

# ---- end ----
# ---- end ----
