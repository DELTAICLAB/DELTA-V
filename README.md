
# DELTA-V
## Team xohw23-135
### Team members :
#### Muhammet Enes Yanik      (m.yanik2019@gtu.edu.tr)
#### Murat Tokez              (m.tokez2019@gtu.edu.tr)
#### Mehmet Akif Nisanci      (m.nisanci2021@gtu.edu.tr)
#### İlker Acar               (i.acar2020@gtu.edu.tr)
### Supervisor:
#### İhsan Cicek


# Introduction

The evolution of microprocessor technology has brought us to the age of custom cores and RISC-V architecture, granting unprecedented flexibility and control.
The Delta-V project is a new approach to this landscape, merging the power of OpenASIP and Xilinx Vitis HLS, enabling users to design, build, and execute C code on their own RISC-V cores.

[OpenASIP](http://openasip.org/): A processor design tool that offers a high degree of freedom in creating application-specific instruction-set processors (ASIPs).


## Documentation

[Documentation](https://github.com/DELTAICLAB/DELTA-V/blob/main/Deltav_manual.pdf)


## Installation

You need to have docker in order to use Delta-v . After installing docker, please pull :

```bash
  docker pull meyanik/deltav:release0
```
    
After pulling the docker image, you are ready to use deltav.tcl file

Delta-v uses Xilinx Vitis HLS as main component. So please make sure it is installed on your system.
## How to write c library for Delta-v

The functions in the C library provided by the user will be converted into VHDL modules using Vitis
HLS. It is important to note that these modules will be added to the RISC-V core as R-type
instructions. Therefore, each module should consist of two inputs and one output. The inputs should
be named op1 and op2, while the output should be named op3. Additionally, the module name and file
name should not contain uppercase letters.Also in order to avoid state machines in Vitis HLS, there should be no data dependency in any loops. These are critical requirements, as the core may not
function properly if these conditions are not met. Here is an example:

```
unsigned int hammingdistance(unsigned int op1, unsigned int op2) {
    unsigned int n = op1 ^ op2;
    unsigned int dist = 0;
    while (n != 0) {
        dist += n & 1;
        n = n >> 1;
    }
    return dist;
}

```
This function have a data dependency problem. Instead please use it like this:

```
unsigned int hammingdistance(unsigned int op1,unsigned  int op2) {
    unsigned int n = op1 ^ op2;
    unsigned int dist = 0;
    for (unsigned int i = 0; i < 32; i++) {
        dist += (n >> i) & 1;
    }
    return dist;
}

```

as you can see there was a data dependency in the while loop. Instead using a for loop with constant cycle will do the trick. Be careful also input names are op1 and op2. 




## Usage


In order to use delta-v , you need to create any directory that consists your c files.
```
as an example, c_file_directory:

-library.c  (you can name them anything)

-library.h  (you can name them anything)

-main.c     (it needs to be main.c only !!)
```

After setting up the directory with your c files, you can now use your tcl script. To generate you custom core , please use:

```
vitis_hls deltav.tcl /path/to/your_c_directory/ core
```
This will also run the main.c file on your cpu.
It also creates a vivado project that you can easily open and run simulations easily.

 If you want to change the main.c file, just edit it and use:

```
vitis_hls deltav.tcl /path/to/your_c_directory/ code
```
this will update the code and run it in your core.

After running the code on your custom risc-v core, you can see the printf outputs at hdl_sim_stdout.txt , see how many cycle did your cpu run at cycles.dump.
## Using custom instructions

You now have a custom risc-v core that executes your c functions in only one clock cycle ! you need to know how to use these instructions.

- Step 1: Backup the Original Code

Before making any changes, it is essential to create a backup of the original C code. This allows us to
revert to the original version if needed.
```
cp hammingdistance.c custom_hammingdistance.c
```

- Step 2: Understanding Custom Instruction Usage

Custom instructions are invoked using specific macros or intrinsics. The format for using custom
operations is as follows:
```
_OA_<opName>(op1, op2, op3);
```
Here, <opName> represents the name of the custom operation. Input operands are op1, op2 and op3
are output operand. For our example, we have defined a custom operation named
"HAMMINGDISTANCE". The intrinsic calls for these operations are as follows:
```
_OA_HAMMINGDISTANCE(op1, op2, op3);
```

- Step 3: Modifying the C Code

To integrate the custom instruction into the C code, we need to make several modifications.

-> hammingdistance function:
```
int hammingdistance(int op1, int op2) {
int n = op1 ^ op2;
int dist = 0;
for (int i = 0; i < 32; i++) {
dist += (n >> i) & 1;
}
return dist;
}
```


-> custom hammingdistance function:
```
int hammingdistance(int op1, int op2) {
int output;
_OA_RV_HAMMINGDISTANCE(op1, op2, output);
return output;
}
```

In this example code, we have modified the original functions to use custom instructions for specific
operations. Each modified function now invokes the corresponding custom instruction using the
provided macros. The output values from the custom instructions are returned as the function results.
If the user wishes, they can define the custom instruction in the specified format within the main
function and call it, assigning it to a desired variable and using it as they wish.


## Demo

https://youtu.be/u1tG6-Joe98


## To-Do

- current docker image size can be reduced

- a statistics.txt can be generated to see how the performance increased using custom instructions

