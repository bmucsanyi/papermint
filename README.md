# papermint

`papermint` is my standalone paper math-font package. It selects math fonts only.

## Requirements

`papermint` supports LuaLaTeX, XeLaTeX, and pdfLaTeX.

Under LuaLaTeX and XeLaTeX, it loads `unicode-math` with
`STIX Two Math`. Under pdfLaTeX, it loads `stix2` with `notext`
and `bm`. All engines load `mathtools`.

## Installation

Install the package into your user TeX tree from the repository root:

```sh
l3build install
```

Check that TeX can find the installed package:

```sh
kpsewhich papermint.sty
```

## Usage

Load the package directly:

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

For arXiv, vendor the exact `papermint.sty` file into the paper source tree.

## Scope

`papermint` owns paper math-font selection. It does not depend on `macromint`,
`figmint`, or `slidemint`, and they do not depend on it either.

## Tests

Run from the repository root:

```sh
l3build check
```

## License

Apache 2.0.
