# Trabalho de Software Básico 2022/2 - Tradutor

## Alunos

- Leonardo Alves Riether - 19/0032413
- Tiago de Souza Fernandes - 18/0131818

## Desenvolvimento do projeto

- Sistema Operacional: Linux (Manjaro/Ubuntu 22.04)
- Compilador: g++ 11.3.0
- [Repositório do Projeto](https://github.com/LeoRiether/tradutor-sb)

## Compilação

Para compilar os arquivos do projeto e gerar o executável do montador, basta utilizar o arquivo makefile no diretório principal:

```
make
``` 

## Uso

O tradutor pode ser executado com o seguinte comando:

```
./TRADUTOR <filename_without_extension>
```

Este comando traduz o arquivo `filename_without_extension.ASM` e coloca a saída
em `filename_without_extension.S`.

Para mais informações a respeito do funcionamento do tradutor:
```
./TRADUTOR -h
```

## Estrutura do Projeto
- Os arquivos fonte estão em `src/`, os headers, no `include/`, e por fim os testes, em `tests/`
- Existem 5 módulos principais:
    - __lexer__: lê os tokens de um arquivo (já funciona, falta tratamento de erros)
    - __preprocessor__: processa EQUs, IFs e MACROs
    - __parser__: transforma os tokens em um vetor "uniforme" de linhas da forma `[label:] <op> [arg1] [arg2]`
    - __codegen__: traduz as linhas geradas pelo parser em assembly IA-32 
    - __main__: executa o pipeline de módulos

## Entrada e Saída
Além do código em C++, escritas funções em IA-32 para realizar entrada e saída. Elas podem ser encontradas em nos arquivos `src/input_int.asm`, `src/input_str.asm`, `src/output_int.asm` e `src/output_str.asm`.

Cada função só é colocada na saída final do tradutor caso sua respectiva instrução seja utilizada no arquivo de entrada. Por exemplo, o `OUTPUT.str` só é colocado na saída caso a instrução `OUTPUT_S` ou `OUTPUT_C` seja usada na entrad.


## Como rodar os testes

Foi utilizado o framework [Catch2](https://github.com/catchorg/Catch2) para realizar testes unitários.

Os testes podem ser executados utilizando os comandos:

```
./gen-build.sh && ./build/tests
```
Para executar o `gen-build.sh` é preciso ter o [CMake](https://cmake.org/) instalado.
