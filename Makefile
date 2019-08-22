PLAT = platf-unix
OBJECTS = activi.o dasave.o dbread.o fsol.o gcalc.o gmini.o hprogs.o prinin.o prtcal.o help.o $(PLAT).o
FFLAGS = ifort -O3

##FFLAGS = ifort -O2 -fbounds-check -Wunused
##FFLAGS = ifort -g -fbacktrace -ffpe-trap=underflow

COMP77 = ifort -O2
SEX = f90

super_tg : super_tg.o theriag_mod.o 
	$(FFLAGS) -o super_tg super_tg.o theriag_mod.o $(OBJECTS)

activi.o : activi.$(SEX) theriak.cmn files.cmn
	 $(FFLAGS) -c activi.$(SEX)
    
dasave.o : dasave.$(SEX) theriak.cmn
	$(FFLAGS) -c dasave.$(SEX)
    
dbread.o : dbread.$(SEX) theriak.cmn files.cmn
	$(FFLAGS) -c dbread.$(SEX)
    
fsol.o : fsol.$(SEX)
	$(FFLAGS) -c fsol.$(SEX)
    
gcalc.o : gcalc.$(SEX) theriak.cmn
	$(FFLAGS) -c gcalc.$(SEX)

gmini.o : gmini.$(SEX) theriak.cmn files.cmn
	$(FFLAGS) -c gmini.$(SEX)

hprogs.o : hprogs.$(SEX)
	$(FFLAGS) -c hprogs.$(SEX)

prinin.o : prinin.$(SEX) theriak.cmn files.cmn
	$(FFLAGS) -c prinin.$(SEX)

prtcal.o : prtcal.$(SEX) theriak.cmn files.cmn
	$(FFLAGS) -c prtcal.$(SEX)

help.o : help.$(SEX) files.cmn thblock.cmn
	$(FFLAGS) -c help.$(SEX)

$(PLAT).o : $(PLAT).$(SEX)
	$(FFLAGS) -c $(PLAT).$(SEX)

theriag_mod.o : theriag_mod.$(SEX) theriak.cmn files.cmn $(OBJECTS)
	$(FFLAGS) -c theriag_mod.$(SEX) 
	
super_tg.o : super_tg.$(SEX) theriag_mod.o 
	$(FFLAGS) -c super_tg.$(SEX)

clean:
	-rm -f $(OBJECTS) theriag_mod.o super_tg.o theriag_mod.mod
