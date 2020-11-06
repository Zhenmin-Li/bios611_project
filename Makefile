.PHONY : clean

## Build the final report.
report.pdf: report.tex figures/top20.png figures/bigramms.png figures/mostused.png figures/wordcloud1.png figures/wordcloud2.png figures/time_bing.png figures/time_affin.png figures/nrc.png
	pdflatex report.tex
	pdflatex report.tex
	mkdir -p versioned_reports
	cp report.pdf versioned_reports/game-timeline-`date | tr ' :' '_'`-`git log -1 | grep commit  | cut -d' ' -f2 |cut -c 1-5`.pdf

HW5.pdf: 
	Rscript -e "rmarkdown::render('homework/HW5.rmd', output_format='pdf_document')"

## generate the image.
figures/top20.png figures/bigramms.png figures/mostused.png figures/wordcloud1.png figures/wordcloud2.png figures/time_bing.png figures/time_affin.png figures/nrc.png: project.R source_data/ttweets1.csv source_data/ttweets1.csv
	Rscript project.R

clean:
	rm *.pdf
	rm figures/*