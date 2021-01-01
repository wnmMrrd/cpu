`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,

    input jump_flag,
    input  wire[`StallBus] stall_state,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
);

    always @ (posedge clk) begin
        if(rst == `RstEnable || jump_flag == `True_v) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if(stall_state[2] == `True_v) begin
            
        end else if(stall_state[1] == `True_v) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule