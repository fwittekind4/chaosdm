# ----------------------------------------------------- #
# Makefile for the Chaos game module for Quake II         #
#                                                       #
# Just type "make" to compile the                       #
#  - Chaos Game (game.so / game.dll)                      #
#                                                       #
# Dependencies:                                         #
# - None, but you need a Quake II to play.              #
#   While in theorie every one should work              #
#   Yamagi Quake II ist recommended.                    #
#                                                       #
# Platforms:                                            #
# - FreeBSD                                             #
# - Linux                                               #
# - Mac OS X                                            #
# - OpenBSD                                             #
# - Windows                                             # 
# ----------------------------------------------------- #

# Detect the OS
ifdef SystemRoot
OSTYPE := Windows
else
OSTYPE := $(shell uname -s)
endif
 
# Special case for MinGW
ifneq (,$(findstring MINGW,$(OSTYPE)))
OSTYPE := Windows
endif

# ----------

# Base CFLAGS. 
#
# -O2 are enough optimizations.
# 
# -fno-strict-aliasing since the source doesn't comply
#  with strict aliasing rules and it's next to impossible
#  to get it there...
#
# -fomit-frame-pointer since the framepointer is mostly
#  useless for debugging Quake II and slows things down.
#
# -g to build allways with debug symbols. Please do not
#  change this, since it's our only chance to debug this
#  crap when random crashes happen!
#
# -fPIC for position independend code.
#
# -MMD to generate header dependencies.
ifeq ($(OSTYPE), Darwin)
CFLAGS := -O2 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -g -fwrapv -arch i386 -arch x86_64
else
CFLAGS := -O2 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -g -MMD -fwrapv
endif

# ----------

# Base LDFLAGS.
ifeq ($(OSTYPE), Darwin)
LDFLAGS := -shared -arch i386 -arch x86_64 
else
LDFLAGS := -shared
endif

# ----------

# Builds everything
all: chaos

# ----------
 
# When make is invoked by "make VERBOSE=1" print
# the compiler and linker commands.

ifdef VERBOSE
Q :=
else
Q := @
endif

# ----------

# Phony targets
.PHONY : all clean chaos

# ----------
 
# Cleanup
clean:
	@echo "===> CLEAN"
	${Q}rm -Rf build release
 
# ----------

# The Chaos game
ifeq ($(OSTYPE), Windows)
chaos:
	@echo "===> Building game.dll"
	$(Q)mkdir -p release
	$(MAKE) release/game.dll

build/%.o: %.c
	@echo "===> CC $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<
else
chaos:
	@echo "===> Building game.so"
	$(Q)mkdir -p release
	$(MAKE) release/game.so

build/%.o: %.c
	@echo "===> CC $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<

release/game.so : CFLAGS += -fPIC
endif
 
# ----------

CHAOS_OBJS_ = \
	src/c_base.o \
	src/c_botai.o \
	src/c_botmisc.o \
	src/c_botnav.o \
	src/c_cam.o \
	src/c_item.o \
	src/c_weapon.o \
	src/g_cmds.o \
	src/g_combat.o \
	src/g_ctf.o \
	src/g_func.o \
	src/g_items.o \
	src/g_main.o \
	src/g_misc.o \
	src/g_phys.o \
	src/g_save.o \
	src/g_spawn.o \
	src/g_svcmds.o \
	src/g_target.o \
	src/g_trigger.o \
	src/g_utils.o \
	src/g_weapon.o \
	src/gslog.o \
	src/m_move.o \
	src/p_client.o \
	src/p_hud.o \
	src/p_menu.o \
	src/p_view.o \
	src/p_weapon.o \
	src/q_shared.o \
	src/stdlog.o

# ----------

# Rewrite pathes to our object directory
CHAOS_OBJS = $(patsubst %,build/%,$(CHAOS_OBJS_))

# ----------

# Generate header dependencies
CHAOS_DEPS= $(CHAOS:.o=.d)

# ----------

# Suck header dependencies in
-include $(CHAOS_DEPS)

# ----------

ifeq ($(OSTYPE), Windows)
release/game.dll : $(CHAOS_OBJS)
	@echo "===> LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $(CHAOS_OBJS)
release/game.dylib : $(CHAOS_OBJS)
	@echo "===> LD $@"
	${Q}$(CC) $(LDFLAGS) -o $@ $(CHAOS_OBJS)
else
release/game.so : $(CHAOS_OBJS)
	@echo "===> LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $(CHAOS_OBJS)
endif
 
# ----------
