#!/usr/bin/env python3
import torch
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer
from trl import DPOTrainer, DPOConfig

PROMPT_TEMPLATE = """You are an exceptionally intelligent coding assistant that consistently delivers accurate and reliable responses to user instructions.
### Instruction
{instruction}
### Response
{response}"""

def format_for_dpo(examples):
    formatted_prompts = []
    for prompt in examples["prompt"]:
        formatted_prompts.append(PROMPT_TEMPLATE.format(instruction=prompt, response=""))
    
    return {
        "prompt": formatted_prompts,
        "chosen": examples["chosen"],
        "rejected": examples["rejected"]
    }

def train_dpo():
    model_path = "./output_model"
    dataset_path = "./dpo_pairs.jsonl"
    output_dir = "./output_model_dpo"
    
    print("Loading model and tokenizer")
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.bfloat16,
        attn_implementation="flash_attention_2",
        device_map="auto"
    )
    
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    print("Loading and formatting dataset")
    dataset = load_dataset("json", data_files=dataset_path, split="train")
    dataset = dataset.map(format_for_dpo, batched=True)
    dataset = dataset.train_test_split(test_size=0.05, seed=42)
    
    print(f"Train examples: {len(dataset['train'])}")
    print(f"Eval examples: {len(dataset['test'])}")
    
    training_args = DPOConfig(
        output_dir=output_dir,
        num_train_epochs=1,
        per_device_train_batch_size=1,
        per_device_eval_batch_size=1,
        gradient_accumulation_steps=64,
        learning_rate=5e-7,
        lr_scheduler_type="cosine",
        warmup_ratio=0.1,
        bf16=True,
        logging_steps=1,
        eval_strategy="no",   # <-- removed eval
        save_strategy="steps",
        save_steps=100,
        save_total_limit=2,
        optim="adamw_torch",
        beta=0.1,
        max_length=1280,
        max_prompt_length=512,
        remove_unused_columns=False,
    )
    
    trainer = DPOTrainer(
        model=model,
        ref_model=None,
        args=training_args,
        train_dataset=dataset["train"],
        eval_dataset=None,   # <-- removed eval dataset
    )
    
    print("Starting DPO training")
    trainer.train()
    
    print("Saving model")
    trainer.save_model(output_dir)
    tokenizer.save_pretrained(output_dir)
    
    print("Done!")

if __name__ == "__main__":
    train_dpo()
