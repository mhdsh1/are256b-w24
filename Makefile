all: welcome.pdf example.pdf

welcome.pdf: welcome.tex
	pdflatex welcome.tex
	# Uncomment following lines if you have bibliography
	# bibtex welcome   
	# pdflatex welcome.tex
	# pdflatex welcome.tex

example.pdf: example.tex
	pdflatex example.tex

clean:
	rm -f *.aux *.bbl *.blg *.log *.pdf