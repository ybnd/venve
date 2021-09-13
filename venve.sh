#!/bin/bash

# Basic shell utility for Python virtual environments
# Usage: source this script in your .bashrc or .zshrc file & use the following functions
#   ve <name> <commands?>           activate an environment (and execute any provided commands)
#   nve <name> <python suffix?>     create a new environment
#   lnve <path>                     link an existing environment
#   cdve <name>                     cd into an environment (or the venve directory if no name is given)
#   lsve                            list all environments
# 
# To remove an environment, simply remove its folder from 

# Requirements: at least one venv-compatible Python installation


# Variables; set values before sourcing this script to override defaults
if [[ -z "$VENVE_DIR" ]]; then
    # environments will be installed here
    VENVE_DIR="$HOME/.local/share/venve"
fi
if [[ -z "$VENVE_DEFAULT_PYTHON_SUFFIX" ]]; then
    # this suffix will be added to python if no suffix is specified
    VENVE_DEFAULT_PYTHON_SUFFIX=""
fi


ve() {
    if [[ -z $1 ]]; then
        echo "venve.sh ve(): No name provided!"
        return 1
    fi

    source "$VENVE_DIR/$1/bin/activate"
    alias exit="deactivate && unalias exit"
    
    if [[ $# -gt 1 ]]; then
        ${@:2} || return 1
        deactivate
    fi
}

nve() {
    if [[ -z $1 ]]; then
        echo "venve.sh nve(): No name provided!"
        return 1
    fi

    local PYTHON='python'
    if [[ -z $2 ]]; then
        PYTHON+="$VENVE_DEFAULT_PYTHON_SUFFIX"
    else
        PYTHON+="$2"
    fi
    
    "$PYTHON" -m venv "$VENVE_DIR/$1" || return 1
    ve $1
    pip install --upgrade pip
    
    __venve
}

lnve() {
    if [[ $# -lt 2 ]]; then
        echo "venve.sh lnve(): Please provide a target path and name for the environment!"
        return 1
    fi
    
    local OG_PWD=$(pwd)

    cd "$VENVE_DIR"
    ln -s "$(realpath $1)" "$2"
    cd "$OG_DIR"
    
    __venve
}

cdve() {
    cd "$VENVE_DIR/$1"
}

lsve() {
    ls "$VENVE_DIR"
}

__venve() {
    if [[ -n "$BASH_VERSION" ]]; then
        complete -W "$(lsve)" ve
        complete -W "$(lsve)" cdve
    
        export -f ve
        export -f nve
        export -f lnve
        export -f cdve
        export -f lsve
    elif [[ -n "$ZSH_VERSION" ]]; then
        autoload -U compinit; compinit

        _completion() {
            compadd $(lsve)
        }

        compdef _completion ve
        compdef _completion cdve
    else
        echo "venve.sh: Current shell '$0' is not supported!"
        return 1
    fi

}

__venve

