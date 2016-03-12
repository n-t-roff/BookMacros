TOC=		toc.tex lof.tex lot.tex
IDX_IN=		idx.txt
IDX_OUT=	idx.tex
XREF_IN=	xref.txt
XREF_OUT=	xref.tex

$(NAM).dvi: $(NAM).tex $(TOC) $(IDX_OUT) $(XREF_OUT) \
    BookMacros/BookMacros.tex
	make tex
	if [ -e $(NAM).aux ]; then \
		bibtex $(NAM).aux; \
	else \
		true; \
	fi
	for i in 1 2 3 4; do \
		make tex || exit 1; \
	done

$(NAM).pdf: $(NAM).tex $(TOC) $(IDX_OUT) $(XREF_OUT) \
    BookMacros/BookMacros.tex
	make pdftex
	if [ -e $(NAM).aux ]; then \
		bibtex $(NAM).aux; \
	else \
		true; \
	fi
	for i in 1 2 3 4; do \
		make pdftex || exit 1; \
	done

pdf: $(NAM).pdf

html: $(NAM).tex $(TOC) $(IDX_OUT) $(XREF_OUT)
	for i in 1 2 3 4; do \
		make httex || exit 1; \
	done

clean:
	rm -f *.log $(TOC) $(IDX_IN) $(IDX_OUT) $(XREF_IN) $(XREF_OUT) \
	    $(NAM).4* *.css *.idv *.lg *.tmp *.xref *.aux *.bbl *.blg

realclean: clean
	rm -f *.dvi $(NAM).ps *.pdf *.html makefile $(FMT).fmt

$(TOC):
	touch $@

$(IDX_OUT):
	touch $@

$(XREF_OUT):
	touch $@

tex:	$(FMT).fmt
	rm -f $(NAM).dvi
	$(TEX) $(TEXFLAGS) $(NAM)
	make postproc

pdftex:	$(FMT).fmt
	rm -f $(NAM).dvi
	pdftex $(TEXFLAGS) $(NAM)
	make postproc

httex:
	rm -f $(NAM).html
	$@ $(TEXFLAGS) $(NAM) "xhtml,html4.4ht,unicode.4ht,mathml.4ht"
	make postproc

postproc:
	if [ -e $(IDX_IN) ]; then \
		BookMacros/mkidx <$(IDX_IN) >$(IDX_OUT) || exit 1; \
	fi
	if [ -e $(XREF_IN) ]; then \
		BookMacros/mkxref <$(XREF_IN) >$(XREF_OUT) || exit 1; \
	fi
	for i in $(TOC); do \
		if grep -q '\\OT1\\ss' $$i; then \
			sed 's/\\OT1\\ss/\\ss/g' $$i >$$i.sed; \
			mv $$i.sed $$i; \
		fi \
	done

$(FMT).fmt:
	# Switch -etex is required even if tool *is* etex!
	if [ -n "$(FMT)" ]; then \
		etex -etex -ini "\input $(FMT)\dump"; \
	else \
		touch $@; \
	fi
