module Imem (
    clk,
    reset,
    PC_in,
    imem_rd,

);

input clk, reset;
input logic [0:31] PC_in;
output logic [0:63] imem_rd;

logic [0:63] imem_memory [0:255]; // 2KB IMEM memory

always_ff @(posedge clk) begin
    imem_rd <= imem_memory[PC_in];
end

endmodule
