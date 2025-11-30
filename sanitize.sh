#!/bin/bash
set -e
SOURCE=$1
TARGET=$2

echo "Splitting file into chunks of 200k lines..."
split -l 200000 $SOURCE "${SOURCE}.chunk_"

echo "Processing chunks..."
for chunk in "${SOURCE}.chunk_"*; do
    if [[ "$chunk" == *.sanitized ]]; then
        continue
    fi
    
    if [ -f "${chunk}.sanitized" ]; then
        echo "Skipping $chunk (already processed)"
        continue
    fi
    
    echo "Processing $chunk..."
    python -m star_align.sanitize_data \
        --data_files $chunk \
        --output_file "${chunk}.sanitized" \
        --parse_raw_response True \
        --exact_match_dedup False \
        --passing_only False \
        --include_left_failed False \
        --get_code_representation False \
        --n_cores 8
done

echo ""
echo "Merging results..."
cat "${SOURCE}.chunk_"*.sanitized > $TARGET

echo "Cleaning up chunks..."
rm "${SOURCE}.chunk_"*

if [[ -n $DECONTAMINATION ]]; then
    echo "Decontaminating.."
    python -m star_align.decontamination.find_substrings \
        --dataset_name "json" \
        --output_file $TARGET \
        --output_dir decontamination-output \
        --columns instruction response \
        --data_files $TARGET \
        --num_proc 8
fi

echo "Done!"