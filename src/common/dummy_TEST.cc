#include <gtest/gtest.h>

#include <string>

#include "common/dummy.h"

TEST(Dummy, reverse) {
  std::string str1 = Dummy::reverse("welcome");
  std::string str2 = Dummy::reverse("nic");

  ASSERT_EQ(str1, "emoclew");
  ASSERT_EQ(str2, "cin");
}
