
#    Assembly Program of an ABI function that calculates factorial of n.
#    Value of n is passed to this program as the first function argument.
#    In Conventional RISC-V software, x10 or a0 is used as both the first function argument and return value.


# Initializing the value of n
    addi    a0, zero, 5

factorial:
    # Setup code, to be executed once
    addi    a1, zero, 1
    addi    a0, a0, 1
    addi    a2, zero, 1
loop:
    # Main code implementing the factorial calculation
    mul a1, a2, a1
    addi a2 , a2 , 1
    bne a2, a0, loop 
    ebreak