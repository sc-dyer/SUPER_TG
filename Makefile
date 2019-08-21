PLAT = platf-unix
OBJECTS = activi.o dasave.o dbread.o fsol.o gcalc.o gmini.o hprogs.o prinin.o prtcal.o help.o $(PLAT).o
COMP90 = ifort -fast

##COMP90 = ifort -O2 -fbounds-check -Wunused
##COMP90 = ifort -g -fbacktrace -ffpe-trap=underflow

COMP77 = ifort -O2
SEX = f90

super_tg : super_tg.o theriag_mod.o 
	$(COMP90) -o super_tg super_tg.o theriag_mod.o $(OBJECTS)

activi.o : activi.$(SEX) theriak.cmn files.cmn
	 $(COMP90) -c activi.$(SEX)
    
dasave.o : dasave.$(SEX) theriak.cmn
	$(COMP90) -c dasave.$(SEX)
    
dbread.o : dbread.$(SEX) theriak.cmn files.cmn
	$(COMP90) -c dbread.$(SEX)
    
fsol.o : fsol.$(SEX)
	$(COMP90) -c fsol.$(SEX)
    
gcalc.o : gcalc.$(SEX) theriak.cmn
	$(COMP90) -c gcalc.$(SEX)

gmini.o : gmini.$(SEX) theriak.cmn files.cmn
	$(COMP90) -c gmini.$(SEX)

hprogs.o : hprogs.$(SEX)
	$(COMP90) -c hprogs.$(SEX)

prinin.o : prinin.$(SEX) theriak.cmn files.cmn
	$(COMP90) -c prinin.$(SEX)

prtcal.o : prtcal.$(SEX) theriak.cmn files.cmn
	$(COMP90) -c prtcal.$(SEX)

help.o : help.$(SEX) files.cmn thblock.cmn
	$(COMP90) -c help.$(SEX)

$(PLAT).o : $(PLAT).$(SEX)
	$(COMP90) -c $(PLAT).$(SEX)

theriag_mod.o : theriag_mod.$(SEX) theriak.cmn files.cmn $(OBJECTS)
	$(COMP90) -c theriag_mod.$(SEX) 
	
super_tg.o : super_tg.$(SEX) theriag_mod.o 
	$(COMP90) -c super_tg.$(SEX)

clean:
	-rm -f $(OBJECTS) theriag_mod.o super_tg.o theriag_mod.mod
