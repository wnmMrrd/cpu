`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,

    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire[`RegBus] id_imm,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,

    input wire jump_flag,
    input wire[`InstAddrBus] id_pc,
    output reg[`InstAddrBus] ex_pc,

    input wire[`StallBus] stall_state,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegBus] ex_imm,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            ex_pc <= `ZeroWord;
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_imm <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
        end else if(stall_state[3] == `True_v) begin

        end else if(stall_state[2] == `True_v || jump_flag) begin
            ex_pc <= `ZeroWord;
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_imm <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
        end else begin
            ex_pc <= id_pc;
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_imm <= id_imm;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
        end
    end

endmodule