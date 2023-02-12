#include <codegen.hpp>

std::ostream& operator<<(std::ostream& os, const GeneratorState& gs) {

    return os;
}

void gen_instruction(GeneratorState& state, const Line& instruction_line) {
    // Token instruction = line.data[0];
    // machine_code.push_back(instr_data.opcode);
    // for (size_t i = 1; i < instr_data.size; i++) {
    //     Token argument = line.data[i];
    //
    //     uint16_t memory_address = symbols.find(argument)->second;
    //     // offset (from the XY+2 syntax)
    //     memory_address += (i == 1 ? line.num : line.num2);
    //
    //     machine_code.push_back(memory_address);
    // }
}

void gen_directive(GeneratorState& state, const Line& directive_line) {
    // Token directive = line.data[0];
    // if (directive == "SPACE")
    //     machine_code.resize(machine_code.size() + line.num, 0);
    // else if (directive == "CONST")
    //     machine_code.push_back(line.num);
}

GeneratorState generate_ia32(const vector<Line>& lines) {
    GeneratorState state;
    for (const auto& line : lines) {
        // Instruction
        if (line.which == Line::IsInstruction) {
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
