#
# "$Id: makefile,v 1.6 Selznick$"
#   Makefile for Seiko Instruments USA Inc. Smart Label Printer Driver
#
#   Copyright yyyy-YYYY by Easy Software Products, all rights
#   reserved.
#
#   These coded instructions, statements, and computer programs are
#   the property of Easy Software Products and are protected by
#   Federal copyright law.  Distribution and use rights are outlined
#   in the file "LICENSE.txt" which should have been included with
#   this file.  If this file is missing or damaged please contact
#   Easy Software Products at:
#
#       Attn: CUPS Licensing Information
#       Easy Software Products
#       44141 Airport View Drive, Suite 204
#       Hollywood, Maryland 20636 USA
#
#       Voice: (301) 373-9600
#       EMail: cups-info@cups.org
#         WWW: http://www.cups.org/

mfdir     := $(shell pwd)
program   := seikoslp.rastertolabel
sources   := DriverUtils.cxx RasterToSIISLP.cxx SIISLPProcessBitmap.cxx
objects   := $(sources:%.cxx=%.o)
depends   := $(sources:%.cxx=.%.d)
ppdfiles  := siislp100.ppd siislp200.ppd siislp240.ppd siislp440.ppd \
	     siislp450.ppd siislp620.ppd siislp650.ppd siislppro.ppd
ppddir    := $(shell cups-config --datadir)/model/seiko
filterdir := $(shell cups-config --serverbin)/filter
cflags    := $(shell cups-config --ldflags --cflags)
ldflags   := $(shell cups-config --image --libs)

build: $(program) $(ppdfiles)

$(program): $(objects)
	$(CXX) -o $(program) $(cflags) $(objects) $(ldflags)

%.o: %.cxx
	$(CXX) $(cflags) -MD -MF .$*.d -c $*.cxx

$(ppdfiles): %.ppd: %.ppd.in
	sed -e 's%@@CUPS_FILTER@@%$(filterdir)/$(program)%' < $@.in > $@

install: $(filterdir)/$(program) $(patsubst %, $(ppddir)/%.gz, $(ppdfiles))

$(filterdir)/$(program): $(program)
	cp $(program) "$@"

$(ppddir)/%.gz: % | $(ppddir)
	gzip -9 -c $* > "$(ppddir)/$*.gz"

$(ppddir):
	mkdir -p "$(ppddir)"

uninstall:
	rm -rfv "$(ppddir)"
	rm -fv "$(filterdir)/$(program)"

clean:
	rm -f $(program) $(objects) *~
	rm -f *.gz
	rm -rf "$(mfdir)/pretty"

archive: clean
	rm -f "$(mfdir)/../SeikoSLPLinuxDriver.zip"
	ditto -c -k --keepParent "$(mfdir)" "$(mfdir)/../SeikoSLPLinuxDriver.zip"
	
test300:
	#test at 300 dpi
	lp -d SLP450 -o scaling=100 SLP2RL-300-outline.png

test203:
	#test at 203 dpi
	lp -d SLP240-430 -o scaling=100 SLP2RL-203-outline.png

pretty:
	# pretty up the source code files using bcpp.  (C++ compatible pretty printer.)
	mkdir "$(mfdir)/pretty"
	mv *.h "$(mfdir)/pretty/"
	mv *.cxx "$(mfdir)/pretty/"
	bcpp "$(mfdir)/pretty/SIISLPProcessBitmap.cxx" "$(mfdir)/SIISLPProcessBitmap.cxx"
	bcpp "$(mfdir)/pretty/SeikoSLPCommands.h" "$(mfdir)/SeikoSLPCommands.h"
	bcpp "$(mfdir)/pretty/SIISLPProcessBitmap.h" "$(mfdir)/SIISLPProcessBitmap.h"
	bcpp "$(mfdir)/pretty/RasterToSIISLP.h" "$(mfdir)/RasterToSIISLP.h"
	bcpp "$(mfdir)/pretty/DriverUtils.h" "$(mfdir)/DriverUtils.h"
	bcpp "$(mfdir)/pretty/RasterToSIISLP.cxx" "$(mfdir)/RasterToSIISLP.cxx"
	bcpp "$(mfdir)/pretty/DriverUtils.cxx" "$(mfdir)/DriverUtils.cxx"
	bcpp "$(mfdir)/pretty/SeikoInstrumentsVendorID.h" "$(mfdir)/SeikoInstrumentsVendorID.h"
	rm -rf "$(mfdir)/pretty"

-include $(depends)
	
#
# End of "$Id: makefile,v 1.6 Selznick$"
#
