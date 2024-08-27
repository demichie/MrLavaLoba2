# Define the compiler and flags
FC = gfortran
FFLAGS = -Ofast -funroll-all-loops -Wall

# Define the sources and objects
SRC = parameters.f90 flow.f90 inpout.f90 mr_lava_loba.f90 
OBJ = $(SRC:.f90=.o)

# Define the executable name
EXEC = mr_lava_loba

# Default target: build the executable
all: $(EXEC)

# Rule to build the executable
$(EXEC): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ)

# Rule to build object files
%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@

# Clean up the build files
clean:
	rm -f $(OBJ) $(EXEC)

# Phony targets
.PHONY: all clean
