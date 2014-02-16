# /etc/bash.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="\[\e[1;34m\][\$(if [[ \$? == 0 ]]; then echo \"\[\033[1;37m\]-\"; else echo \"\[\033[1;31m\]x\"; fi)\[\e[1;34m\]]\[\e[1;34m\][\[\e[1;37m\]\u\[\e[1;36m\]@\[\e[1;37m\]\H \W\[\e[1;34m\]]$\[\e[0m\] "
PS2='> '
PS3='> '
PS4='+ '

case ${TERM} in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
                                                        
    ;;
  screen)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
    ;;
esac

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion


#Colors for common commands
alias ls="ls --color=auto"
alias ll="ls -l"
alias dir="dir --color=auto"
alias grep="grep --color=auto"
alias dmesg='dmesg --color'
alias pacman="pacman --color=auto"
alias vi="vim"
alias getip='ifconfig | grep -E "inet ([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v "127.0.0.1" | sed "s/^\s*//" | cut -f2 -d" "'
alias motd='clear; /etc/motd.sh'
alias users='cat /etc/passwd | awk -F ":" "{if(\$3 > 999) print}" | column -ts:'
#System alias's

/etc/motd.sh
