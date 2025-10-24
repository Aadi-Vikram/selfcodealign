#!/bin/bash

MODEL_KEY="$1"
MODEL="$2"

echo "Evaluating the model - $MODEL"

DATASET="$3"

SAVE_PATH=evalplus-$(basename $MODEL)-$DATASET.jsonl
CUDA_VISIBLE_DEVICES=0

echo "Saving evaluation results in $SAVE_PATH"


cd ..
python -m evaluation.text2code \
  --model_key $MODEL_KEY \
  --model_name_or_path $MODEL \
  --save_path $SAVE_PATH \
  --dataset $DATASET \
  --temperature 0.0 \
  --top_p 1.0 \
  --max_new_tokens 512 \
  --n_problems_per_batch 16 \
  --n_samples_per_problem 1 \
  --n_batches 1

echo "Evaluating results for $DATASET"
python -m evalplus.evaluate --dataset $DATASET --samples $SAVE_PATH
