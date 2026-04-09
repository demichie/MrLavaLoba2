FC ?= gfortran

NF_CONFIG := $(shell which nf-config 2>/dev/null)

ifeq ($(NF_CONFIG),)
$(error nf-config not found. Activate the conda environment with netcdf-fortran installed)
endif

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

BASE_FLAGS = -O3 -Wall
ARCH_FLAGS = -march=native
LTO_FLAGS = -flto

# Disable -flto on Apple Silicon
ifeq ($(UNAME_S),Darwin)
  ifeq ($(UNAME_M),arm64)
    LTO_FLAGS =
  endif
endif

FFLAGS_OBJ = $(BASE_FLAGS) $(ARCH_FLAGS) $(LTO_FLAGS) $(shell nf-config --fflags)
FFLAGS     = $(BASE_FLAGS) $(ARCH_FLAGS) $(LTO_FLAGS)
FLIBS      = $(shell nf-config --flibs)

SRC = parameters.f90 flow.f90 inpout.f90 mr_lava_loba.f90
OBJ = $(SRC:.f90=.o)

EXEC = mr_lava_loba

all: $(EXEC)

$(EXEC): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ) $(FLIBS)

%.o: %.f90
	$(FC) $(FFLAGS_OBJ) -c $< -o $@

clean:
	rm -f $(OBJ) $(EXEC)

.PHONY: all clean
