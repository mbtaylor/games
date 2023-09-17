
NSAMPLE = 10000
FMT = pdf
STILTS = java -classpath stilts.jar:game.jar -Djel.classes=Game \
              uk.ac.starlink.ttools.Stilts

build: tiles

stilts.jar:
	curl -LO http://www.starlink.ac.uk/stilts/$@

game.jar: Game.java stilts.jar
	rm -rf tmp
	mkdir tmp
	javac -d tmp -classpath stilts.jar Game.java 
	cd tmp; jar cf ../$@ .
	rm -rf tmp

tiles: game.jar stilts.jar
	for roll in 1 2 3 4; \
        do \
           for keep in 1 2 3 4 5 6 7 8 9 10; \
           do \
              if [ $$keep -le $$roll ]; \
              then \
                  echo $${roll}k$${keep}; \
                  $(STILTS) plot2plane in=:loop:$(NSAMPLE) \
                            icmd="addcol basic keep($$roll,$$keep,false)" \
                            layer=histogram x=basic binsize=1 \
                            xlabel= ylabel= x2func=x insets=24,2,24,2 \
                            grid=true legend=true legpos=.9,.9 \
                            leglabel="$${roll}k$${keep} basic" \
                            out=basic-$${roll}k$${keep}.$(FMT); \
                  $(STILTS) plot2plane in=:loop:$(NSAMPLE) \
                            icmd="addcol explode keep($$roll,$$keep,true)" \
                            layer=histogram x=explode binsize=1 \
                            xlabel= ylabel= x2func=x insets=24,2,24,2 \
                            grid=true legend=true legpos=.9,.9 \
                            leglabel="$${roll}k$${keep} explode" \
                            out=explode-$${roll}k$${keep}.$(FMT); \
              fi \
           done \
        done
	
clean:
	rm -f game.jar
	rm -f basic-*k*.$(FMT) explode-*k*.$(FMT)

veryclean: clean
	rm -f stilts.jar
