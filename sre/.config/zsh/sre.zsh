# sre.zsh — aliases y autocompletado del perfil sre

if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
  alias k='kubectl'
  compdef k=kubectl
  alias kctx='kubectx'
  alias kns='kubens'
fi

command -v helm >/dev/null && source <(helm completion zsh)

if command -v terraform >/dev/null; then
  alias tf='terraform'
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v terraform)" terraform
fi

command -v aws_completer >/dev/null && {
  autoload -U +X bashcompinit && bashcompinit
  complete -C aws_completer aws
}
