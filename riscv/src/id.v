`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    input ld_flag,
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,

    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,
    
    output reg[`InstAddrBus] pc_o,
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] imm,

    output wire id_stall
);

    wire[6:0] opcode = inst_i[6:0];
    wire[4:0] rd = inst_i[11:7];
    wire[2:0] func3 = inst_i[14:12];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];
    wire[6:0] func7 = inst_i[31:25];
    wire[11:0] I_imm = inst_i[31:20];
    wire[11:0] S_imm = {inst_i[31:25], inst_i[11:7]};
    wire[11:0] SB_imm = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
    wire[19:0] U_imm = inst_i[31:12];
    wire[19:0] UJ_imm = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};
    reg[31:0] imm;
    reg reg1_stall;
    reg reg2_stall;

    always @ (*) begin
        aluop_o = `EX_NOP;
        alusel_o = `EX_RES_NOP;
        wreg_o = `False_v;
        reg1_read_o = `False_v;
        reg2_read_o = `False_v;
        imm = `ZeroWord;
        wd_o = rd;
        reg1_addr_o = rs1;
        reg2_addr_o = rs2;
        pc_o = pc_i;
        if(rst != `RstEnable) begin
            case(opcode)
                `OPI:begin
                    case(func3)
                        `F3_ADDI:begin
                            aluop_o = `EX_ADD;
                            alusel_o = `EX_RES_ARITH;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_SLTI:begin
                            aluop_o = `EX_SLT;
                            alusel_o = `EX_RES_ARITH;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_SLTIU:begin
                            aluop_o = `EX_SLTU;
                            alusel_o = `EX_RES_ARITH;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_XORI:begin
                            aluop_o = `EX_XOR;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_ORI:begin
                            aluop_o = `EX_OR;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_ANDI:begin
                            aluop_o = `EX_AND;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_SLLI:begin
                            aluop_o = `EX_SLL;
                            alusel_o = `EX_RES_SHIFT;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {27'h0,I_imm[4:0]};
                        end
                        `F3_SRLI:begin
                            case(func7)
                                `F7_SRLI:begin
                                    aluop_o = `EX_SRL;
                                    alusel_o = `EX_RES_SHIFT;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `False_v;
                                    imm = {27'h0,I_imm[4:0]};
                                end
                                `F7_SRAI:begin
                                    aluop_o = `EX_SRA;
                                    alusel_o = `EX_RES_SHIFT;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `False_v;
                                    imm = {27'h0,I_imm[4:0]};
                                end
                            endcase
                        end
                        default:begin
                        end
                    endcase
                end
                `OP:begin
                    case(func3)
                        `F3_ADD:begin
                            case(func7)
                                `F7_ADD:begin
                                    aluop_o = `EX_ADD;
                                    alusel_o = `EX_RES_ARITH;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `True_v;
                                    imm = `ZeroWord;
                                end
                                `F7_SUB:begin
                                    aluop_o = `EX_SUB;
                                    alusel_o = `EX_RES_ARITH;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `True_v;
                                    imm = `ZeroWord;
                                end
                            endcase
                        end
                        `F3_SLT:begin
                            aluop_o = `EX_SLT;
                            alusel_o = `EX_RES_ARITH;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_SLTU:begin
                            aluop_o = `EX_SLTU;
                            alusel_o = `EX_RES_ARITH;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_XOR:begin
                            aluop_o = `EX_XOR;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_OR:begin
                            aluop_o = `EX_OR;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_AND:begin
                            aluop_o = `EX_AND;
                            alusel_o = `EX_RES_LOGIC;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_SLL:begin
                            aluop_o = `EX_SLL;
                            alusel_o = `EX_RES_SHIFT;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = `ZeroWord;
                        end
                        `F3_SRL:begin
                            case(func7)
                                `F7_SRL:begin
                                    aluop_o = `EX_SRL;
                                    alusel_o = `EX_RES_SHIFT;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `True_v;
                                    imm = `ZeroWord;
                                end
                                `F7_SRA:begin
                                    aluop_o = `EX_SRA;
                                    alusel_o = `EX_RES_SHIFT;
                                    wreg_o = `True_v;
                                    reg1_read_o = `True_v;
                                    reg2_read_o = `True_v;
                                    imm = `ZeroWord;
                                end
                            endcase
                        end
                        default:begin
                        end
                    endcase
                end
                `LOAD:begin
                    case(func3)
                        `F3_LB:begin
                            aluop_o = `EX_LB;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_LH:begin
                            aluop_o = `EX_LH;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_LW:begin
                            aluop_o = `EX_LW;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_LBU:begin
                            aluop_o = `EX_LBU;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        `F3_LHU:begin
                            aluop_o = `EX_LHU;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `True_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `False_v;
                            imm = {{20{I_imm[11]}},I_imm[11:0]};
                        end
                        default:begin
                        end
                    endcase
                end
                `STORE:begin
                    case(func3)
                        `F3_SB:begin
                            aluop_o = `EX_SB;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{20{S_imm[11]}},S_imm[11:0]};
                        end
                        `F3_SH:begin
                            aluop_o = `EX_SH;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{20{S_imm[11]}},S_imm[11:0]};
                        end
                        `F3_SB:begin
                            aluop_o = `EX_SW;
                            alusel_o = `EX_RES_LD_ST;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{20{S_imm[11]}},S_imm[11:0]};
                        end
                        default:begin
                        end
                    endcase
                end
                `BRANCH:begin
                    case(func3)
                        `F3_BEQ:begin
                            aluop_o = `EX_BEQ;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        `F3_BNE:begin
                            aluop_o = `EX_BNE;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        `F3_BLT:begin
                            aluop_o = `EX_BLT;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        `F3_BGE:begin
                            aluop_o = `EX_BGE;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        `F3_BLTU:begin
                            aluop_o = `EX_BLTU;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        `F3_BGEU:begin
                            aluop_o = `EX_BGEU;
                            alusel_o = `EX_RES_NOP;
                            wreg_o = `False_v;
                            reg1_read_o = `True_v;
                            reg2_read_o = `True_v;
                            imm = {{19{SB_imm[11]}},SB_imm,1'b0};
                        end
                        default:begin
                        end
                    endcase
                end
                `JAL:begin
                    aluop_o = `EX_JAL;
                    alusel_o = `EX_RES_JAL;
                    wreg_o = `True_v;
                    reg1_read_o = `False_v;
                    reg2_read_o = `False_v;
                    imm = {{11{UJ_imm[19]}},UJ_imm,1'h0};
                end
                `JALR:begin
                    aluop_o = `EX_JALR;
                    alusel_o = `EX_RES_JAL;
                    wreg_o = `True_v;
                    reg1_read_o = `True_v;
                    reg2_read_o = `False_v;
                    imm = {{20{I_imm[11]}},I_imm};
                end
                `LUI:begin
                    aluop_o = `EX_OR;
                    alusel_o = `EX_RES_LOGIC;
                    wreg_o = `True_v;
                    reg1_read_o = `False_v;
                    reg2_read_o = `False_v;
                    imm = {U_imm,12'h0};
                end
                `AUIPC:begin
                    aluop_o = `EX_AUIPC;
                    alusel_o = `EX_RES_ARITH;
                    wreg_o = `True_v;
                    reg1_read_o = `False_v;
                    reg2_read_o = `False_v;
                    imm = {U_imm,12'h0};
                end
                default:begin
                end   
            endcase             
        end
    end

    always @ (*) begin
        reg1_stall = `False;
        if(rst == `RstEnable) begin
            reg1_o = `ZeroWord;
        end else if((reg1_read_o == `True_v) && (ld_flag == `True_v) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o = `ZeroWord;
            reg1_stall = `True_v;
        end else if((reg1_read_o == `True_v) && (ex_wreg_i == `True_v) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o = ex_wdata_i;
        end else if ((reg1_read_o == `True_v) && (mem_wreg_i == `True_v) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o = mem_wdata_i;
        end else if(reg1_read_o == `True_v) begin
            reg1_o = reg1_data_i;
        end else if(reg1_read_o == `False_v) begin
            reg1_o =imm;
        end else begin
            reg1_o = `ZeroWord;
        end
    end

    always @ (*) begin
        reg2_stall = `False;
        if(rst == `RstEnable) begin
            reg2_o = `ZeroWord;
        end else if((reg2_read_o == `True_v) && (ld_flag == `True_v) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o = `ZeroWord;
            reg2_stall = `True_v;
        end else if((reg2_read_o == `True_v) && (ex_wreg_i == `True_v) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o = ex_wdata_i;
        end else if ((reg2_read_o == `True_v) && (mem_wreg_i == `True_v) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o = mem_wdata_i;
        end else if(reg2_read_o == `True_v) begin
            reg2_o = reg2_data_i;
        end else if(reg2_read_o == `False_v) begin
            reg2_o =imm;
        end else begin
            reg2_o = `ZeroWord;
        end
    end

    assign id_stall = reg1_stall|reg2_stall;

endmodule