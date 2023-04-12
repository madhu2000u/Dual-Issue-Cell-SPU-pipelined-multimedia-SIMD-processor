#include <iostream>
#include <fstream>
#include <bitset>
#include <typeinfo>
#include <vector>
#include <sstream>
#include <algorithm>
#include "constants.cpp"

// std::string lexer(std::string instr){
    

// }

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

int main(){
    std::vector<std::string> parsed_instr;
    std::string asm_file = "test.asm";
    std::ifstream infile(asm_file.c_str());

    if(!infile.is_open()){
        std::cerr << "Failed to open assembly file " << asm_file << std::endl;
        return 1;
    }

    std::string instr;
    while (std::getline(infile, instr)){
        // std::cout<< instr << std::endl;
        parser(instr, parsed_instr);
        // std::cout<< parsed_instr.size() << std::endl;
        for(const auto &item : parsed_instr){
            std::cout << item << std::endl;
        }
        parsed_instr.clear();
        

        // Write the binary value to the file
        // std::bitset<opcode_map.at(instr).length() > opcode_bits(opcode_map.at(instr));
        // outfile << opcode_bits << std::endl;

    }
    
    // Open the text file for writing
    std::ofstream outfile("output.txt");

    // Check if the file was successfully opened
    if (!outfile.is_open())
    {
        std::cerr << "Failed to open output file" << std::endl;
        return 1;
    }
    
    

    
    // Close the file
    outfile.close();

    return 0;
}