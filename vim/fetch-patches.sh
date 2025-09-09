#!/bin/sh

A=$(ls -v vim-*.tar* | tail -n 1)
P=${A%.tar*}
PV=${P#vim-}

lftp -c "mirror -rp ftp://ftp.vim.org/pub/vim/patches/$PV/ patches"
ls patches/$PV.??? | cut -d. -f3 | sort -rn | head -n1 >PATCHLEVEL
echo Patchlevel $(cat PATCHLEVEL)

