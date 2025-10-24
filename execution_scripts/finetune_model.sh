MODEL_KEY="$1"

echo "Fine Tuning model $MODEL_KEY"
LR=1e-5
EPOCH=4
SEQ_LEN=1280
WARMUP_RATIO=0.05


OUTPUT_DIR="$2"

echo "Will store the output model in directory: $2 "
DATASET_FILE="$3"

accelerate launch -m star_align.train \
    --model_key $MODEL_KEY \
    --model_name_or_path $MODEL_KEY \
    --datafile_paths $DATASET_FILE \
    --output_dir $OUTPUT_DIR \
    --bf16 True \
    --num_train_epochs $EPOCH \
    --max_training_seq_length $SEQ_LEN \
    --pad_to_max_length False \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 64 \
    --group_by_length False \
    --ddp_find_unused_parameters False \
    --logging_steps 1 \
    --log_level info \
    --optim adafactor \
    --max_grad_norm -1 \
    --warmup_ratio $WARMUP_RATIO \
    --learning_rate $LR \
    --lr_scheduler_type linear \
    --attention_dropout 0.0 \
    --residual_dropout 0.0 \
    --embedding_dropout 0.0