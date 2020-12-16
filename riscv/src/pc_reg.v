`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire[`StallBus] stall_state,

    input wire ex_be_i,
    input wire[`InstAddrBus] ex_bto_i,

    input wire je,
    input wire jto,

    output reg[`InstAddrBus] pc,
    output reg jmp
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            pc <= `ZeroWord;
            jmp <= `False_v;
        end else if(stall_state[1] == `True_v) begin
            
        end else if(ex_be_i == `True_v) begin
            pc <= ex_bto_i;
            jmp <= `False_v;
        end else if(stall_state[0] == `True_v) begin
            
        end else if(je == `True_v) begin
            pc <= jto;
            jmp <= `True_v;
        end else begin
            pc <= pc+4;
            jmp <= `False_v;
        end
    end

endmodule