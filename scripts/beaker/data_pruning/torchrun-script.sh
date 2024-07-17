#!/usr/bin/env bash
set -exuo pipefail
IFS=$'\n\t'

BEAKER_LEADER_REPLICA_HOSTNAME=$1
shift

NUM_NODES=$1
shift

TASK_NAME=$1
shift

MAX_DURATION=$1
shift

# Warm HF cache
mkdir -p /root/.cache
pushd /root/.cache
curl "https://storage.googleapis.com/hf-cache/huggingface_cache_v4.tar.gz" | tar --keep-newer-files -xzf -
popd
export HF_DATASETS_OFFLINE=1

torchrun \
  --nnodes ${NUM_NODES}:${NUM_NODES} \
  --nproc-per-node 8 \
  --rdzv_id=101 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=$BEAKER_LEADER_REPLICA_HOSTNAME:29400 \
  scripts/train.py \
    configs/data_pruning/reference-OLMo-60M.yaml \
      --run_name=$TASK_NAME \
      --wandb.name=$TASK_NAME \
      --wandb.group=$TASK_NAME \
      --wandb.project=data-pruning \
      --max_duration=$MAX_DURATION \
      --stop_at=$MAX_DURATION \
      --save_overwrite