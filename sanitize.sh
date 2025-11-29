#!/bin/bash
set -e

SOURCE=$1
TARGET=$2

echo "Sanitizing.."
python -m star_align.sanitize_data \
    --data_files $SOURCE \
    --output_file $TARGET \
    --parse_raw_response True \
    --exact_match_dedup False \
    --passing_only False \
    --include_left_failed False \
    --n_cores 2

if [[ -n $DECONTAMINATION ]]; then
    echo "Decontaminating.. (saving to decontamination-output)"
    python -m star_align.decontamination.find_substrings \
        --dataset_name "json" \
        --output_file $TARGET \
        --output_dir decontamination-output \
        --columns instruction response \
        --data_files $TARGET
fi

echo "Minihash dedup..(not running for dpo)"

