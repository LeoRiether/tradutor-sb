#include <codegen.hpp>

const char* indent = "    ";

std::ostream& operator<<(std::ostream& os, const GeneratorState& gs) {
    os << "section .data\n" << gs.data.rdbuf() << '\n';

    os << "section .bss\n" << gs.bss.rdbuf() << '\n';

    os << "section .text\n"
       << "global _start\n"
       << "_start:\n"
       << gs.text.rdbuf() << '\n'
       << "STOP: mov eax, 1\n"
       << "      xor ebx, ebx\n"
       << "      int 80h";

    return os;
}

void gen_label(GeneratorState& state, const Line& line) {
    if (state.current_section == GeneratorState::Section::Text)
        state.text << line.data[0] << ":\n";
    else
        // We don't know yet if we should put the label on .data or .bss 
        state.pending_labels.emplace(line.data[0]);
}

void gen_instruction(GeneratorState& state, const Line& line) {
    // Token instruction = line.data[0];
    // machine_code.push_back(instr_data.opcode);
    // for (size_t i = 1; i < instr_data.size; i++) {
    //     Token argument = line.data[i];
    //
    //     uint32_t memory_address = symbols.find(argument)->second;
    //     // offset (from the XY+2 syntax)
    //     memory_address += (i == 1 ? line.num : line.num2);
    //
    //     machine_code.push_back(memory_address);
    // }
}

void gen_directive(GeneratorState& state, const Line& line) {
    Token directive = line.data[0];
    stringstream& section = directive == "SPACE" ? state.bss : state.data;

    // Put the pending labels in the section they belong 
    bool first = true;
    while (!state.pending_labels.empty()) {
        const string label = state.pending_labels.front();
        state.pending_labels.pop();

        if (!first) section << ":\n";
        section << label;
        first = false;
    }
  
    if (directive == "SPACE")
        section << " resd " << line.num << '\n';
    else if (directive == "CONST" && !line.data[1].empty())
        section << " db '" << line.data[1] << "'\n";
    else if (directive == "CONST")
        section << " dd " << line.num << '\n';
}

GeneratorState generate_ia32(const vector<Line>& lines) {
    GeneratorState state;
    for (const auto& line : lines) {
        // Label
        if (line.which == Line::IsLabel) {
            gen_label(state, line);
        }
        // Instruction
        else if (line.which == Line::IsInstruction) {
            gen_instruction(state, line);
        }
        // Directive
        else if (line.which == Line::IsDirective) {
            gen_directive(state, line);
        }
        // Section
        else if (line.which == Line::IsSection) {
            state.current_section = section_from_string(line.data[0]);
        }
    }

    return state;
}
