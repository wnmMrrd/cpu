`include "defines.v"

module predictor(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus] if_pc,
    output reg je,
    output reg[`InstAddrBus] jaddr,

    input wire[`InstAddrBus] ex_pc,
    input wire is_j,
    input wire[`InstAddrBus] jto,
    input wire jmp_res
);

reg