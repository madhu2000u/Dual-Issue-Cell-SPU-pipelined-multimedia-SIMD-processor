`include "constants.sv"
`include "./evenPipe/evenPipe.sv"
`include "registerFile.sv"
`include "forwardMacro.sv"

module spuMainModule (
    clk,
    reset,
    unit_id,
    opcode,
    /*regWr_en_even,*/
    addr_ra_rd_even,
    addr_rb_rd_even,
    addr_rc_rd_even,
    addr_rt_wt_even,
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rt_wt_odd,
    imm7,
    imm10
);
    
    input                                   clk, reset;
    input [0 : UNIT_ID_SIZE - 1]            unit_id;
    input [0 : INTERNAL_OPCODE_SIZE - 1]    opcode;
    input [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd;
    input [0 : IMM7]                        imm7;
    input [0 : IMM10]                       imm10;
    input [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;

    logic [0 : QUADWORD - 1]                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;
    logic                                   regWr_en_even, regWr_en_odd;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, FWE8;


    assign regWr_en_even = FWE8[UNIT_ID_SIZE + 1];
    assign addr_rt_wt_even = FWE8[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH];
    assign rt_wt_even = FWE8 [UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD];

    registerFile registerFile (clk, reset, ra_rd_even, rb_rd_even, rc_rd_even, rt_wt_even, ra_rd_odd, rb_rd_odd, rt_wt_odd, addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_rt_wt_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rt_wt_odd, regWr_en_even, regWr_en_odd);

    forwardMacro forwardMacro (clk, reset, ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, FWE8, FWO8);

    evenPipe evenPipe (clk, reset, unit_id, opcode, ra_rd_even, rb_rd_even, rc_rd_even, addr_rt_wt_even, imm7, imm10, x1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result);


endmodule