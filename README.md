# papermint

`papermint` selects the math fonts of a paper.

## Requirements

LuaLaTeX, XeLaTeX, or pdfLaTeX, `mathtools`, and the STIX Two fonts:
`unicode-math` with `STIXTwoMath-Regular.otf` under LuaLaTeX and XeLaTeX,
`stix2` with `bm` under pdfLaTeX.

## Installation

From the repository root:

```sh
l3build install
```

This installs `papermint.sty` into the user TeX tree, where `kpsewhich
papermint.sty` finds it. For arXiv, vendor the file into the paper source.

## Usage

```tex
\usepackage{papermint}
```

In a paper that uses the mint stack:

```tex
\usepackage{neurips_2026}
\usepackage{papermint}
\usepackage{macromint}
\usepackage{figmint}
```

Load `papermint` before any package that loads `unicode-math` or `stix2`. It
stops with an error otherwise.

## Public interface

`papermint` defines no commands. It selects the math fonts and leaves the text
fonts, the layout, and everything else to the class.

## Tests

From the repository root:

```sh
l3build check
```

The tests need checkouts of `figmint`, which provides the shared test harness,
and `macromint` next to this repository.

## License

Apache 2.0.
