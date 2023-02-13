#include <codegen.hpp>
#include <fstream>

const char* indent = "    ";

std::ostream& operator<<(std::ostream& os, const GeneratorState& gs) {
    os << "section .data\n" << gs.data.str() << '\n';

    os << "section .bss\n" << gs.bss.str();
    if (gs.used_feature[GeneratorState::Features::Output_I] or
        gs.used_feature[GeneratorState::Features::Input_I]) {
        os << "int.buffer resb 12 ; buffer for INPUT/OUTPUT.int\n";
    }
    os << "\n";

    os << "section .text\n"
       << "global _start\n"
       << "_start:\n"
       << gs.text.str() << '\n'
       << "STOP: mov eax, 1\n"
       << "      xor ebx, ebx\n"
       << "      int 80h\n\n";

    auto dump_io_file = [&](int feature_type, std::string file_name) {
        std::string line;
        if (gs.used_feature[feature_type]) {
            std::ifstream file ("src/" + file_name);
            if (file.is_open()) {
                while (getline(file,line))
                    os << line << "\n";
                file.close();
                os << "\n";
            }
        }
    };

    dump_io_file(GeneratorState::Features::Output_I, "output_int.asm");
    dump_io_file(GeneratorState::Features::Output_S, "output_str.asm");
    dump_io_file(GeneratorState::Features::Input_I, "input_int.asm");
    dump_io_file(GeneratorState::Features::Input_S, "input_str.asm");

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
void gen_instruction(GeneratorState& state, const Line& line) {
    Token instruction = line.data[0];

    state.text << indent << "; " << line.to_string() << '\n';

    string label1 = format_label_with_offset(line.data[1], line.num);
    string label2 = format_label_with_offset(line.data[2], line.num2);

    // OUTPUT
    if (instruction == "OUTPUT_S") {
        state.used_feature.set(GeneratorState::Features::Output_S);
        state.text << indent << "push eax\n";
        state.text << indent << "mov ecx, " << label1 << "\n"
                   << indent << "mov edx, " << line.num2 << "\n"
                   << indent << "call OUTPUT.str\n"
                   << indent << "pop eax\n";
    }
    else if (instruction == "OUTPUT_C") {
        state.used_feature.set(GeneratorState::Features::Output_S);
        state.text << indent << "push eax\n"
                   << indent << "mov ecx, " << label1 << "\n"
                   << indent << "mov edx, 1\n"
                   << indent << "call OUTPUT.str\n"
                   << indent << "pop eax\n";

    }
    else if (instruction == "OUTPUT") {
        state.used_feature.set(GeneratorState::Features::Output_I);
        state.text << indent << "push eax\n"
                   << indent << "push DWORD [" << label1 << "]\n"
                   << indent << "call OUTPUT.int\n"
                   << indent << "pop eax\n";
    }

    // INPUT
    else if (instruction == "INPUT_S") {
        state.used_feature.set(GeneratorState::Features::Input_S);
        state.text << indent << "push eax\n"
                   << indent << "mov ecx, " << label1 << "\n"
                   << indent << "mov edx, " << line.num2 << "\n"
                   << indent << "call INPUT.str\n"
                   << indent << "pop eax\n";
    }
    else if (instruction == "INPUT_C") {
        state.used_feature.set(GeneratorState::Features::Input_S);
        state.text << indent << "push eax\n"
                   << indent << "mov ecx, " << label1 << "\n"
                   << indent << "mov edx, 1\n"
                   << indent << "call INPUT.str\n"
                   << indent << "pop eax\n";

    }
    else if (instruction == "INPUT") {
        state.used_feature.set(GeneratorState::Features::Input_I);
        state.text << indent << "push eax\n"
                   << indent << "call INPUT.int\n"
                   << indent << "mov DWORD [" << label1 << "], eax\n"
                   << indent << "pop eax\n";

    }

    // ARITHMETIC OPERATIONS
    else if (instruction == "ADD") {
        state.text << indent << "add eax, DWORD [" << label1 << "]\n";
    }
    else if (instruction == "SUB") {
        state.text << indent << "sub eax, DWORD [" << label1 << "]\n";
    }
    else if (instruction == "MUL" or instruction == "MULT") {
        state.text << indent << "imul DWORD [" << label1 << "]\n";
    }
    else if (instruction == "DIV") {
        state.text << indent << "cdq" << "\n"
                   << indent << "idiv DWORD [" << label1 << "]\n";
    }

    // JUMPS
    else if (instruction == "JMP") {
        state.text << indent << "jmp " << label1 << "\n";
    }
    else if (instruction == "JMPN") {
        state.text << indent << "cmp eax, 0\n"
                   << indent << "jl " << label1 << "\n";
    }
    else if (instruction == "JMPP") {
        state.text << indent << "cmp eax, 0\n"
                   << indent << "jg " << label1 << "\n";
    }
    else if (instruction == "JMPZ") {
        state.text << indent << "cmp eax, 0\n"
                   << indent << "je " << label1 << "\n";
    }

    // MEMORY/SYSTEM
    else if (instruction == "COPY") {
        state.text << indent << "mov ebx, DWORD [" << label1 << "]\n"
                   << indent << "mov DWORD [" << label2 << "], ebx\n";
    }
    else if (instruction == "LOAD") {
        state.text << indent << "mov eax, DWORD [" << label1 << "]\n";
    }
    else if (instruction == "STORE") {
        state.text << indent << "mov DWORD [" << label1 << "], eax\n";
    }
    else if (instruction == "STOP") {
        state.text << indent << "jmp STOP\n";
    }

    state.text << '\n';
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
