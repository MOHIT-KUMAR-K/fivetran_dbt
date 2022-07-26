#!/bin/bash

LOC="--location US"
INPUT=gs://mem_sql_transfer_sampe/results-2022-07-25T150941.csv

bq $LOC mk memsql_datatransfer # okay if it fails
bq $LOC rm memsql_datatransfer.result # replace

DEF=/tmp/college_scorecard_def.json

SCHEMA=$(gsutil cat $INPUT | head -1 | awk -F, '{ORS=","}{for (i=1; i <= NF; i++){ print $i":STRING"; }}' | sed 's/,$//g'| cut -b 4- )
echo $SCHEMA > /tmp/schema.txt

bq $LOC \
   mkdef \
   --source_format=CSV \
   --noautodetect \
   $INPUT \
   $SCHEMA \
  | sed 's/"skipLeadingRows": 0/"skipLeadingRows": 1/g' \
  | sed 's/"allowJaggedRows": false/"allowJaggedRows": true/g' \
  > $DEF


bq mk --external_table_definition=$DEF memsql_datatransfer.result
