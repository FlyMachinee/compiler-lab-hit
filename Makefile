SRC_DIR = ./src
BUILD_DIR = ./build
BIN_DIR = ./bin
SCANNER_DIR = $(SRC_DIR)/scanner
PAESER_DIR = $(SRC_DIR)/parser
TREE_DIR = $(SRC_DIR)/tree

SCANNER_TARGET = $(BIN_DIR)/scanner
PARSER_TARGET = $(BIN_DIR)/parser
TARGET = $(PARSER_TARGET)

CC = gcc
FLEX = flex
BISON = bison

INCLUDES = -I$(BUILD_DIR) -I$(TREE_DIR)

SCANNER_SRCS = $(SCANNER_DIR)/main.c $(BUILD_DIR)/scanner.c $(TREE_DIR)/parse_tree.c
PARSER_SRCS = $(PAESER_DIR)/main.c $(BUILD_DIR)/parser.c $(BUILD_DIR)/scanner.c $(TREE_DIR)/parse_tree.c

.PHONY: all clean

all: $(TARGET)

clean:
	rm -r -f $(BUILD_DIR)/* $(BIN_DIR)/*

$(BUILD_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

$(SCANNER_TARGET): $(SCANNER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h | $(BIN_DIR)
	$(CC) -o $@ -lfl $(INCLUDES) $(SCANNER_SRCS)

$(PARSER_TARGET): $(PARSER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h | $(BIN_DIR)
	$(CC) -o $@ -lfl $(INCLUDES) -ly $(PARSER_SRCS)

$(BUILD_DIR)/scanner.c: $(SCANNER_DIR)/scanner.l | $(BUILD_DIR)
	$(FLEX) -o $@ $<

$(BUILD_DIR)/parser.c $(BUILD_DIR)/parser.h: $(PAESER_DIR)/parser.y | $(BUILD_DIR)
	$(BISON) -d -o $(BUILD_DIR)/parser.c $<