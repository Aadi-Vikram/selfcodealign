#!/usr/bin/env python3
import json
from collections import defaultdict
import sys
import random

def create_dpo_pairs(input_file, output_file, max_pairs_per_instruction=None, seed=42):
    random.seed(seed)
    
    instruction_groups = defaultdict(lambda: {'pass': [], 'fail': []})
    
    print("Loading data")
    with open(input_file, 'r') as f:
        for line in f:
            data = json.loads(line)
            instruction = data['instruction']
            response = data['response']
            pass_status = data['pass']
            
            if pass_status:
                instruction_groups[instruction]['pass'].append(response)
            else:
                instruction_groups[instruction]['fail'].append(response)
    
    print(f"Loaded {len(instruction_groups)} unique instructions")
    
    print("Creating DPO pairs")
    pairs = []
    for instruction, responses in instruction_groups.items():
        passed = responses['pass']
        failed = responses['fail']
        
        if len(passed) > 0 and len(failed) > 0:
            for chosen in passed:
                for rejected in failed:
                    pairs.append({
                        'prompt': instruction,
                        'chosen': chosen,
                        'rejected': rejected
                    })
            
            if max_pairs_per_instruction:
                random.shuffle(pairs[-len(passed)*len(failed):])
                pairs = pairs[:-len(passed)*len(failed)] + pairs[-max_pairs_per_instruction:]
    
    print(f"Created {len(pairs)} DPO pairs")
    
    random.shuffle(pairs)
    
    print(f"Writing to {output_file}")
    with open(output_file, 'w') as f:
        for pair in pairs:
            f.write(json.dumps(pair) + '\n')
    
    print("Done!")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python create_dpo_pairs.py <input_file> <output_file> [max_pairs_per_instruction]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    max_pairs = int(sys.argv[3]) if len(sys.argv) > 3 else None
    
    create_dpo_pairs(input_file, output_file, max_pairs)
