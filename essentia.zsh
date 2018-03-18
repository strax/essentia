color() {
  if [[ -n $1 ]]; then
    echo -n "%F{$1}"
  else
    echo -n "%f"
  fi
}

strax_dir() {
  local dir

  if is_git && ! is_git_root; then
    local git_root=${$(git rev-parse --absolute-git-dir):h}
    dir="$(color magenta)$git_root:t${$(expr $(pwd -P) : "$git_root\(.*\)")}$(color)"
 else
    dir="%~"
  fi
  
  echo -n "$dir"
}

strax_git_dirty() {
  is_git_dirty && echo -n "$(color yellow)*$(color)"
}

is_git_dirty() {
  ! git diff-index --quiet HEAD &>/dev/null
}

is_git() {
  command git rev-parse --is-inside-work-tree &>/dev/null
}

is_git_root() {
  command test $(git rev-parse --show-toplevel) = $(pwd)
}

strax_git_info() {
  if $(is_git); then 
    local prefix="\ue0a0"
    echo -n " %{%b$(color blue)%}${prefix} ${vcs_info_msg_0_}$(strax_git_dirty)%{%B%}"
  fi
}

strax_prompt_arrow() {
  local arrow_color
  [[ RETVAL -eq 0 ]] && arrow_color="$(color green)" || arrow_color="$(color red)"
  echo -n "%{%b$arrow_color%}->$(color)"
}

strax_prompt() {
  RETVAL=$?
  echo -n "$(strax_dir)$(strax_git_info) $(strax_prompt_arrow) "
}

precmd() {
  vcs_info
}

prompt_strax_setup() {
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  prompt_opts=(cr percent sp subst)

  # Borrowed from promptinit, sets the prompt options in case the prompt was not
  # initialized via promptinit.
  setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

  VIRTUAL_ENV_DISABLE_PROMPT=true
  
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git*' formats '%b'

  PROMPT='$(strax_prompt)'
}

# Entry point for `prompt`
prompt_strax_setup "$@"