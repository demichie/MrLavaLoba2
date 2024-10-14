To compile the code, first edit the Makefile file in the src folder, and change the path of the NETCDF library according to where is installed on your computer.
Then, you need to add the path of library also to your paths. In linux, for example, you wil do it in this way:

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/mattia/anaconda3/lib"

This assumes that the Netcdf library has been installed with anaconda.

Finally, from the src folder, compile the source with:

make

