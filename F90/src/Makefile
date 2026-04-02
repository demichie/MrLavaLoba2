# Define the compiler and flags
FC = gfortran
NETCDF = /home/mattia/miniconda3/envs/fortran_env

#FFLAGS_OBJ = -Ofast -funroll-all-loops -Wall -I$(NETCDF)/include 
#FFLAGS = -Ofast -funroll-all-loops -Wall

FFLAGS_OBJ = -O3 -march=native -flto -Wall -I$(NETCDF)/include
FFLAGS     = -O3 -march=native -flto -Wall


#FFLAGS_OBJ = -O2 -pg -Wall -I$(NETCDF)/include
#FFLAGS     = -O2 -pg -Wall

FLIBS = -L$(NETCDF)/lib -lnetcdff -lnetcdf

# Define the sources and objects
SRC = parameters.f90 flow.f90 inpout.f90 mr_lava_loba.f90 
OBJ = $(SRC:.f90=.o)

# Define the executable name
EXEC = mr_lava_loba

# Default target: build the executable
all: $(EXEC)

# Rule to build the executable
$(EXEC): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ)  $(FLIBS)

# Rule to build object files
%.o: %.f90
	$(FC) $(FFLAGS_OBJ) -c $< -o $@ $(FLIBS) 

# Clean up the build files
clean:
	rm -f $(OBJ) $(EXEC)

# Phony targets
.PHONY: all clean
