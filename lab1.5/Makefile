SRC_DIR = ./src
INCLUDE_DIR = ./include
BUILD_DIR = ./build
BIN_DIR = ./bin

TARGET = $(BIN_DIR)/parser

SRCS_T = $(wildcard $(SRC_DIR)/*.cpp)
OBJS_T = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(SRCS_T))
DEPS_T = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.d, $(SRCS_T))

SRCS = $(SRCS_T) $(BUILD_DIR)/scanner.cpp $(BUILD_DIR)/parser.cpp
OBJS = $(OBJS_T) $(BUILD_DIR)/scanner.o $(BUILD_DIR)/parser.o
DEPS = $(DEPS_T) $(BUILD_DIR)/scanner.d $(BUILD_DIR)/parser.d

CC = g++
CCFLAGS = -std=c++20 -Wall -O2
FLEX = flex
BISON = bison

INCLUDES = -I$(BUILD_DIR) -I$(INCLUDE_DIR)

.PHONY: all clean test

all: $(TARGET)

test:
	@echo $(SRCS)
	@echo $(OBJS)
	@echo $(DEPS)

clean:
	rm -r -f $(BUILD_DIR)/* $(BIN_DIR)/*

$(BUILD_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CC) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	$(CC) $(CCFLAGS) -c -o $@ $< $(INCLUDES)

$(BUILD_DIR)/scanner.o: $(BUILD_DIR)/scanner.cpp | $(BUILD_DIR)
	$(CC) $(CCFLAGS) -c -o $@ $< $(INCLUDES)

$(BUILD_DIR)/parser.o: $(BUILD_DIR)/parser.cpp | $(BUILD_DIR)
	$(CC) $(CCFLAGS) -c -o $@ $< $(INCLUDES)

$(BUILD_DIR)/%.d: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	@set -e; rm -f $@; \
	$(CC) -MM $< $(INCLUDES) > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,$(BUILD_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(BUILD_DIR)/scanner.d: $(BUILD_DIR)/scanner.cpp | $(BUILD_DIR)
	@set -e; rm -f $@; \
	$(CC) -MM $< $(INCLUDES) > $@.$$$$; \
	sed 's,\(.*\)\.o[ :]*,$(BUILD_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(BUILD_DIR)/parser.d: $(BUILD_DIR)/parser.cpp | $(BUILD_DIR)
	@set -e; rm -f $@; \
	$(CC) -MM $< $(INCLUDES) > $@.$$$$; \
	sed 's,\(.*\)\.o[ :]*,$(BUILD_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(BUILD_DIR)/scanner.cpp: $(SRC_DIR)/scanner.l | $(BUILD_DIR)
	$(FLEX) -+ -o $@ $<

$(BUILD_DIR)/parser.cpp $(BUILD_DIR)/parser.hpp $(BUILD_DIR)/location.hh: $(SRC_DIR)/parser.y | $(BUILD_DIR)
	$(BISON) -o $(BUILD_DIR)/parser.cpp $<

-include $(DEPS)