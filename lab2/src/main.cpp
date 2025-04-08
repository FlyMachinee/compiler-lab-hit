#include <fstream>
#include <iostream>

#include "driver.h"

using namespace my;
using namespace std;

int main(int argc, char **argv)
{
    if (argc <= 1) {
        return 1;
    }

    ifstream f(argv[1]);
    if (!f) {
        return 1;
    }

    driver d;
    d.parse(f);

    if (d.has_lexical_error || d.has_syntax_error) {
        return 1;
    } else {
        d.pt->print();
        return 0;
    }
}