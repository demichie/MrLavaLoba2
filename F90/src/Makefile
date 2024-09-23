# Define the compiler and flags
FC = gfortran
NETCDF = /opt/homebrew/Cellar/netcdf-fortran/4.6.1

FFLAGS_OBJ = -Ofast -funroll-all-loops -Wall -I$(NETCDF)/include -lnetcdff
FFLAGS = -Ofast -funroll-all-loops -Wall

# FFLAGS_OBJ = -g -ffpe-trap=zero,invalid,overflow,underflow -Ofast -funroll-all-loops -Wall -I$(NETCDF)/include -lnetcdff
# FFLAGS = -g -ffpe-trap=zero,invalid,overflow,underflow -Ofast -funroll-all-loops -Wall


# FFLAGS_OBJ = -O0 -funroll-all-loops -Wall -Wextra -fcheck=all -fimplicit-none -fbacktrace -I$(NETCDF)/include -lnetcdff
# FFLAGS = -O0 -funroll-all-loops -Wall -Wextra -fcheck=all -fimplicit-none -fbacktrace

FLIBS = -L$(NETCDF)/lib -lnetcdff  

# Define the sources and objects
SRC = parameters.f90 flow.f90 inpout.f90 mr_lava_loba.f90 
OBJ = $(SRC:.f90=.o)

# Define the executable name
EXEC = mr_lava_loba

# Default target: build the executable
all: $(EXEC)

# Rule to build the executable
$(EXEC): $(OBJ)
	$(FC) $(FFLAGS) $(FLIBS) -o $@ $(OBJ)

# Rule to build object files
%.o: %.f90
	$(FC) $(FFLAGS_OBJ) -c $< -o $@

# Clean up the build files
clean:
	rm -f $(OBJ) $(EXEC)

# Phony targets
.PHONY: all clean
