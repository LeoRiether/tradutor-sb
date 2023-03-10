#pragma once
#include <algorithm>
#include <iostream>
#include <ostream>
#include <string>
#include <vector>

using std::ostream;
using std::string;
using std::vector;

// Displays boxed output.
// Not really relevant to the implementation of the assembler
struct Box {
    string header;
    int minwidth, maxwidth;
    vector<string> buffer{""};

    Box(const string& _header, int _minwidth = 40, int _maxwidth = 80)
        : header(_header), minwidth(_minwidth), maxwidth(_maxwidth) {
    }

    Box& operator<<(const string& s) {
        for (char c : s) {
            if (c == '\n')
                buffer.emplace_back();
            else if ((int)buffer.back().size() >= maxwidth - 4)
                buffer.emplace_back(std::string{c});
            else
                buffer.back().push_back(c);
        }
        return *this;
    }
};

inline ostream& operator<<(ostream& os, Box& box) {
    // Trim trailing blank lines
    while (box.buffer.size() >= 2 && box.buffer.back().empty())
        box.buffer.pop_back();

    int width = std::max<int>(box.minwidth, box.header.size() + 4);
    for (const auto& line : box.buffer)
        width = std::max<int>(width, line.size() + 4);

    auto repeat = [&](const char* s, int n) {
        for (int i = 0; i < n; i++)
            os << s;
    };

    // Header
    int left = (width - box.header.size() - 4) / 2;
    int right = width - box.header.size() - 4 - left;
    os << "╭";
    repeat("─", left);
    os << " " << box.header << " ";
    repeat("─", right);
    os << "╮\n";

    // Body
    for (const auto& line : box.buffer) {
        os << "│ ";
        os << line;
        repeat(" ", width - 3 - line.size());
        os << "│\n";
    }

    // Footer
    os << "╰";
    repeat("─", width - 2);
    os << "╯";

    box.buffer.clear();
    box.buffer.emplace_back();

    return os;
}

inline ostream& operator<<(ostream& os, Box&& box) {
    os << box;
    return os;
}
