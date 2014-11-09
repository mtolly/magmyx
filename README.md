# `magmyx`

This is a wrapper around Harmonix's Magma compiler for Rock Band 3 which makes
it behave like a proper command-line app. The original program chokes on
relative paths outside of the exe folder.

## Usage

    magmyx [-c3] in.rbproj [out.rba]

If `-c3` is given, uses [C3's edited Magma][c3magma] which supports songs
over 10 minutes. Otherwise, uses Harmonix's.

[c3magma]: http://www.pksage.com/ccc/forums/viewtopic.php?f=12&t=381

If `out.rba` is omitted, uses the output path from `in.rbproj`.

On Mac/Linux, Wine must be installed and in your PATH.
