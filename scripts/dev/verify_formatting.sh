#!/bin/bash


# At the moment the search for formatting violations is executed twice. Once
# to count how many warnings there are, and a second time to report on them.

# Why twice? Because in a very large diff set, storing all the results in a script variable
# then counting / reporting from there consumes a lot of memory and time

# This is actually faster.

func() {
  find src -name "*.hpp" -o -name "*.h" -o -name "*.hh" -o -name "*.cc" -o -name "*.cpp" -o -name "*.c" | xargs -n 1 -I '{}' diff  --unchanged-line-format="" --new-line-format="" --old-line-format="{ \"filename\": \"{}\", \"line\": %dn, \"messagetype\": \"warning\", \"message\": \"Formatting does not meet standards, See .clang_format and apply formatting.\", \"tool\": \"format-checker\" }%c'\012'" "{}" <(clang-format-3.9 "{}") 
}

NUMERRORS=$(func | wc -l)

if (( NUMERRORS > 100)); then
  # If the number of errors is > 100, then report 1 error per file affected
  func | sed "s/\"line\": [0-9]\+/\"line\": 1/g" | sed "s/\"warning\"/\"error\"/g" | sort -u
else
  # Otherwise report a warning on each line affected
  func
fi
