/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: March 03, 2023
*/

module LocalStore (
    clk,
    reset,
    ls_addr,
    ls_data_wr,
    ls_data_rd,
    ls_wr_en
);    
    input clk, reset;
    input logic [0:31] ls_addr;
    input logic [0:127] ls_data_wr;
    input logic ls_wr_en;
    output logic [0:127] ls_data_rd;
    
    logic [0:7] [32767:0] lsa_mem;  //32 KB local store


    always_ff @ (posedge clk) begin
        if (reset) begin
            ls_data_rd <= 0;
        end
        
        else if(ls_wr_en) begin
            for (int i = 0; i < 16; i++) begin
                lsa_mem[ls_addr + i] = ls_data_wr[8*i +: 8];
            end
        end
          
    end

    always_comb begin
        for(int k =0; k<16; k++) begin
            if(ls_wr_en)
                ls_data_rd[8*i +:8] = ls_data_wr[8*i +: 8];
            else  
                ls_data_rd[8*i +:8] = lsa_mem[ls_addr + i];   

    end
    end

endmodule