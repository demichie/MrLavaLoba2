# Mr Lava Loba

Mr Lava Loba is a lava-flow simulation code available in two implementations:

- **Fortran** (`F90/`)
- **Python** (`PYTHON/`)

The repository also includes example cases for both versions.

## Repository structure

```text
.
├── README.md
├── environment_mr_lava_loba.yml
├── bin/
│   ├── mr_lava_loba_f90
│   └── mr_lava_loba_py
├── scripts/
│   ├── install_conda_hooks.sh
│   └── uninstall_conda_hooks.sh
├── F90/
│   ├── src/
│   │   ├── Makefile
│   │   ├── parameters.f90
│   │   ├── flow.f90
│   │   ├── inpout.f90
│   │   └── mr_lava_loba.f90
│   └── EXAMPLES/
└── PYTHON/
    ├── src/
    │   └── mr_lava_loba.py
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

After activating the environment, verify that both Python and Fortran dependencies are available:

```bash
python -c "import numpy, scipy, pandas, numba, shapely, shapefile; print('Python dependencies OK')"
which gfortran
which nf-config
nf-config --fflags
nf-config --flibs
```

## Install command-line launchers with Conda hooks

The repository provides two launchers:

- `mr_lava_loba_f90`
- `mr_lava_loba_py`

These can be made available automatically in your shell every time you run:

```bash
conda activate mr-lava-loba
```

### One-time setup

From the repository root:

```bash
conda activate mr-lava-loba
bash scripts/install_conda_hooks.sh
conda deactivate
conda activate mr-lava-loba
```

Then verify that the launchers are on your `PATH`:

```bash
which mr_lava_loba_f90
which mr_lava_loba_py
```

### Remove the hooks

If needed, you can remove the Conda hook setup with:

```bash
conda activate mr-lava-loba
bash scripts/uninstall_conda_hooks.sh
conda deactivate
conda activate mr-lava-loba
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
make clean
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

After the hooks are installed and the code is compiled, move to an example directory and run:

```bash
cd F90/EXAMPLES/<case_directory>
mr_lava_loba_f90
```

The launcher executes the compiled binary located in `F90/src/`, while using the current example directory as the working directory.

## Python version

The Python source code is in:

```text
PYTHON/src
```

The example directories in `PYTHON/EXAMPLES/` are intended to contain the case-specific input files and datasets.

### Run the Python version

After the hooks are installed, move to a Python example directory and run:

```bash
cd PYTHON/EXAMPLES/<case_directory>
mr_lava_loba_py
```

The launcher executes `PYTHON/src/mr_lava_loba.py`, while using the current example directory as the working directory.

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
2. install the Conda hooks
3. compile the Fortran code in `F90/src`
4. run one of the example cases in `F90/EXAMPLES`
5. run one of the example cases in `PYTHON/EXAMPLES`

## Suggested workflow

### Fortran

```bash
conda activate mr-lava-loba
cd F90/src
make clean
make
cd ../EXAMPLES/<case_directory>
mr_lava_loba_f90
```

### Python

```bash
conda activate mr-lava-loba
cd PYTHON/EXAMPLES/<case_directory>
mr_lava_loba_py
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

### The repository was moved after hook installation

If you rename or move the repository directory after running `install_conda_hooks.sh`, run the install script again from the new repository location.

## License

Add the project license here.

## Citation

Add citation information here if the code is associated with a paper or software release.
