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
    rc_rd_odd,
    rt_wt_odd,
    addr_ra_rd_even,
    addr_rb_rd_even, 
    addr_rc_rd_even,
    addr_rt_wt_even, 
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rc_rd_odd,
    addr_rt_wt_odd,
    regWr_en_even, 
    regWr_en_odd,
    init,
    init2
);             

    input                               clk, reset;
    input [0 : QUADWORD - 1]            rt_wt_even, rt_wt_odd;
    input [0 : REG_ADDR_WIDTH - 1]      addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    input [0 : REG_ADDR_WIDTH - 1]      addr_rt_wt_even, addr_rt_wt_odd;
    input                               regWr_en_even, regWr_en_odd;

    input init, init2; //TODO: testing purposes. remove later

    output logic [0:QUADWORD-1]         ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd;
    
    logic [0:QUADWORD-1]                registerFile [0:REG_COUNT-1];
    
    always_ff @( posedge clk ) begin : registerFileWriteLogic
        if(reset) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                registerFile[i] <= 0;
            end
        end

        ra_rd_even <= registerFile[addr_ra_rd_even];
        rb_rd_even <= registerFile[addr_rb_rd_even];
        rc_rd_even <= registerFile[addr_rc_rd_even];
        ra_rd_odd <= registerFile[addr_ra_rd_odd];
        rb_rd_odd <= registerFile[addr_rb_rd_odd];
        rc_rd_odd <= registerFile[addr_rc_rd_odd];
        
        if(regWr_en_even)
            registerFile[addr_rt_wt_even] <= rt_wt_even;
        
        if(regWr_en_odd)
            registerFile[addr_rt_wt_odd] <= rt_wt_odd;
    end

endmodule