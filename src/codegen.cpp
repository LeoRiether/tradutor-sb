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

// TODO: tomar cuidado para colocar label+offset certo!
// TODO: estou admitindo que o AX é o registrador acumulador
void gen_instruction(GeneratorState& state, const Line& line) {
    Token instruction = line.data[0];

    // OUTPUT
    if (instruction == "OUTPUT_S") {
        state.used_feature.set(GeneratorState::Features::Output_S);
        // TODO: mudar para uma call a "OUTPUT.str"
        state.text << indent << "mov eax, 4\n"
                   << indent << "mov ebx, 1\n"
                   << indent << "mov ecx, " << line.data[1]
                   << "\n"  // BUG: faltando offset!
                   << indent << "mov edx, " << line.num2 << "\n"
                   << indent << "int 80h\n";
    }
    else if (instruction == "OUTPUT_C") {

    }
    else if (instruction == "OUTPUT") {

    }

    // INPUT
    else if (instruction == "INPUT_S") {

    }
    else if (instruction == "INPUT_C") {

    }
    else if (instruction == "INPUT") {

    }

    // ARITHMETIC OPERATIONS
    else if (instruction == "ADD") {
        state.text << indent << "add ax " << line.data[1] << "\n";
    }
    else if (instruction == "SUB") {
        state.text << indent << "sub ax " << line.data[1] << "\n";
    }
    else if (instruction == "MUL" or instruction == "MULT") {
        state.text << indent << "imul ax " << line.data[1] << "\n";
    }
    else if (instruction == "DIV") {
        state.text << indent << "cdq" << "\n";
        state.text << indent << "idiv ax " << line.data[1] << "\n";
    }

    // JUMPS
    else if (instruction == "JMP") {
        state.text << indent << "call " << line.data[1] << "\n";
    }
    else if (instruction == "JMPN") {
        state.text << indent << "cmp ax, 0\n";
        state.text << indent << "jl " << line.data[1] << "\n";
    }
    else if (instruction == "JMPP") {
        state.text << indent << "cmp ax, 0\n";
        state.text << indent << "jg " << line.data[1] << "\n";
    }
    else if (instruction == "JMPZ") {
        state.text << indent << "cmp ax, 0\n";
        state.text << indent << "je " << line.data[1] << "\n";
    }

    // MEMORY/SYSTEM
    else if (instruction == "COPY") {
        
    }
    else if (instruction == "LOAD") {
        
    }
    else if (instruction == "STORE") {
        
    }
    else if (instruction == "STOP") {
        state.text << indent << "jmp STOP\n";
    }





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
