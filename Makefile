## The OpenGL Extension Wrangler Library
## Copyright (C) 2003, 2002, Milan Ikits
## Copyright (C) 2002, Lev Povalahev
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without 
## modification, are permitted provided that the following conditions are met:
## 
## * Redistributions of source code must retain the above copyright notice, 
##   this list of conditions and the following disclaimer.
## * Redistributions in binary form must reproduce the above copyright notice, 
##   this list of conditions and the following disclaimer in the documentation 
##   and/or other materials provided with the distribution.
## * The name of the author may be used to endorse or promote products 
##   derived from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
## THE POSSIBILITY OF SUCH DAMAGE.

GLEW_DEST ?= /usr
GLEW_VERSION = 1.0.7

SYSTEM = $(strip $(shell uname -s))

ifeq ($(patsubst CYGWIN%,CYGWIN,$(SYSTEM)), CYGWIN)
CC = \gcc -mno-cygwin
LD = \gcc -mno-cygwin
NAME = glew32
DEFINE = -D'GLEW_STATIC'
BIN.LIBS = -Llib -lglut -l$(NAME) -lglu32 -lopengl32 
P.BIN = .exe
else
ifeq ($(patsubst Linux%,Linux,$(SYSTEM)), Linux)
CC = \gcc
LD = \ld
NAME = GLEW
BIN.LIBS = -Llib -L/usr/X11R6/lib -lglut -l$(NAME) -lGLU -lGL -lXmu -lX11
P.BIN =
else
$(error "Platform '$(SYSTEM)' not supported")
endif
endif

AR = \ar
INSTALL = \install
RM = \rm -f
LN = \ln -fs
ifeq ($(MAKECMDGOALS), debug)
OPT = -g
else
OPT = -O3 -fomit-frame-pointer
endif
INCLUDE = -Iinclude
CFLAGS = $(OPT) $(INCLUDE) $(DEFINE)

LIB.A = lib$(NAME).a
LIB.SO = lib$(NAME).so.$(GLEW_VERSION)
LIB.SO.LNK = lib$(NAME).so
LIB.SRCS = src/glew.c
LIB.OBJS = $(LIB.SRCS:.c=.o)

BIN = glewinfo$(P.BIN)
BIN.SRCS = src/glewinfo.c
BIN.OBJS = $(BIN.SRCS:.c=.o)

all: bin/$(BIN) lib/$(LIB.SO) 

lib/$(LIB.A): $(LIB.OBJS)
	$(AR) cr $@ $^

lib/$(LIB.SO): $(LIB.OBJS)
	$(LD) -shared -o $@ $^
	$(LN) $(LIB.SO) lib/$(LIB.SO.LNK)

bin/$(BIN): $(BIN.SRCS) lib/$(LIB.A)
	$(CC) $(CFLAGS) -o $@ $< $(BIN.LIBS)

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

install: all
	$(INSTALL) -d -m 755 $(GLEW_DEST)/include/GL
	$(INSTALL) -m 644 include/GL/glew.h include/GL/glxew.h $(GLEW_DEST)/include/GL
	$(INSTALL) -d -m 755 $(GLEW_DEST)/lib
	$(INSTALL) -s -m 755 lib/$(LIB.A) $(GLEW_DEST)/lib
	$(INSTALL) -s -m 755 lib/$(LIB.SO) $(GLEW_DEST)/lib
	$(LN) $(GLEW_DEST)/lib/$(LIB.SO) $(GLEW_DEST)/lib/$(LIB.SO.LNK)
	$(INSTALL) -d -m 755 $(GLEW_DEST)/bin
	$(INSTALL) -s -m 755 bin/$(BIN) $(GLEW_DEST)/bin

uninstall:
	$(RM) $(GLEW_DEST)/include/GL/glew.h $(GLEW_DEST)/include/GL/glxew.h
	$(RM) $(GLEW_DEST)/lib/$(LIB.SO.LNK) $(GLEW_DEST)/lib/$(LIB.SO)
	$(RM) $(GLEW_DEST)/bin/$(BIN)

clean:
	$(RM) $(LIB.OBJS) lib/$(LIB.A) lib/$(LIB.SO) lib/$(LIB.SO.LNK) \
	$(BIN.OBJS) bin/$(BIN)
