module fetchTb ();
    logic clk, reset;
    logic [0:31] PC_in, instr1, instr2;


    initial clk = 0;
    always #5 clk = ~clk;


    Imem dut(clk, reset,PC_in,instr1,instr2);

    initial begin
        PC_in = 32'd0;
        @ (posedge clk);
        PC_in = 32'd8;
        @ (posedge clk);
    end
endmodule