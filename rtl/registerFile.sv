/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: March 03, 2023
*/


module registerFile (
    clk,
    reset,
    ra_rd_even,
    rb_rd_even,
    rc_rd_even,
    rt_wt_even,
    ra_rd_odd,
    rb_rd_odd,
    rt_wt_odd,
    addr_ra_rd_even,
    addr_rb_rd_even, 
    addr_rc_rd_even,
    addr_rt_wt_even, 
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rt_wt_odd,
    regWr_en_even, 
    regWr_en_odd
);             

    input                               clk, reset;
    input [0 : QUADWORD - 1]            rt_wt_even, rt_wt_odd;
    input [0 : REG_ADDR_WIDTH - 1]      addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd;
    input [0 : REG_ADDR_WIDTH - 1]      addr_rt_wt_even, addr_rt_wt_odd;
    input                               regWr_en_even, regWr_en_odd;

    output logic [0:QUADWORD-1]         ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd;
    
    logic [0:QUADWORD-1]                registerFile [0:REG_COUNT-1];

    assign ra_rd_even = registerFile[addr_ra_rd_even];
    assign rb_rd_even = registerFile[addr_rb_rd_even];
    assign rc_rd_even = registerFile[addr_rc_rd_even];
    assign ra_rd_odd = registerFile[addr_ra_rd_odd];
    assign rb_rd_odd = registerFile[addr_rb_rd_odd];

    always_ff @( posedge clk ) begin : registerFileWriteLogic
        if(regWr_en_even)
            registerFile[addr_rt_wt_even] <= rt_wt_even;
        
        if(regWr_en_odd)
            registerFile[addr_rt_wt_odd] <= rt_wt_odd;
    end

endmodule