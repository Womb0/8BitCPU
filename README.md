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

## Data Path

The micro-archetecture for the CPU datapath:

![alt text](https://github.com/Womb0/8BitCPU/blob/master/8bitCPUDesign.png "CPU Datapath")

The LPM library was used to build the CPU. It offers verified VHDL designs of basic digital design circuits. Each block is a register or multiplexer. The upper right corner is the title of the block and lower right corner its LPM module, with the lpm's in/out signals around the block.

## Control Unit

The micro-archetecture for the CPU control unit:

*to be updated

## Source Code - 8BitCPUDatapath.vhd

*to be updated

## Source Code - 8BitCPUControlUnit.vhd

*to be updated
