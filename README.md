# 8BitCPU
8-bit VHDL implementation lab project. Written with Altera Quartus II and synthesized on Altera DE-2

Final lab project for undergraduate computer engineering degree
***
## Given Instruction Set

The CPU has 7 operation registers:
* Program Counter PC - 8-bits
* Memory Address Register MAR- 8-bits
* Instruction Register IR - 8-bits
* Data Register DR - 8-bits
* Accumulator A - 8-bits
* General Purpose Register R - 8-bits
* Program Counter PC - 8-bits
* Condition Flip-Flop Z - 1 bit

Z tests for 0x00 in the accumulator.

The given instruction set:

| **Instruction**  | **Instruction Code** | **Operation**             |
| ---------------- |:-------------------- | --------------------------|
| NOP              | 00000000             | No Operation              |
| LOADI X          | 00010000 X           | A 🡠 X                    |
| LOAD X           | 00100000 X           | A 🡠 M[X]                 |
| STORE X          | 00110000 X           | M[X] 🡠 A                 |
| MOVE             | 01000000             | R 🡠 A                    |
| ADD              | 01010000             | A 🡠 A + R                |
| SUB              | 01100000             | A 🡠 A - R                |
| TESTNZ           | 01110000             | Z 🡠 !V                   |
| TESTZ            | 01110001             | Z 🡠 V                    |
| JUMP X           | 10000000 X           | PC 🡠 X                   |
| JUMPZ X          | 10010000 X           | If (Z = 1) then PC 🡠 X   |
| ADDI X           | 10100000 X           | A 🡠 A + X                |
| SUBI X           | 10110000 X           | A 🡠 A - X                |
| ADD X            | 11000000 X           | A 🡠 A + M[X]             |
| SUB X            | 11010000 X           | A 🡠 A - M[X]             |
| HALT             | 11110000             | PC 🡠 0, Stop increment   |

V is the OR of A data bits.
X is an 8-bit data or address value.

## RTL Statements

The developed RTL statements to structure the micro-archetecture.
 
Fetch 
* Fetch1: MAR <= PC 
* Fetch2: DR <= M[MAR], PC <= PC + 1 
* Fetch3: IR <= DR

Loadi x 
* LOADIX1: MAR <= PC 
* LOADIX2: DR <= M[MAR], PC <= PC + 1 
* LOADIX3: A <= DR 
 
Load x 
 * LOADX1: MAR <= PC 
 * LOADX2: DR <= M[MAR], PC <= PC + 1 
 * LOADX3: MAR <= DR 
 * LOADX4: A <= M[MAR] 
 
Store x 
* STOREX1: MAR <= PC 
* STOREX2: DR <= M[MAR], PC <= PC + 1 
* STOREX3: MAR <= DR 
* STOREX4: DR <= A 
* STOREX5: M[MAR] <= DR

Add 
* ADD1: A <= A + R 

Addi X 
* ADDIX1: MAR <= PC 
* ADDIX2: DR <= M[MAR], PC <= PC + 1 
* ADDIX3: A <= A + DR

Subi X 
* SUBIX1: MAR <= PC 
* SUBIX2: DR <= M[MAR], PC <= PC + 1 
* SUBIX3: A <= A - DR 

Add x  
* ADDX1: MAR <= PC 
* ADDX2: DR <= M[MAR], PC <= PC + 1 
* ADDX3: MAR <= DR 
* ADDX4: A <= A + M[MAR] 

Sub x  
* SUBX1: MAR <= PC 
* SUBX2: DR <= M[MAR], PC <= PC + 1 
* SUBX3: MAR <= DR 
* SUBX4: A <= A - M[MAR] 

Sub 
* SUB1: A <= A - R 

Move 
* MOVE1: R <= A 

Test NZ 
* TESTNZ1: Z <= not (A (7) or A (6) or A (5) or A (4) or A (3) or A (2) or A (1) or A (0)) 

Test Z 
* TESTZ1: Z <= A (7) or A (6) or A (5) or A (4) or A (3) or A (2) or A (1) or A (0) 

Jump x 
* JUMPX1: MAR <= PC 
* JUMPX2: PC <= M[MAR] 

JumpZ X 
* JUMPZ1: MAR <= PC 
* JUMPZ2: DR <= M[MAR], PC <= PC + 1 
* JUMPZ3: IF (Z = 1) THEN PC <= DR 

Halt 
* HALT1: PC <= 0 

## Datapath

The micro-archetecture for the CPU datapath:

![alt text](https://github.com/Womb0/8BitCPU/blob/master/8bitCPUDesign.png "CPU Datapath")

The LPM library was used to build the CPU. It offers verified VHDL designs of basic digital design circuits. Each block is a register or multiplexer. The upper right corner is the title of the block and lower right corner its LPM module, with the lpm's in/out signals around the block. All signals are 8 bits wide unless otherwise specified, other than control signals (en/sel/write) which are 1 bit wide.

## Control Unit

The micro-architecture for the CPU control unit:

![alt text](https://github.com/Womb0/8BitCPU/blob/master/8bitCPUuSeq.png "CPU Control Unit")

Also built with the LPM library. *Opcode* is the IR register for the first fetch execution. *uPC_enable* is the signal to load the next set of uops. *uPC_clear* loads all zeros into the uPC register and points to the first uop in the ROM. One cycle is lost here as the NOP command is located at uROM location 0x00, which then points to the proper FETCH command. The uROM content is compiled in **uromcontent.mif**. 

## Source Code - 8BitCPUDatapath.vhd

This defines the CPU data path in VHDL. The entity block has 3 inputs, *clk*, *pause*, and *clear*. *clk* is the system clock and routed from the board. The other 2 are buttons on the board. *Pause* is meant to temporarily stop clock progression while asserted. *Clear* is sent to the microsequencer to clear the uPC register that points to a uROM address. This allows for proper sequencing (should be asserted once before first clock cycle, that is, the first *cout* clock cycle discussed later.)

The architecture block first has two component inclusions, the uSequencer and a decoder. The decoder allows for debugging and decodes particular registers and outputs them to a seven-segment-display.

All the signals are then created. These are all the mux, register, and control I/O signals. This includes *cout*, which is a signal for an incrementing counter on the system clock *clk*. This allows for changing (slowing) the clock frequency by adjusting the counter's width.

The counter is then defined and assigned *cout*. This is followed by the mux data initialization, with some use of generate and logic statments.

Next, the control signals are defined. *upc_enable* is later sent as the uSeq input to lead the next uOp set, and so is the AND of the *cout* clock and NOT *pause*. The rest of the control signals are then the AND of its particular *uop* bit and *upc_enable*. The rest of the file then defines and connects the data path modules as described above. Notable here is that a RAM.mif file must be provided and linked to run a program. Also some decoders are defined for monitoring.

## Source Code - 8BitCPUControlUnit.vhd

* to be updated
