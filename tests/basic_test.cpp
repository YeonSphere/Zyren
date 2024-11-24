#include <gtest/gtest.h>

TEST(BasicTest, Sanity) {
    EXPECT_TRUE(true);
}

TEST(BasicTest, Addition) {
    EXPECT_EQ(2 + 2, 4);
}
