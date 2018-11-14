# vimget
> like wget for vim plugins.

Meant to be used with [pathogen](https://github.com/tpope/vim-pathogen),
`vimget` accepts a git repo URL of a vim plugin, clones it to `~/.vim/bundle`,
and runs `:helptags`.


## install

```bash
  # assuming you have a $HOME/bin directory in your $PATH
  $ curl https://raw.githubusercontent.com/alissa-huskey/vimget/master/vimget > $HOME/bin/vimget
  $ chmod 755 $HOME/bin/vimget
```

```bash
  # alternately
  $ git clone curl https://github.com/alissa-huskey/vimget.git
  $ cd vimget && sudo make install
```

## usage
```bash
usage: vimget [-q|-n] <repo url>

options:
  -q  quiet mode
  -n  no colors
```

## examples

```bash
 # use the same github url that you would clone
 $ vimget https://github.com/vim-utils/vim-man.git

 # a github url without the .git will also work
 $ vimget https://github.com/tpope/vim-fugitive

 # -n for no colors
 $ vimget -n https://github.com/plasticboy/vim-markdown

 # -q for quiet mode
 $ vimget -q https://github.com/mileszs/ack.vim.git

 # in theory, any URL that git can clone will work
 $ vimget /path/to/repo.git
 $ vimget ssh://[user@]host.xz[:port]/path/to/repo.git
 $ vimget git://host.xz[:port]/~[user]/path/to/repo.git
```

## requirements

- Vim
- git
- bash 3.2+

> Note: this has only been tested on MacOS.

## meta

* [github](https://github.com/alissa-huskey/vimget)
