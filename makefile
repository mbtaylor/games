.SUFFIXES: .tex .pdf .view

NSAMPLE = 10000
FMT = pdf
DATA = 5k3.fits
STILTS = java -classpath stilts.jar:game.jar -Djel.classes=Game \
              uk.ac.starlink.ttools.Stilts
JYSTILTS = java -classpath jystilts.jar:game.jar -Djel.classes=Game \
                org.python.util.jython
JSRC = Game.java KeepPage.java
DOC = keepspage

.tex.pdf:
	pdflatex $<

.pdf.view:
	okular $<

$(DOC).tex: game.jar jystilts.jar games.py
	$(JYSTILTS) games.py > $@

PLOTCMD = $(STILTS) plot2plane in=:loop:$(NSAMPLE) x=stat \
          layer_h=histogram binsize_h=1 barform_h=semi_steps \
          cumulative_h=reverse normalise_h=height \
          xlabel= ylabel= grid=true minor=false \
          layer_m=function fexpr_m=0.5 color_m=black thick_m=3 \
          layer_q1=function fexpr_q1=0.25 \
          layer_q3=function fexpr_q3=0.75 \
          color_q=black thick_q=2 dash_q=3,3 \
          ycrowd=0.8 xcrowd=2 ymin=0 ymax=1.01 \
          seq=_h,_m,_q1,_q3 legseq=_h \
          legend=true legpos=.9,.9 \
          xpix=300 ypix=212

build: doc

view: build $(DOC).view

doc: $(DOC).pdf

data: $(DATA)

stilts.jar jystilts.jar:
	curl -LO http://www.starlink.ac.uk/stilts/$@

game.jar: $(JSRC) stilts.jar
	rm -rf tmp
	mkdir tmp
	javac -d tmp -classpath stilts.jar $(JSRC)
	cd tmp; jar cf ../$@ .
	rm -rf tmp

5k3.fits: Game.java stilts.jar
	$(STILTS) tpipe in=:loop:$(NSAMPLE) \
                        cmd='addcol explode_5k3 keep(5,3,true)' \
                        cmd='addcol basic_5k3 keep(5,3,false)' \
                        cmd='delcols i' \
                        out=$@

plot: game.jar stilts.jar
	$(PLOTCMD) icmd="addcol stat keep(5,3,true)" \
                   leglabel="5k3 exploding"

tiles: game.jar stilts.jar
	for roll in 1 2 3 4 5; \
        do \
           for keep in 1 2 3 4 5 6 7 8 9 10; \
           do \
              if [ $$keep -le $$roll ]; \
              then \
                  rk=$${roll}k$${keep}; \
                  echo $$rk; \
                  $(PLOTCMD) icmd="addcol stat keep($$roll,$$keep,false)" \
                             leglabel="$$rk basic" \
                             out=basic-$$rk.$(FMT); \
                  $(PLOTCMD) icmd="addcol stat keep($$roll,$$keep,true)" \
                             leglabel="$$rk exploding" \
                             out=explode-$$rk.$(FMT); \
              fi \
           done \
        done

clean:
	rm -f game.jar
	rm -f k[0-9].png $(DATA)
	rm -f $(DOC).tex $(DOC).pdf $(DOC).aux $(DOC).log texput.log

veryclean: clean
	rm -f stilts.jar
