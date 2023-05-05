#include <iostream>
#include <fstream>
#include <bitset>
#include <typeinfo>
#include <vector>
#include <sstream>
#include <algorithm>
#include "constants.cpp"



void parser(std::string instr, std::vector<std::string> &parsed_instr){
    std::stringstream ss(instr);
    std::string token;
    while(std::getline(ss, token, ',')){
        //std::cout<< token << std::endl;
        std::stringstream ss2(token);
        std::string subtoken;
        while (std::getline(ss2, subtoken, ' ')){
            //std::cout<< subtoken << std::endl;
            subtoken.erase(subtoken.begin(), std::find_if(subtoken.begin(), subtoken.end(), [](unsigned char ch){
                return !std::isspace(ch);
            }));
            subtoken.erase(std::find_if(subtoken.rbegin(), subtoken.rend(), [](unsigned char ch){
                return !std::isspace(ch);
            }).base(), subtoken.end());
            //subtoken = std::string(subtoken.begin() + subtoken.find_first_not_of(" "), subtoken.begin() + subtoken.find_last_not_of(" ") + 1);
            //std::cout<< subtoken << std::endl;
            if(!subtoken.empty()) parsed_instr.push_back(subtoken);
        }
    }
    
}

std::string codegen(std::vector<std::string> parsed_instr){
    int opcode_len = opcode_map.at(parsed_instr[0]).length();
    std::string opcode, ra, rb, rc, rt, final_binary_instr;
    std::bitset<REG_ADDR_LEN> opcode_bits;
    switch (opcode_len){
        case instrFormatOpcodeLenEnum::RR_RI7:   //machine code format as interpreted by SPU processor: op[11-bits]rb[7]ra[7]rt[7]
            //for RI7 instruction, the I7 field is at the same location and bit count as RR's rb field (check SPU ISA docs' instruction formats)
            //so doesn't matter in assembler if we put I7 values in rb field as it depends on the processor to interpret it as immediate or register field based on opcode
            {   
                if(parsed_instr[0] == "stop"){
                    std::bitset<INSTR_LEN> stop(0);
                    final_binary_instr = stop.to_string();
                    return final_binary_instr;
                }
                else if(parsed_instr[0] == "bi"){
                    opcode = opcode_map.at(parsed_instr[0]);
                    opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                    ra = opcode_bits.to_string();
                    rt = "0000000";
                    rb = "0000000";
                    final_binary_instr = opcode + rb + ra + rt;
                    return final_binary_instr;

                }
                else if(parsed_instr[0] == "clz" || parsed_instr[0] == "cntb" || parsed_instr[0] == "fsmh" || parsed_instr[0] == "fsm" || parsed_instr[0] == "gbb" || parsed_instr[0] == "gbh" || parsed_instr[0] == "gb"){
                    opcode = opcode_map.at(parsed_instr[0]);
                    opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                    rt = opcode_bits.to_string();
                    rb = "0000000";
                    opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[2]));
                    ra = opcode_bits.to_string();
                    final_binary_instr = opcode + rb + ra + rt;
                    return final_binary_instr;

                }

                else if(parsed_instr[0] == "nop" || parsed_instr[0] == "lnop"){
                    opcode = opcode_map.at(parsed_instr[0]);
                    rt = "0000000";
                    rb = "0000000";
                    ra = "0000000";
                    final_binary_instr = opcode + rb + ra + rt;
                    return final_binary_instr;
                    
                }
                if(parsed_instr.size() != 4) { 
                    std::cerr << "invalid number of operands for instruction type RR_RI7" << std::endl; 
                    return "";
                }
                
                opcode = opcode_map.at(parsed_instr[0]);

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                rt = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[2]));
                ra = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[3]));
                rb = opcode_bits.to_string();
                
                final_binary_instr = opcode + rb + ra + rt;
                if(final_binary_instr.length() != INSTR_LEN){
                    std::cerr << "err at RR_RI7: invalid instruction length: expected 32-bits but found " << final_binary_instr.length() << "-bits" << std::endl; 
                    return "";
                }
                return final_binary_instr;
            }
            
        
        case instrFormatOpcodeLenEnum::RRR:     //SPU interpretation: op[4-bits]rt[7]rb[7]ra[7]rc[7]  
            {   
                if(parsed_instr.size() != 5) { 
                    std::cerr << "invalid number of operands for instruction type RRR" << std::endl; 
                    return "";
                }

                opcode = opcode_map.at(parsed_instr[0]);
                std::cout<< parsed_instr[0] <<std::endl;
                std::cout<< parsed_instr[1] <<std::endl;
                std::cout<< parsed_instr[2] <<std::endl;
                std::cout<< parsed_instr[3] <<std::endl;
                std::cout<< parsed_instr[4] <<std::endl;
                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                rt = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[2]));
                ra = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[3]));
                rb = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[4]));
                rc = opcode_bits.to_string();
                
                final_binary_instr = opcode + rt + rb + ra + rc;

                if(final_binary_instr.length() != INSTR_LEN){
                    std::cerr << "err at RRR: invalid instruction length: expected 32-bits but found" << final_binary_instr.length() << "-bits" << std::endl; 
                    return "";
                }
                return final_binary_instr;

            }

            case instrFormatOpcodeLenEnum::RI10:     //SPU interpretation: op[8-bits]imm10[10]rb[7]rt[7]  
            {
                if(parsed_instr.size() != 4) { 
                    std::cerr << "invalid number of operands for instruction type RI10" << std::endl; 
                    return "";
                }

                opcode = opcode_map.at(parsed_instr[0]);

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                rt = opcode_bits.to_string();

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[2]));
                ra = opcode_bits.to_string();

                //rb is used as the imm10 field but the bitset param changes to the imm length
                std::bitset<IMM10_LEN> imm10_bits(std::stoi(parsed_instr[3]));
                rb = imm10_bits.to_string();
                
                final_binary_instr = opcode + rb + ra + rt;

                if(final_binary_instr.length() != INSTR_LEN){
                    std::cerr << "err at RI10: invalid instruction length: expected 32-bits but found" << final_binary_instr.length() << "-bits" << std::endl; 
                    return "";
                }
                return final_binary_instr;

            }

            case instrFormatOpcodeLenEnum::RI16:     //SPU interpretation: op[8-bits]imm10[10]rb[7]rt[7]  
            {
                if((parsed_instr[0] == "br" || parsed_instr[0] == "bra")){
                    if(parsed_instr.size() != 2){
                        std::cerr << "invalid number of operands for instruction type RI16 for branch instructions - " << parsed_instr[0] << std::endl; 
                        return "";
                    }
                    std::bitset<IMM16_LEN> imm16_bits(std::stoi(parsed_instr[1]));
                    rb = imm16_bits.to_string();
                    rt = "0000000";

                }
                else{
                    if(parsed_instr.size() != 3) {
                        std::cerr << "invalid number of operands for instruction type RI16 - " << parsed_instr[0] << std::endl; 
                        return "";
                    }

                    opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                    rt = opcode_bits.to_string();

                    //rb is used as the imm16 field but the bitset param changes to the imm length
                    std::bitset<IMM16_LEN> imm16_bits(std::stoi(parsed_instr[2]));
                    rb = imm16_bits.to_string();

                }


                opcode = opcode_map.at(parsed_instr[0]);

                final_binary_instr = opcode + rb + rt;

                if(final_binary_instr.length() != INSTR_LEN){
                    std::cerr << "err at RI16: invalid instruction length: expected 32-bits but found -" << final_binary_instr.length() << "-bits" << std::endl; 
                    return "";
                }
                return final_binary_instr;

            }

            case instrFormatOpcodeLenEnum::RI18:     //SPU interpretation: op[8-bits]imm10[10]rb[7]rt[7]  
            {
                if(parsed_instr.size() != 3) { 
                    std::cerr << "invalid number of operands for instruction type RI18" << std::endl; 
                    return "";
                }

                opcode = opcode_map.at(parsed_instr[0]);

                opcode_bits = std::bitset<REG_ADDR_LEN>(std::stoi(parsed_instr[1]));
                rt = opcode_bits.to_string();

                //rb is used as the imm18 field but the bitset param changes to the imm length
                std::bitset<IMM18_LEN> imm18_bits(std::stoi(parsed_instr[2]));
                rb = imm18_bits.to_string();
                
                final_binary_instr = opcode + rb + rt;

                if(final_binary_instr.length() != INSTR_LEN){
                    std::cerr << "err at RI18: invalid instruction length: expected 32-bits but found" << final_binary_instr.length() << "-bits" << std::endl; 
                    return "";
                }
                return final_binary_instr;

            }

        default:
            std::cerr << "Invalid instr type" << std::endl;
            break;
    }
}

int main(int argc, char *argv[]){
    std::vector<std::string> parsed_instr;
    std::string asm_file = argv[1];
    std::ifstream infile(asm_file.c_str());

    if(!infile.is_open()){
        std::cerr << "Failed to open assembly file " << asm_file << std::endl;
        return 1;
    }
    std::ofstream outfile("output.txt");

    // Check if the file was successfully opened
    if (!outfile.is_open())
    {
        std::cerr << "Failed to open output file" << std::endl;
        return 1;
    }

    std::string instr;
    std::stringstream ss;
    std::string instr_byte;
    int line_count = 0;
    while (std::getline(infile, instr)){
        parser(instr, parsed_instr);    //Parse
        instr = codegen(parsed_instr);  //Codegen
        std::cout << "line count - " << line_count + 1 << std::endl;
        line_count++;
        if(instr.empty()){
            std::cerr << "assembler.cpp:Error at line:"<< line_count <<". Codegen couldn't generate machine code due to error. Exiting" << std::endl;
            return 1;
        }

        for (int i = 0; i < INSTR_LEN - 7; i = i + 8)
        {   
            ss.str("");
            for (int j = i; j < i + 8; j++)
            {
                instr_byte = instr_byte + instr[j];
                     
            }
            std::cout << instr_byte << std::endl; 
            ss << std::hex << std::stoi(instr_byte, nullptr, 2);
            std::string hex_str = ss.str();
            std::cout << hex_str << std::endl;
            outfile << hex_str << std::endl;
            instr_byte = "";
        }
        
        parsed_instr.clear();
        

    }
    
    infile.close();
    outfile.close();

    return 0;
}