`include "defines.v"

module ex(
    input wire rst,
    
    input wire[`InstAddrBus] pc_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegBus] imm_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    output reg[`AluOpBus] aluop_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[`InstAddrBus] memd_o,

    output reg[`InstAddrBus] branch_to,
    output reg jump_flag,
    output reg ld_flag
);

    reg[`RegBus] arithout;
    reg[`RegBus] logicout;
    reg[`RegBus] shiftres;
    wire[`InstAddrBus] jalr_to = reg1_i+imm_i;

    always @ (*) begin
        if(rst != `RstEnable) begin
            wd_o = wd_i;
            wreg_o = (rd&&wreg_i) ? 1'b1:1'b0;
            jump_flag = `False_v;
            case(aluop_i)
                `EX_JAL:begin
                    jump_flag = `True_v;
                    branch_to = pc_i+imm_i;
                end
                `EX_JALR:begin
                    jump_flag = `True_v;
                    branch_to = {jarl_to[31:1],1'b0};
                end
                `EX_BEQ:begin
                    if(reg1_i == reg2_i) begin
                        jump_flag = `True_v;
                        branch_to = pc_i+imm_i;
                    end else begin
                        branch_to = pc_i+4;
                    end
                end
                `EX_BNE:begin
                    if(reg1_i != reg2_i) begin
                        jump_flag = `True_v;
                        branch_to = pc_i+imm_i;
                    end else begin
                        branch_to = pc_i+4;
                    end
                end
                `EX_BLT:begin
                    if($signed(reg1_i) < $signed(reg2_i)) begin
                        jump_flag = `True_v;
                        branch_to = pc_i+imm_i;
                    end else begin
                        branch_to = pc_i+4;
                    end
                end
                `EX_BLT:begin
                    if($signed(reg1_i) >= $signed(reg2_i)) begin
                        jump_flag = `True_v;
                        branch_to = pc_i+imm_i;
                    end else begin
                        branch_to = pc_i+4;
                    end
                end
            endcase
        end
    end

endmodule