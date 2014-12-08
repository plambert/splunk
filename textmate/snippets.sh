#!/bin/bash

if type tm_snippet_xml.pl > /dev/null; then
  TM=tm_snippet_xml.pl
elif [[ -x tm_snippet_xml.pl ]]; then
  TM=./tm_snippet_xml.pl
else
  echo "$0: tm_snippet_xml.pl: not found in PATH or \"$(pwd)\""
  exit 1
fi

case "$1" in

fieldset )

$TM fieldset \
  -autoRun=False \
  -submitButton=True \
  html \
  input \
  label="foo" 

;;

checkbox )

$TM input --type=checkbox --token:token_name -depends:list,of,required,tokens -rejects:list,of,conflicting,tokens -searchWhenChanged:False change condition default=default_value delimiter earliest latest fieldForLabel fieldForValue label prefix search suffix valuePrefix valueSuffix

;;

dropdown )

$TM input --type=dropdown --token:token_name -depends:list,of,required,tokens -rejects:list,of,conflicting,tokens -searchWhenChanged:False change condition default=default_value allowCustomValues choice delimiter earliest latest fieldForLabel fieldForValue label prefix search suffix valuePrefix valueSuffix selectFirstChoice

;;

* )

$TM "$1"

;;

esac

