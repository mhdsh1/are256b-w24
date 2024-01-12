all: welcome.pdf

welcome.pdf: welcome.tex
	pdflatex welcome.tex
#	bibtex   welcome
#	pdflatex welcome.tex
#	pdflatex welcome.tex

clean:
	rm -f *.aux *.bbl *.blg *.log *.pdf