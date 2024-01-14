#    Assembly Program of an ABI function that calculates factorial of n.
#    Value of n is passed to this program as the first function argument.
#    In Conventional RISC-V software, x10 or a0 is used as both the first function argument and return value.


# Initializing the value of n
    addi    a0, zero, 5

factorial:
    # Setup code, to be executed once
        li t0,1
        mv t1,a0
    
loop:
    # Main code implementing the factorial calculation
     blez t1,exit
     mul  t0,t0,t1
     addi t1,t1,-1
     j loop

    exit:
    mv t2,t0
    ebreak