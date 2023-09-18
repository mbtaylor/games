.SUFFIXES: .tex .pdf .view

NSAMPLE = 10000
FMT = pdf
DATA = 5k3.fits medians.fits
STILTS = java -classpath stilts.jar:game.jar -Djel.classes=Game \
              uk.ac.starlink.ttools.Stilts
JYSTILTS = java -classpath jystilts.jar:game.jar -Djel.classes=Game \
                org.python.util.jython
JSRC = Game.java KeepPage.java
FIGDOC = keepspage
STATSDOC = statspage
GRIDSDOC = gridspage

.tex.pdf:
	pdflatex $<

.pdf.view:
	okular $<

$(FIGDOC).tex: game.jar jystilts.jar games.py
	$(JYSTILTS) games.py > $@

$(STATSDOC).tex: game.jar jystilts.jar stats.py
	$(JYSTILTS) stats.py \
        | sed 's/^ *sep.*/\\hline/' \
        >$@

$(GRIDSDOC).pdf: $(GRIDSDOC).tex grid-explode.pdf grid-basic.pdf
	pdflatex $(GRIDSDOC).tex

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

build: docs

view: build
	okular $(FIGDOC).pdf $(STATSDOC).pdf $(GRIDSDOC).pdf

docs: $(FIGDOC).pdf $(STATSDOC).pdf $(GRIDSDOC).pdf

data: $(DATA)

stilts.jar jystilts.jar:
	curl -LO http://www.starlink.ac.uk/stilts/$@

game.jar: $(JSRC) stilts.jar
	rm -rf tmp
	mkdir tmp
	javac -d tmp -classpath stilts.jar $(JSRC)
	cd tmp; jar cf ../$@ .
	rm -rf tmp

medians.fits: stilts.jar game.jar
	$(STILTS) tgroup in=:loop:10000000 icmd=progress \
                  icmd='addcol roll 1+(i%10)' \
                  icmd='addcol keep 1+((i/100)%10)' \
                  icmd='select keep<=roll' \
                  icmd='addcol explode keep(roll,keep,true)' \
                  icmd='addcol basic keep(roll,keep,false)' \
                  keys='roll keep' \
                  aggcols='basic;median explode;median null;count' \
                  ocmd='replacecol basic (int)basic' \
                  ocmd='replacecol explode (int)explode' \
                  out=$@

grid-explode.pdf grid-explode.png: stilts.jar medians.fits
	$(STILTS) plot2plane xpix=600 ypix=600 insets=60,60,60,60 \
                  x2func=x y2func=y aspect=1 \
                  grid=true minor=false fontsize=20 fontweight=bold \
                  xmin=0.5 xmax=10.5 ymin=0.5 ymax=10.5 \
                  auxmap=tropical auxvisible=false \
                  title=Exploding \
                  in=medians.fits x=roll y=keep \
                  layer_g=grid weight_g=explode xbinsize_g=1 ybinsize_g=1 \
                               xphase_g=0.5 yphase_g=0.5 \
                  layer_t=label label_t='toString(explode)' \
                                fontsize_t=22 fontweight_t=bold \
                                anchor_t=center color_t=black \
                  out=$@

grid-basic.pdf grid-basic.png: stilts.jar medians.fits
	$(STILTS) plot2plane xpix=600 ypix=600 insets=60,60,60,60 \
                  x2func=x y2func=y aspect=1 \
                  grid=true minor=false fontsize=20 fontweight=bold \
                  xmin=0.5 xmax=10.5 ymin=0.5 ymax=10.5 \
                  auxmap=tropical auxvisible=false \
                  title=Basic \
                  in=medians.fits x=roll y=keep \
                  layer_g=grid weight_g=basic xbinsize_g=1 ybinsize_g=1 \
                               xphase_g=0.5 yphase_g=0.5 \
                  layer_t=label label_t='toString(basic)' \
                                fontsize_t=22 fontweight_t=bold \
                                anchor_t=center color_t=black \
                  out=$@

5k3.fits: Game.java stilts.jar
	$(STILTS) tpipe in=:loop:$(NSAMPLE) \
                        cmd='addcol explode_5k3 keep(5,3,true)' \
                        cmd='addcol basic_5k3 keep(5,3,false)' \
                        cmd='delcols i' \
                        out=$@

plot: game.jar stilts.jar
	$(PLOTCMD) icmd="addcol stat keep(5,3,true)" \
                   leglabel="5k3 exploding"

stats: game.jar jystilts.jar
	$(JYSTILTS) stats.py

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
	rm -f $(FIGDOC).tex $(FIGDOC).pdf $(FIGDOC).aux $(FIGDOC).log
	rm -f $(STATSDOC).tex $(STATSDOC).pdf $(STATSDOC).aux $(STATSDOC).log
	rm -f $(GRIDSDOC).pdf $(GRIDSDOC).aux $(GRIDSDOC).log
	rm -f texput.log
	rm -f medians.fits grid-basic.pdf grid-explode.pdf

veryclean: clean
	rm -f stilts.jar
