vim-motion-fcharchar
====================

<img src="https://raw.githubusercontent.com/AbrahamSue/vim-motion-fcharchar/master/profile.png">

## Introduction
  This is vim plugin project that provides a in one line search and jump motion, like f but accepts up to two characters. There are several existing vim plugin that support a montion with 2 or more characters, e.g. [vim-easymotion][1], [vim-sneak][2], and [vim-seek][3]. Easymotion and sneak are cross line boundry motion, while vim-seek works within current line. 

  Cross line motion has a different application scenario, I personally keep easymotion-s2 on <Leader>s, which is very useful. Current line two characters montion will be more quick and column move focused. I was using vim-seek on my key 's/S', but it doesn't support visual mode and operator-pending mode, and doesn't work with ';,' repeator so far. So I wrote this plugin.

  * Support *visual mode* motion
  * Support *operator-pending* mode motion
  * Support repeat ;, and work well with f/F/t/T repeator

###  Demo:
   

## Usaage

> nnoremap s <Plug>(motion-fcharchar-fwd)
> nnoremap S <Plug>(motion-fcharchar-fwd)

## Installation

### [vim plug][10]
> Plug 'AbrahamSue/vim-motion-fcharchar'
> PlugInstall


### [Vundle][11]
> Plugin 'AbrahamSue/vim-motion-fcharchar'
> PluginInstall

### Manual
> cd ~/.vim/bundle
> git clone https://github.com/AbrahamSue/vim-motion-fcharchar

## Reference

[1] https://github.com/easymotion/vim-easymotion
[2] https://github.com/justinmk/vim-sneak
[3] https://github.com/goldfeld/vim-seek
[10] https://github.com/junegunn/vim-plug
[11] https://github.com/VundleVim/Vundle.vim

## Promotion

Like fcharchar? Follow the repository on GitHub and vote for it on vim.org. And if you're feeling especially charitable, follow me on Twitter and GitHub.

## License

Copyright (c) Abraham Sue. Distributed under the same terms as Vim itself. See :help license.


