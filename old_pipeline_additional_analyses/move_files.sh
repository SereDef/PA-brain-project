#!/bin/bash

# Bit too chaotic with the different dates and outcomes so I am just copying each model "manually"
# NOTE: copying only the files that are needed

MOVE_FROM="/home/sdefina/pa_brain/results"
cd $MOVE_FROM

MOVE_TO="/home/sdefina/pa_brain/PA-brain-project/results"

HEMIS="lh rh"
EXPOS="light_pa mvpa"
MODES="adjint adjicv"
OUTCS="area thickness"

for e in $EXPOS; do
  for o in $OUTCS; do
    for m in $MODES; do
      for h in $HEMIS; do

	SOURCE_DIR="$MOVE_FROM/$e/$h.${e}_$m.$o"
        if [[ -d $SOURCE_DIR ]]; then
          OUTPUT_DIR="$MOVE_TO/$e/$h.${e}_$m.$o/"

	  if [[ -d $OUTPUT_DIR ]]; then
	    echo "$OUTPUT_DIR already existed"
	  else
            mkdir -p $OUTPUT_DIR
            echo $OUTPUT_DIR

            cp $SOURCE_DIR/stack_names.txt $OUTPUT_DIR
            cp $SOURCE_DIR/stack*.coef.mgh $OUTPUT_DIR
            cp $SOURCE_DIR/stack*.ocn.mgh $OUTPUT_DIR
	  fi

	else
	  echo "$SOURCE_DIR does not exist"
	fi
      done
    done
  done
done
