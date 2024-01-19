all: welcome.pdf example.pdf

welcome.pdf: welcome.tex
	pdflatex welcome.tex
	# bibtex welcome   # Uncomment these lines if you have bibliography
	# pdflatex welcome.tex
	# pdflatex welcome.tex

example.pdf: example.tex
	pdflatex example.tex

clean:
	rm -f *.aux *.bbl *.blg *.log *.pdf