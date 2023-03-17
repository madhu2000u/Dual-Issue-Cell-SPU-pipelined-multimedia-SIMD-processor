module forwardMacro (
    clk,
    reset,
    ra_rd_even, 
    rb_rd_even, 
    rc_rd_even, 
    ra_rd_odd, 
    rb_rd_odd,
    rc_rd_odd,
    fw_ra_rd_even_out,
    fw_rb_rd_even_out,
    fw_rc_rd_even_out, 
    fw_ra_rd_odd_out, 
    fw_rb_rd_odd_out, 
    fw_rc_rd_odd_out,
    fx1_stage2_result,
    byte_stage3_result,
    fx2_stage3_result,
    sp_fp_stage6_result,
    sp_int_stage7_result,
    perm_stage3_result,
    ls_stage6_result,
    FWE8,
    FWO8
);

    input clk, reset;
    input logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]    fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result;
    //input logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD + WORD + 1)-1] ls_stage6_result;

    output logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]   FWE8, FWO8;

    output logic [0 : QUADWORD - 1] fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out;
    
    input [0 : QUADWORD - 1]                                                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]          FWE3, FWE4, FWE5, FWE6, FWE7;       //FWE3 -> Foward Even stage 3
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]          FWO4, FWO5, FWO6, FWO7;             //FWO4 -> Forward Odd stage 4
    
    
    always_comb begin : forwardMacroLogic
        fw_ra_rd_even_out = ra_rd_even;
        fw_rb_rd_even_out = rb_rd_even;
        fw_rc_rd_even_out = rc_rd_even;

        fw_ra_rd_odd_out = ra_rd_odd;
        fw_rb_rd_odd_out = rb_rd_odd;
        fw_rc_rd_odd_out = rc_rd_odd;
    end

    always_ff @( posedge clk ) begin : forwardMacroLogicStages
        if(reset) begin
            FWE3 <= 0;
            FWE4 <= 0;
            FWE5 <= 0;
            FWE6 <= 0;
            FWE7 <= 0;
            FWE8 <= 0;

            FWO4 <= 0;
            FWO5 <= 0;
            FWO6 <= 0;
            FWO7 <= 0;
            FWO8 <= 0;
        end

        /*Even Pipe*/
        FWE3 <= fx1_stage2_result;

        // if(FWE3 > 0)
        //     FWE4 <= FWE3;
        if(byte_stage3_result > 0)
            FWE4 <= byte_stage3_result;
        else if(fx2_stage3_result > 0)
            FWE4 <= fx2_stage3_result;
        else
            FWE4 <= FWE3;

        FWE5 <= FWE4;
        FWE6 <= FWE5;

        if(FWE6 > 0)
            FWE7 <= FWE6;
        else if(sp_fp_stage6_result > 0)
            FWE7 <= sp_fp_stage6_result;

        if(FWE7 > 0)
            FWE8 <= FWE7;
        else if(sp_int_stage7_result > 0)
            FWE8 <= sp_int_stage7_result;

        /*Odd Pipe*/
        FWO4 <= perm_stage3_result;
        FWO5 <= FWO4;
        FWO6 <= FWO5;

        if(ls_stage6_result > 0)
            FWO7 <= ls_stage6_result;
        else
            FWO7 <= FWO6;
        
        FWO8 <= FWO7;
    end

    
endmodule