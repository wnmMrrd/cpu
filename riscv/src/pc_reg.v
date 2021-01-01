`include "defines.v"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire[`StallBus] stall_state,

    input wire jump_flag,
    input wire[`InstAddrBus] jump_to,

    output reg[`InstAddrBus] pc
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            pc <= `ZeroWord;
        end else if(jump_flag == `True_v) begin
            pc <= jump_to;
        end else if(stall_state[0] == `True_v) begin
            
        end else begin
            pc <= pc+4;
        end
    end

endmodule