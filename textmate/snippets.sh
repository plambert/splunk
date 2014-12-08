#!/bin/bash

if type tm_snippet_xml.pl > /dev/null 2>&1; then
  TM=tm_snippet_xml.pl
elif [[ -x tm_snippet_xml.pl ]]; then
  TM=./tm_snippet_xml.pl
elif [[ -x "textmate/tm_snippet_xml.pl" ]]; then
  TM=textmate/tm_snippet_xml.pl
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

$TM input --type=checkbox \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  change \
  condition \
  default=default_value \
  delimiter \
  earliest \
  latest \
  fieldForLabel \
  fieldForValue \
  label \
  prefix \
  search \
  suffix \
  valuePrefix \
  valueSuffix

;;

dropdown )

$TM input --type=dropdown \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  change \
  condition \
  default=default_value \
  allowCustomValues \
  choice \
  delimiter \
  earliest \
  latest \
  fieldForLabel \
  fieldForValue \
  label \
  prefix \
  search \
  suffix \
  valuePrefix \
  valueSuffix \
  selectFirstChoice

;;

multiselect )

$TM input --type=multiselect \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  allowCustomValues \
  default=default_value \
  delimiter=" " \
  earliest \
  latest \
  fieldForLabel \
  fieldForValue \
  label=label_text \
  prefix \
  search \
  suffix \
  valuePrefix \
  valueSuffix

;;

radio )

$TM input --type=radio \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  change \
  choice \
  condition \
  default=default_value \
  delimiter=" " \
  earliest \
  latest \
  fieldForLabel \
  fieldForValue \
  label=label_text \
  prefix \
  search \
  selectFirstChoice \
  suffix

;;

text )

$TM input --type=text \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  change \
  condition \
  default=default_value \
  label=label_text \
  prefix \
  seed \
  suffix

;;

time )

$TM input --type=time \
  --token:token_name \
  -id:input_id \
  -depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  -searchWhenChanged:False \
  change \
  condition \
  default=default_value \
  earliest \
  latest \
  label=label_text

;;

change )

$TM change \
  condition \
  set

;;

condition )

$TM condition \
  --label:\* \
  --value:\* \
  -field:\* \
  link \
  set \
  unset

;;

chart )

$TM chart \
  --id:chart_id \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  title \
  search \
  drilldown \
  selection \
  option \
  .charting.chart::area,bar,clumn,fillerGauge,line,markerGauge,pie,radialGauge,scatter

;;

event )

$TM event \
  --id:event_id \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  title \
  search \
  fields \
  option \
  .count:10\? \
  .displayRowNumbers::False,True \
  .drilldown::all,none

;;

html )

$TM html \
  --id:html_id \
  --tokens:True \
  -src:file.html \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens

;;

map )

$TM map \
  --id:map_id \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  option \
  title \
  search

;;

single )

$TM single \
  --id:single_id \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  title \
  search \
  option \
  .afterLabel\? \
  .beforeLabel\? \
  .additionalClass:css_class\? \
  .classField::severe,high,elevated,guarded,low,None\? \
  .drilldown::none,all\? \
  .field\? \
  .underLabel\?

;;

table )

$TM table \
  --id:table_id \
  -depends:depends:list,of,required,tokens \
  -rejects:list,of,conflicting,tokens \
  title \
  search \
  fields \
  drilldown \
  format \
  option \
  .wrap::True,False \
  .showPager::True,False \
  .rowNumbers::False,True \
  .previewResults::True,False

;;

title )

$TM title

;;

format )

$TM format \
  --type=sparkline \
  --field:fieldname \
  .height:auto\? \
  .type::line,bar,discrete \
  option

;;

fields )

$TM fields

;;

option )

$TM option \
  --name \
  -1

;;

search )

$TM search \
  --id:search_id \
  -base:base_id \
  -ref:ref_id \
  -app:app_id \
  query \
  earliest \
  latest

;;

"" )

echo "$0: must give a tag as an argument:"
perl -ne 'push @t, $1 if (/^(\w+)\s+\)\s*$/); END{print join(", ", sort @t), "\n"}' "$0" 

;;

--all )

perl -ne 'print "$1\n" if (/^(\w+)\s+\)\s*$/);' "$0" | while read tag; do echo "=== $tag ==="; echo; "$0" "$tag"; echo; done

;; 

* )

$TM "$1"

;;

esac

