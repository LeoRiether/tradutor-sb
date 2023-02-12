#pragma once
#include <parser.hpp>
#include <string>
#include <unordered_map>

using std::string;

struct GeneratorState {
    // TODO: do we even need to know the current section?
    enum Section { Text, Data };
    Section current_section;

    string data, bss, text;

    GeneratorState() : current_section(Text), data(""), bss(""), text("") {
    }

    friend std::ostream& operator<<(std::ostream& os, const GeneratorState& gs);
};

inline GeneratorState::Section section_from_string(const string& section) {
    return section == "DATA" ? GeneratorState::Section::Data
                             : GeneratorState::Section::Text;
}

GeneratorState generate_ia32(const vector<Line>& lines);
