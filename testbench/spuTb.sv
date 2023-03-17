`include "../rtl/constants.sv"
// `include "../rtl/spuMainModule.sv"
module spuTb ();
    
    logic                                   clk, reset;
    logic [0 : UNIT_ID_SIZE - 1]            unit_id;
    logic [0 : INTERNAL_OPCODE_SIZE - 1]    opcode_even, opcode_odd;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    logic [0 : IMM7 - 1]                    imm7;
    logic [0 : IMM10 - 1]                   imm10;
    logic [0 : IMM16 - 1]                   imm16;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;
    logic                                   regWr_en_even, regWr_en_odd;
    logic [0:QUADWORD-1]                    ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd;
    logic init, init2;
    
    initial clk = 0;
    always #5 clk = ~clk;

    spuMainModule dut(clk,
    reset,
    unit_id,
    opcode_even,
    opcode_odd,
    /*regWr_en_even,*/
    addr_ra_rd_even,
    addr_rb_rd_even,
    addr_rc_rd_even,
    addr_rt_wt_even,
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rc_rd_odd,
    addr_rt_wt_odd,
    imm7,
    imm10,
    imm16,
    init,
    init2);

    // registerFile registerFile (clk,
    // reset,
    // ra_rd_even,
    // rb_rd_even,
    // rc_rd_even,
    // rt_wt_even,
    // ra_rd_odd,
    // rb_rd_odd,
    // rt_wt_odd,
    // addr_ra_rd_even,
    // addr_rb_rd_even, 
    // addr_rc_rd_even,
    // addr_rt_wt_even, 
    // addr_ra_rd_odd, 
    // addr_rb_rd_odd,
    // addr_rt_wt_odd,
    // regWr_en_even, 
    // regWr_en_odd);

    // task load_reg_file;
    //     input [0:127] reg1_value;
    //     input [0:127] reg2_value;

    //     // Hierarchical reference to the register file

    //     // Load values into the registers
    //     spuMainModule.registerFile.registerFile.registerFile[0] <= reg1_value;
    //     spuMainModule.registerFile.registerFile.registerFile[3] <= reg2_value;
    // endtask


    initial begin
        // init = 1;
        // init2 = 0;
        // @(posedge clk);
        // init = 0;
        // init2 = 1;
        // @(posedge clk);
        // init = 0;
        // init2 = 0;
        //load_reg_file(128'h00000005000000070000000A0000001F, 128'h00000005000000070000000A0000001F);
        reset = 1;
        @(posedge clk);
        reset = 0;
        unit_id = 1;
        opcode_even = ADD_WORD_IMMEDIATE;
        addr_ra_rd_even = 0;
        addr_rt_wt_even = 7'd1;
        imm10 = 10'd5;
        @(posedge clk);
        opcode_even = ADD_WORD_IMMEDIATE;
        addr_ra_rd_even = 1;
        addr_rt_wt_even = 7'd2;
        imm10 = 10'd3;
        @(posedge clk);
        opcode_even = NOP;
        unit_id = 0;
        addr_rt_wt_even = 0;
        repeat(9) begin
            @(posedge clk);
        end
        opcode_even = ADD_WORD;
        addr_ra_rd_even = 1;
        addr_rb_rd_even = 2;
        addr_rt_wt_even = 7'd3;
        imm10 = 10'd3;
        repeat(9) begin
            @(posedge clk);
        end
        opcode_even = NOP;
        unit_id = 0;
        addr_rt_wt_even = 0;

        opcode_odd = STORE_QUADWORD_D;
        imm10 = 10;
        addr_ra_rd_odd = 2;
        addr_rc_rd_odd = 3;
        @(posedge clk);
        opcode_odd = STORE_QUADWORD_X;
        addr_ra_rd_odd = 2;
        addr_rb_rd_odd = 3;
        addr_rc_rd_odd = 1; 
        @(posedge clk);
        opcode_odd = STORE_QUADWORD_A;
        imm16 = 10;
        addr_rc_rd_odd = 2;
        @(posedge clk);
        // repeat(5) begin
        //     @(posedge clk);
        // end
        opcode_odd = LOAD_QUADWORD_D;
        imm10 = 10;
        addr_ra_rd_odd = 2;
        addr_rt_wt_odd = 5;
        @(posedge clk);
        opcode_odd = LNOP;
        repeat(20) begin
            @(posedge clk);
        end

        $finish;
    end

    

    



endmodule