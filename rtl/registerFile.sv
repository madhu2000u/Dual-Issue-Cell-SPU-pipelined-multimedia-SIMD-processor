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
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    wr_en_even, 
    wr_en_odd
);
    parameter                   REG_WIDTH=128, REG_COUNT=128;
    localparam                  ADDR_WIDTH=$clog2(REG_COUNT);

    input clk, reset;
    input [REG_WIDTH-1:0]           rt_wt_even, rt_wt_odd;
    output logic [REG_WIDTH-1:0]    ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd;
    input [ADDR_WIDTH-1:0]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd;
    input [ADDR_WIDTH-1:0]          addr_rt_wt_even, addr_rt_wt_odd;
    input                           wr_en_even, wr_en_odd;
    
    logic [REG_WIDTH-1:0] registerFile [REG_COUNT-1:0];

    assign ra_rd_even = registerFile[addr_ra_rd_even];
    assign rb_rd_even = registerFile[addr_rb_rd_even];
    assign rc_rd_even = registerFile[addr_rc_rd_even];
    assign ra_rd_odd = registerFile[addr_ra_rd_odd];
    assign rb_rd_odd = registerFile[addr_rb_rd_odd];

    always_ff @( posedge clk ) begin : registerFileWriteLogic
        if(wr_en_even)
            registerFile[addr_rt_wt_even] <= rt_wt_even;
        
        if(wr_en_odd)
            registerFile[addr_rt_wt_odd] <= rt_wt_odd;
    end

endmodule