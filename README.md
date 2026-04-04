# Mr Lava Loba

Mr Lava Loba is a lava-flow simulation code available in two implementations:

- **Fortran** (`F90/`)
- **Python** (`PYTHON/`)

The repository also includes example cases for both versions.

## Repository structure

```text
.
├── environment_mr_lava_loba.yml
├── F90/
│   ├── src/
│   │   ├── Makefile
│   │   ├── parameters.f90
│   │   ├── flow.f90
│   │   ├── inpout.f90
│   │   └── mr_lava_loba.f90
│   └── EXAMPLES/
└── PYTHON/
    └── EXAMPLES/
```

## Requirements

The project uses:

- Python libraries for the Python implementation
- a Fortran compiler for the Fortran implementation
- NetCDF Fortran libraries for compiling the Fortran code

A complete Conda environment is provided in the repository root.

## Create the Conda environment

From the repository root:

```bash
conda env create -f environment_mr_lava_loba.yml
conda activate mr-lava-loba
```

## Check the installation

After activating the environment, you can verify that both Python and Fortran dependencies are available:

```bash
python -c "import numpy, scipy, pandas, numba, shapely, shapefile; print('Python dependencies OK')"
which gfortran
which nf-config
nf-config --fflags
nf-config --flibs
```

## Fortran version

The Fortran source code is in:

```text
F90/src
```

### Compile the Fortran code

Move to the source directory and run:

```bash
cd F90/src
make
```

This will build the executable:

```text
mr_lava_loba
```

### Notes on the Makefile

The `Makefile` is expected to use `nf-config` to retrieve the correct NetCDF include and link flags from the active Conda environment.

A typical workflow is:

```bash
conda activate mr-lava-loba
cd F90/src
make clean
make
```

### macOS / Apple Silicon note

On Apple Silicon (`arm64`), `-flto` may fail with an error involving `lto1`. If this happens, disable `-flto` in the `Makefile`, or use a `Makefile` that automatically disables it on `Darwin arm64`.

A warning such as:

```text
ld: warning: duplicate -rpath '.../lib' ignored
```

is usually harmless and does not prevent successful compilation.

### Run the Fortran version

Run the executable from a case directory containing the required input files, for example from one of the example folders:

```bash
/path/to/F90/src/mr_lava_loba
```

or copy/link the executable into the working directory.

## Python version

The Python implementation is located in the `PYTHON/` directory.

### Run the Python code

Activate the Conda environment, move to the Python case directory, and run the main script:

```bash
cd PYTHON
python mr_lava_loba.py
```

If your workflow uses specific input files or case directories, run the script from the corresponding example folder or copy the required input files there.

## Examples

Both implementations include example cases:

- `F90/EXAMPLES/`
- `PYTHON/EXAMPLES/`

These folders can be used to:

- test that the installation works correctly
- inspect the expected input-file structure
- compare the Fortran and Python workflows

A recommended first test is:

1. create and activate the Conda environment
2. compile the Fortran code in `F90/src`
3. run one of the example cases in `F90/EXAMPLES`
4. run one of the example cases in `PYTHON/EXAMPLES`

## Suggested workflow

### Fortran

```bash
conda activate mr-lava-loba
cd F90/src
make clean
make
```

Then move to an example directory and run the executable.

### Python

```bash
conda activate mr-lava-loba
cd PYTHON
python mr_lava_loba.py
```

## Troubleshooting

### `nf-config not found`

Make sure the Conda environment is activated:

```bash
conda activate mr-lava-loba
```

and verify that `netcdf-fortran` is installed.

### `cannot execute 'lto1'`

This is typically related to `-flto` in the Fortran build flags, especially on macOS Apple Silicon. Remove `-flto` from the `Makefile` or disable it conditionally for `Darwin arm64`.

### NetCDF library not found at runtime

In most Conda-based setups this is handled automatically by the environment. If needed, make sure you are running inside the activated environment.

## License

Add the project license here.

## Citation

Add citation information here if the code is associated with a paper or software release.
