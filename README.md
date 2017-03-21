vim-motion-fcharchar :fire:
====================

<img src="https://raw.githubusercontent.com/AbrahamSue/vim-motion-fcharchar/master/profile.png" width=50 height=50>

## Introduction
  This is vim plugin project that provides a in one line search and jump motion, like f but accepts up to two characters. There are several existing vim plugin that support a montion with 2 or more characters, e.g. vim-easymotion, vim-sneak, and vim-seek. Easymotion and sneak are cross line boundry motion, while vim-seek works within current line. This plugin also is inspired by clever-f, which allow people to use f itself to repeat, and save ';' ',' to other usage.

  Cross line motion has a different application scenario, I personally keep easymotion-s2 on \<Leader\>s, which is very useful. Current line two characters montion will be more quick and column move focused.

  * Support *visual mode* motion
  * Support *operator-pending* mode motion
  * Support repeat **;,** and work well with f/F/t/T repeator

###  Demo:


## Usaage
### Set up key
  You can use default 'f'/'F' key, but also can use other key binding, e.g, 's'/'S'. If you only set g:fcharchar_key, plugin will use its upper case for reverse direction.
```
  let g:fcharchar_key = 'f'
  let g:fcharchar_key2 = 'F'
```

### Enable/disable repeat itself
  To enable / disable repeat by itself, please use the following global variable, need restart vim.

```
  let g:fcharchar_repeat_by_self = 1
```
### Set up timeout
  There are two timeouts float in second for this plugin.
  After the repeat timeout, more f/F won't repeat itself again.
  The '2ndchar' timeout is the time to wait to complete the 2nd char. If there is only one instance of the first character, the cursor will jump immedietely without asking for the second character or waiting.
```
  let g:fcharchar_timeout = 2.0
  let g:fcharchar_timeout = [ 4.0, 2.0 ]
  let g:fcharchar_timeout = [ 'repeat': 4.0, '2ndchar': 2.0 ]

```


| Key                         | Description                        |
| :---------------------------| :----------------------------------|
| [count]f\<char\>\<timeout\> | like original vim f\<char\> motion |
| [count]f\<char\>\<ESC\>     | like original vim f\<char\> motion |
| [count]f\<char\>\<char\>    | cursor motion jump to the first \<char\>\<char\> locaiton, the fisrt char is inclusiave, the second is exclusive |

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
* https://github.com/rhysd/clever-f.vim
* https://github.com/t9md/vim-smalls
* https://github.com/junegunn/vim-plug
* https://github.com/VundleVim/Vundle.vim

## Promotion

Like fcharchar? Follow the repository on GitHub and vote for it on vim.org. And if you're feeling especially charitable, follow me on Twitter and GitHub.

## License

Copyright (c) Abraham Sue. Distributed under the same terms as Vim itself. See :help license.
