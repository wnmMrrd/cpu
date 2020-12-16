`include "defines.v"

module stall(
    input wire rst,
    input wire if_stall,
    input wire id_stall,
    input wire mem_stall,
    output reg stall_state
);

    always @ (*) begin
        if(rst == `RstEnable) begin
            state_state <= `AllStall;
        end else if(mem_stall == `True_v) begin
            stall_state <= `MemStall;
        end else if(id_stall == `True_v) begin
            stall_state <= `IdStall;
        end else if(if_stall == `True_v) begin
            stall_state <= `IfStall;
        end else begin
            stall_state <= `NoStall;
        end
    end

endmodule