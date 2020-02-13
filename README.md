# vimget
> like wget for vim plugins.

`vimget` makes adding vim plugins fast and simple. Given a plugin repo URI it will clone it to your plugin dir and run `:helptags`. Intended for use with pathogen or Vim8+ packages.


Usage
---

```bash
usage: vimget [-d|-q|-n|-q|-V] <repo-uri> [[-n] <name>] [<repo-uri>...]

options:
  -c | --no-color
  -d | --dry-run
  -q | --quiet
  -V | --verbose
  -n | --name <name>
```


Environment
---

* `VIMDIR`
    * The toplevel location of your personal vim initialization files.
         `vimget` will search for common locations like `\$HOME/.vim` (as found in
         vim and nvim helpfiles |vimrc|). You can use this to set a nonstandard
         location or avoid ambiguity.

* `VIM_PLUGINS_DIR`
    * The subdirectory under `\$VIMDIR` where your plugins are located. `vimget`
         will look for `\$VIMDIR/bundle` and `\$VIMDIR/pack/bundle/start`. If you
         install your plugins elsewhere, use this to specify it.

* `NO_COLOR`
    * Set to any nonblank value to disable color output


Examples
---

```bash
 # use the same github URL that you would clone
 $ vimget https://github.com/vim-utils/vim-man.git

 # so will github shorthand
 $ vimget plasticboy/vim-markdown

 # non-github URIS will work too
 $ vimget git://sourceware.org/git/systemtap

 # anything that looks like *.git, *github.com*
 # git://* or <username>/<repo_name> will work
 $ vimget /path/to/repo.git
 $ vimget ssh://github.com/path/to/repo
 $ vimget git://host.xz[:port]/~[user]/path/to/repo

 # pass in a list of repos
 $ vimget reedes/vim-pencil junegunn/goyo.vim junegunn/limelight.vim

 # for a single plugin, you can specify an alternate name like you would in git
 $ vimget aliou/bats.vim bats

# or follow the repo uri with the -n flag in a list
$ vimget tpope/vim-markdown spacevim/vim-markdown -n spacevim-markdown

```


Install
---

You can put `vimget` anywhere in your path.

To install it globally:

```bash
  $ git clone https://github.com/alissa-huskey/vimget.git
  $ cd vimget && sudo make install
```


Requirements
---

- git
- bash 3.2+

**Compatable with**

- Vim with Pathogen, Vim8+ or Neovim with |+packages|

> Note: this has only been tested on MacOS.
