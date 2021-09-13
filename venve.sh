#!/bin/bash

# Basic shell utility for Python virtual environments
# Usage: source this script in your .bashrc file & use the following functions
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
    VENVE_DEFAULT_PYTHON_SUFFIX=""
fi

# Check is script is sourced, complain if it's not
( return 0 2>/dev/null ) || echo "venve.sh should be called ~ source!"


ve() {
    if [[ -z $1 ]]; then
        echo "No name provided!"
        return 1
    fi

    source "$VENVE_DIR/$1/bin/activate"
    
    if [[ $# -gt 1 ]]; then
        ${@:2} || return 1
        deactivate
    fi
}

nve() {
    if [[ -z $1 ]]; then
        echo "No name provided!"
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
    
    __venve_export
}

lnve() {
    if [[ $# -lt 2 ]]; then
        echo "Please provide a target path and name for the environment!"
        return 1
    fi
    
    local OG_PWD=$(pwd)

    cd "$VENVE_DIR"
    ln -s "$(realpath $1)" "$2"
    cd "$OG_DIR"
    
    __venve_export
}

cdve() {
    cd "$VENVE_DIR/$1"
}

lsve() {
    ls "$VENVE_DIR"
}

__venve_export() {
    complete -W "$(lsve)" ve
    complete -W "$(lsve)" cdve
    
    export -f ve
    export -f nve
    export -f lnve
    export -f cdve
    export -f lsve
}

__venve_export

