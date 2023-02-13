#pragma once
#include <bitset>
#include <fstream>
#include <iostream>
#include <parser.hpp>
#include <queue>
#include <sstream>
#include <string>
#include <unordered_map>

using std::string;
using std::stringstream;

struct GeneratorState {
    enum Section { Text, Data };
    Section current_section;
    std::queue<string> pending_labels;

    enum Features { Output_I, Input_I, Output_S, Input_S, _FeaturesLen };
    std::bitset<_FeaturesLen> used_feature;

    stringstream data, bss, text;

    GeneratorState() : current_section(Text), data(""), bss(""), text("") {
    }

    friend std::ostream& operator<<(std::ostream& os, const GeneratorState& gs);
};

inline GeneratorState::Section section_from_string(const string& section) {
    return section == "DATA" ? GeneratorState::Section::Data
                             : GeneratorState::Section::Text;
}

void gen_label(GeneratorState& state, const Line& line);
void gen_instruction(GeneratorState& state, const Line& line);
void gen_directive(GeneratorState& state, const Line& line);
GeneratorState generate_ia32(const vector<Line>& lines);
