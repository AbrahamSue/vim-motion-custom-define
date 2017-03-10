vim-motion-fcharchar :fire:
====================

<img src="https://raw.githubusercontent.com/AbrahamSue/vim-motion-fcharchar/master/profile.png" width=50 height=50>

## Introduction
  This is vim plugin project that provides a in one line search and jump motion, like f but accepts up to two characters. There are several existing vim plugin that support a montion with 2 or more characters, e.g. vim-easymotion, vim-sneak, and vim-seek. Easymotion and sneak are cross line boundry motion, while vim-seek works within current line. 

  Cross line motion has a different application scenario, I personally keep easymotion-s2 on <Leader>s, which is very useful. Current line two characters montion will be more quick and column move focused. I was using vim-seek on my key 's/S', but it doesn't support visual mode and operator-pending mode, and doesn't work with ';,' repeator so far. So I wrote this plugin.

  * Support *visual mode* motion
  * Support *operator-pending* mode motion
  * Support repeat **;,** and work well with f/F/t/T repeator

###  Demo:
   

## Usaage
```
nnoremap s <Plug>(motion-fcharchar-fwd)
nnoremap S <Plug>(motion-fcharchar-fwd)
```


| Key                     | Description                      |
| :---                    | :---                             |
| [count]f<char><timeout> | like original vim f<char> motion |
| [count]f<char><ESC>     | like original vim f<char> motion |
| [count]f<char><char>    | cursor motion jump to the first <char><char> locaiton, the fisrt char is inclusiave, the second is exclusive |

## Installation

### [vim plug](https://github.com/junegunn/vim-plug)
```
Plug 'AbrahamSue/vim-motion-fcharchar'
PlugInstall
```


### [Vundle](https://github.com/VundleVim/Vundle.vim)
```
Plugin 'AbrahamSue/vim-motion-fcharchar'
PluginInstall
```

### Manual
```
cd ~/.vim/bundle
git clone https://github.com/AbrahamSue/vim-motion-fcharchar
```

## Reference

* https://github.com/easymotion/vim-easymotion
* https://github.com/justinmk/vim-sneak
* https://github.com/goldfeld/vim-seek
* https://github.com/junegunn/vim-plug
* https://github.com/VundleVim/Vundle.vim

## Promotion

Like fcharchar? Follow the repository on GitHub and vote for it on vim.org. And if you're feeling especially charitable, follow me on Twitter and GitHub.

## License

Copyright (c) Abraham Sue. Distributed under the same terms as Vim itself. See :help license.


