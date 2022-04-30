# Matrix Processor
## Matrix Processor axi peripheral for ast tpu 2.0

PROGRESS ![](https://us-central1-progress-markdown.cloudfunctions.net/progress/100)

TPU is designed for int 8, thus accumulate will store data in ddr as 32 bit

MAC unit has 3 stages
1. load data
2. multiply data
3. accumulate data

Array is of dynamic size and multiplies in format AxB, where rows of A are multiplied to columns of B.

Countplex Modules relay data from cache to systolic array in proper, stagnated form.

Control module handles control signals of the array's multiplication stages and countplexs' data alignment

## Simulation Results

The following matrix multiplication example was used to simulate the processor
![alt text](https://github.com/atondwalkar/matrix_processor/blob/master/images/multiplication_example.png?raw=true)

The results of the matrix muliplcation can be seen on output ```rdata```, which will be used as the axi output for reading status and accumulator data
![alt text](https://github.com/atondwalkar/matrix_processor/blob/master/images/mxu_simulation.png?raw=true)
