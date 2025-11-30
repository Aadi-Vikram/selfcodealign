#!/bin/bash
set -e
SOURCE=$1
TARGET=$2

echo "Splitting file into chunks of 200k lines..."
split -l 200000 $SOURCE "${SOURCE}.chunk_"

echo "Chunks created:"
ls -lh "${SOURCE}.chunk_"*

echo ""
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
        --n_cores 2
done

echo ""
echo "Merging results..."
cat "${SOURCE}.chunk_"*.sanitized > $TARGET

echo "Cleaning up chunks..."
rm "${SOURCE}.chunk_"*

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
echo "Done!"