#!/bin/bash
set -e

# Default to 'jac' if JAC_CMD is not set
JAC_CMD=${JAC_CMD:-jac}
PYTHON_CMD=${PYTHON_CMD:-python3}

echo "Generating frontend assets using $JAC_CMD..."

# Create directories
mkdir -p src/frontend/components
mkdir -p src/frontend/pages

# Generate app.js
echo "Generating src/app.js..."
$JAC_CMD js app.jac > src/app.js

# Generate client_runtime.js
echo "Generating src/client_runtime.js..."
# Find client_runtime.jac location using the python environment
CLIENT_RUNTIME_JAC=$($PYTHON_CMD -c "import jac_client.plugin; import os; print(os.path.join(list(jac_client.plugin.__path__)[0], 'client_runtime.jac'))")

if [ -f "$CLIENT_RUNTIME_JAC" ]; then
    echo "Found client_runtime.jac at $CLIENT_RUNTIME_JAC"
    $JAC_CMD js "$CLIENT_RUNTIME_JAC" > src/client_runtime.js
else
    echo "Error: Could not find client_runtime.jac"
    # Fallback for local testing if needed, or fail
    exit 1
fi

# Generate frontend components
echo "Generating frontend components..."
for file in frontend/components/*.jac; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .jac)
        echo "Compiling $file -> src/frontend/components/$filename.js"
        $JAC_CMD js "$file" > "src/frontend/components/$filename.js"
    fi
done

# Generate frontend pages
echo "Generating frontend pages..."
for file in frontend/pages/*.jac; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .jac)
        echo "Compiling $file -> src/frontend/pages/$filename.js"
        $JAC_CMD js "$file" > "src/frontend/pages/$filename.js"
    fi
done

# Create main.js
echo "Creating src/main.js..."
cat <<EOF > src/main.js
import React from "react";
import { createRoot } from "react-dom/client";
import { app as App } from "./app.js";

const root = createRoot(document.getElementById("root"));
root.render(<App />);
EOF

echo "Frontend generation complete."
