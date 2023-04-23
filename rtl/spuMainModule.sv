`include "constants.sv"
`include "evenPipe.sv"
`include "oddPipe.sv"
`include "registerFile.sv"
`include "forwardMacro.sv"
`include "instrFetch.sv"
`include "decode.sv"

module spuMainModule (
    clk,
    reset,
    rf_unit_id,
    rf_opcode_even,
    rf_opcode_odd,
    /*regWr_en_even,*/
    addr_ra_rd_even,
    addr_rb_rd_even,
    addr_rc_rd_even,
    rf_addr_rt_wt_even,
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rc_rd_odd,
    rf_addr_rt_wt_odd,
    rf_imm7_even,
    rf_imm7_odd,
    rf_imm10_even,
    rf_imm10_odd,
    rf_imm16_odd,
    rf_imm18_odd,
    PC_out,
    branch_taken,
    br_first_instr,
    init,
    init2
);
    
    input                                   clk, reset, br_first_instr;
    input [0 : UNIT_ID_SIZE - 1]            rf_unit_id;
    input [0 : INTERNAL_OPCODE_SIZE - 1]    rf_opcode_even, rf_opcode_odd;
    input [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    input [0 : IMM7 - 1]                    rf_imm7_even, rf_imm7_odd;
    input [0 : IMM10 - 1]                   rf_imm10_even, rf_imm10_odd;
    input [0 : IMM16 - 1]                   rf_imm16_odd;              //no 16-bit immediate for even pipe instructions
    input [0 : IMM18 - 1]                   rf_imm18_odd;           
    input [0 : REG_ADDR_WIDTH - 1]          rf_addr_rt_wt_even, rf_addr_rt_wt_odd;
    

    output branch_taken;
    output [0 : WORD - 1]                   PC_out;

    input init, init2; //TODO: testing purposes

    //TODO: add fw_rc register
    logic                                   dep_stall_instr2;
    logic                                   regWr_en_even, regWr_en_odd, flush;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;
    logic [0 : UNIT_ID_SIZE - 1]            unit_id;
    logic [0 : INTERNAL_OPCODE_SIZE - 1]    opcode_even, opcode_odd;
    logic [0 : IMM7 - 1]                    imm7_even, imm7_odd;
    logic [0 : IMM10 - 1]                   imm10_even, imm10_odd;
    logic [0 : IMM16 - 1]                   imm16_odd;
    logic [0 : IMM18 - 1]                   imm18_odd;
    logic [0 : QUADWORD - 1]                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, branch_stage3_result,  FWE8, FWO8;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] fx1_stage1_result,                      //sp -> Single Precision, fp -> Floating Point
                                                                   byte_stage1_result, byte_stage2_result,
                                                                   fx2_stage1_result, fx2_stage2_result,
                                                                   sp_fp_stage1_result, sp_fp_stage2_result, sp_fp_stage3_result, sp_fp_stage4_result, sp_fp_stage5_result,
                                                                   sp_int_stage1_result, sp_int_stage2_result, sp_int_stage3_result, sp_int_stage4_result, sp_int_stage5_result, sp_int_stage6_result;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] perm_stage1_result, perm_stage2_result,
                                                                   ls_stage1_result, ls_stage2_result, ls_stage3_result, ls_stage4_result, ls_stage5_result,
                                                                   branch_stage1_result, branch_stage2_result;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even_internal, addr_rt_wt_odd_internal;
    logic [0 : WORD - 1]                    instr1, instr2;
    logic [0 : WORD - 1]                    PC;

    assign regWr_en_even = FWE8[UNIT_ID_SIZE];
    assign regWr_en_odd = FWO8[UNIT_ID_SIZE];

    assign addr_rt_wt_even_internal = FWE8[(UNIT_ID_SIZE + 1) +: REG_ADDR_WIDTH];
    assign addr_rt_wt_odd_internal = FWO8[(UNIT_ID_SIZE + 1) +: REG_ADDR_WIDTH];

    assign rt_wt_even = FWE8 [UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD];
    assign rt_wt_odd = FWO8 [UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD];

    always_ff @( posedge clk ) begin : RegisterFetchStage
        unit_id <= rf_unit_id;
        opcode_even <= rf_opcode_even;
        opcode_odd <= rf_opcode_odd;
        addr_rt_wt_even <= rf_addr_rt_wt_even;
        addr_rt_wt_odd <= rf_addr_rt_wt_odd;
        imm7_even <= rf_imm7_even;
        imm7_odd <= rf_imm7_odd;
        imm10_even <= rf_imm10_even;
        imm10_odd <= rf_imm10_odd;
        imm16_odd <= rf_imm16_odd;
        imm18_odd <= rf_imm18_odd;
    end

    instrFetch instrFetch (clk, reset, PC, instr1, instr2, dep_stall_instr2);
    
    decode decode (clk, reset, instr1, instr2, dep_stall_instr2,
        fx1_stage1_result,
        fx1_stage2_result,
        byte_stage1_result,
        byte_stage2_result,
        byte_stage3_result,
        fx2_stage1_result,
        fx2_stage2_result,
        fx2_stage3_result,
        sp_fp_stage1_result,
        sp_fp_stage2_result,
        sp_fp_stage3_result,
        sp_fp_stage4_result,
        sp_fp_stage5_result,
        sp_fp_stage6_result,
        sp_int_stage1_result,
        sp_int_stage2_result,
        sp_int_stage3_result,
        sp_int_stage4_result,
        sp_int_stage5_result,
        sp_int_stage6_result,
        sp_int_stage7_result,
        //odd pipe
        perm_stage1_result,
        perm_stage2_result,
        perm_stage3_result, 
        ls_stage1_result,
        ls_stage2_result,
        ls_stage3_result,
        ls_stage4_result,
        ls_stage5_result,
        ls_stage6_result,
        branch_stage1_result,
        branch_stage2_result,
        branch_stage3_result
    );

    registerFile registerFile (clk, reset, ra_rd_even, rb_rd_even, rc_rd_even, rt_wt_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, rt_wt_odd, addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_rt_wt_even_internal, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd, addr_rt_wt_odd_internal, regWr_en_even, regWr_en_odd, init, init2);

    forwardMacro forwardMacro (clk, reset, addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd, ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out,
        fx1_stage2_result,
        byte_stage3_result,
        fx2_stage3_result,
        sp_fp_stage6_result,
        sp_int_stage7_result,
        perm_stage3_result,
        ls_stage6_result,
        branch_stage3_result,
        FWE8,
        FWO8
    );

    evenPipe evenPipe (clk, reset, flush, unit_id, opcode_even, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, addr_rt_wt_even, imm7_even, imm10_even,
        fx1_stage1_result,
        fx1_stage2_result, 
        byte_stage1_result,
        byte_stage2_result,
        byte_stage3_result,
        fx2_stage1_result,
        fx2_stage2_result,
        fx2_stage3_result,
        sp_fp_stage1_result,
        sp_fp_stage2_result,
        sp_fp_stage3_result,
        sp_fp_stage4_result,
        sp_fp_stage5_result,
        sp_fp_stage6_result,
        sp_int_stage1_result,
        sp_int_stage2_result,
        sp_int_stage3_result,
        sp_int_stage4_result,
        sp_int_stage5_result,
        sp_int_stage6_result,
        sp_int_stage7_result
    );

    oddPipe oddPipe (clk, reset, flush, unit_id, PC, PC_out, br_first_instr, branch_taken, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out, addr_rt_wt_odd, opcode_odd, imm7_odd, imm10_odd, imm16_odd, imm18_odd, 
        perm_stage1_result,
        perm_stage2_result,
        perm_stage3_result, 
        ls_stage1_result,
        ls_stage2_result,
        ls_stage3_result,
        ls_stage4_result,
        ls_stage5_result,
        ls_stage6_result,
        branch_stage1_result,
        branch_stage2_result,
        branch_stage3_result
    );


endmodule