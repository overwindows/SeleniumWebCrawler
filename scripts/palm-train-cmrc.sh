total_updates=500000
warmup_updates=500      
# lr=3e-05
lr=0.001
max_tokens=2048
UPDATE_FREQ=4
pointer_layer=-2
# roberta_path=/bigdata/roberta.base/model.pt
datadrive=/apdcephfs/private_kevinkyhong/data/cmrc2018_public/corpus
task=finetune_cmrc

root=/apdcephfs/private_kevinkyhong/PALM

rm -rf /apdcephfs/private_kevinkyhong/logdir/palm_"$task"

python3 /apdcephfs/private_kevinkyhong/PALM/utils/train.py "$datadrive"_bin \
    --user-dir "$root"/src --truncate-source --source-lang source --target-lang target \
    --task auto_encoding_regressive --arch palm_base --criterion label_smoothed_cross_entropy_with_masked_lm --label-smoothing 0.1 \
    --layernorm-embedding --share-all-embeddings --share-decoder-input-output-embed \
    --optimizer adam --adam-betas "(0.9, 0.999)" --adam-eps 1e-08 \
    --lr-scheduler inverse_sqrt --lr "$lr" --max-update "$total_updates" --warmup-updates "$warmup_updates" \
    --act-dropout 0.1 --weight-decay 0.01 --dropout 0.1 --attention-dropout 0.1 --clip-norm 0.1 \
    --skip-invalid-size-inputs-valid-test --validate-interval 1 --max-tokens-valid 2048 \
    --max-tokens "$max_tokens" --required-batch-size-multiple 1 \
    --alignment-layer "$pointer_layer" \
    --alignment-heads 1 \
    --encoder-embed-dim 512 \
    --encoder-ffn-embed-dim 2048 \
    --encoder-attention-heads 8 \
    --decoder-embed-dim 512 \
    --decoder-ffn-embed-dim 2048 \
    --decoder-attention-heads 8 \
    --encoder-normalize-before \
    --decoder-normalize-before \
    --source-position-markers 1000 --update-freq "$UPDATE_FREQ" \
    --train-subset train \
    --valid-subset valid \
    --keep-interval-updates -1 \
    --keep-last-epochs -1 \
    --keep-best-checkpoints -1 \
    --no-epoch-checkpoints \
    --best-checkpoint-metric loss \
    --reset-optimizer --reset-dataloader --reset-meters \
    --save-dir /apdcephfs/private_kevinkyhong/fine_tuned_model/palm_"${task}"_checkpoints \
    --tensorboard-logdir /apdcephfs/private_kevinkyhong/logdir/palm_"$task" --ddp-backend=legacy_ddp \
    --restore-file /apdcephfs/private_kevinkyhong/prev_trained_model/palm_pretrain_checkpoints/checkpoint_best.pt \
    # --fp16 \
    # --find-unused-parameters \
    # --wandb-project PALM \
    # --eval-bleu \