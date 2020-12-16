`timescale 1ns/1ps

`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 7:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI 6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

`define EXE_SLL 6'b000000
`define EXE_SLLV 6'b000100
`define EXE_SRL 6'b000010
`define EXE_SRLV 6'b000110
`define EXE_SRA 6'b000011
`define EXE_SRAV 6'b000111

`define EXE_SYNC 6'b001111
`define EXE_PREV 6'b110011
`define EXE_SPECIAL_INST 6'b000000

`define EXE_OR_OP 8'b00100101
`define EXE_NOP_OP 8'b00000000

`define EXE_RES_LOGIC 3'b001

`define EXE_RES_NOP 3'b000

`define AUIPC       7'b0010111
`define LUI         7'b0110111
`define OP          7'b0110011
`define OPI         7'b0010011
`define JAL         7'b1101111
`define JALR        7'b1100111
`define LOAD        7'b0000011
`define STORE       7'b0100011
`define BRANCH      7'b1100011

`define F3_BEQ   3'b000
`define F3_BNE   3'b001
`define F3_BLT   3'b100
`define F3_BGE   3'b101
`define F3_BLTU  3'b110
`define F3_BGEU  3'b111

`define F3_LB    3'b000
`define F3_LH    3'b001
`define F3_LW    3'b010
`define F3_LBU   3'b100
`define F3_LHU   3'b101

`define F3_SB    3'b000
`define F3_SH    3'b001
`define F3_SW    3'b010

`define F3_ADD   3'b000
`define F3_SUB   3'b000
`define F3_SLL   3'b001
`define F3_SLT   3'b010
`define F3_SLTU  3'b011
`define F3_XOR   3'b100
`define F3_SRL   3'b101
`define F3_SRA   3'b101
`define F3_OR    3'b110
`define F3_AND   3'b111

`define F3_ADDI  3'b000
`define F3_SLTI  3'b010
`define F3_SLTIU 3'b011
`define F3_XORI  3'b100
`define F3_ORI   3'b110
`define F3_ANDI  3'b111
`define F3_SLLI  3'b001
`define F3_SRLI  3'b101
`define F3_SRAI  3'b101

`define F7_SLLI 7'b0000000
`define F7_SRLI 7'b0000000
`define F7_SRAI 7'b0100000
`define F7_ADD 7'b0000000
`define F7_SUB 7'b0100000
`define F7_SLL 7'b0000000
`define F7_SLT 7'b0000000
`define F7_SLTU 7'b0000000
`define F7_XOR 7'b0000000
`define F7_SRL 7'b0000000
`define F7_SRA 7'b0100000
`define F7_OR 7'b0000000
`define F7_AND 7'b0000000

`define EX_NOP   5'h0
`define EX_ADD   5'h1
`define EX_SUB   5'h2
`define EX_SLT   5'h3
`define EX_SLTU  5'h4
`define EX_XOR   5'h5
`define EX_OR    5'h6
`define EX_AND   5'h7
`define EX_SLL   5'h8
`define EX_SRL   5'h9
`define EX_SRA   5'ha
`define EX_AUIPC 5'hb

`define EX_JAL   5'hc
`define EX_JALR  5'hd
`define EX_BEQ   5'he
`define EX_BNE   5'hf
`define EX_BLT   5'h10
`define EX_BGE   5'h11
`define EX_BLTU  5'h12
`define EX_BGEU  5'h13

`define EX_LB    5'h14
`define EX_LH    5'h15
`define EX_LW    5'h16
`define EX_LBU   5'h17
`define EX_LHU   5'h18

`define EX_SB    5'h19
`define EX_SH    5'h1a
`define EX_SW    5'h1b

`define MEM_NOP   5'h0

`define EX_RES_NOP      3'b000
`define EX_RES_LOGIC    3'b001
`define EX_RES_SHIFT    3'b010
`define EX_RES_ARITH    3'b011
`define EX_RES_JAL      3'b100
`define EX_RES_LD_ST    3'b101
`define EX_RES_NOP      3'b000

`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

`define NoStall 4'b0000
`define IfStall 4'b00011
`define IdStall 4'b00111
`define MemStall 4'b11111
`define AllStall 5'b11111
`define StallBus 4:0

`define RamBus 7:0

`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000