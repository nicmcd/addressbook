#include "common/dummy.h"

#include <sstream>

std::string Dummy::reverse(std::string _str) {
  std::stringstream ss;
  for (int i = _str.size() - 1; i >= 0; i--) {
    ss << _str[i];
  }
  return ss.str();
}
