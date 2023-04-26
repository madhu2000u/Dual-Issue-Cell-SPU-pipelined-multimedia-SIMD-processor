`ifndef constants
`define constants

parameter BYTE = 8;
parameter HALFWORD = 16;
parameter WORD = 32;
parameter QUADWORD = 128;
parameter IMM10 = 10;
parameter IMM7 = 7;
parameter IMM16 = 16;
parameter IMM18 = 18;


parameter UNIT_ID_SIZE = 3;
parameter INTERNAL_OPCODE_SIZE = 7;

parameter REG_COUNT=128;
parameter REG_ADDR_WIDTH=$clog2(REG_COUNT);

parameter Smax = $bitstoshortreal(32'h7FFFFFFF);
parameter Smin = $bitstoshortreal(32'h00800000);

parameter LSLR = 32'h00007FFF;

//Simple Fixed 1
parameter add_word = 11'b00011000000;
parameter add_word_immediate = 8'b00011100;
parameter subtract_from_word = 11'b00001000000;
parameter subtract_from_word_immediate = 8'b00001100;
parameter add_extended = 11'b01101000000;
parameter carry_generate = 11'b00011000010;
parameter subtract_from_extended = 11'b01101000001;
parameter borrow_generate = 11'b00001000010;
parameter add_halfword = 11'b00011001000;
parameter add_halfword_immediate = 8'b00011101;
parameter subtract_from_halfword = 11'b00001001000;
parameter subtract_from_halfword_immediate = 8'b00001101;
parameter count_leading_zeros = 11'b01010100101;
parameter form_select_mask_for_halfword = 11'b00110110101;
parameter form_select_mark_for_words = 11'b00110110100;
parameter And = 11'b00011000001;
parameter and_with_complement = 11'b01011000001;
parameter and_halfword_immediate = 8'b00010101;
parameter and_word_immediate = 8'b00010100;
parameter Or = 11'b00001000001;
parameter or_with_complement = 11'b01011001001;
parameter or_halfword_immediate = 8'b00000101;
parameter or_word_immediate = 8'b00000100;
parameter exclusive_or = 11'b01001000001;
parameter exclusive_or_halfword_immediate = 8'b01000101;
parameter exclusive_or_word_immediate = 8'b01000100;
parameter Nand = 11'b00011001001;
parameter Nor = 11'b00001001001;
parameter compare_equal_halfword = 11'b01111001000;
parameter compare_equal_halfword_immediate = 8'b01111101;
parameter compare_equal_word = 11'b01111000000;
parameter compare_equal_word_immediate = 8'b01111100;
parameter compare_greater_than_halfword = 11'b01001001000;
parameter compare_greater_than_halfword_immediate = 8'b01001101;
parameter compare_greater_than_word = 11'b01001000000;
parameter compare_greater_than_word_immediate = 8'b01001100;
parameter compare_logical_greater_than_halfword = 11'b01011001000;
parameter compare_logical_greater_than_halfword_immediate= 8'b01011101;
parameter compare_logical_greater_than_word = 11'b01011000000;
parameter compare_logical_greater_than_word_immediate = 8'b01011100;

//Simple Fixed 2
parameter shift_left_halfword = 11'b00001011111;
parameter shift_left_halfword_immediate = 11'b00001111111;
parameter shift_left_word = 11'b00001011011;
parameter shift_left_word_immediate = 11'b00001111011;
parameter rotate_halfword = 11'b00001011100;
parameter rotate_halfword_immediate = 11'b00001111100;
parameter rotate_word = 11'b00001011000;
parameter rotate_word_immediate = 11'b00001111000;

// // Branch
parameter branch_relative = 9'b001100100;
parameter branch_absolute = 9'b001100000;
parameter branch_relative_and_set_link = 9'b001100110;
parameter branch_absolute_and_set_link = 9'b001100010;
parameter branch_if_not_zero_word = 9'b001000010;
parameter branch_if_zero_word = 9'b001000000;
parameter branch_if_not_zero_halfword = 9'b001000110;
parameter branch_if_zero_halfword = 9'b001000100;


//Single Precision FP MAC
parameter floating_add = 11'b01011000100;
parameter floating_subtract = 11'b01011000101;
parameter floating_multiply_and_add = 4'b1110;
parameter floating_negative_multiply_and_substract = 4'b1101;
parameter floating_multiply_and_subtract = 4'b1111;
parameter flaoting_multiply = 11'b01011000110;


//Single precision integer MAC
parameter multiply = 11'b01111000100;
parameter multiply_unsigned = 11'b01111001100;
parameter multiply_immediate = 8'b01110100;
parameter multiply_unsigned_immediate = 8'b01110101;
parameter multiply_and_add = 4'b1100;

//Byte
parameter count_ones_in_bytes = 11'b01010110100;
parameter absolute_differences_of_bytes = 11'b00001010011;
parameter average_bytes = 11'b00011010011;
parameter sum_bytes_into_halfword = 11'b01001010011;

// //Permute 
parameter shift_left_quadword_by_bits = 11'b00111011011;
parameter shift_left_quadword_by_bits_immediate = 11'b00111111011;
parameter shift_left_quadword_by_bytes = 11'b00111011111;
parameter shift_left_quadword_by_bytes_immediate = 11'b00111111111;
parameter shift_left_quadword_by_bytes_from_bit_shift_count = 11'b00111001111;
parameter rotate_quadword_by_bytes = 11'b00111011100;
parameter rotate_quadword_by_bytes_immediate = 11'b00111111100;
parameter rotate_quadword_by_bytes_from_bit_shift_count = 11'b00111001100;
parameter rotate_quadword_by_bits = 11'b00111011000;
parameter rotate_quadword_by_bits_immediate = 11'b00111111000;
parameter gather_bits_from_bytes = 11'b00110110010;
parameter gather_bits_from_halfword = 11'b00110110001;
parameter gather_bits_from_words =11'b00110110000;
parameter shuffle_bytes = 4'b1011;


// //Load & Store
parameter load_quadword_d = 8'b00110100;
parameter load_quadword_x = 11'b00111000100;
parameter load_quadword_a = 9'b001100001;
parameter store_quadword_d = 8'b00100100;
parameter store_quadword_x = 11'b00101000100;
parameter store_quadword_a = 9'b001000001;
parameter immediate_load_halfword = 9'b010000011;
parameter immediate_load_word = 9'b010000001;
parameter immediate_load_address = 7'b0100001;


// //Misc Instrs
parameter nop = 11'b01000000001;
parameter lnop = 11'b00000000001;

typedef enum logic [0 : 6] {

//Simple Fixed 1
    ADD_WORD = 7'd1,
    ADD_WORD_IMMEDIATE = 7'd2,
    SUBTRACT_FROM_WORD = 7'd3,
    SUBTRACT_FROM_WORD_IMMEDIATE= 7'd4,
    ADD_EXTENDED = 7'd5,
    CARRY_GENERATE = 7'd6,
    SUBTRACT_FROM_EXTENDED = 7'd7,
    BORROW_GENERATE = 7'd8,
    ADD_HALFWORD= 7'd9,
    ADD_HALFWORD_IMMEDIATE= 7'd10,
    SUBTRACT_FROM_HALFWORD = 7'd11,
    SUBTRACT_FROM_HALFWORD_IMMEDIATE = 7'd12,
    COUNT_LEADING_ZEROS = 7'd13,
    FORM_SELECT_MASK_FOR_HALFWORD = 7'd14,
    FORM_SELECT_MARK_FOR_WORDS = 7'd15,
    AND = 7'd16,
    AND_WITH_COMPLEMENT = 7'd17,
    AND_HALFWORD_IMMEDIATE = 7'd18,
    AND_WORD_IMMEDIATE = 7'd19,
    OR = 7'd20,
    OR_WITH_COMPLEMENT = 7'd21,
    OR_HALFWORD_IMMEDIATE= 7'd22,
    OR_WORD_IMMEDIATE= 7'd23,
    EXCLUSIVE_OR = 7'd24,
    EXCLUSIVE_OR_HALFWORD_IMMEDIATE = 7'd25,
    EXCLUSIVE_OR_WORD_IMMEDIATE = 7'd26,
    NAND = 7'd27,
    NOR = 7'd28,
    COMPARE_EQUAL_HALFWORD = 7'd29,
    COMPARE_EQUAL_HALFWORD_IMMEDIATE = 7'd30,
    COMPARE_EQUAL_WORD = 7'd31,
    COMPARE_EQUAL_WORD_IMMEDIATE = 7'd32,
    COMPARE_GREATER_THAN_HALFWORD = 7'd33,
    COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd34,
    COMPARE_GREATER_THAN_WORD = 7'd35,
    COMPARE_GREATER_THAN_WORD_IMMEDIATE = 7'd36,
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD = 7'd37,
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd38,
    COMPARE_LOGICAL_GREATER_THAN_WORD = 7'd39,
    COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE = 7'd40,

 //Simple Fixed 2
    SHIFT_LEFT_HALFWORD =  7'd41,
    SHIFT_LEFT_HALFWORD_IMMEDIATE = 7'd42,
    SHIFT_LEFT_WORD = 7'd43,
    SHIFT_LEFT_WORD_IMMEDIATE = 7'd44,
    ROTATE_HALFWORD = 7'd45,
    ROTATE_HALFWORD_IMMEDIATE = 7'd46,
    ROTATE_WORD = 7'd47,
    ROTATE_WORD_IMMEDIATE = 7'd48,

 // Branch
    BRANCH_RELATIVE = 7'd49,
    BRANCH_ABSOLUTE = 7'd50,
    BRANCH_RELATIVE_AND_SET_LINK = 7'd51,
    BRANCH_ABSOLUTE_AND_SET_LINK = 7'd52,
    BRANCH_IF_NOT_ZERO_WORD = 7'd53,
    BRANCH_IF_ZERO_WORD = 7'd54,
    BRANCH_IF_NOT_ZERO_HALFWORD = 7'd55,
    BRANCH_IF_ZERO_HALFWORD = 7'd56,

//Single Precision FP MAC
    FLOATING_ADD = 7'd90,
    FLOATING_SUBTRACT = 7'd91,
    FLOATING_MULTIPLY_AND_ADD = 7'd57,
    FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT = 7'd58,
    FLOATING_MULTIPLY_AND_SUBTRACT = 7'd59,
    FLAOTING_MULTIPLY = 7'd60,

//Single precision integer MAC   
    MULTIPLY = 7'd61,
    MULTIPLY_UNSIGNED = 7'd62,
    MULTIPLY_IMMEDIATE = 7'd63,
    MULTIPLY_UNSIGNED_IMMEDIATE = 7'd64,
    MULTIPLY_AND_ADD = 7'd65,

//Byte
    COUNT_ONES_IN_BYTES = 7'd66,
    ABSOLUTE_DIFFERENCES_OF_BYTES = 7'd67,
    AVERAGE_BYTES = 7'd68,
    SUM_BYTES_INTO_HALFWORD = 7'd69,

//Permute   
    SHIFT_LEFT_QUADWORD_BY_BITS = 7'd70,
    SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE = 7'd71,
    SHIFT_LEFT_QUADWORD_BY_BYTES = 7'd72,
    SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE = 7'd73,
    SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd74,
    ROTATE_QUADWORD_BY_BYTES = 7'd75,
    ROTATE_QUADWORD_BY_BYTES_IMMEDIATE = 7'd76,
    ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd77,
    ROTATE_QUADWORD_BY_BITS = 7'd78,
    ROTATE_QUADWORD_BY_BITS_IMMEDIATE = 7'd79,
    GATHER_BITS_FROM_BYTES = 7'd80,
    GATHER_BITS_FROM_HALFWORD = 7'd81, 
    GATHER_BITS_FROM_WORDS = 7'd82,
    SHUFFLE_BYTES = 7'd83,

//Load & Store
    LOAD_QUADWORD_D = 7'd84,
    LOAD_QUADWORD_X = 7'd85,
    LOAD_QUADWORD_A = 7'd86,
    STORE_QUADWORD_D = 7'd87,
    STORE_QUADWORD_X = 7'd88,
    STORE_QUADWORD_A = 7'd89,
    IMMEDIATE_LOAD_HALFWORD = 7'd94,
    IMMEDIATE_LOAD_WORD = 7'd95,
    IMMEDIATE_LOAD_ADDRESS = 7'd96,


//Misc Instrs
    NOP = 7'd92,
    LNOP = 7'd93


} internal_opcodes;

`endif 