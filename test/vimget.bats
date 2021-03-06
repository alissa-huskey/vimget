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

teardown() {
  if [[ $SAVE_FIXTURES_ON_FAIL ]]; then
    return
  fi

  while read -r dir; do
    rm_fixture_dir "${dir}"
  done < <( find "$VIM_PLUGINS_DIR" "$VIMDIR/pack" -maxdepth 1 -mindepth 1 2> /dev/null )
}

# matchers {{{


@test "vimget */<name>.git" {
  run ${rootdir}/vimget --dry-run ssh://sourceware.org/git/systemtap.git

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 ssh://sourceware.org/git/systemtap.git"
  assert_equal "${#lines[@]}" 2
}

@test "vimget */<name>.git/" {
  run ${rootdir}/vimget --dry-run ssh://sourceware.org/git/systemtap.git/

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 ssh://sourceware.org/git/systemtap.git/"
  assert_equal "${#lines[@]}" 2
}

@test "vimget *github.com/*/<name>" {
  run ${rootdir}/vimget --dry-run http://github.com/pseewald/vim-anyfold

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 http://github.com/pseewald/vim-anyfold"
  assert_equal "${#lines[@]}" 2
}

@test "vimget *github.com/*/<name>/" {
  run ${rootdir}/vimget --dry-run http://github.com/pseewald/vim-anyfold/

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 http://github.com/pseewald/vim-anyfold/"
  assert_equal "${#lines[@]}" 2
}

@test "vimget git://*/<name>" {
  run ${rootdir}/vimget --dry-run git://sourceware.org/git/systemtap

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 git://sourceware.org/git/systemtap"
  assert_equal "${#lines[@]}" 2
}

@test "vimget git://*/<name>/" {
  run ${rootdir}/vimget --dry-run git://sourceware.org/git/systemtap/

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 git://sourceware.org/git/systemtap/"
  assert_equal "${#lines[@]}" 2
}

@test "vimget <owner>/<name>" {
  run ${rootdir}/vimget --dry-run vim/killersheep

  assert_success
  assert_line --index 0 '> cd $VIM_PLUGINS_DIR'
  assert_line --index 1 "> git clone --depth 1 https://github.com/vim/killersheep"
  assert_equal "${#lines[@]}" 2
}

#
# }}} / matchers

# args {{{
#

@test "vimget -Vd is translated to -V -d" {
  run ${rootdir}/vimget -Vd git://sourceware.org/git/systemtap.git

  assert_success
  assert_line --regexp "> cd .*$"
  assert_line --regexp "\| plugins-dir  \| .*$"
}

@test "vimget --quiet --dry-run: prints no output, installs no plugin" {
  run ${rootdir}/vimget --quiet --dry-run aliou/bats.vim

  assert_success
  assert_output ""
  [[ ! -d "${VIM_PLUGINS_DIR}/bats.vim" ]]
}

@test "vimget --quiet --verbose: verbose overrides quiet" {
  run ${rootdir}/vimget --verbose --dry-run --quiet aliou/bats.vim

  assert_success
  assert_line --regexp "\| plugins-dir  \| .*$"
  assert_line --regexp "> cd .*$"
}

@test "vimget --quiet : will still print errors" {
  mkdir ${VIM_PLUGINS_DIR}/vim-gitgutter
  run ${rootdir}/vimget --quiet --dry-run https://github.com/airblade/vim-gitgutter

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 '     > $VIM_PLUGINS_DIR/vim-gitgutter'
  assert_equal "${#lines[@]}" 2
}

@test "vimget <repo> <name>" {
  run ${rootdir}/vimget --dry-run https://github.com/airblade/vim-gitgutter gitgutter2

  assert_success
  assert_line --index 1 "> git clone --depth 1 https://github.com/airblade/vim-gitgutter gitgutter2"
}

@test "vimget <repo> <invalid-name>" {
  run ${rootdir}/vimget --dry-run https://github.com/airblade/vim-gitgutter vim@gitgutter

  assert_failure $code_usr
  assert_output "Error: Invalid argument for <name>: vim@gitgutter"
}

@test "vimget <repo> -n <name>" {
  run ${rootdir}/vimget --dry-run https://github.com/airblade/vim-gitgutter -n gitgutter2

  assert_success
  assert_line --index 1 "> git clone --depth 1 https://github.com/airblade/vim-gitgutter gitgutter2"
}

@test "vimget <repo> -n <invalid-name>" {
  run ${rootdir}/vimget --dry-run https://github.com/airblade/vim-gitgutter -n vim@gitgutter

  assert_failure $code_usr
  assert_output "Error: Invalid argument for <name>: vim@gitgutter"
}

@test "vimget <repo> <repo>" {
  run ${rootdir}/vimget --dry-run jez/vim-superman vim-utils/vim-man

  assert_success
  assert_line "> git clone --depth 1 https://github.com/jez/vim-superman"
  assert_line "> git clone --depth 1 https://github.com/vim-utils/vim-man"
}

@test "vimget <repo> -n <name> <repo> -n <name> <repo>" {
  run ${rootdir}/vimget --dry-run jez/vim-superman -n superman vim-utils/vim-man -n man mzlogin/vim-markdown-toc

  assert_success
  assert_line "> git clone --depth 1 https://github.com/jez/vim-superman superman"
  assert_line "> git clone --depth 1 https://github.com/vim-utils/vim-man man"
  assert_line "> git clone --depth 1 https://github.com/mzlogin/vim-markdown-toc"
}

@test "echo <repo> -n <name> <repo> -n <name> | vimget" {
  skip
}

#
# }}} / args

# conditions {{{
#

@test "when VIMDIR does not exist" {
  rm_fixture_dir "${VIMDIR}"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Unable to access provided VIMDIR:"
  assert_line --index 1 "     > ./test/.vim"
  assert_equal "${#lines[@]}" 2
}

@test "when VIM_PLUGINS_DIR does not exist" {
  rm_fixture_dir "${VIM_PLUGINS_DIR}"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Unable to access provided VIM_PLUGINS_DIR:"
  assert_line --index 1 '     > $VIMDIR/bundle'
  assert_equal "${#lines[@]}" 2
}

@test "when VIMDIR is not set a likely existing vimdir is found" {
  export VIMDIR=
  run ${rootdir}/vimget --verbose --dry-run https://github.com/junegunn/fzf.vim

  assert_success
  assert_line --partial '| vimdir       | ./test/.vim '
}

@test "when VIMDIR is not set and no likely vimdir can be found" {
  rm_fixture_dir "${VIMDIR}"
  export VIMDIR=
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}

  assert_line --index 0 "Error: Unable to find vimdir."
  assert_line --index 1 "     > Please set the environment variable VIMDIR to continue."
  assert_equal "${#lines[@]}" 2
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
  assert_equal "${#lines[@]}" 2
}

@test "when plugin already installed" {
  touch "${VIM_PLUGINS_DIR}/fzf.vim"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 '     > $VIM_PLUGINS_DIR/fzf.vim'
  assert_equal "${#lines[@]}" 2
}

@test "when plugin already installed in a different dir" {
  mkdir -p "${VIMDIR}/pack/others/start/fzf.vim"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 '     > $VIMDIR/pack/others/start/fzf.vim'
  assert_equal "${#lines[@]}" 2
}

@test "when plugin already installed with a different case" {
  mkdir "${VIM_PLUGINS_DIR}/FZF.vim"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 '     > $VIM_PLUGINS_DIR/FZF.vim'
  assert_equal "${#lines[@]}" 2
}

@test "when multiple matching plugins are already installed" {
  mkdir "${VIM_PLUGINS_DIR}/FZF.vim"
  mkdir -p "${VIMDIR}/pack/others/start/fzf.vim"
  run ${rootdir}/vimget --dry-run https://github.com/junegunn/fzf.vim

  assert_failure ${code_env}
  assert_line --index 0 "Error: Plugin already installed at:"
  assert_line --index 1 '     > $VIM_PLUGINS_DIR/FZF.vim'
  assert_line --index 2 '     > $VIMDIR/pack/others/start/fzf.vim'
  assert_equal "${#lines[@]}" 3
}

#
# }}} / conditions

# behavior {{{
#

@test "verify -- plugin added, helptags generated" {
  run ${rootdir}/vimget https://github.com/plasticboy/vim-markdown

  assert_success
  assert_line "| Cloning into 'vim-markdown'..."
  assert_line --partial '> vim -E -s -C -u NONE -c'
  assert_line '[SUCCESS] Plugin installed at: $VIM_PLUGINS_DIR/vim-markdown'

  [[ -d "${VIM_PLUGINS_DIR}/vim-markdown" ]]
  assert_file_exist "${VIM_PLUGINS_DIR}/vim-markdown/doc/tags"
}

#
# }}} / behavior
