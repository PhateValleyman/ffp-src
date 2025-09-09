#!/bin/sh

lftp -c "mirror -rp ftp://ftp.cwru.edu/pub/bash/readline-6.2-patches/ patches"

ls patches/*-??? | cut -d- -f2 | sort -rn | head -n1 >PATCHLEVEL
echo Patchlevel $(cat PATCHLEVEL)

