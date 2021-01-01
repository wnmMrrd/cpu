`include "defines.v"

module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`AluOpBus] ex_aluop,
    input wire[`MemBus] ex_mem_addr,
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,

    input wire[`StallBus] stall_state,

    output reg[`AluOpBus] mem_aluop,
    output reg[`MemBus] mem_mem_addr,
    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            mem_aluop <= `MEM_NOP;
            mem_mem_addr <= `ZeroWord;
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
        end else if(stall_state[3] == `True_v) begin

        end else begin
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
        end
    end

endmodule