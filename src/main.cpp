#include <box.hpp>
#include <codegen.hpp>
#include <cstring>
#include <errors.hpp>
#include <fstream>
#include <iostream>
#include <lexer.hpp>
#include <preprocessor.hpp>
#include <sstream>

using std::cerr;
using std::endl;

Box token_box(const vector<Token>& tokens, const char* title = "Tokens") {
    Box box{title};
    for (string tok : tokens) {
        if (tok != "\n") {
            box << "<" << tok << "> ";
        } else {
            box << "<\\n>\n";
        }
    }
    return box;
}

vector<Token> do_preprocessing(std::string file_base);
void do_translation(std::vector<Token>, std::string file_base);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "TRADUTOR v1.0\n"
                "Leonardo Riether <riether.leonardo@gmail.com> e "
                "Tiago Fernandes <tiagotsf2000@gmail.com>\n"
                "\n"
                "Modo de uso: TRADUTOR <arquivo>\n"
                "    <arquivo>: Nome do arquivo .ASM, sem a extensão\n"
                "\n"
             << endl;
        exit(1);
    }
    std::vector<Token> tokens = do_preprocessing(argv[1]);
    do_translation(tokens, argv[1]);

    return 0;
}

// Lê um arquivo ASM e preprocessa IF's e EQU's
std::vector<Token> do_preprocessing(std::string file_base) {
    std::ifstream file(file_base + ".ASM");
    if (!file.is_open()) {
        file.open(file_base + ".asm");
        if (!file.is_open()) {
            cerr << "Não foi possível abrir o arquivo <" << file_base << ".ASM"
                 << "> na fase de preprocessamento de EQUs e IFs" << endl;
            exit(1);
        }
    }

    // Preprocessing
    std::vector<Token> tokens;
    try {
        tokens = lex(file);
        cerr << token_box(tokens) << endl;
        tokens = preprocess_equs_ifs(tokens);
        cerr << token_box(tokens, "Tokens (Sem EQUs e IFs)") << endl;
    } catch (AssemblerError& e) {
        std::cerr << e.what() << std::endl;
        exit(1);
    }

    return tokens;
}

// Realiza a tradução do Assembly inventado para IA-32 e escreve um arquivo .S
void do_translation(std::vector<Token> tokens, std::string file_base) {
    std::ofstream output(file_base + ".S");

    std::cout << "ok" << std::endl;
    try {
        // Parse tokens into lines
        auto lines = parse(tokens);


        // Print lines
        {
            Box box{"Lines"};
            for (const auto& line : lines)
                box << line.to_string() << "\n";
            cerr << box << endl;
        }

        // Translate program...
        std::stringstream code;
        code << generate_ia32(lines);

        // ...and write it to the output file
        output << code.str();
        output.close();

        // Print translated code
        {
            Box box{"IA32"};
            box << code.str();
            cerr << box << endl;
        }
    } catch (AssemblerError& e) {
        std::cerr << e.what() << std::endl;
        exit(1);
    }
}
