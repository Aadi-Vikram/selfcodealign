# Project Proposal - Group 12 - Course 11-785

We are using self-code align for our base implementation, although we will be testing the implementation on a smaller model set. 

To run the evaluation of the model please use the evaluate_model.sh script present in the evaluation model. The base paper was implemented on A100 GPU, for our implementation we are doing it on a lesser compute, hence we have created scripts that will be useful for setting up the environment and executing smaller models. 


## Evaluation Script

**Template to run evaluation:**
```bash
./evaluate_model.sh <MODEL_KEY> <MODEL_PATH> <DATASET_NAME>
```

**Parameters:**
- `<MODEL_KEY>`: Key of model
- `<MODEL_PATH>`: Hugging Face path of model or local location of your model
- `<DATASET_NAME>`: HumanEval or MBPP

---

## Fine-tuning Script

To fine-tune the model, execute the following script which is present in the evaluation folder:
```bash
./finetune_model.sh <MODEL_KEY> <OUTPUT_DIR> <DATASET_FILE>
```

**Parameters:**
- `<MODEL_KEY>`: The model to fine-tune
- `<OUTPUT_DIR>`: Location where output model will be stored
- `<DATASET_FILE>`: Instruction dataset