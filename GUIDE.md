# Guide to Installing and Using the Mr Lava Loba Code

## 1. Introduction

Lava flows are one of the most destructive hazards associated with volcanic activity. Numerical models are therefore widely used to estimate possible inundation areas, support hazard assessment, and compare alternative eruptive scenarios.

**Mr Lava Loba** is a stochastic lava-flow model in which lava emplacement is represented through the sequential deposition of elliptical lobes over a digital elevation model (DEM). The code is available in two implementations:

- a **Python** version
- a **Fortran** version

This guide is intended as a **complete user guide**. It complements the repository `README.md`, which focuses on installation and quick-start usage.

## 2. The Mr Lava Loba approach

Numerical lava-flow codes are often divided into two broad families:

1. **deterministic models**, based on simplified physical equations
2. **stochastic models**, based on probabilistic propagation rules

Mr Lava Loba belongs to the second family.

The simulation requires at least:

- a **DEM**
- the location of one or more **eruptive sources / vents**

The DEM defines the computational domain and strongly controls the simulated flow paths, just as natural topography controls the propagation of real lava flows.

In Mr Lava Loba, the deposit is built through a sequence of elliptical lobes:

- the first lobe is placed at the source
- subsequent lobes are generated from previously emplaced lobes
- the position and orientation of each new lobe are influenced by the local slope and by user-defined stochastic parameters
- repeating many lobe chains produces the final lava-flow footprint and thickness distribution

In this sense, Mr Lava Loba directly constructs the **final deposit** rather than explicitly solving the full time-dependent fluid dynamics of the lava.

## 3. Python and Fortran versions

The project includes both:

- a **Python implementation**, useful for development, inspection, and flexible experimentation
- a **Fortran implementation**, designed for faster execution and large simulation campaigns

The repository structure is:

```text
.
├── README.md
├── guide.md
├── environment_mr_lava_loba.yml
├── bin/
├── scripts/
├── F90/
│   ├── src/
│   └── EXAMPLES/
└── PYTHON/
    ├── src/
    └── EXAMPLES/
```

The source code is separated from the example cases:

- `F90/src/` and `PYTHON/src/` contain the code
- `F90/EXAMPLES/` and `PYTHON/EXAMPLES/` contain case-specific inputs and datasets

## 4. Running the code

Detailed installation and launcher setup are described in `README.md`.

In short:

- compile the Fortran version in `F90/src/`
- run simulations from the example / case directory
- use the Python or Fortran launcher so that the current example directory remains the working directory

Typical commands are:

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

## 5. Main model inputs

The most important model inputs are:

- **DEM** (`source`)
- **vent / source geometry**
- **total erupted volume**
- **number of flows and lobes**
- **lobe size and thickness controls**
- **stochastic spreading controls**

Many parameters exist, but only a subset typically dominates calibration.

### 5.1 Core calibration parameters

The most useful parameters during calibration are usually:

- `n_flows`: number of lobe chains
- `min_n_lobes`, `max_n_lobes`: number of lobes per chain
- `lobe_area`: characteristic area of each lobe
- `thickness_ratio`: controls how lobe thickness varies along a chain
- `lobe_exponent`: controls branching versus single-chain propagation
- `max_slope_prob`: controls how strongly propagation follows the steepest descent direction
- `inertial_exponent`: controls inheritance of direction from the parent lobe
- `thickening_parameter`: controls the tendency to pile up versus spread laterally

### 5.2 Practical calibration logic

A useful practical rule is to vary one parameter at a time and inspect how the output changes.

Very roughly:

- increasing `max_n_lobes` tends to increase runout
- increasing `n_flows` usually increases the number of explored branches
- increasing `lobe_exponent` favors more branching
- increasing `max_slope_prob` produces more slope-controlled, channelized propagation
- decreasing `thickening_parameter` usually promotes more lateral spreading and less pile-up

## 6. Source-based geometry, vent_flag, and activation windows

### 6.1 Source-based architecture

In the current implementation, eruptive inputs are internally converted into a common **source-based representation**. The original input geometry may describe:

- isolated point vents
- a polyline defined by consecutive points
- a set of independent fissures defined by explicit start and end coordinates

During preprocessing, these input geometries are converted into the discrete source entities that the model actually samples. These entities are stored internally through `n_sources` and the source-coordinate arrays. This design separates the geometric description provided by the user from the discrete entities that are effectively selected when the first lobe location is generated.

The source entities are not always identical to the original input vents:

- for **point-vent configurations**, each source coincides with one vent
- for **polyline configurations**, each source is one segment between consecutive points
- for **independent-fissure configurations**, each source is one fissure

As a consequence, probability arrays and activation arrays must be dimensioned using the number of **sampled source entities**, not just the number of input coordinates.

### 6.2 Vent-flag overview

| `vent_flag` | Input geometry | Sampled source entity | `n_sources` | Selection rule | Activation windows |
|---|---|---:|---:|---|---|
| `0` | Point vents `x_vent(i), y_vent(i)` | Point sources | `n_vents` | Deterministic assignment over the active source set | Supported |
| `1` | Point vents `x_vent(i), y_vent(i)` | Point sources | `n_vents` | Uniform random choice among active point sources | Supported |
| `2` | Polyline defined by `n_vents` points | Consecutive segments | `n_vents - 1` | Length-weighted choice among active segments | Supported |
| `3` | Polyline defined by `n_vents` points | Consecutive segments | `n_vents - 1` | Uniform random choice among active segments | Supported |
| `4` | Independent fissures with start/end pairs | Independent fissures | `n_vents` | Length-weighted choice among active fissures | Supported |
| `5` | Independent fissures with start/end pairs | Independent fissures | `n_vents` | Uniform random choice among active fissures | Supported |
| `6` | Polyline defined by `n_vents` points | Consecutive segments | `n_vents - 1` | **User-defined probability choice among active segments** | Supported |
| `7` | Independent fissures with start/end pairs | Independent fissures | `n_vents` | User-defined probability choice among active fissures | Supported |
| `8` | Point vents `x_vent(i), y_vent(i)` | Point sources | `n_vents` | User-defined probability choice among active point sources | Supported |


### 6.3 Detailed behaviour by vent_flag

#### `vent_flag = 0`
A set of point vents. Each discrete source entity coincides with one vent. The active subset is first identified, then the flow index is mapped deterministically to one active source. Deterministic cycling therefore occurs over the active source set only.

#### `vent_flag = 1`
Also a point-vent configuration, but the source is selected randomly with uniform probability among the currently active point sources.

#### `vent_flag = 2`
The input coordinates define a polyline. The sampled source entities are the consecutive segments. Segment selection is weighted by segment length. The code samples only among the active segments, then samples a point uniformly along the chosen segment.

#### `vent_flag = 3`
Same polyline geometry as `2`, but all active segments are weighted uniformly. After selecting a segment, the emplacement point is sampled uniformly along that segment.

#### `vent_flag = 4`
Independent fissures are represented directly as source entities. Selection is weighted by fissure length, restricted to the active subset. The emplacement point is then sampled uniformly along the chosen fissure.

#### `vent_flag = 5`
Same independent-fissure geometry as `4`, but with uniform weights over the active fissures.

#### `vent_flag = 6`
The input coordinates define a polyline, and the sampled source entities are again the consecutive polyline segments. Unlike `2`, the relative probability of each segment is **provided directly by the user** through `source_probabilities`. During source selection, those probabilities are restricted to the currently active subset of segments, renormalized over that subset, and used to sample the active segment. After selecting the segment, the emplacement point is sampled uniformly along it.

#### `vent_flag = 7`
Independent fissures with user-defined probabilities. The source probabilities are restricted to the active fissures only, and the emplacement point is sampled uniformly along the selected fissure.

#### `vent_flag = 8`
Point vents with user-defined probabilities. The source probabilities are restricted to the active point vents only. No secondary sampling along a segment is needed because the sources are points.

### 6.4 Source activation windows

The current code supports optional **source activation windows** based on cumulative erupted volume.

The key quantity is:

```text
Vcum = cell * cell * SUM(Zflow)
```

Each source can be assigned a lower and upper activation bound:

```text
source_volume_from(i) <= Vcum < source_volume_to(i)
```

A source is considered active only when this condition is satisfied. If multiple sources are active at the same cumulative volume, the usual selection rule for the chosen `vent_flag` is applied only to that active subset. If no source is active, the code stops with an explicit error. The activation-window mechanism is described in the source-based technical summary. 


### 6.5 Input representation for activation windows

The activation feature is represented by two optional source-based arrays:

- `source_volume_from`
- `source_volume_to`

They must be dimensioned using the number of **sampled source entities** for the current geometry:

- one value per vent for point-source configurations
- one value per polyline segment for polyline configurations
- one value per fissure for independent-fissure configurations

If the arrays are omitted, the code preserves the historical behaviour by assigning:

- `source_volume_from = 0`
- `source_volume_to = total_volume`

so that all sources remain active for the entire simulation. The current input validation also checks that:

- the bounds are non-negative
- they do not exceed `total_volume`
- `source_volume_from <= source_volume_to` for every source

### 6.6 Example of activation windows

```text
source_volume_from = 0.0, 300000.0, 600000.0
source_volume_to   = 300000.0, 600000.0, 1000000.0
```

In this case:

- source 1 is active from the start until `Vcum = 300000`
- source 2 is active between `300000` and `600000`
- source 3 is active between `600000` and `1000000`

Overlapping windows are also allowed. When more than one source is active, the code applies the usual source-selection rule of the chosen `vent_flag` to the active subset only. 

## 7. Python input parameters

The Python version is typically configured through:

- `input_data.py`
- `input_data_advanced.py`

The following table summarizes the main parameters from the original user guide.

### 7.1 Main parameters in `input_data.py`

| Input parameter | Description |
|---|---|
| `run_name` | Root name assigned to all outputs and to the saved input backup files for a simulation. |
| `source` | ASCII file representing the DEM used as topographic input. |
| `vent_flag` | Defines the source geometry and source-selection mode. See the dedicated section above for the updated source-based interpretation. |
| `x_vent`, `y_vent` | Coordinates of the eruptive vents or polyline points, depending on `vent_flag`. |
| `east_to_vent`, `west_to_vent`, `south_to_vent`, `north_to_vent` | Distances used to crop the input DEM around the source area. |
| `hazard_flag` | If enabled, saves a raster map representing relative hazard / weighted flow-path persistence. |
| `masking_threshold` | Defines the fraction of invaded area or volume retained in masked outputs. |
| `n_flows` | Number of computational lobe chains. |
| `min_n_lobes`, `max_n_lobes` | Minimum and maximum number of lobes generated per flow. |
| `volume_flag` | Indicates whether the total erupted volume is provided as input. |
| `total_volume` | Total lava volume in cubic meters. |
| `fixed_dimension_flag` | Indicates whether lobe area or lobe thickness is treated as fixed. |
| `lobe_area` | Area of each lobe in square meters when area is fixed. |
| `avg_lobe_thickness` | Average lobe thickness when thickness is fixed. |
| `thickness_ratio` | Ratio controlling how lobe thickness varies along a chain. |
| `topo_mod_flag` | Controls whether emplacement modifies the topography during the simulation. |
| `n_flows_counter` | Number of flows after which the topography is updated, when flow-based updating is enabled. |
| `n_lobes_counter` | Number of lobes after which the topography is updated, when lobe-based updating is enabled. |
| `thickening_parameter` | Controls the tendency to pile up versus spread laterally. |
| `lobe_exponent` | Controls whether new lobes tend to originate from recent lobes or from any prior lobe. |
| `max_slope_prob` | Controls how strongly propagation follows the local steepest descent direction. |
| `inertial_exponent` | Controls how much the new-lobe direction inherits from the parent-lobe direction. |
| `union_diff_file` | Reference file used to compare the simulated footprint with another map or observed deposit. |

### 7.2 Practical note on calibration

In practice, many simulations can be calibrated mainly by acting on:

- `n_flows`
- `min_n_lobes`, `max_n_lobes`
- `lobe_area`
- `lobe_exponent`
- `max_slope_prob`
- `thickening_parameter`

The original user guide emphasizes that these are often the key parameters for tuning runout, spreading, and deposit thickness.

## 8. Fortran input file

The Fortran version is configured through a plain-text input file, typically named:

```text
mr_lava_loba.inp
```

It uses a **Fortran namelist** structure.

Typical sections include:

- `&RUN_PARAMETERS`
- `&UNION_DIFF_PARAMETERS`
- `&VENT_PARAMETERS`
- `&CROP_PARAMETERS`
- `&FLOW_PARAMETERS`
- `&NUMERICAL_PARAMETERS`

and, after the namelist blocks, a `MASKING_THRESHOLDS` section.

### 8.1 Main namelist parameters

| Namelist / parameter | Description |
|---|---|
| `RUN_NAME` | Base name for all output files. |
| `SOURCE` | Input DEM file in ASCII grid format. |
| `VENT_FLAG` | Source geometry / source-selection mode. See the dedicated section above for the source-based interpretation. |
| `CROP_FLAG` | Enables or disables DEM cropping. |
| `HAZARD_FLAG` | Enables or disables hazard-map output. |
| `VOLUME_FLAG` | Indicates whether the total erupted volume is provided. |
| `FIXED_DIMENSION_FLAG` | Indicates whether lobe dimensions are fixed. |
| `TOPO_MOD_FLAG` | Enables or disables topography modification during emplacement. |
| `RESTART_FLAG` | Enables restarting from a previous state. |
| `NC_FLAG` | Enables NetCDF outputs. |
| `ASC_FLAG` | Enables ASCII-grid outputs. |
| `UNION_DIFF_FLAG` | Enables comparison against a reference footprint / map. |
| `UNION_DIFF_FILE` | Reference file used for union / difference analysis. |
| `N_VENTS` | Number of vents or source points explicitly defined. |
| `X_VENT`, `Y_VENT` | Coordinates of the vents or source points. |
| `EAST_TO_VENT`, `WEST_TO_VENT`, `SOUTH_TO_VENT`, `NORTH_TO_VENT` | Distances defining the crop box around the source area. |
| `N_FLOWS` | Number of simulated lobe chains. |
| `MIN_N_LOBES`, `MAX_N_LOBES` | Minimum and maximum number of lobes per chain. |
| `TOTAL_VOLUME` | Total erupted volume in cubic meters. |
| `LOBE_AREA` | Area of each lobe. |
| `THICKNESS_RATIO` | Controls how thickness varies along a lobe chain. |
| `THICKENING_PARAMETER` | Controls pile-up versus lateral spreading. |
| `LOBE_EXPONENT` | Controls branching behaviour. |
| `MAX_SLOPE_PROB` | Controls the tendency to follow the steepest slope. |
| `INERTIAL_EXPONENT` | Controls directional inheritance from the parent lobe. |
| `ASPECT_RATIO_COEFF` | Controls how lobe aspect ratio varies with slope. |
| `MAX_ASPECT_RATIO` | Maximum allowed aspect ratio for a lobe. |
| `NPOINTS`, `NV` | Numerical parameters related to the geometric and integration discretization. |

### 8.2 `MASKING_THRESHOLDS`

After the namelist blocks, the input file may include a section such as:

```text
'MASKING_THRESHOLDS'
2
0.97
0.95
```

This indicates that the code should produce masked outputs using multiple thresholds in a single run.

## 9. Understanding the main outputs

The most important outputs are raster files describing deposit thickness or relative hazard.

### 9.1 Full thickness map

The full thickness map represents the complete simulated deposit.

It is built by accumulating the contribution of every lobe over the computational grid. This output is useful for mass-balance checks and for inspecting the full raw result of the simulation.

### 9.2 Masked thickness map

Stochastic simulations often generate a thin peripheral “halo” around the main deposit.  
The masked output removes the least significant part of the deposit, according to one or more masking thresholds.

In practice, the masked thickness map is often the most useful product for:

- visualization
- comparison with observed flow outlines
- hazard-oriented interpretation

### 9.3 Hazard map

The hazard map is not simply a final-thickness map.

Instead, it highlights the parts of the domain that are more persistently traversed by the simulated flows. It can be interpreted as a **relative flow-path frequency / hazard index**, emphasizing the main flow corridors.

In simple terms:

- the **thickness map** tells you where lava accumulates
- the **hazard map** tells you which paths are most repeatedly used by the simulated propagation

## 10. Suggested workflow for a new case

A practical workflow is:

1. prepare the DEM and source / vent information
2. copy an existing example case into a new case directory
3. modify the input parameters
4. run the model
5. inspect the full and masked thickness outputs
6. compare the footprint with observed or expected deposits
7. iteratively recalibrate the key parameters

## 11. Notes on the example directories

The example directories are intended to contain case-specific files such as:

- input files
- DEM rasters
- shapefiles or auxiliary geospatial data
- comparison rasters

The source code is intentionally kept separate in `src/` so that example directories remain clean working directories.

## 12. Troubleshooting notes

### Python launcher does not find the input files

The Python launcher must be executed from inside the desired example / case directory, because the case-specific files are expected there.

### Fortran code compiles but a run behaves unexpectedly

Check first:

- the DEM path
- the source / vent coordinates
- the crop settings
- whether the example directory contains all required inputs
- whether the chosen lobe size is consistent with the DEM cell size

### Repository moved after installing Conda hooks

If the repository directory is renamed or moved, re-run:

```bash
bash scripts/install_conda_hooks.sh
```

from the new repository location.
