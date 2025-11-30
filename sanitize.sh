#!/bin/bash
set -e
SOURCE=$1
TARGET=$2

echo "Splitting file into chunks..."
split -l 200000 $SOURCE "${SOURCE}.chunk_"

echo "Processing chunks..."
for chunk in "${SOURCE}.chunk_"*; do
    echo "Processing $chunk..."
    python -m star_align.sanitize_data \
        --data_files $chunk \
        --output_file "${chunk}.sanitized" \
        --parse_raw_response True \
        --exact_match_dedup False \
        --passing_only False \
        --include_left_failed False \
        --n_cores 4
done

echo "Merging results..."
cat "${SOURCE}.chunk_"*.sanitized > $TARGET

echo "Cleaning up..."
rm "${SOURCE}.chunk_"*

echo "Done! Output: $TARGET"