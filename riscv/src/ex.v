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
    output reg[`MemBus] addr_o,
    output wire[`RegAddrBus] wd_o,
    output wire wreg_o,
    output reg[`RegBus] wdata_o,

    output reg jump_flag,
    output reg[`InstAddrBus] jump_to,
    output reg ld_flag
);

    reg[`RegBus] arithout;
    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    wire[`InstAddrBus] jalr_to = reg1_i+imm_i;

    assign wd_o = wd_i;
    assign wreg_o = (wd_i&&wreg_i) ? 1'b1:1'b0;

    always @ (*) begin
        if(rst != `RstEnable) begin
            case(aluop_i)
                `EX_JAL:begin
                    jump_flag = `True_v;
                    jump_to = pc_i+imm_i;
                end
                `EX_JALR:begin
                    jump_flag = `True_v;
                    jump_to = {jalr_to[31:1],1'b0};
                end
                `EX_BEQ:begin
                    if(reg1_i == reg2_i) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                `EX_BNE:begin
                    if(reg1_i != reg2_i) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                `EX_BLT:begin
                    if($signed(reg1_i) < $signed(reg2_i)) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                `EX_BGE:begin
                    if($signed(reg1_i) >= $signed(reg2_i)) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                `EX_BLTU:begin
                    if(reg1_i < reg2_i) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                `EX_BGEU:begin
                    if(reg1_i >= reg2_i) begin
                        jump_flag = `True_v;
                        jump_to = pc_i+imm_i;
                    end else begin
                        jump_flag = `False_v;
                    end
                end
                default:begin
                    jump_flag = `False_v;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            arithout = `ZeroWord;
        end else begin
            case(aluop_i)
                `EX_ADD:
                    arithout = reg1_i+reg2_i;
                `EX_SUB:
                    arithout = reg1_i-reg2_i;
                `EX_SLTU:
                    arithout = reg1_i<reg2_i;
                `EX_SLT:
                    arithout = $signed(reg1_i)<$signed(reg2_i);
                `EX_AUIPC:
                    arithout = pc_i+imm_i;
                default:begin
                    arithout = `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            logicout = `ZeroWord;
        end else begin
            case(aluop_i)
                `EX_AND:
                    logicout = reg1_i&reg2_i;
                `EX_OR:
                    logicout = reg1_i|reg2_i;
                `EX_XOR:
                    logicout = reg1_i^reg2_i;
                default:begin
                    logicout = `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            shiftout = `ZeroWord;
        end else begin
            case(aluop_i)
                `EX_SLL:
                    shiftout = reg1_i<<(reg2_i[4:0]);
                `EX_SRL:
                    shiftout = reg1_i>>(reg2_i[4:0]);
                `EX_SRA:
                    shiftout = (reg1_i>>(reg2_i[4:0])) | ({32{reg1_i[31]}}<<(6'd32-{1'b0,reg2_i[4:0]}));
                default:begin
                    shiftout = `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            addr_o = `ZeroWord;
            ld_flag = `False_v;
        end else begin
            case(aluop_i)
                `EX_LW,`EX_LH,`EX_LB,`EX_LHU,`EX_LBU:begin
                    addr_o = reg1_i+imm_i;
                    ld_flag = `True_v;
                end
                `EX_SH,`EX_SB,`EX_SW:begin
                    addr_o = reg1_i+imm_i;
                    ld_flag = `False_v;
                end
                default:begin
                    addr_o = `ZeroWord;
                    ld_flag = `False_v;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            wdata_o = `ZeroWord;
            aluop_o = `MEM_NOP;
        end else begin
            case(alusel_i)
                `EX_RES_JAL:begin
                    wdata_o = pc_i+4;
                    aluop_o = `MEM_NOP;
                end
                `EX_RES_ARITH:begin
                    wdata_o = arithout;
                    aluop_o = `MEM_NOP;
                end
                `EX_RES_LOGIC:begin
                    wdata_o = logicout;
                    aluop_o = `MEM_NOP;
                end
                `EX_RES_SHIFT:begin
                    wdata_o = shiftout;
                    aluop_o = `MEM_NOP;
                end
                `EX_RES_LD_ST:begin
                    wdata_o = reg2_i;
                    aluop_o = aluop_i;
                end
                `EX_RES_NOP:begin
                    wdata_o = `ZeroWord;
                    aluop_o = `MEM_NOP;
                end
                default:begin
                    wdata_o = `ZeroWord;
                    aluop_o = `MEM_NOP;
                end
            endcase
        end
    end

endmodule