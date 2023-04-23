module instrFetch (
    clk,
    reset,
    PC,
    instr1,
    instr2,
    dep_stall_instr2

);

input clk, reset, dep_stall_instr2;
output logic [0 : WORD - 1] PC, instr1, instr2;

logic [0:7] imem_memory [0:2047] ; // 2KB IMEM memory

initial begin
    $readmemh("../assembler/output.txt", imem_memory);
end

always_ff @(posedge clk) begin
    if(!dep_stall_instr2) begin
        if(!PC[29]) begin
            for (int i = 0; i < 8; i++) begin
                instr1[8 * i +: 8] <= imem_memory[PC + i];
                instr2[8 * i +: 8] <= imem_memory[(PC + 4) + i];
            end
            PC <= PC + 8;
        end
        else begin
            for (int i = 0; i < 4; i++) begin
                instr1 = {11'b00000000001, 21'd0};  //send nop
                instr2[8 * i +: 8] <= imem_memory[PC + i];
            end
            PC <= PC + 4;

        end
    end
end

endmodule
