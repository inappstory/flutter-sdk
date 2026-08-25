#!/usr/bin/env bash
set -euo pipefail

echo "================ QUALITY REPORT ================"

# 1. Number of test files and total tests
echo "--- Tests ---"
if [ -d "test" ]; then
    TEST_FILES=$(find test -name "*_test.dart" | wc -l)
    echo "Test files: $TEST_FILES"
else
    echo "Test files: 0"
fi

TEST_OUTPUT=$(flutter test --reporter compact 2>&1 || true)
if echo "$TEST_OUTPUT" | grep -q "All tests passed"; then
    echo "Test results: PASS"
else
    echo "Test results: FAIL or WARNING"
fi

# 2. Coverage summary
echo "--- Coverage Summary ---"
LCOV_FILE="coverage/lcov.info"
if [ -f "$LCOV_FILE" ]; then
    TOTAL_LF=$(awk '/^SF:/ { skip = ($0 ~ /\.g\.dart$/) } /^LF:/ { if (!skip) lf += substr($0, 4) } END { print lf }' "$LCOV_FILE")
    TOTAL_LH=$(awk '/^SF:/ { skip = ($0 ~ /\.g\.dart$/) } /^LH:/ { if (!skip) lh += substr($0, 4) } END { print lh }' "$LCOV_FILE")
    if [ -n "$TOTAL_LF" ] && [ "$TOTAL_LF" -gt 0 ]; then
        COVERAGE=$(awk "BEGIN { printf \"%.2f\", ($TOTAL_LH / $TOTAL_LF) * 100 }")
        echo "Total Coverage: ${COVERAGE}%"
    else
        echo "Total Coverage: 0%"
    fi

    # 3. Files without coverage
    echo "--- Files Without Coverage (0%) ---"
    awk '
    /^SF:/ { file = substr($0, 4); lf = 0; lh = 0 }
    /^LF:/ { lf = substr($0, 4) }
    /^LH:/ { lh = substr($0, 4) }
    /^end_of_record/ {
        if (lf > 0 && lh == 0) {
            print file
        }
    }
    ' "$LCOV_FILE"
else
    echo "No coverage/lcov.info found. Run flutter test --coverage first."
fi

# 4. Test density ratio
echo "--- Code vs Test Density ---"
if [ -d "lib" ] && [ -d "test" ]; then
    LIB_LINES=$(find lib -name "*.dart" -exec cat {} + | wc -l | tr -d ' ')
    TEST_LINES=$(find test -name "*.dart" -exec cat {} + | wc -l | tr -d ' ')
    echo "Lines of production code (lib/): $LIB_LINES"
    echo "Lines of test code (test/): $TEST_LINES"
    if [ "$LIB_LINES" -gt 0 ]; then
        RATIO=$(awk "BEGIN { printf \"%.2f\", $TEST_LINES / $LIB_LINES }")
        echo "Test Density Ratio: $RATIO (tests / prod)"
    fi
else
    echo "lib/ or test/ directory not found."
fi

echo "================================================"
