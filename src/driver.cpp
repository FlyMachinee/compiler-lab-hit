#include <iostream>

#include "driver.h"

using namespace my;
using namespace std;

driver::driver() : s(*this), p(*this), has_lexical_error(false), has_syntax_error(false)
{
}

driver::~driver()
{
}

int driver::parse(istream &is, ostream &os)
{
    s.switch_streams(is, os);
    return p.parse();
}