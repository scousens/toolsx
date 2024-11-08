#! /bin/bash

# MYGIT_DIR is set in .zshrc
d1=$1
d2=$2
cd $MYGIT_DIR

if [ ! -z "$d1" ]; then
  case "$d1" in
    g | gh )
      d1="gh"
      ;;
    n | ntlie | nt )
      d1="nt"
      ;;
    f | fork )
      d1="fork"
      ;;
    scoloco )
      d1="scoloco"
      ;;
  esac  
  if [ -d "$d1" ]; then
    cd "${d1}"
  fi

  if [ -d "$d2" ]; then
    cd $d2
  elif [ ! -z $d2 ]; then
    case "$d2" in
      es | env )
        d2="env-service"
        ;;
      jp )
        d2="jenkins-pipelines"
        ;;
      pep | penv )
        d2="pytest-env-plugin"
        ;;
      naw | nmc )
        d2="nmc-api-wrapper"
        ;;
      u )
        d2="unity"
        ;;
      pa | a )
        d2="pytest-automation"
        ;;
      * )
        for name in $(ls) ; do
          #echo "$name; 1: ${d2:0:1}. 2: ${d2:1:1}."
          if [[ ${#d2} -eq 2 ]]; then
            if [[ $name =~ ^(${d2:0:1}[a-z0-9]+)-(${d2:1:1}[a-z0-9]+) ]]; then
              d2=$name
              break
            fi
          elif [[ ${#d2} -eq 3 ]]; then
            if [[ $name =~ ^(${d2:0:1}[a-z0-9]+)-(${d2:1:1}[a-z0-9]+)-(${d2:2:1}[a-z0-9]+) ]]; then
              d2=$name
              break
            fi
          elif [[ -d $d2 ]]; then
            d2=$name
            break
          elif [[ ${#d2} -eq 1 ]]; then
            if [[ $name =~ ^(${d2:0:1}[a-z0-9]+) ]]; then
              d2=$name
              break
            fi
          fi
        done
        echo "Dynamic code result: $d2"
        ;;
    esac  
    if [ -d "$d2" ]; then
      cd $d2
    fi
  fi
fi
echo "final:" `pwd` " [$d1/$d2]"
