#!/bin/sh
: "${LLAMA_CLI:=llama-cli}"
: "${1:?"no prompt supplied"}"

llm() {
	$LLAMA_CLI -m ~/models/Qwen3-Coder-30B-A3B-Instruct-Q5_K_M.gguf \
		   --no-warmup --no-conversation --no-display-prompt --simple-io \
		   "$@"
}

filter_llm_noise() {
	grep . | grep -v '^```' | sed -re 's/ *\[end of text\]//'
}

generate_cmd() {
	llm -n 32 \
	    -p "The customer asked me to write a portable unix shell one-liner to solve the following:

> $1

I was told that it must be on a single line (no newlines) and i must not use any other notation like markdown. Don't use any placeholder values, since the command should be used as-is. I must only transform the input in ways i was explicitly told to.

This is what I came up with:

" 2>/dev/null | filter_llm_noise | head -n1
}

review_cmd() {
	llm -n 2 --no-conversation --simple-io \
	    --grammar 'root ::= "yes" | "no"' \
	    -p "You review shell oneliners for correctness. It is important that the shell script matches the description. You output 'yes' or 'no' only (lowercase). The command should not operate on placeholder filenames like input.txt or similar, unless the description describes it explicitly. It is perfectly fine to solve the problem using external tools like perl, sed, awk or jq.

# INPUT
Description: $1
Command: $2

# OUTPUT
Verdict: " 2>/dev/null | filter_llm_noise
}

case $1 in
	--help) llm --help; exit 0 ;;
esac
while :; do
	cmd="$(generate_cmd "$1")"
	review="$(review_cmd "$1" "$cmd")";
	case "$review" in
		yes) printf "VALID: " 2>/dev/null; echo "$cmd"; exit 0 ;;
		no) echo "INVALID: $cmd" >&2 ;;
		*) echo "INVALID: $cmd, INVALID REVIEW: '$review'" >&2 ;;
	esac
done
