# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH

alias c=clear
alias rake='bundle exec rake'
alias vi=vim

export EDITOR=vim
export GIT_EDITOR=vim

# Customize the prompt for git.
function parse_git_dirty {
  regex="nothing to commit.*working directory clean"
  [[ $(git status 2> /dev/null | tail -n1) =~ $regex ]] || echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}
export CLICOLOR=1
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$(parse_git_branch)\$ "
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=UTF-8
