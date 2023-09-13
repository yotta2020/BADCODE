#!/bin/bash
ip=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {if ($2 ~ /^222\./) print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
echo $ip

python_enviroment=/home/yjy/.conda/envs/lstm/bin/python3.7
DATA_DIR=/data1/yjy/code/2023/paper01_data/code_function/data
MODEL_DIR=/data1/yjy/code/2023/paper01_data/code_function/model

# 参数候选组合比如[['codebert','ALERT','code_function'],['graphcodebert','SAFECODE','code_function'],['LSTM','CARROT','code_defect']]。
param_combinations=(['codebert','ALERT','code_function'] ['graphcodebert','SAFECODE','code_function'] ['LSTM','CARROT','code_defect'])

# 循环运行参数组合。${model}，${enhance_method},${task}分别对应['codebert','ALERT','code_function']的1、2、3
for params in "${param_combinations[@]}"; do
  model=${params[0]}
  enhance_method=${params[1]}
  task=${params[2]}

  # 任务1：比如训练模型
  nohup ${python_enviroment} -u poison_data.py  \
   --poison_mode 1 --target file --trigger sh --identifier function_definition --fixed_trigger True --position l > output.log


  # 任务2：比如测试模型
  nohup ${python_enviroment} -u attacker.py --server ${ip} --gpu 0 --task ${task}   --model_save_path ${MODEL_DIR}/${model}/${enhance_method}/mix/origin,random_mix0,random_mix1/best.pt > attack_log_${model}_${enhance_method}.log 2>&1 &
done
