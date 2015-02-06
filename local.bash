
#
# Scripts to bootstrap a local dev environment. Made to be sourced.
#

_info() { local blue=4; _out $blue "$@"; }
_error() { local red=1; _out $red "$@"; }
_changed() { local yellow=3; _out $yellow $1 $(_strong $2) "${@:3}"; }
_unchanged() { local green=2; _out $green $1 $(_strong $2) "${@:3}"; }
_strong(){ local purple=5; printf "$(tput bold)$(tput setaf $purple)$1$(tput sgr0)"; }
_out() { printf "$(tput bold)$(tput setaf $1)%14s ==>$(tput sgr0) ${*:3}\n" "[$2]"; }

brew_setup() {
  # brew requires the os x developer tools
  if "xcode-select" --print-path 1>/dev/null; then
    _unchanged brew/setup xcode-tools installed
  else
    sudo "xcode-select" --install
    _changed brew/setup xcode-tools installing...
  fi

  if hash brew; then
    _unchanged brew/setup brew installed
  else
    _changed brew/setup brew installing..
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # to add the `homebrew versions` command
  brew_tap homebrew/boneyard
  _info brew/update updating package list...
  brew update 1>/dev/null
}

brew_tap() {
  local name=$1

  if brew tap | grep -q $name; then
    _unchanged brew/tap $name tapped
  else
    _changed brew/tap $name tapping...
    brew tap $name
    _info brew/update updating package list...
    brew update 1>/dev/null
  fi
}

brew_install() {
  local name=${1%==*}
  # when specifing a name with slashes, the actual package name is the basename
  local short=$(basename $name)
  local version=""
  # allow specifying additional options that are passed through to brew install
  local options="${@:2}"
  local installed=false

  # allow specifying versions like "package==1234"
  [[ $1 == *==* ]] \
    && version=${1#*==};

  if [[ -n $version ]]; then
    if ! brew ls --versions $short | grep -q $version; then
      # the root directory of the brew repo
      pushd /usr/local/Library
      # checkout the correct version of the brew formula
      # FIXME: this will fail if the selected version isn't available
      $(brew versions $short | grep $version | cut -d' ' -f2-)
      popd
      # we might be installing over another version
      if brew ls --versions $short | grep -q $short; then
        brew unlink $name
      fi
    else
      installed=true
    fi
  elif brew ls --versions $short | grep -q $short; then
    installed=true
  fi

  if $installed; then
    _unchanged brew/install $name installed
  else
    _changed brew/install $name installing...
    brew install $name $options
  fi
}

cask_setup() {
  brew_install "caskroom/cask/brew-cask"
}

cask_install() {
  local name=$1

  if brew cask list $name 1>/dev/null; then
    _unchanged cask/install $name installed
  else
    _changed cask/install $name installing...
    brew cask install $name
  fi
}

pip_setup() {
  if hash pip; then
    _unchanged pip/setup pip installed
  else
    _changed pip/setup pip installing...
    sudo -H easy_install pip
  fi
}

pip_install() {
  local name=$1

  if pip show $name 1>/dev/null; then
    _unchanged pip/install $name installed
  else
    _changed pip/install $name installing...
    sudo -H pip install $name
  fi
}

brew_enable() {
  local name=$1

  if [[ -e ~/Library/LaunchAgents/homebrew.mxcl.$name.plist ]]; then
    _unchanged brew/enable $name enabled
  else
    _changed brew/enable $name enabling...
    ln -sfv /usr/local/opt/$name/*.plist ~/Library/LaunchAgents;
  fi
}

brew_start() {
  local name=$1

  if [[ -n $(launchctl list | awk -v n=$name '$1 != "-" && $3 == ("homebrew.mxcl." n)') ]]; then
    _unchanged brew/start $name started
  else
    _changed brew/start $name starting...
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.$name.plist
  fi
}
