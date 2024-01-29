# Multi-cycle RISC-V Processor

This project focuses on designing and implementing a multi-cycle RISC-V processor using microprogrammed control. The processor is capable of executing R-type and I-type instructions, along with some other B_type like BNE and BGE.
The processor consists of three main units:
Memory
Data path
Controller

In the multi-cycle design, a combined memory for instructions and data is used for more realistic and feasible operation. This enables reading the instruction in one cycle and reading or writing the data in another cycle.
Data path design focuses on the design of ALU and other functional units as well as accessing the registers and memory. Control path design focuses on the design of the state machines to decode instructions and generate the sequence of control signals necessary to appropriately manipulate the data path.


![figure1](https://raw.githubusercontent.com/parhamsoltani/Multicycle_RISCV/main/Docs/figure1.png?token=GHSAT0AAAAAACKAEWWFZ5XXBGTND44MUIROZNW7EVA)


![figure2](https://raw.githubusercontent.com/parhamsoltani/Multicycle_RISCV/main/Docs/figure2.png?token=GHSAT0AAAAAACKAEWWEA6JB4IX33QCUDHFWZNW7FHA)


![figure3](https://raw.githubusercontent.com/parhamsoltani/Multicycle_RISCV/main/Docs/figure3.png?token=GHSAT0AAAAAACKAEWWFTT5LJN4VAPU6BX6WZNW7FSQ)


Processsor Output:

![RISCV_Core_Waveform]([https://github.com/parhamsoltani/Multicycle_RISCV/assets/70743729/3e23d9bc-83d2-4bec-a09f-aba2e75bedca](https://raw.githubusercontent.com/parhamsoltani/Multicycle_RISCV/main/Waveforms/RISCV_Core_Waveform.png?token=GHSAT0AAAAAACKAEWWE6NJ44C2WOQI6PV44ZNW7JRA)https://raw.githubusercontent.com/parhamsoltani/Multicycle_RISCV/main/Waveforms/RISCV_Core_Waveform.png?token=GHSAT0AAAAAACKAEWWE6NJ44C2WOQI6PV44ZNW7JRA)
