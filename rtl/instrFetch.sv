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
    // int file_handle;
    // bit [0:31] temp;
    // file_handle = $fopen("../assembler/output.txt", "r");
    // for (int i = 0; i < 4; i++) begin
    //         temp = $fscanf(file_handle, "%b", temp);   //Read each 32-bit line from the file.
    //         $display("%b", temp);
    //     for (int j = 0; j < 4; j++) begin
    //         imem_memory[i][j] = temp[8 * j +: 8];
    //     end
    // end
end

always_ff @(posedge clk) begin
    for (int i = 0; i < 8; i++) begin
        instr1[8 * i +: 8] <= imem_memory[PC_in + i];
        instr2[8 * i +: 8] <= imem_memory[(PC_in + 4) + i];
    end
end

endmodule
