zmodload zsh/datetime

function preexec() {
  __TIMER=$EPOCHREALTIME
}

function powerline_precmd() {
    local __DURATION=0

    if [ -n $__TIMER ]; then
        local __ERT=$EPOCHREALTIME
        __DURATION="$(($__ERT - ${__TIMER:-__ERT}))"
    fi

    local modules="venv,user,host,ssh,cwd,perms,git,hg,jobs,root"
    local modules_right="duration,exit"

    # conditional modules
    if command -v kubectl &>/dev/null; then
        modules_right="kube,$modules_right"
    fi

    if command -v gcloud &>/dev/null; then
        modules_right="gcp,$modules_right"
    fi

    if command -v awscli &>/dev/null; then
        modules_right="aws,$modules_right"
    fi

    eval "$($GOPATH/bin/powerline-go \
      -modules ${modules} \
      -duration $__DURATION \
      -error $? \
      -shell zsh \
      -eval \
      # -modules-right ${modules_right} \ # TODO: investigate why this causes each new line to be off by one position, maybe because of the broken exit module
      -theme ${HOME}/.config/zsh/pl_colors.json \
      -jobs ${${(%):%j}:-0})"

    unset __TIMER

    # Uncomment the following line to automatically clear errors after showing
    # them once. This not only clears the error for powerline-go, but also for
    # everything else you run in that shell. Don't enable this if you're not
    # sure this is what you want.

    #set "?"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    install_powerline_precmd
fi

