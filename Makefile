TARGET      ?= hocoslamfy-bb10

# Adjust this for your key if needed
TOKEN=~/Development/BlackBerry/keys/debug_token_all.bar

ifeq ($(TARGET), hocoslamfy-bb10)
  CC        := arm-unknown-nto-qnx8.0.0eabi-gcc
  STRIP     := arm-unknown-nto-qnx8.0.0eabi-strip
  OBJS       = platform/generic.o
  DEFS      := 
endif

SYSROOT	    := $(QNX_TARGET)/armle-v7
SDL_CFLAGS  := $(shell $(SYSROOT)/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/bin/sdl-config --libs)

OBJS        += main.o init.o title.o game.o score.o audio.o bg.o text.o unifont.o
              
HEADERS     += main.h init.h platform.h title.h game.h score.h audio.h bg.h text.h unifont.h

INCLUDE     := -I.
DEFS        +=

CFLAGS       = $(SDL_CFLAGS) -Wall -Wno-unused-variable \
               -O2 -fomit-frame-pointer $(DEFS) $(INCLUDE)
LDFLAGS     := $(SDL_LIBS) -lm -lSDL_image -lSDL_mixer

include Makefile.rules

.PHONY: all opk

all: $(TARGET)

$(TARGET): $(OBJS)

bar: $(TARGET).bar

$(TARGET).bar: $(TARGET)
	blackberry-nativepackager -package $(TARGET)-release.bar bar-descriptor-bb10.xml

bar-debug: $(TARGET)
	blackberry-nativepackager -devMode -debugToken $(TOKEN) -package $(TARGET)-debug.bar bar-descriptor-bb10.xml

opk: $(TARGET).opk

$(TARGET).opk: $(TARGET)
	$(SUM) "  OPK     $@"
	$(CMD)rm -rf .opk_data
	$(CMD)cp -r data .opk_data
	$(CMD)cp COPYRIGHT .opk_data/COPYRIGHT
	$(CMD)cp $< .opk_data/$(TARGET)
	$(CMD)$(STRIP) .opk_data/$(TARGET)
	$(CMD)mksquashfs .opk_data $@ -all-root -noappend -no-exports -no-xattrs -no-progress >/dev/null

# The two below declarations ensure that editing a .c file recompiles only that
# file, but editing a .h file recompiles everything.
# Courtesy of Maarten ter Huurne.

# Each object file depends on its corresponding source file.
$(C_OBJS): %.o: %.c

# Object files all depend on all the headers.
$(OBJS): $(HEADERS)
