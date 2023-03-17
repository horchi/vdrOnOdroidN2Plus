
if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
fi

if [ -f ~/.bash_user ]; then
   source ~/.bash_user
fi

if [[ -f /etc/lsb-release ]]; then
   source ~/.bashrc_ubuntu
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

export EDITOR=vi
export PATH='/opt/bin:/storage/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa"

cd

