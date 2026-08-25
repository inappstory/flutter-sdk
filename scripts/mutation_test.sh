#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [ "${1:-}" == "--dry-run" ]; then
    DRY_RUN=true
    echo "Running in dry-run mode..."
fi

TARGET_FILES=(
    "lib/src/data/observable.dart"
    "lib/src/controllers/feed_stories_controller.dart"
    "lib/src/callbacks/call_to_action_callback_impl.dart"
    "lib/src/callbacks/ias_error_callback_impl.dart"
    "lib/src/callbacks/ias_checkout_callback_impl.dart"
    "lib/src/callbacks/ias_skus_callback_impl.dart"
    "lib/src/data/story_from_pigeon_dto.dart"
    "lib/src/controllers/logger.dart"
    "lib/src/ias_story_list_host_api_decorator.dart"
)

declare -a MUT_SEARCH=(
    "=="
    "!="
    "true"
    "false"
    "return;"
    ">="
    "<="
    "&&"
    "||"
)
declare -a MUT_REPLACE=(
    "!="
    "=="
    "false"
    "true"
    ""
    ">"
    "<"
    "||"
    "&&"
)

KILLED=0
SURVIVED=0
TOTAL=0

SURVIVOR_LOG="survivors.log"
> "$SURVIVOR_LOG"

trap 'echo -e "\n\033[0;31mScript interrupted! Restoring files...\033[0m"; for f in "${TARGET_FILES[@]}"; do if [ -f "$f.bak" ]; then mv "$f.bak" "$f"; fi; done' EXIT

for file in "${TARGET_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Warning: File $file not found, skipping."
        continue
    fi

    echo "Processing $file..."
    cp "$file" "$file.bak"

    for i in "${!MUT_SEARCH[@]}"; do
        search="${MUT_SEARCH[$i]}"
        replace="${MUT_REPLACE[$i]}"
        
        lines=$(grep -nF "$search" "$file" | grep -v '^[0-9]*:[[:space:]]*//' | grep -v '^[0-9]*:[[:space:]]*import ' | cut -d: -f1 || true)
        
        for line in $lines; do
            TOTAL=$((TOTAL + 1))
            
            if [ "$DRY_RUN" = true ]; then
                echo "  [DRY-RUN] Would apply mutation '$search' -> '$replace' at $file:$line"
                continue
            fi
            
            escaped_search=$(printf '%s' "$search" | sed -e 's/[]\/$*.^[]/\\&/g')
            escaped_replace=$(printf '%s' "$replace" | sed -e 's/[\/&]/\\&/g')
            
            sed -i '' "${line}s/${escaped_search}/${escaped_replace}/" "$file"
            
            set +e
            flutter test --reporter compact > /dev/null 2>&1
            test_exit_code=$?
            set -e
            
            if [ $test_exit_code -eq 0 ]; then
                SURVIVED=$((SURVIVED + 1))
                echo "  -> SURVIVED: $file:$line ('$search' -> '$replace')"
                echo "$file:$line ('$search' -> '$replace')" >> "$SURVIVOR_LOG"
            else
                KILLED=$((KILLED + 1))
            fi
            
            cp "$file.bak" "$file"
        done
    done
    
    rm -f "$file.bak"
done
trap - EXIT

if [ "$DRY_RUN" = true ]; then
    echo "Dry run completed. Total potential mutations: $TOTAL"
    exit 0
fi

echo "================ MUTATION TEST RESULTS ================"
echo "Total Mutations: $TOTAL"
echo "Killed: $KILLED"
echo "Survived: $SURVIVED"

if [ "$TOTAL" -gt 0 ]; then
    SCORE=$(awk "BEGIN { printf \"%.2f\", ($KILLED / $TOTAL) * 100 }")
    echo "Mutation Score: $SCORE%"
else
    echo "Mutation Score: N/A"
fi

if [ "$SURVIVED" -gt 0 ]; then
    echo "--- Surviving Mutants ---"
    cat "$SURVIVOR_LOG"
fi
echo "======================================================="

rm -f "$SURVIVOR_LOG"
