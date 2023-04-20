module Imem (
    clk,
    reset,
    PC_in,
    instr1,
    instr2

);

input clk, reset;
input logic [0:31] PC_in;
output logic [0:31] instr1, instr2;

logic [0:7] imem_memory [0:2047] ; // 2KB IMEM memory

initial begin
    $readmemh("../assembler/output.txt", imem_memory);
end

always_ff @(posedge clk) begin
    for (int i = 0; i < 8; i++) begin
        instr1[8 * i +: 8] <= imem_memory[PC_in + i];
        instr2[8 * i +: 8] <= imem_memory[(PC_in + 4) + i];
    end
end

endmodule
