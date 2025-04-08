#!/bin/bash

# Test the parser with the input cmm files
# If some error occurs, the error message will be printed out directly
# If the parser runs normally, the parse tree output will be compared with the expected output

PARSER='./bin/parser'
MAKEFILE='./Makefile'
TEST_DIR='./Tests (normal)/inputs/'
# TEST_DIR='./test/'
EXPECTED_DIR='./Tests (normal)/expects/'

TMP_FILE="tmp.txt"

if [ ! -d "$TEST_DIR" ]; then
    echo "Test directory \"$TEST_DIR\" not found, please check the path."
    exit 1
fi

if [ -f "$MAKEFILE" ]; then
    echo "Makefile found, try to make the parser..."
    make
    if [ $? -ne 0 ]; then
        echo "Make failed, please check the error message."
        exit 1
    else 
        echo "Make success."
    fi
else
    echo "Makefile not found, try to directly use the parser..."
    if [ ! -f "$PARSER" ]; then
        echo "Parser not found in path \"$PARSER\", please check the path."
        exit 1
    else
        echo "Parser found."
    fi
fi

if [ -f "$TMP_FILE" ]; then
    rm -f $TMP_FILE
fi

oldifs="$IFS"
IFS=$'\n'

for file in $(find "$TEST_DIR" -name "*.cmm" | sort -t- -k1,1 -k2,2n); do
    filename=$(basename $file)
    echo "--------------------------------"
    echo "Testing $filename ..."
    $PARSER $file > $TMP_FILE
    if [ $? -ne 0 ]; then
        cat $TMP_FILE
    else
        echo "No error found by parser, comparing parse tree..."
        expected_file="$EXPECTED_DIR${filename%.*}.exp"
        if [ ! -f "$expected_file" ]; then
            echo "Expected file \"$expected_file\" not found, printing parse tree..."
            cat $TMP_FILE
        else
            diff "$TMP_FILE" "$expected_file"
            if [ $? -eq 0 ]; then
                echo "Parse tree matched."
            fi
        fi
    fi
done

IFS="$oldifs"

echo "--------------------------------"
echo "All tests run."

rm $TMP_FILE

exit 0