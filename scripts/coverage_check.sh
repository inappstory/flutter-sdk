#!/usr/bin/env bash
set -euo pipefail

# Run flutter test with coverage
flutter test --coverage

MIN_COVERAGE="${MIN_COVERAGE:-30}"
LCOV_FILE="coverage/lcov.info"

if [ ! -f "$LCOV_FILE" ]; then
    echo -e "\033[0;31mError: $LCOV_FILE not found.\033[0m"
    exit 1
fi

echo "--- Coverage Breakdown ---"
awk '
/^SF:/ { file = substr($0, 4); skip = (file ~ /\.g\.dart$/) }
/^LF:/ { if (skip) next; lf = substr($0, 4); total_lf += lf }
/^LH:/ { if (skip) next; lh = substr($0, 4); total_lh += lh }
/^end_of_record/ {
    if (skip) next;
    if (lf > 0) {
        cov = (lh / lf) * 100;
        printf "File: %s - Coverage: %.2f%%\n", file, cov;
    }
}
END {
    if (total_lf > 0) {
        total_cov = (total_lh / total_lf) * 100;
        printf "\nTotal Line Coverage: %.2f%%\n", total_cov;
        if (total_cov < min_cov) {
            exit 1;
        }
    } else {
        print "No coverage data found."
        exit 2;
    }
}
' min_cov="$MIN_COVERAGE" "$LCOV_FILE"

if [ $? -eq 1 ]; then
    echo -e "\033[0;31mCoverage is below threshold ($MIN_COVERAGE%).\033[0m"
    exit 1
elif [ $? -eq 2 ]; then
    echo -e "\033[0;33mNo coverage data found.\033[0m"
    exit 1
else
    echo -e "\033[0;32mCoverage check passed! (Threshold: $MIN_COVERAGE%)\033[0m"
fi
