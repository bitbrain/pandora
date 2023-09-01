# NanoIDAlphabets class from github.com/eth0net/nanoid-godot (MIT) v0.2.0
class_name NanoIDAlphabets


# This alphabet uses `A-Za-z0-9_-` symbols.
# The order of characters is optimized for better gzip and brotli compression.
# References to the same file (works both for gzip and brotli):
# `'use`, `andom`, and `rict'`
# References to the brotli default dictionary:
# `-26T`, `1983`, `40px`, `75px`, `bush`, `jack`, `mind`, `very`, and `wolf`
const URL: String = "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"

# These alphabets are from https://github.com/CyberAP/nanoid-dictionary
const NUMBERS: String = "1234567890"
const LOWERCASE: String = "abcdefghijklmnopqrstuvwxyz"
const UPPERCASE: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ALPHANUMERIC: String = NUMBERS + LOWERCASE + UPPERCASE
const HEXADECIMAL_LOWERCASE: String = NUMBERS + "abcdef"
const HEXADECIMAL_UPPERCASE: String = NUMBERS + "ABCDEF"
const NO_LOOKALIKES: String = "346789ABCDEFGHJKLMNPQRTUVWXYabcdefghijkmnpqrtwxyz"
const NO_LOOKALIKES_SAFE: String = "6789BCDFGHJKLMNPQRTWbcdfghjkmnpqrtwz"
