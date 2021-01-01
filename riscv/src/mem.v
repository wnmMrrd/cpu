`include "defines.v"

module mem(
    input wire rst,

    input wire[`AluOpBus] aluop_i,

    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    input wire ram_done,
    input wire[`MemBus] mem_addr,
    input wire[`RegBus] ram_r_data,
    output reg[3:0] buffer_pointer,

    output reg ram_r_req,
    output reg ram_w_req,
    output reg[`MemBus] ram_addr,
    output reg[`RegBus] ram_w_data,

    output reg mem_stall
);

    always @ (*) begin
        if(rst == `RstEnable) begin
            wd_o = 5'b00000;
            wreg_o = `WriteDisable;
            wdata_o = `ZeroWord;
            buffer_pointer = 3'h0;
            ram_r_req = `False_v;
            ram_w_req = `False_v;
            ram_addr = `ZeroWord;
            ram_w_data = `ZeroWord;
            mem_stall = `False_v;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            case(aluop_i)
                `MEM_NOP:begin
                    wdata_o = wdata_i;
                    buffer_pointer = 3'h0;
                    ram_r_req = `False_v;
                    ram_w_req = `False_v;
                    ram_addr = `ZeroWord;
                    ram_w_data = `ZeroWord;
                    mem_stall = `False_v;
                end
                `EX_LB:begin
                    wdata_o = {{24{ram_r_data[7]}},ram_r_data[7:0]};
                    ram_r_req = `True_v;
                    ram_w_req = `False_v;
                    ram_addr = mem_addr;
                    ram_w_data = `ZeroWord;
                    mem_stall = !ram_done;
                end
                `EX_LBU:begin
                    wdata_o = {24'h000000,ram_r_data[7:0]};
                    ram_r_req = `True_v;
                    ram_w_req = `False_v;
                    ram_addr = mem_addr;
                    ram_w_data = `ZeroWord;
                    mem_stall = !ram_done;
                end
                `EX_LH:begin
                    wdata_o = {{16{ram_r_data[15]}},ram_r_data[15:0]};
                    ram_r_req = `True_v;
                    ram_w_req = `False_v;
                    ram_addr = mem_addr;
                    ram_w_data = `ZeroWord;
                    mem_stall = !ram_done;
                end
                `EX_LHU:begin
                    wdata_o = {16'h0000,ram_r_data[15:0]};
                    ram_r_req = `True_v;
                    ram_w_req = `False_v;
                    ram_addr = mem_addr;
                    ram_w_data = `ZeroWord;
                    mem_stall = !ram_done;
                end
                `EX_LW:begin
                    wdata_o = ram_r_data;
                    ram_r_req = `True_v;
                    ram_w_req = `False_v;
                    ram_addr = mem_addr;
                    ram_w_data = `ZeroWord;
                    mem_stall = !ram_done;
                end
                `EX_SB:begin
                    wdata_o = wdata_i;
                    buffer_pointer = 3'h3;
                    ram_r_req = `False_v;
                    ram_w_req = `True_v;
                    ram_addr = mem_addr;
                    ram_w_data = wdata_i[7:0];
                    mem_stall = !ram_done;
                end
                `EX_SH:begin
                    wdata_o = wdata_i;
                    buffer_pointer = 3'h2;
                    ram_r_req = `False_v;
                    ram_w_req = `True_v;
                    ram_addr = mem_addr;
                    ram_w_data = wdata_i[15:0];
                    mem_stall = !ram_done;
                end
                `EX_SW:begin
                    wdata_o = wdata_i;
                    buffer_pointer = 3'h0;
                    ram_r_req = `False_v;
                    ram_w_req = `True_v;
                    ram_addr = mem_addr;
                    ram_w_data = wdata_i[31:0];
                    mem_stall = !ram_done;
                end
                default:begin
                    wdata_o = `ZeroWord;
                    buffer_pointer = 3'h0;
                    ram_r_req = `False_v;
                    ram_w_req = `False_v;
                    ram_addr = `ZeroWord;
                    ram_w_data = `ZeroWord;
                    mem_stall = `False_v;
                end
            endcase
        end
    end

endmodule