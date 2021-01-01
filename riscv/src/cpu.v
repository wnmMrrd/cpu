`include "defines.v"

// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

  wire rst;
  assign rst = rst_in|(~rdy_in);

  //pc_reg -> if
  wire [`InstAddrBus] if_pc_i;

  wire jump_flag;
  wire [`InstAddrBus] jump_to;

  //if -> if_id
  wire [`InstAddrBus] if_pc_o;
  wire [`InstBus] if_inst_o;

  //if_id -> id
  wire [`InstAddrBus] id_pc_i;
  wire [`InstBus] id_inst_i;

  //id -> regfile
  wire reg1_read;
  wire reg2_read;
  wire [`RegAddrBus] reg1_addr;
  wire [`RegAddrBus] reg2_addr;

  //regfile -> id
  wire [`RegBus] reg1_data;
  wire [`RegBus] reg2_data;

  //id -> id_ex
  wire [`RegAddrBus] id_wd_o;
  wire [`InstAddrBus] id_pc_o;
  wire [`AluOpBus] id_aluop_o;
  wire [`AluSelBus] id_alusel_o;
  wire id_wreg_o;
  wire [`RegBus] id_imm;
  wire [`RegBus] id_reg1_o;
  wire [`RegBus] id_reg2_o;

  //id_ex -> ex
  wire[`InstAddrBus] ex_pc_i;
  wire [`AluOpBus] ex_aluop_i;
  wire [`AluSelBus] ex_alusel_i;
  wire [`RegBus] ex_reg1_i;
  wire [`RegBus] ex_reg2_i;
  wire [`RegBus] ex_imm_i;
  wire [`RegAddrBus] ex_wd_i;
  wire ex_wreg_i;

  //ex -> ex_mem
  wire [`AluOpBus] ex_aluop_o;
  wire [`MemBus] ex_addr_o;
  wire [`RegAddrBus] ex_wd_o;
  wire ex_wreg_o;
  wire [`RegBus] ex_wdata_o;

  //ex LOAD_FLAG
  wire ex_ld_flag_o;

  //ex_mem -> mem
  wire [`AluOpBus] mem_aluop_i;
  wire [`MemBus] mem_mem_addr_i;
  wire [`RegAddrBus] mem_wd_i;
  wire mem_wreg_i;
  wire [`RegBus] mem_wdata_i;

  //mem -> mem_wb
  wire [`RegAddrBus] mem_wd_o;
  wire mem_wreg_o;
  wire [`RegBus] mem_wdata_o;

  //mem_wb -> regfile
  wire [`RegAddrBus] wb_wd_i;
  wire wb_wreg_i;
  wire [`RegBus] wb_wdata_i;

  //mem_ctrl
  wire inst_req_i;
	wire [`InstAddrBus] inst_addr_i;
	wire [`InstBus] inst_o;
	wire [`InstAddrBus] inst_addr_o;
	wire inst_done_o;
  wire ram_r_req;
	wire ram_w_req;
	wire [31:0] ram_addr;
	wire [31:0] ram_r_data;
	wire [31:0] ram_w_data;
	wire [3:0] buffer_pointer_i;
	wire ram_done;

  //stall
  wire if_stall;
  wire id_stall;
  wire mem_stall;
  wire [4:0] stall_state;

  assign dbgreg_dout = wb_wreg_i ? wb_wdata_i : `ZeroWord;

  pc_reg pc_reg0(
    .clk(clk_in), .rst(rst),
    .stall_state(stall_state),
    .jump_flag(jump_flag), .jump_to(jump_to),
    .pc(if_pc_i)
  );

  IF IF0(
    .clk(clk_in), .rst(rst),
    .pc_i(if_pc_i), .pc_o(if_pc_o), .inst_o(if_inst_o),
    .inst_done(inst_done_o), .inst_i(inst_o), .inst_pc(inst_addr_o), .inst_req(inst_req_i), .inst_addr(inst_addr_i),
    .if_stall(if_stall)
  );

  if_id if_id0(
    .clk(clk_in), .rst(rst),
    .if_pc(if_pc_o), .if_inst(if_inst_o),
    .jump_flag(jump_flag), .stall_state(stall_state),
    .id_pc(id_pc_i), .id_inst(id_inst_i)
  );

  id id0(
    .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    .ld_flag(ex_ld_flag_o), .ex_wreg_i(ex_wreg_o), .ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o),
    .mem_wreg_i(mem_wreg_o), .mem_wdata_i(mem_wdata_o), .mem_wd_i(mem_wd_o),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr), .wd_o(id_wd_o),
    .pc_o(id_pc_o), .aluop_o(id_aluop_o), .alusel_o(id_alusel_o), .reg1_read_o(reg1_read), .reg2_read_o(reg2_read), .wreg_o(id_wreg_o), .imm(id_imm), 
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .id_stall(id_stall)
  );

  regfile regfile0(
    .clk(clk_in), .rst(rst),
    .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i),
    .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
  );

  id_ex id_ex0(
    .clk(clk_in), .rst(rst),
    .id_aluop(id_aluop_o), .id_alusel(id_alusel_o), .id_reg1(id_reg1_o), .id_reg2(id_reg2_o), .id_imm(id_imm), .id_wd(id_wd_o), .id_wreg(id_wreg_o),
    .jump_flag(jump_flag), .id_pc(id_pc_o), .ex_pc(ex_pc_i),
    .stall_state(stall_state),
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i), .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i), .ex_imm(ex_imm_i), .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i)
  );

  ex ex0(
    .rst(rst),
    .pc_i(ex_pc_i), .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i), .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i), .imm_i(ex_imm_i), .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
    .aluop_o(ex_aluop_o), .addr_o(ex_addr_o), .wd_o(ex_wd_o), .wreg_o(ex_wreg_o), .wdata_o(ex_wdata_o),
    .jump_flag(jump_flag), .jump_to(jump_to), .ld_flag(ex_ld_flag_o)
  );

  ex_mem ex_mem0(
    .clk(clk_in), .rst(rst),
    .ex_aluop(ex_aluop_o), .ex_mem_addr(ex_addr_o), .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o), .ex_wdata(ex_wdata_o),
    .stall_state(stall_state),
    .mem_aluop(mem_aluop_i), .mem_mem_addr(mem_mem_addr_i), .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i), .mem_wdata(mem_wdata_i)
  );

  mem mem0(
    .rst(rst),
    .aluop_i(mem_aluop_i),
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i), .wdata_i(mem_wdata_i),
    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o), .wdata_o(mem_wdata_o),
    .ram_done(ram_done), .mem_addr(mem_mem_addr_i), .ram_r_data(ram_r_data), .buffer_pointer(buffer_pointer_i),
    .ram_r_req(ram_r_req), .ram_w_req(ram_w_req), .ram_addr(ram_addr), .ram_w_data(ram_w_data),
    .mem_stall(mem_stall)
  );

  mem_ctrl mem_ctrl0(
    .clk(clk_in), .rst(rst),
    .inst_req_i(inst_req_i), .inst_addr_i(inst_addr_i), .inst_o(inst_o), .inst_addr_o(inst_addr_o), .inst_done_o(inst_done_o),
    .ram_r_req(ram_r_req), .ram_w_req(ram_w_req), .ram_addr(ram_addr), .ram_r_data(ram_r_data), .ram_w_data(ram_w_data), .buffer_pointer_i(buffer_pointer_i), .ram_done(ram_done),
    .mem_din(mem_din), .mem_dout(mem_dout), .mem_a(mem_a), .mem_wr(mem_wr)
  );

  mem_wb mem_wb0(
    .clk(clk_in), .rst(rst),
    .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o), .mem_wdata(mem_wdata_o),
    .stall_state(stall_state),
    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i), .wb_wdata(wb_wdata_i)
  );

  stall stall0(
    .rst(rst),
    .if_stall(if_stall), .id_stall(id_stall), .mem_stall(mem_stall), .stall_state(stall_state)
  );

endmodule