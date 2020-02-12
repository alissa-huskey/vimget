#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'
rootdir="$(cd -P "${BATS_TEST_DIRNAME}/.." && printf "%s" "${PWD}")"

# exit codes
local code_suc=0      # success
local code_err=1      # error
local code_env=102    # missing requirement
local code_usr=103    # invalid input
local code_fail=104   # external command failure

p() {
  while read -r line; do
    printf "# %s\n" "${line}" >&3
  done <<< "${@}"
}

rm_fixture_dir() {
  dir="$1"

  if [[ ! "${dir}" =~ test ]]; then
    p "ERROR Refusing to remove directory: '${dir}'"
    return 1
  fi

  rm -r "${dir}"
}

setup() {
  export NO_COLOR=1

  export HOME="${rootdir}/test"
  export VIMDIR="${rootdir}/test/.vim"
  export VIM_PLUGINS_DIR="${VIMDIR}/bundle"

  if [[ ! -d ${VIM_PLUGINS_DIR} ]]; then
    mkdir -p ${VIM_PLUGINS_DIR}
  fi
}

@test "vimget github.com/*" {
  run ${rootdir}/vimget --dry-run http://github.com/pseewald/vim-anyfold

  assert_success
  assert_line --index 0 "> cd ${VIM_PLUGINS_DIR}"
  assert_line --index 1 "> git clone --depth 1 http://github.com/pseewald/vim-anyfold"
  assert_equal 2 "${#lines[@]}"
}

@test "vimget *.git" {
  run ${rootdir}/vimget --dry-run git://sourceware.org/git/systemtap.git

  assert_success
  assert_line --index 0 "> cd ${VIM_PLUGINS_DIR}"
  assert_line --index 1 "> git clone --depth 1 git://sourceware.org/git/systemtap.git"
  assert_equal 2 "${#lines[@]}"
}

@test "vimget -Vd is translated to -V -d" {
  run ${rootdir}/vimget -Vd git://sourceware.org/git/systemtap.git

  assert_success
  assert_line --regexp "> cd .*$"
  assert_line --regexp "\| plugins-dir  \| .*$"
}

@test "when VIMDIR does not exist" {
  rm_fixture_dir "${VIMDIR}"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Unable to access provided VIMDIR:"
  assert_line --index 1 "     > /Users/alissahuskey/Dropbox/projects/vim/vimget/test/.vim"
  assert_equal 2 "${#lines[@]}"
}

@test "when VIM_PLUGINS_DIR does not exist" {
  rm_fixture_dir "${VIM_PLUGINS_DIR}"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Unable to access provided VIM_PLUGINS_DIR:"
  assert_line --index 1 "     > /Users/alissahuskey/Dropbox/projects/vim/vimget/test/.vim/bundle"
  assert_equal 2 "${#lines[@]}"
}

@test "when VIMDIR is not set a likely existing vimdir is found" {
  export VIMDIR=
  run ${rootdir}/vimget --verbose --dry-run https://github.com/junegunn/fzf.vim

  assert_success
  assert_line --partial '| vimdir       | $HOME/.vim '
}

@test "when VIMDIR is not set and no likely vimdir can be found" {
  rm_fixture_dir "${VIMDIR}"
  export VIMDIR=
  run ${rootdir}/vimget --verbose --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}

  assert_line --index 0 "Error: Unable to find vimdir."
  assert_line --index 1 "     > Please set the environment variable VIMDIR to continue."
  assert_equal 2 "${#lines[@]}"
}

@test "when VIM_PLUGINS_DIR is not set a likely existing vim_plugins_dir is found" {
  export VIM_PLUGINS_DIR=
  run ${rootdir}/vimget --verbose --dry-run https://github.com/junegunn/fzf.vim

  assert_success
  assert_line --partial '| plugins-dir  | $VIMDIR/bundle '
}

@test "when VIM_PLUGINS_DIR is not set and no likely vim_plugins_dir can be found" {
  rm_fixture_dir "${VIM_PLUGINS_DIR}"
  export VIM_PLUGINS_DIR=
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}

  assert_line --index 0 "Error: Unable to find plugins dir."
  assert_line --index 1 "     > Please set the environment variable VIM_PLUGINS_DIR to continue."
  assert_equal 2 "${#lines[@]}"
}

@test "when plugin already installed" {
  touch "${VIM_PLUGINS_DIR}/fzf.vim"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 "     > /Users/alissahuskey/Dropbox/projects/vim/vimget/test/.vim/bundle/fzf.vim"
  assert_equal 2 "${#lines[@]}"
}

@test "verify -- vimdir created" {
  skip
}

@test "verify -- helptags generated" {
  skip
}
