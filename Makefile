# Makefile for mp3 plugin
ifeq ($(OS),Windows_NT)
    SUFFIX = dll
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        SUFFIX = dylib
        DEADBEEF_OSX = /Applications/DeaDBeeF.app
    else
        SUFFIX = so
    endif
endif

# plugin name
PLUGNAME=mp3

# compiler settings
CC=gcc
CXX=g++
STD=gnu99

CFLAGS += -fPIC -I /usr/local/include -Wall
CXXFLAGS += -fPIC -I /usr/local/include -Wall
ifeq ($(UNAME_S),Darwin)
    CFLAGS+=-I $(DEADBEEF_OSX)/Contents/Headers
    CXXFLAGS+=-I $(DEADBEEF_OSX)/Contents/Headers
endif
ifeq ($(DEBUG),1)
CFLAGS += -g -O0
CXXFLAGS += -g -O0
endif

PREFIX=/usr/local/lib/deadbeef
ifeq ($(UNAME_S),Darwin)
    PREFIX=$(DEADBEEF_OSX)/Contents/Resources
endif

# library selection
OBJS=$(PLUGNAME).o
ifneq ($(DISABLE_PKGCONFIG), 1)
	ifeq ($(shell pkg-config libmpg123 --validate && echo yes || echo no), yes)
		USE_LIBMPG123=1
		LIBS += $(shell pkg-config libmpg123 --libs)
		OBJS += mp3_mpg123.o
		CFLAGS +=-D USE_LIBMPG123
	endif

	ifeq ($(shell pkg-config mad --validate && echo yes || echo no), yes)
		USE_LIBMAD=1
		LIBS += $(shell pkg-config mad --libs)
		OBJS += mp3_mad.o
		CFLAGS += -D USE_LIBMAD
	endif
endif

# rules
$(PLUGNAME).$(SUFFIX): $(OBJS)
	$(CC) -std=$(STD) -shared $(CFLAGS) -o $(PLUGNAME).$(SUFFIX) $(OBJS) $(LIBS) $(LDFLAGS)

$(OBJS): %.o: %.c
	$(CC) -std=$(STD) -c $(CFLAGS)  $< -o $@ 

install:
	cp $(PLUGNAME).$(SUFFIX) $(PREFIX)

clean:
	rm -fv $(PLUGNAME).o $(PLUGNAME).$(SUFFIX)