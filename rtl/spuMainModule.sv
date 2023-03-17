`include "constants.sv"
`include "./evenPipe/evenPipe.sv"
`include "oddPipe.sv"
`include "registerFile.sv"
`include "forwardMacro.sv"

module spuMainModule (
    clk,
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
    init2
);
    
    input                                   clk, reset;
    input [0 : UNIT_ID_SIZE - 1]            unit_id;
    input [0 : INTERNAL_OPCODE_SIZE - 1]    opcode_even, opcode_odd;
    input [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    input [0 : IMM7 - 1]                    imm7;
    input [0 : IMM10 - 1]                   imm10;
    input [0 : IMM16 - 1]                   imm16;
    input [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;

    input init, init2; //TODO: testing purposes

    //TODO: add fw_rc register
    logic [0 : QUADWORD - 1]                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;
    logic                                   regWr_en_even, regWr_en_odd;
    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, FWE8, FWO8;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even_internal, addr_rt_wt_odd_internal;

    assign regWr_en_even = FWE8[UNIT_ID_SIZE];
    assign regWr_en_odd = FWO8[UNIT_ID_SIZE];

    assign addr_rt_wt_even_internal = FWE8[(UNIT_ID_SIZE + 1) +: REG_ADDR_WIDTH];
    assign addr_rt_wt_odd_internal = FWO8[(UNIT_ID_SIZE + 1) +: REG_ADDR_WIDTH];

    assign rt_wt_even = FWE8 [UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD];
    assign rt_wt_odd = FWO8 [UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD];

    registerFile registerFile (clk, reset, ra_rd_even, rb_rd_even, rc_rd_even, rt_wt_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, rt_wt_odd, addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_rt_wt_even_internal, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd, addr_rt_wt_odd_internal, regWr_en_even, regWr_en_odd, init, init2);

    forwardMacro forwardMacro (clk, reset, ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out, fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result, perm_stage3_result, ls_stage6_result, FWE8, FWO8);

    evenPipe evenPipe (clk, reset, unit_id, opcode_even, fw_ra_rd_even_out, fw_rb_rd_even_out, fw_rc_rd_even_out, addr_rt_wt_even, imm7, imm10, fx1_stage2_result, byte_stage3_result, fx2_stage3_result, sp_fp_stage6_result, sp_int_stage7_result);

    oddPipe oddPipe (clk, reset, unit_id, fw_ra_rd_odd_out, fw_rb_rd_odd_out, fw_rc_rd_odd_out, addr_rt_wt_odd, opcode_odd, imm7, imm10, imm16, perm_stage3_result, ls_stage6_result);


endmodule