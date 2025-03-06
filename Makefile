SRC_DIR = ./src
BUILD_DIR = ./build
BIN_DIR = ./bin
SCANNER_DIR = $(SRC_DIR)/scanner
PAESER_DIR = $(SRC_DIR)/parser
TREE_DIR = $(SRC_DIR)/tree

SCANNER_TARGET = $(BIN_DIR)/scanner
SCANNER_DEBUG_TARGET = $(BIN_DIR)/scanner_debug
PARSER_TARGET = $(BIN_DIR)/parser
PARSER_DEBUG_TARGET = $(BIN_DIR)/parser_debug
TARGET = $(PARSER_TARGET)
DEBUG_TARGET = $(PARSER_DEBUG_TARGET)

CC = gcc
FLEX = flex
BISON = bison

INCLUDES = -I$(BUILD_DIR) -I$(TREE_DIR)

SCANNER_SRCS = $(SCANNER_DIR)/main.c $(BUILD_DIR)/scanner.c $(TREE_DIR)/parse_tree.c
PARSER_SRCS = $(PAESER_DIR)/main.c $(BUILD_DIR)/parser.c $(BUILD_DIR)/scanner.c $(TREE_DIR)/parse_tree.c

.PHONY: all clean debug

all: $(TARGET)

debug: $(DEBUG_TARGET)

clean:
	rm -r -f $(BUILD_DIR)/* $(BIN_DIR)/*

$(SCANNER_TARGET): $(SCANNER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h
	$(CC) -o $@ -lfl $(INCLUDES) $(SCANNER_SRCS)

$(SCANNER_DEBUG_TARGET): $(SCANNER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h
	$(CC) -o $@ -lfl $(INCLUDES) -D__SCANNER_DEBUG $(SCANNER_SRCS)

$(PARSER_TARGET): $(PARSER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h
	$(CC) -o $@ -lfl $(INCLUDES) -ly $(PARSER_SRCS)

$(PARSER_DEBUG_TARGET): $(PARSER_SRCS) $(BUILD_DIR)/parser.h $(TREE_DIR)/parse_tree.h
	$(CC) -o $@ -lfl $(INCLUDES) -ly -D__SCANNER_DEBUG $(PARSER_SRCS)

$(BUILD_DIR)/scanner.c: $(SCANNER_DIR)/scanner.l
	$(FLEX) -o $@ $<

$(BUILD_DIR)/parser.c $(BUILD_DIR)/parser.h: $(PAESER_DIR)/parser.y
	$(BISON) -d -o $(BUILD_DIR)/parser.c $<