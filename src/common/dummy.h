#ifndef COMMON_DUMMY_H_
#define COMMON_DUMMY_H_

#include <string>

class Dummy {
 public:
  Dummy() = delete;
  ~Dummy() = delete;
  static std::string reverse(std::string _str);
};

#endif  // COMMON_DUMMY_H_
