#!/bin/bash

set -e

# Script to generate AMQP framing sources for rabbit_common
# This script replicates the functionality of the Makefile targets

PYTHON=${PYTHON:-python}
CODEGEN_DIR=${CODEGEN_DIR:-deps/rabbitmq_codegen}
CODEGEN=$(dirname "$0")/codegen.py

AMQP_SPEC_JSON_FILES_0_8="$CODEGEN_DIR/amqp-rabbitmq-0.8.json"
AMQP_SPEC_JSON_FILES_0_9_1="$CODEGEN_DIR/amqp-rabbitmq-0.9.1.json $CODEGEN_DIR/credit_extension.json"

# Check if generated files already exist and are newer than sources
HEADER_FILE="include/rabbit_framing.hrl"
BODY_0_9_1_FILE="src/rabbit_framing_amqp_0_9_1.erl"
BODY_0_8_FILE="src/rabbit_framing_amqp_0_8.erl"

# Function to check if file needs regeneration
needs_generation() {
    local target_file="$1"
    local source_files="$2"
    
    if [ ! -f "$target_file" ]; then
        return 0  # File doesn't exist, needs generation
    fi
    
    # Check if any source file is newer than target
    for source_file in $source_files; do
        if [ -f "$source_file" ] && [ "$source_file" -nt "$target_file" ]; then
            return 0  # Source is newer, needs regeneration
        fi
    done
    
    return 1  # Target is up to date
}

# Check if codegen directory exists
if [ ! -d "$CODEGEN_DIR" ]; then
    echo "Warning: $CODEGEN_DIR directory not found."
    echo "If generated files exist, they will be used as-is."
    echo "To regenerate, ensure rabbitmq_codegen dependency is available."
    
    # Check if all generated files exist
    if [ -f "$HEADER_FILE" ] && [ -f "$BODY_0_9_1_FILE" ] && [ -f "$BODY_0_8_FILE" ]; then
        echo "All generated files exist, proceeding with build."
        exit 0
    else
        echo "Error: Generated files missing and codegen directory not available."
        exit 1
    fi
fi

# Check if Python script exists
if [ ! -f "$CODEGEN" ]; then
    echo "Error: $CODEGEN not found."
    exit 1
fi

# Check Python availability
if ! command -v "$PYTHON" >/dev/null 2>&1; then
    echo "Error: Python interpreter '$PYTHON' not found."
    exit 1
fi

# Create directories if they don't exist
mkdir -p include
mkdir -p src

# Generate header file if needed
SOURCE_FILES="$CODEGEN $(echo $AMQP_SPEC_JSON_FILES_0_9_1 $AMQP_SPEC_JSON_FILES_0_8)"
if needs_generation "$HEADER_FILE" "$SOURCE_FILES"; then
    echo "Generating include/rabbit_framing.hrl..."
    env PYTHONPATH="$CODEGEN_DIR" \
        $PYTHON "$CODEGEN" --ignore-conflicts header \
        $AMQP_SPEC_JSON_FILES_0_9_1 $AMQP_SPEC_JSON_FILES_0_8 \
        include/rabbit_framing.hrl
else
    echo "include/rabbit_framing.hrl is up to date."
fi

# Generate AMQP 0.9.1 body if needed
SOURCE_FILES="$CODEGEN $(echo $AMQP_SPEC_JSON_FILES_0_9_1)"
if needs_generation "$BODY_0_9_1_FILE" "$SOURCE_FILES"; then
    echo "Generating src/rabbit_framing_amqp_0_9_1.erl..."
    env PYTHONPATH="$CODEGEN_DIR" \
        $PYTHON "$CODEGEN" body $AMQP_SPEC_JSON_FILES_0_9_1 \
        src/rabbit_framing_amqp_0_9_1.erl
else
    echo "src/rabbit_framing_amqp_0_9_1.erl is up to date."
fi

# Generate AMQP 0.8 body if needed
SOURCE_FILES="$CODEGEN $AMQP_SPEC_JSON_FILES_0_8"
if needs_generation "$BODY_0_8_FILE" "$SOURCE_FILES"; then
    echo "Generating src/rabbit_framing_amqp_0_8.erl..."
    env PYTHONPATH="$CODEGEN_DIR" \
        $PYTHON "$CODEGEN" body $AMQP_SPEC_JSON_FILES_0_8 \
        src/rabbit_framing_amqp_0_8.erl
else
    echo "src/rabbit_framing_amqp_0_8.erl is up to date."
fi

echo "Code generation completed successfully."