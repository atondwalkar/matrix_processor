## matrix_processor
#matrix processor axi peripheral for ast tpu 2.0

TPU is designed for int 8, thus accumulate will store data in ddr as 32 bit

MAC unit has 3 stages
1. load data
2. multiply data
3. accumulate data

Array is of dynamic size
