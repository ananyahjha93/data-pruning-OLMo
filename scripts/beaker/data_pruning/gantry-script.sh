#!/usr/bin/env bash

set -ex

NUM_NODES=2
TASK_NAME=baseline-olmo-300M-pes2o-60B
MAX_DURATION=30_000
CONFIG_FILE=configs/data_pruning/baseline-OLMo-300M.yaml

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
    --synchronized-start-timeout 30m \
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
    -- /bin/bash -c "scripts/beaker/data_pruning/torchrun-script.sh \$BEAKER_LEADER_REPLICA_HOSTNAME ${CONFIG_FILE} ${NUM_NODES} ${TASK_NAME} ${MAX_DURATION}"