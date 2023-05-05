#include <map>

const int INSTR_LEN = 32;
const int REG_ADDR_LEN = 7;
const int IMM10_LEN = 10;
const int IMM16_LEN = 16;
const int IMM18_LEN = 18;

enum instrFormatOpcodeLenEnum {
    RR_RI7 = 11, RRR = 4, RI10 = 8, RI16 = 9, RI18 = 7  //opcode lengths or different instruction type
};

struct instrFormat
{
    std::string instr;
    instrFormatOpcodeLenEnum type;

    instrFormat(const std::string& instr_, instrFormatOpcodeLenEnum type_) : instr(instr_), type(type_) {}
};


// instrFormat f;
// f.instr = "00011000000";
// f.type = instrFormatOpcodeLenEnum::RR_RI7;
const std::map<std::string, std::string> opcode_map{
   {"a", "00011000000"},
   {"ai", "00011100"},
   {"sf", "00001000000"},
   {"sfi", "00001100"},
   {"addx", "01101000000"},
   {"cg", "00011000010"},
   {"sfx", "01101000001"},
   {"bg", "00001000010"},
   {"ah", "00011001000"},
   {"ahi", "00011101"},
   {"sfh", "00001001000"},
   {"sfhi", "00001101"},
   {"clz", "01010100101"},
   {"fsmh", "00110110101"},
   {"fsm", "00110110100"},
   {"and", "00011000001"},
   {"andc", "01011000001"},
   {"andhi", "00010101"},
   {"andi", "00010100"},
   {"or", "00001000001"},
   {"orc", "01011001001"},
   {"orhi", "00000101"},
   {"ori", "00000100"},
   {"xor", "01001000001"},
   {"xorhi", "01000101"},
   {"xori", "01000100"},
   {"nand", "00011001001"},
   {"nor", "00001001001"},
   {"ceqh", "01111001000"},
   {"ceqhi", "01111101"},
   {"ceq", "01111000000"},
   {"ceqi", "01111100"},
   {"cgth", "01001001000"},
   {"cgthi", "01001101"},
   {"cgt", "01001000000"},
   {"cgti", "01001100"},
   {"clgth", "01011001000"},
   {"clgthi", "01011101"},
   {"clgt", "01011000000"},
   {"clgti", "01011100"},


    //SIMPLE FIXED 2
   {"shlh", "00001011111"},
   {"shlhi", "00001111111"},
   {"shl", "00001011011"},
   {"shli", "00001111011"},
   {"roth", "00001011100"},
   {"rothi", "00001111100"},
   {"rot", "00001011000"},
   {"roti", "00001111000"},

    //BRANCH
   {"br", "001100100"},
   {"bra", "001100000"},
   {"bi", "00110101000"},
   {"brsl", "001100110"},
   {"brasl", "001100010"},
   {"brnz", "001000010"},
   {"brz", "001000000"},
   {"brhnz", "001000110"},
   {"brhz", "001000100"},

    //Single Precision FP MAC
    {"fa", "01011000100"},
   {"fs", "01011000101"},
   {"fma", "1110"},
   {"fnms", "1101"},
   {"fms", "1111"},
   {"fm", "01011000110"},

    //Single Precision Integer MAC
    {"mpy", "01111000100"},
    {"mpyu", "01111001100"},
    {"mpyi", "01110100"},
    {"mpyui", "01110101"},
    {"mpya", "1100"},

    //    Byte
    {"cntb", "01010110100"},
    {"absdb", "00001010011"},
    {"avgb", "00011010011"},
    {"sumb", "01001010011"},

        //Permute
    {"shlqbi", "00111011011"},
    {"shlqbii", "00111111011"},
    {"shlqby", "00111011111"},
    {"shlqbyi", "00111111111"},
    {"shlqbybi", "00111001111"},
    {"rotqby", "00111011100"},
    {"rotqbyi", "00111111100"},
    {"rotqbybi", "00111001100"},
    {"rotqbi", "00111011000"},
    {"rotqbii", "00111111000"},
    {"gbb", "00110110010"},
    {"gbh", "00110110001"},
    {"gb", "00110110000"},
    {"shufb", "1011"},


    //Load & Store
    {"lqd", "00110100"},
   {"lqx", "00111000100"},
   {"lqa", "001100001"},
   {"stqd", "00100100"},
   {"stqx", "00101000100"},
   {"stqa", "001000001"},
   {"ilh", "010000011"},
   {"il", "010000001"},
   {"ila", "0100001"},
   
   
    //Misc Instrs
    {"stop", "00000000000"},
    {"nop", "01000000001"},
   {"lnop", "00000000001"},

};