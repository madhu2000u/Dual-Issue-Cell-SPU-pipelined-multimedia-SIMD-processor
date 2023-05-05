module instrFetch (
    clk,
    reset,
    stop_and_signal,
    PC,
    branch_taken,
    BTA,
    instr1,
    instr2,
    dep_stall_instr1,
    dep_stall_instr2

);

input clk, reset, stop_and_signal, branch_taken, dep_stall_instr1, dep_stall_instr2;
input [0 : WORD - 1] BTA;
logic [0 : WORD - 1] instr1_read, instr2_read;
output logic [0 : WORD - 1] PC, instr1, instr2;

logic [0:7] imem_memory [0:2047] ; // 2KB IMEM memory

initial begin
    $readmemh("../assembler/output.txt", imem_memory);
end

always_comb begin

    if(!PC[29]) begin
        for (int i = 0; i < 8; i++) begin
            instr1_read[8 * i +: 8] = imem_memory[PC + i];
            instr2_read[8 * i +: 8] = imem_memory[(PC + 4) + i];
        end
    end
    else begin
        for (int i = 0; i < 4; i++) begin
            instr1_read = {11'b00000000001, 21'd0};  //send lnop
            instr2_read[8 * i +: 8] = imem_memory[PC + i];
        end

    end
end

always_ff @( posedge clk ) begin : instrFetch
    if(reset) begin
        PC <= 0;
    end
    else if(!stop_and_signal) begin
        if((!dep_stall_instr1 && !dep_stall_instr2) && !branch_taken) begin
            if(!PC[29]) 
                PC <= PC + 8;
            else 
                PC <= PC + 4;
            
                instr1 <= instr1_read;
                instr2 <= instr2_read;
        end

        if(branch_taken)
            PC <= BTA;
    end
end

endmodule
