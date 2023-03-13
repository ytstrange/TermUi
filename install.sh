#!/bin/bash

bl(){
  while getopts 'rgbpfias:h' opt; do
    case "${opt}" in
      r)var3="\e[0;31m";;g)var3="\e[0;32m";;
      b)var3="\e[0;34m";;p)var3="\e[0;2m";;
      f)var3+="\e[1m";;i)var3+="\e[3m";;
      a)var3="\e[0;31m\e[3m\e[1m[∆] ";;
      s)var3="\e[0;32m\e[3m\e[1m[√] ";;
      ?|h)
        echo -e "\e[1mUsage: \e[0;m";
        echo -e " -r  red\n -g  green\n -b  blue\n -p  pearly<Grey>
 -f  fearless<Bold>\n -i  italic\n -a  alert\n -s  success";return 1;;
    esac
  done
  if [[ -z "${2}" ]]; then echo -e "\e[0;32m\e[3m\e[1m[√] Hello World\e[0;m";return 1;
  else echo -e "${var3}${2}\e[0;m";return 0;fi
}

Spin(){
  echo;_PID=${!};i=1;_spins=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█');echo -n ' ';
  while [ -d /proc/${_PID} ];do
  for _snip in ${_spins[@]} ; do echo -ne "\r\e[0;32mLoading...[${_snip}]\e[0;m ";sleep 0.2;done;done;echo;return;
}

ping_off(){
  (ping -c 3 google.com) &> /dev/null 2>&1
  if [[ "${?}" != 0 ]];then
    echo
	  bl -ai "Please Check Your Internet Connection...";
    return 0 # return true
  else
    return 1 # return false
	fi
}

pkg_build(){
  pkg_info=${1}
  _pkg_not_found="Sorting... Done
Full Text Search... Done"
  (ping -c 3 google.com) &> /dev/null 2>&1;
  if [[ "${?}" != 0 ]]; then echo;echo -e "\e[0;31m\e[3m\e[1m[∆] Internet Connection Error...\e[0;m";echo;return 1;
  elif [[ -z "${pkg_info}" ]]; then echo;echo -e "\e[0;31m\e[3m\e[1m[∆] Package Parameter is Empty...\e[0;m";echo;return 1;
  elif [[ "$(eval "apt search ${pkg_info}")"=="${_pkg_not_found}" ]]; then echo;echo -e "\e[0;31m\e[3m\e[1m[∆] Package does not Exist...\e[0;m";echo;return 1;
  fi
}

# Process --install figlet "Install Figlet"

Process(){
  process_func=${1} # install,git clone,dnload
  process_args=${2} # args for install,git clone,dnload
  process_identity=${3} # args for name
  if [[ -z "${process_func}" ]]; then
    exit
  elif [[ -z ${process_args} ]]; then
    exit
  elif [[ -z ${process_identity} ]]; then
    exit
  fi
  if ping_off; then
    exit
  fi
  # args variable for Process
  # process_variable=""
  case ${process_func} in
    --install)
      process_variable=""
      _build_pkg_var1=$(pwd)
      _build_pkg_var2="com.termux"
      if [[ ${_build_pkg_var1==*"${_build_pkg_var2}"*} ]]; then
        process_variable+="apt-get install "
      else
        process_variable+="sudo apt-get install "
      fi
      process_variable+="${process_args}"
      process_variable+=" -y &> /dev/null"
      # process_variable has apt
      # eval "${process_variable}" || exit
      ;;
    --gitcl)
      process_variable=""
      process_variable+="git clone"
      process_variable+=" ${process_args}"
      gitcl_file="${process_identity}"
      process_identity="${4}"
      process_variable+=" ${gitcl_file}"
      process_variable+=" --depth 1"
      process_variable+=" &> /dev/null"
      # eval "${process_variable}" ||
      ;;
    --dnload)
      process_variable=""
      process_variable+="curl -OL "
      process_variable+="${process_args}"
      process_variable+=" &> /dev/null"
      # eval "${process_variable}" || exit
      ;;
    *)
      exit
      ;;
  esac
  count=0
  total=34
  pstr="[======================================]"
  echo
  bl -si "${process_identity}"
  echo
  while [ $count -lt $total ]; do
    eval ${process_variable}
    count=$(( $count + 1 ))
    pd=$(( $count * 73 / $total ))
    printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr
  done
  echo
  return 1
}

phase2(){
  if [[ -f "${HOME}/.ui/p2.dl" ]]; then
    exit
  else
    {
      Process --gitcl "https://github.com/ohmyzsh/ohmyzsh.git" "${HOME}/.oh-my-zsh" "Downloading OhMyZsh"
      Process --gitcl "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${HOME}/.zsh-syntax-highlighting" "Downloading zsh-syntax-highlighting"
      echo
    } && {
      if [[ -e "${HOME}/.zshrc" ]]; then
        mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak.$(date +%Y.%m.%d-%H:%M:%S)"
      fi
      cp "${HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${HOME}/.zshrc"
      sed -i '/^ZSH_THEME/d' "${HOME}/.zshrc"
      sed -i '1iZSH_THEME="agnoster"' "${HOME}/.zshrc"
      echo "alias chcolor='${HOME}/.termux/colors.sh'" >> "${HOME}/.zshrc"
      echo "alias chfont='${HOME}/.termux/fonts.sh'" >> "${HOME}/.zshrc"
    } && {
      echo "source ${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "${HOME}/.zshrc"
    } && {
      chsh -s zsh
    } && {
      chmod +x ${HOME}/.termux/colors.sh
      chmod +x ${HOME}/.termux/fonts.sh
      echo -e "\e[0;m"
      ${HOME}/.termux/colors.sh
      ${HOME}/.termux/fonts.sh
      echo
      echo "1" >> "${HOME}/.ui/p2.dl"
      bl -si "Please restart Termux app..."
      rm -rf ${HOME}/../usr/etc/motd* &> /dev/null
      echo
      exit
    }
  fi
}

phase1(){
  if [[ -f "${HOME}/.ui/p1.dl" ]]; then
    phase2
  else
    if [[ -d "${HOME}/.termux" ]]; then
      mv "${HOME}/.termux" "${HOME}/.termux.bak.$(date +%Y.%m.%d-%H:%M:%S)"
    fi
    Process --dnload "https://github.com/strangecode4u/TermUi/raw/main/TermUi.zip" "Downloading TermUi"
    echo -e "\e[0;2m\e[3m"
    unzip -d ${HOME} TermUi.zip &> /dev/null
    echo -e "\e[0;m"
    rm TermUi.zip
    echo "1" > ${HOME}/.ui/p1.dl
    phase2
  fi
}

depends(){
  Process --install git "Installing Git"
  Process --install zsh "Installing Zsh"
  phase1
}

config_files(){
  if [[ -d "${HOME}/.ui" ]]; then
    depends
  else
    mkdir ${HOME}/.ui && depends
  fi
}

setup_storage(){
  clear
  echo
  if [[ -d "${HOME}/storage/shared" ]]; then
    bl -si "Storage permission is already allowed..."
  else
    bl -si "Please allow storage permission..."
    eval "termux-setup-storage"
  fi
  config_files
}

setup_storage