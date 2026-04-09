# Mr Lava Loba

Mr Lava Loba is a stochastic lava-flow simulation code available in two implementations:

- **Fortran** (`F90/`)
- **Python** (`PYTHON/`)

The model emplaces lava as a sequence of elliptical lobes over a digital elevation model (DEM).  
Its main inputs are:

- a **DEM** defining the computational domain
- one or more **eruption sources / vents**
- a set of parameters controlling flow lengthening, spreading, thickening, and total erupted volume

The repository includes both source code and ready-to-run example cases.

## Repository structure

```text
.
├── README.md
├── guide.md
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

## Quick installation

A complete Conda environment is provided in the repository root.

From the repository root:

```bash
conda env create -f environment_mr_lava_loba.yml
conda activate mr-lava-loba
```

Then verify that both Python and Fortran dependencies are available:

```bash
python -c "import numpy, scipy, pandas, numba, shapely, shapefile; print('Python dependencies OK')"
which gfortran
which nf-config
nf-config --fflags
nf-config --flibs
```

## Enable command-line launchers

The repository provides two launchers:

- `mr_lava_loba_f90`
- `mr_lava_loba_py`

To make them automatically available every time the Conda environment is activated, run:

```bash
conda activate mr-lava-loba
bash scripts/install_conda_hooks.sh
conda deactivate
conda activate mr-lava-loba
```

Then verify:

```bash
which mr_lava_loba_f90
which mr_lava_loba_py
```

To remove the hooks:

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

### Compile the code

```bash
cd F90/src
make clean
make
```

This builds the executable:

```text
mr_lava_loba
```

### Run a Fortran example

After compilation, move to an example directory and run:

```bash
cd F90/EXAMPLES/<case_directory>
mr_lava_loba_f90
```

The launcher runs the compiled binary from `F90/src/` while using the current example directory as the working directory.

## Python version

The Python source code is in:

```text
PYTHON/src
```

The example directories in `PYTHON/EXAMPLES/` are intended to contain the case-specific input files and datasets.

### Run a Python example

```bash
cd PYTHON/EXAMPLES/<case_directory>
mr_lava_loba_py
```

The launcher runs `PYTHON/src/mr_lava_loba.py` while using the current example directory as the working directory.

## Examples

Both implementations include example cases:

- `F90/EXAMPLES/`
- `PYTHON/EXAMPLES/`

These folders can be used to:

- test that the installation works correctly
- inspect the expected case structure
- compare the Fortran and Python workflows

A recommended first test is:

1. create and activate the Conda environment
2. install the Conda hooks
3. compile the Fortran code in `F90/src`
4. run one of the example cases in `F90/EXAMPLES`
5. run one of the example cases in `PYTHON/EXAMPLES`

## Model overview

Mr Lava Loba is a **stochastic lobe-based model**. The emplaced lava is represented as a set of elliptical lobes that are sequentially placed on the topography.

Very roughly:

- the **first lobe** is placed at the eruptive source
- subsequent lobes are generated from previously emplaced lobes
- the direction of propagation is influenced by the local slope and by user-defined stochastic parameters
- repeating many lobe chains produces the final deposit

This makes the code especially suitable for probabilistic lava-flow footprint simulations and hazard-oriented analyses.

## Parameters that matter most during calibration

Although the model exposes many input parameters, a small subset usually controls most of the behavior:

- `n_flows`: number of simulated lobe chains
- `min_n_lobes`, `max_n_lobes`: number of lobes per chain, strongly influencing runout
- `lobe_area`: characteristic size of each lobe
- `lobe_exponent`: tendency to form single chains versus branching patterns
- `max_slope_prob`: tendency to follow the steepest descent direction
- `thickening_parameter`: tendency to pile up versus spread laterally

In practice, calibration is usually performed by varying one parameter at a time and comparing the simulation output against known lava-flow deposits.

## Main outputs

The most important output rasters are:

- **full thickness map**: the complete simulated deposit
- **masked thickness map**: a filtered version of the deposit, usually more useful for visualization and comparison
- **hazard map**: a weighted flow-path frequency / relative hazard map highlighting the most persistently invaded corridors

In many practical applications, the masked thickness output is the most useful map for comparing the model footprint with real lava-flow outlines.

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

## More detailed documentation

For a longer introduction to the model, a more detailed explanation of the main parameters, the Fortran input file, and the interpretation of the outputs, see:

```text
guide.md
```

## License

Add the project license here.

## Citation

Add citation information here if the code is associated with a paper or software release.
