# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"
#ZSH_THEME="catppuccin"
#CATPPUCCIN_FLAVOR="mocha"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
findf () {
  [ $# -lt 1 ]  && {
    echo "Error: seach term is missing!"
     return
  }

  local carg=""

  [ $# -eq 2 ]  &&  {
    carg="-C$2"
  }
  unalias grep
  local find=$(which find)
  local grep=$(which grep)
  local find_args1=( . -type f -exec )
  local gargs=( -Hn --color )

  ${find} ${find_args1} ${grep} ${carg} ${gargs} ${1} {} \;
}

function sshaccess(){ 
    local sshhost dc;
    sshhost=${1};
    shift;
    dc="$(echo -n ${sshhost} | sed -r -e "s/.*\.([a-z0-9-]*)\.profitbricks\.net/\1/g")";
    export VAULT_ADDR=https://vault.any.profitbricks.net;
    passkeys="$(gopass ${USER}/passwords/ionos/ldap)";
    export VAULT_TOKEN=$(vault login -method ldap -path uildap -token-only username=$(gpw .user) password=$(gpw .pass));
    vault read -field data -format json secret/data/sre/awx/${dc}/${sshhost}/ | jq -r .ssh_key | tee /tmp/${sshhost}_ssh.key > /dev/null;
    chmod 600 /tmp/${sshhost}_ssh.key;
    ssh -l ionos -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/${sshhost}_ssh.key ${sshhost} $@
}

function scpaccess(){
    local sshhost dc file dest;
    file=${2};
    dest=${3};
    sshhost=${1};
    shift;
    dc="$(echo -n ${sshhost} | sed -r -e "s/.*\.([a-z0-9-]*)\.profitbricks\.net/\1/g")";
    export VAULT_ADDR=https://vault.any.profitbricks.net;
    passkeys="$(gopass ${USER}/passwords/ionos/ldap)";
    export VAULT_TOKEN=$(vault login -method ldap -token-only username=$(gpw .user) password=$(gpw .pass));
    vault read -field data -format json secret/data/sre/awx/${dc}/${sshhost}/ | jq -r .ssh_key | tee /tmp/${sshhost}_ssh.key > /dev/null;
    chmod 600 /tmp/${sshhost}_ssh.key;
    su -c 'scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/${sshhost}_ssh.key ionos@${sshhost}:${file} ${dest}'
}

function gpw () { 
    echo "${passkeys}" | yq e "${1}" -
}

#eval `dircolors ~/.dir_colors/dircolors`
eval $(dircolors ~/.dircolors)
eval "$(direnv hook zsh)"
prompt_context() {}
source <(kubectl completion zsh)
complete -C /usr/bin/terraform terraform
[[ -s "/home/mfriedrich/.gvm/scripts/gvm" ]] && source "/home/mfriedrich/.gvm/scripts/gvm"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# eval `gopass completion zsh`
export KUBECONFIG=$HOME/kubeconfigs.yaml
alias baty=bat -l yaml
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="${PATH}:/usr/local/bin"
export PATH="${PATH}:$HOME/.cargo/bin"
export PATH="${PATH}:$HOME/.local/bin/"
export PATH="${PATH}:$HOME/go/bin"
export SSH_AUTH_SOCK='/run/user/1000/gcr/ssh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval 
            fuck () {
                TF_PYTHONIOENCODING=$PYTHONIOENCODING;
                export TF_SHELL=zsh;
                export TF_ALIAS=fuck;
                TF_SHELL_ALIASES=$(alias);
                export TF_SHELL_ALIASES;
                TF_HISTORY="$(fc -ln -10)";
                export TF_HISTORY;
                export PYTHONIOENCODING=utf-8;
                TF_CMD=$(
                    thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
                ) && eval $TF_CMD;
                unset TF_HISTORY;
                export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
                test -n "$TF_CMD" && print -s $TF_CMD
            }

#returns all resources in a namespace
#usage: kga <namespace>
function kga {
    for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
        echo "Resource: " $i

        if [ -z "$1" ]
        then
            kubectl get --ignore-not-found ${i}
        else
            kubectl -n ${i} get --ignore-not-found ${i}
        fi
    done
}

#keychain ~/.ssh/id_rsa
#. ~/.keychain/${HOST}-sh
#. ~/.keychain/${HOST}-sh-gpg   

# Ensure XDG_RUNTIME_DIR is set
if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR=$(/run/user/$(id -u)-runtime-dir.XXX)
fi
 
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
