#!/usr/bin/env bash
# 创建文件
for i in {1..5}; do
  touch -m -t 202301010100.00 test_dir/file202301010100${i}.txt
  touch -m -t 202302010100.00 test_dir/file202302010100${i}.txt
  touch -m -t 202401010100.00 test_dir/file202401010100${i}.txt
  touch -m -t 202402010100.00 test_dir/file202402010100${i}.txt
done
