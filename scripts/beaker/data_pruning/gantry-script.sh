#!/usr/bin/env bash

set -ex

NUM_NODES=1
TASK_NAME=pruned-olmo-300M-pes2o-12B-low-ref-olmo-60M-c4-24B
MAX_DURATION=6_000
SAVE_INTERVAL=6_000
CONFIG_FILE=configs/data_pruning/pruned-OLMo-300M-low.yaml

gantry run \
    --allow-dirty \
    --workspace ai2/data-pruning \
    --task-name ${TASK_NAME} \
    --description "data pruning experiments" \
    --priority high \
    --preemptible \
    --beaker-image shanea/olmo-torch2.2-gantry \
    --cluster ai2/pluto-cirrascale \
    --gpus 8 \
    --replicas "${NUM_NODES}" \
    --leader-selection \
    --host-networking \
    --budget ai2/oe-training \
    --no-nfs \
    --propagate-failure \
    --env LOG_FILTER_TYPE=local_rank0_only \
    --env OMP_NUM_THREADS=8 \
    --env OLMO_TASK=model \
    --env-secret WANDB_API_KEY=ANANYA_WANDB_API_KEY \
    --env-secret AWS_ACCESS_KEY_ID=ANANYA_AWS_ACCESS_KEY_ID \
    --env-secret AWS_SECRET_ACCESS_KEY=ANANYA_AWS_SECRET_ACCESS_KEY \
    --shared-memory 10GiB \
    --venv base \
    --yes \
    --timeout=-1 \
    -- /bin/bash -c "scripts/beaker/data_pruning/torchrun-script.sh \$BEAKER_LEADER_REPLICA_HOSTNAME ${CONFIG_FILE} ${NUM_NODES} ${TASK_NAME} ${MAX_DURATION} ${SAVE_INTERVAL}"