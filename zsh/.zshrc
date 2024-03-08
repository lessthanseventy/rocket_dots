# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export GTK_THEME="Catppuccin-Mocha-Standard-Lavender-Dark"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' widget-style menu-select

# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# options that should be mostly pretty agreeable

# no c-s/c-q output freezing
setopt noflowcontrol
# allow expansion in prompts
setopt prompt_subst
# this is default, but set for share_history
setopt append_history
# save each command's beginning timestamp and the duration to the history file
setopt extended_history
# display PID when suspending processes as well
setopt longlistjobs
# try to avoid the 'zsh: no matches found...'
setopt nonomatch
# report the status of backgrounds jobs immediately
setopt notify
# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt hash_list_all
# not just at the end
setopt completeinword
# use zsh style word splitting
setopt noshwordsplit
# allow use of comments in interactive code
setopt interactivecomments

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_all_dups   # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

plugins=(
	asdf
	bgnotify
  colored-man-pages
  command-not-found
	extract
  fzf
	git
	mix
  z
  zinsults
  zsh-autosuggestions
	zsh-history-substring-search
	zsh-syntax-highlighting
  fzf-tab
)

source $ZSH/oh-my-zsh.sh

# #Don't pollute history if commmand fails
# delete-failed-history() {
#   (( ? )) &&
#     hist -s d -1
# }
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd delete-failed-history

#Run exa on change directory
function chpwd() {
  emulate -L zsh
  eza -a --color=always --group-directories-first --icons
}

function tt() {
  mix test $1 --color --trace
}

#zsh-autosuggest settings
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
bindkey '^ ' autosuggest-accept

export NVIM_TUI_ENABLE_TRUE_COLOR=1

alias nvsql="nvim '+SQLua'"
alias nvim="nvim --listen ~/.cache/nvim/server.pipe"

export VISUAL="nvim"
export EDITOR="nvim"

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
fi

eval "$(starship init zsh)"
eval "$(navi widget zsh)"
eval "$(direnv hook zsh)"
eval "$(mcfly init zsh)"

#crashfix? https://groups.google.com/g/qtcontribs/c/cWQgcrbKUCM
export QT_LOGGING_RULES="*.debug=false"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# HSTR configuration - add this to ~/.zshrc
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors

export PATH="/home/andrew/.local/bin:$PATH"
export PATH="/home/andrew/.cargo/bin:$PATH"
export PATH="/home/andrew/.npm-global/lib/node_modules/*:$PATH"
# export PATH="/home/andrew/.local/share/nvim/mason/bin:/home/andrew/.asdf/installs/nodejs/18.9.1/bin:$PATH"
export PATH="$PATH:/home/andrew/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin"
export PATH="$PATH:/home/andrew/.spicetify"

export LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib"


export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
export KERL_BUILD_DOCS="yes"

# ASDF version manager
. /opt/asdf-vm/asdf.sh


#FZF 
export FZF_CTRL_T_OPTS="--preview='less {}' --height=100% --bind shift-up:preview-page-up,shift-down:preview-page-down"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export PATH=$HOME/.config/rofi/scripts:$PATH

# Aliases
alias zshconfig="nvim ~/.zshrc"
alias srczsh="source ~/.zshrc"

alias iex='iex --erl "-kernel shell_history enabled"'

alias lg="lazygit"

# Replace some more things with better alternatives
alias cat='bat --style header --style snip --style changes --style header'

alias ls='exa -a --color=always --group-directories-first --icons'  # all files and dirs
alias la='exa -al --color=always --group-directories-first --icons' # preferred listing
alias ll='exa -l --color=always --group-directories-first --icons'  # long format
alias lt='exa -aT --color=always --group-directories-first --icons' # tree listing
alias l.="exa -a | grep -E '^\.'"                                     # show only dotfiles

alias ip="ip -color"
