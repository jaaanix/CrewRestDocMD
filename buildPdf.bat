pandoc -s -S --filter pandoc-citeproc --latex-engine=xelatex --include-before-body=titlepage.tex doku.md -o doku.pdf
