# vimget
> like wget for vim plugins.

`vimget` makes adding vim plugins fast and simple. Given a plugin repo URI it will clone it to your plugin dir and run `:helptags`. Intended for use with pathogen or Vim8+ packages.


Install
---

You can put `vimget` anywhere in your path. To install it globally:

```bash
  $ git clone https://github.com/alissa-huskey/vimget.git
  $ cd vimget && sudo make install
```

Usage
---

```bash
usage: vimget [-q|-n|-d-q] <repo-uri>

options:
  -n | --no-color
  -d | --dry-run
  -q | --quiet
  -V | --verbose
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
         will look for `\$VIMDIR/bundles` and `\$VIMDIR/pack/start/bundles`. If you
         install your plugins elsewhere, use this to specify it.

* `NO_COLOR`
    * Set to any nonblank value to disable color output


Examples
---

```bash
 # use the same github URL that you would clone
 $ vimget https://github.com/vim-utils/vim-man.git

 # non-github URIS will work too
 $ vimget git://sourceware.org/git/systemtap

 # anything that looks like *.git, *github.com* or
 # git://* will work
 $ vimget /path/to/repo.git
 $ vimget ssh://github.com/path/to/repo
 $ vimget git://host.xz[:port]/~[user]/path/to/repo
```


Requirements
---

- git
- bash 3.2+

**Compatable with**

- Vim with Pathogen, Vim8+ or Neovim with |+packages|

> Note: this has only been tested on MacOS.


Meta
---

 [github](https://github.com/alissa-huskey/vimget)
