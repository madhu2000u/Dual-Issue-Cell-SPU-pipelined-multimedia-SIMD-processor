module forwardMacro (
    clk,
    reset,
    stop2, stop3, stop4, stop5, stop6, stop7, stop8, stop9,
    rf_addr_ra_rd_even, 
    rf_addr_rb_rd_even, 
    rf_addr_rc_rd_even, 
    rf_addr_ra_rd_odd, 
    rf_addr_rb_rd_odd, 
    rf_addr_rc_rd_odd,
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
    branch_stage1_result,
    FWE8,
    FWO8
);

    parameter REG_ADDR = UNIT_ID_SIZE + 1;  //Location of the register address in the 139-bit stage packet.
    parameter RESULT = UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH; //Location of the 128-bit result in the 139-bit stage packet.

    input clk, reset,  stop2, stop3, stop4, stop5, stop6, stop7, stop8, stop9;
    input logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]    fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, branch_stage3_result;
    logic [0 : QUADWORD - 1] fw_ra_rd_even, fw_rb_rd_even, fw_rc_rd_even, fw_ra_rd_odd, fw_rb_rd_odd, fw_rc_rd_odd;
    //input logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD + WORD + 1)-1] ls_stage6_result;

    output logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]   FWE8, FWO8;

    output logic [0 : QUADWORD - 1] fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out;
    
    input [0 : QUADWORD - 1]                                                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd;
    //input [0 : QUADWORD - 1]                                                rf_ra_rd_even, rf_rb_rd_even, rf_rc_rd_even, rf_ra_rd_odd, rf_rb_rd_odd, rf_rc_rd_odd;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]          FWE3, FWE4, FWE5, FWE6, FWE7;       //FWE3 -> Foward Even stage 3
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]          FWO2, FWO3, FWO4, FWO5, FWO6, FWO7;             //FWO4 -> Forward Odd stage 4
    input [0 : REG_ADDR_WIDTH - 1]                                          rf_addr_ra_rd_even, rf_addr_rb_rd_even, rf_addr_rc_rd_even, rf_addr_ra_rd_odd, rf_addr_rb_rd_odd, rf_addr_rc_rd_odd;                 //Register fetch stage
    
    
    always_comb begin : forwardMacroLogic

        /*Even Pipe Forwarding with Cross-Forwarding from Odd Pipe*/
        if(rf_addr_ra_rd_even == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])    // regWrite_en_even should also be checked.
            fw_ra_rd_even = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_ra_rd_even = FWE8[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_even == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_ra_rd_even = FWO8[RESULT +: QUADWORD];
        else
            fw_ra_rd_even = ra_rd_even;

        if(rf_addr_rb_rd_even == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_rb_rd_even = FWE8[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_even == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_rb_rd_even = FWO8[RESULT +: QUADWORD];
        else
            fw_rb_rd_even = rb_rd_even;

        if(rf_addr_rc_rd_even == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_rc_rd_even = FWE8[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_even == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_rc_rd_even = FWO8[RESULT +: QUADWORD];
        else
            fw_rc_rd_even = rc_rd_even;






        /*Odd Pipe Forwarding with Cross-Forwarding from Even Pipe*/
        if(rf_addr_ra_rd_odd == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWO8[RESULT +: QUADWORD];
        else if(rf_addr_ra_rd_odd == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE8[RESULT +: QUADWORD];
        else
            fw_ra_rd_odd = ra_rd_odd;

        if(rf_addr_rb_rd_odd == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWO8[RESULT +: QUADWORD];
        else if(rf_addr_rb_rd_odd == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_rb_rd_odd = FWE8[RESULT +: QUADWORD];
        else
            fw_rb_rd_odd = rb_rd_odd;

        if(rf_addr_rc_rd_odd == FWO2[REG_ADDR +: REG_ADDR_WIDTH] & FWO2[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO2[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO3[REG_ADDR +: REG_ADDR_WIDTH] & FWO3[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO3[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE3[REG_ADDR +: REG_ADDR_WIDTH] & FWE3[UNIT_ID_SIZE])
            fw_ra_rd_odd = FWE3[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO4[REG_ADDR +: REG_ADDR_WIDTH] & FWO4[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO4[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE4[REG_ADDR +: REG_ADDR_WIDTH] & FWE4[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWE4[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO5[REG_ADDR +: REG_ADDR_WIDTH] & FWO5[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO5[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE5[REG_ADDR +: REG_ADDR_WIDTH] & FWE5[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWE5[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO6[REG_ADDR +: REG_ADDR_WIDTH] & FWO6[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO6[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE6[REG_ADDR +: REG_ADDR_WIDTH] & FWE6[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWE6[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO7[REG_ADDR +: REG_ADDR_WIDTH] & FWO7[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO7[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE7[REG_ADDR +: REG_ADDR_WIDTH] & FWE7[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWE7[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWO8[REG_ADDR +: REG_ADDR_WIDTH] & FWO8[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWO8[RESULT +: QUADWORD];
        else if(rf_addr_rc_rd_odd == FWE8[REG_ADDR +: REG_ADDR_WIDTH] & FWE8[UNIT_ID_SIZE])
            fw_rc_rd_odd = FWE8[RESULT +: QUADWORD];
        else
            fw_rc_rd_odd = rc_rd_odd;
        
    end

    always_ff @( posedge clk ) begin : forwardMacroLogicStages
        if(reset) begin
            FWE3 <= 0;
            FWE4 <= 0;
            FWE5 <= 0;
            FWE6 <= 0;
            FWE7 <= 0;
            FWE8 <= 0;

            FWO2 <= 0;
            FWO3 <= 0;
            FWO4 <= 0;
            FWO5 <= 0;
            FWO6 <= 0;
            FWO7 <= 0;
            FWO8 <= 0;
        end

        /*Even Pipe*/
        if(!stop4) FWE3 <= fx1_stage2_result;

        if(!stop5) begin
            if(byte_stage3_result > 0)
                FWE4 <= byte_stage3_result;
            else if(fx2_stage3_result > 0)
                FWE4 <= fx2_stage3_result;
            else
                FWE4 <= FWE3;
        end

        if(!stop6) FWE5 <= FWE4;
        if(!stop7) FWE6 <= FWE5;

        if(!stop8) begin
            if(sp_fp_stage6_result > 0)
                FWE7 <= sp_fp_stage6_result;
            else
                FWE7 <= FWE6;

            if(sp_int_stage7_result > 0)
                FWE8 <= sp_int_stage7_result;
            else
                FWE8 <= FWE7;
        end



        /*Odd Pipe*/
        if(!stop3) FWO2 <= branch_stage1_result;

        if(!stop4) FWO3 <= FWO2;

        if(!stop5) begin
            if(FWO3 > 0)
                FWO4 <= FWO3;
            else
                FWO4 <= perm_stage3_result;
        end
        
        if(!stop6) FWO5 <= FWO4;
        if(!stop7) FWO6 <= FWO5;

        if(!stop8) begin
            if(ls_stage6_result > 0)
                FWO7 <= ls_stage6_result;
            else
                FWO7 <= FWO6;
        end
        
        if(!stop9) FWO8 <= FWO7;


        if(!stop2) begin
            fw_ra_rd_even_out <= fw_ra_rd_even;
            fw_rb_rd_even_out <= fw_rb_rd_even;
            fw_rc_rd_even_out <= fw_rc_rd_even;

            fw_ra_rd_odd_out <= fw_ra_rd_odd;
            fw_rb_rd_odd_out <= fw_rb_rd_odd;
            fw_rc_rd_odd_out <= fw_rc_rd_odd;
        end
    end

    
endmodule