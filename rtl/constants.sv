`ifndef constants
`define constants

parameter BYTE = 8;
parameter HALFWORD = 16;
parameter WORD = 32;
parameter QUADWORD = 128;
parameter IMM10 = 10;
parameter IMM7 = 7;
parameter IMM16 = 16;

parameter UNIT_ID_SIZE = 3;
parameter INTERNAL_OPCODE_SIZE = 7;

parameter REG_COUNT=128;
parameter REG_ADDR_WIDTH=$clog2(REG_COUNT);

parameter Smax = $bitstoshortreal(32'h7FFFFFFF);
parameter Smin = $bitstoshortreal(32'h00800000);

`typedef enum logic [0 : 6] {

//Simple Fixed 1
    ADD_WORD = 7'd1;
    ADD_WORD_IMMEDIATE = 7'd2
    SUBTRACT_FROM_WORD = 7'd3
    SUBTRACT_FROM_WORD_IMMEDIATE= 7'd4
    ADD_EXTENDED = 7'd5
    CARRY_GENERATE = 7'd6
    SUBTRACT_FROM_EXTENDED = 7'd7
    BORROW_GENERATE = 7'd8
    ADD_HALFWORD= 7'd9
    ADD_HALFWORD_IMMEDIATE= 7'd10
    SUBTRACT_FROM_HALFWORD = 7'd11
    SUBTRACT_FROM_HALFWORD_IMMEDIATE = 7'd12
    COUNT_LEADING_ZEROS = 7'd13
    FORM_SELECT_MASK_FOR_HALFWORD = 7'd14
    FORM_SELECT_MARK_FOR_WORDS = 7'd15
    AND = 7'd16
    AND_WITH_COMPLEMENT = 7'd17
    AND_HALFWORD_IMMEDIATE = 7'd18
    AND_WORD_IMMEDIATE = 7'd19
    OR = 7'd20
    OR_WITH_COMPLEMENT = 7'd21
    OR_HALFWORD_IMMEDIATE= 7'd22
    OR_WORD_IMMEDIATE= 7'd23
    EXCLUSIVE_OR = 7'd24
    EXCLUSIVE_OR_HALFWORD_IMMEDIATE = 7'd25
    EXCLUSIVE_OR_WORD_IMMEDIATE = 7'd26
    NAND = 7'd27
    NOR = 7'd28
    COMPARE_EQUAL_HALFWORD = 7'd29
    COMPARE_EQUAL_HALFWORD_IMMEDIATE = 7'd30
    COMPARE_EQUAL_WORD = 7'd31
    COMPARE_EQUAL_WORD_IMMEDIATE = 7'd32
    COMPARE_GREATER_THAN_HALFWORD = 7'd33
    COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd34
    COMPARE_GREATER_THAN_WORD = 7'd35
    COMPARE_GREATER_THAN_WORD_IMMEDIATE = 7'd36
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD = 7'd37
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd38
    COMPARE_LOGICAL_GREATER_THAN_WORD = 7'd39
    COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE = 7'd40

 //Simple Fixed 2
    SHIFT_LEFT_HALFWORD =  7'd41;
    SHIFT_LEFT_HALFWORD_IMMEDIATE = 7'd42;
    SHIFT_LEFT_WORD = 7'd43;
    SHIFT_LEFT_WORD_IMMEDIATE = 7'd44;
    ROTATE_HALFWORD = 7'd45;
    ROTATE_HALFWORD_IMMEDIATE = 7'd46;
    ROTATE_WORD = 7'd47;
    ROTATE_WORD_IMMEDIATE = 7'd48;

 // Branch
    BRANCH_RELATIVE = 7'd49;
    BRANCH_ABSOLUTE = 7'd50;
    BRANCH_RELATIVE_AND_SET_LINK = 7'd51;
    BRANCH_ABSOLUTE_AND_SET_LINK = 7'd52;
    BRANCH_IF_NOT_ZERO_WORD = 7'd53;
    BRANCH_IF_ZERO_WORD = 7'd54;
    BRANCH_IF_NOT_ZERO_HALFWORD = 7'd55;
    BRANCH_IF_ZERO_HALFWORD = 7'd56;

//Single Precision FP MAC
    FLOATING_ADD = 7'd90;
    FLOATING_SUBTRACT = 7'd91;
    FLOATING_MULTIPLY_AND_ADD = 7'd57;
    FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT = 7'd58;
    FLOATING_MULTIPLY_AND_SUBTRACT = 7'd59;
    FLAOTING_MULTIPLY = 7'd60;

//Single precision integer MAC   
    MULTIPLY = 7'd61;
    MULTIPLY_UNSIGNED = 7'd62;
    MULTIPLY_IMMEDIATE = 7'd63;
    MULTIPLY_UNSIGNED_IMMEDIATE = 7'd64;
    MULTIPLY_AND_ADD = 7'd65;

//Byte
    COUNT_ONES_IN_BYTES = 7'd66;
    ABSOLUTE_DIFFERENCES_OF_BYTES = 7'd67;
    AVERAGE_BYTES = 7'd68;
    SUM_BYTES_INTO_HALFWORD = 7'd69;

//Permute   
    SHIFT_LEFT_QUADWORD_BY_BITS = 7'd70;
    SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE = 7'd71;
    SHIFT_LEFT_QUADWORD_BY_BYTES = 7'd72;
    SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE = 7'd73
    SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd74;
    ROTATE_QUADWORD_BY_BYTES = 7'd75;
    ROTATE_QUADWORD_BY_BYTES_IMMEDIATE = 7'd76;
    ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd77;
    ROTATE_QUADWORD_BY_BITS = 7'd78;
    ROTATE_QUADWORD_BY_BITS_IMMEDIATE = 7'd79;
    GATHER_BITS_FROM_BYTES = 7'd80;
    GATHER_BITS_FROM_HALFWORD = 7'd81;
    GATHER_BITS_FROM_WORDS = 7'd82;
    SHUFFLE_BYTES = 7'd83;

//Load & Store
    LOAD_QUADWORD_D = 7'd84;
    LOAD_QUADWORD_X = 7'd85;
    LOAD_QUADWORD_A = 7'd86;
    STORE_QUADWORD_D = 7'd87;
    STORE_QUADWORD_X = 7'd88;
    STORE_QUADWORD_A = 7'd89;


} internal_opcodes;

`endif 