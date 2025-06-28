# Guide to Installing and Using the MrLavaLoba Code

## 1. Introduction

Lava flows represent one of the most destructive hazards associated with volcanic activity, capable of causing the loss of infrastructure, homes, and occasionally human lives. At active volcanoes, it is therefore crucial to identify areas that could potentially be inundated by future lava flows. For this reason, several numerical codes have been developed in recent decades to simulate lava emplacement. These codes allow for the estimation of areas potentially affected by lava flows, enabling the creation of hazard maps or providing forecasts in the event of future eruptions.

Some of these numerical models are freely available online, such as **Q-Lavha** (Mossoux et al., 2016) and **MrLavaLoba** (de’ Michieli Vitturi and Tarquini, 2018). In this guide, we provide a step-by-step tutorial on how to use the latter model, specifically its Python version, on a Windows computer (via the Windows Subsystem for Linux) or a native Linux system.

## 2. The MrLavaLoba Code

Numerical codes for lava flow simulation are generally divided into two categories: (i) deterministic models based on simplified physical equations governing the natural phenomenon, and (ii) stochastic models based on the principle that gravity-driven flows tend, as a first approximation, to follow the path of steepest descent. **MrLavaLoba** belongs to the family of stochastic codes and is suitable for simulating any type of lava flow, such as *pāhoehoe* or *‘a‘ā* (de’ Michieli Vitturi and Tarquini, 2018).

As with any lava flow simulation code, **MrLavaLoba** requires as input data a digital elevation model (DEM) and the location of the eruptive vent(s). The DEM represents the computational domain over which the simulation takes place. The volcano's topography strongly influences the downhill propagation of real lava flows, and a similar relationship holds between the digital topography (i.e., the DEM) and the outcome of lava flow numerical simulations (Favalli et al., JGR 2009).

In **MrLavaLoba**, emplaced lava is represented by elliptical lobes of predefined size (area). The simulation proceeds by iteratively placing new lobes in their final position on the computational domain. In this sense, **MrLavaLoba** directly builds the final deposit of the lava flow. The first lava lobe is placed on the eruptive vent, taking into account the local slope. The simulation of the lava flow then propagates as subsequent lobes are iteratively positioned on the topography adjacent to an already settled lobe (the "parent lobe"), with the position and orientation of the new lobe roughly following the direction of steepest descent. This process forms a series of settled lobes, creating a chain or cluster extending downslope from the vent.

The choice of the parent lobe from which a new lobe originates is probabilistic and influenced by a specific input parameter. Another input parameter controls the degree to which the direction of propagation can deviate (again, probabilistically) from the strict steepest descent path. The number of lobes that can be sequentially connected to the first lobe positioned at the eruptive vent is also defined as an input parameter. Once this number is reached, the simulation restarts by placing a new lobe at the eruptive vent, and the process repeats. This cycle continues until the total volume of lava (another specific input parameter) is emplaced on the topography.

Besides those described above, other input parameters describe specific aspects that influence the simulation's evolution, such as the extent to which settled lobes alter the pre-eruption topography. It's important to remember that the definition of all these input parameters determines the emplacement "style" of the lava flow, for example, the maximum distance reached, the spreading, and consequently, the final thickness of the deposit. Setting these parameters is referred to as calibrating the simulation to the scenario under consideration. In practice, when addressing a specific scenario for the first time, an initial calibration phase is carried out by iteratively varying the input parameters. After each run, the output is compared with lava deposits from previous eruptions. Once a satisfactory agreement is achieved between the simulation output and the real deposit, the model's calibration phase for the given scenario is considered complete.

## 3. Using the Code: Python and Fortran Versions

The **MrLavaLoba** code was originally written in Python (de’ Michieli Vitturi and Tarquini, 2018). Python offers several advantages: it is currently widely used, and Python interpreters are freely available for common operating systems, including Windows, macOS, Linux, and Android. However, Python is generally slower for computationally intensive tasks compared to compiled languages like C++ and Fortran.

To overcome this limitation, the **MrLavaLoba** code was also rewritten in FORTRAN 90. A popular, free Fortran 90 compiler, gfortran, is readily available for Linux. While Fortran compilers exist for Windows, their setup might be less straightforward for some users. Additionally, the Python version itself has been significantly optimized, resulting in a speed increase of approximately fivefold compared to its original version.

This guide will focus on the Python version. To streamline the explanation for both Windows and native Linux users, we will demonstrate its usage within a Linux environment. For Windows users, we will first show how to install a Linux subsystem.

### 3.1. Installing Linux on Windows 10/11 (Windows Subsystem for Linux - WSL)

The following procedure allows for the installation of the Windows Subsystem for Linux (WSL) and the Ubuntu Linux distribution. This setup enables the use of Linux applications and command-line tools directly within Windows.

**Prerequisites:**
*   A licensed copy of Windows 10 version 2004 (or later) or Windows 11.

**Steps:**

#### i) Install Windows Subsystem for Linux (WSL)
1.  Open the Run dialog by pressing the `❖ Win` + `R` keys simultaneously.
2.  Type `PowerShell`. To open it in administrator mode, press `Ctrl` + `Shift` + `Enter`. Confirm any User Account Control prompts.
3.  In the PowerShell window, type the following command and press `Enter`:
    ```bash
    wsl --install
    ```
4.  Once the process is complete, restart your PC.

#### ii) Set up Ubuntu
1.  By default, the Linux distribution installed with the command above is usually Ubuntu. Upon restarting your PC, a WSL terminal window running Ubuntu should open automatically.
2.  If this does not happen, open the Microsoft Store, search for "Ubuntu," and install it like any other application. Once installed, launch the Ubuntu application.
3.  When Ubuntu starts for the first time, you will be prompted to set up a username and password for your Linux account. Enter your desired credentials and press `Enter`. Remember these credentials.

You now have a Linux (Ubuntu) environment running on your Windows machine. All subsequent Linux commands in this guide should be run in the Ubuntu terminal.

### 3.2. Setting up MrLavaLoba (Python version)

The Python version of **MrLavaLoba** doesn't have a traditional installer. Instead, you'll download the source code and run it within a Python environment after installing necessary dependencies. We'll use Anaconda to manage Python and its packages.

#### i) Install Anaconda (Python Distribution)
1.  Open your Ubuntu terminal (if not already open).
2.  Download the Anaconda installer script for Linux. You can find the latest version on the [Anaconda website](https://www.anaconda.com/products/distribution). For example:
    ```bash
    wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
    ```
    > *(Note: Replace `Anaconda3-2023.09-0-Linux-x86_64.sh` with the latest version if different.)*
3.  Make the installation script executable:
    ```bash
    chmod +x Anaconda3-2023.09-0-Linux-x86_64.sh
    ```
4.  Run the Anaconda installation script:
    ```bash
    ./Anaconda3-2023.09-0-Linux-x86_64.sh
    ```
    Follow the on-screen prompts. It's generally recommended to accept the default settings, including allowing the installer to initialize Anaconda3 by running `conda init`.
5.  Close and reopen your Ubuntu terminal for the changes to take effect. You should see `(base)` at the beginning of your command prompt, indicating that Anaconda's base environment is active.

#### ii) Create a Conda Virtual Environment
When working with Python projects, it's good practice to create isolated virtual environments for each project to manage dependencies.
1.  Create a new virtual environment for Python 3.10 (or another compatible version) named "MrLavaLoba":
    ```bash
    conda create -n MrLavaLoba python=3.10
    ```
    Confirm by typing `y` when prompted.
2.  Activate the virtual environment:
    ```bash
    conda activate MrLavaLoba
    ```
    Your command prompt should now start with `(MrLavaLoba)`. All subsequent Python-related commands will be executed within this environment.

#### iii) Download MrLavaLoba Source Code
1.  Download the source code from GitHub:
    ```bash
    wget https://github.com/demichie/MrLavaLoba2/archive/refs/heads/main.zip
    ```
2.  Unzip the downloaded file:
    ```bash
    unzip main.zip
    ```
    This will create a folder named `MrLavaLoba2-main` (or similar, depending on the branch name).

#### iv) Navigate and Prepare an Example Case
Linux commands for navigation:
*   `ls`: Lists files and directories in the current directory.
*   `cd directory_name`: Changes to the specified directory.
*   `cd ..`: Moves one directory up.

1.  Navigate into the example directory provided with the code. For instance, the Etna example:
    ```bash
    cd MrLavaLoba2-main/PYTHON/EXAMPLES/ETNA_LFS1/
    ```
    You can use `ls` here to view the files. The main Python script is `mr_lava_loba.py`.

2.  It's best to create a separate folder for each new simulation or case study. To do this, first navigate out of the `ETNA_LFS1` directory (e.g., `cd ../` to go up to the `EXAMPLES` directory) and then copy the entire `ETNA_LFS1` folder to a new folder:
    ```bash
    cp -r ETNA_LFS1/ MY_NEW_SIMULATION_FOLDER
    cd MY_NEW_SIMULATION_FOLDER/
    ```
    Replace `MY_NEW_SIMULATION_FOLDER` with your desired name.

#### v) Understanding the Example Files
The `ETNA_LFS1` (or your copied) folder contains:
*   `input_data.py`: Python script containing basic settings and parameters used as input for the lava flow simulation. **This is the primary file you will modify for new simulations.**
*   `input_data_advance.py`: Python script with more advanced and specific input parameters for refined calibration.
*   `mr_lava_loba.py`: The main script containing the core logic for executing the lava flow simulation.
*   `shapefile.py`: Python script with functions for handling shapefiles (a geospatial vector data format).
*   `tinit_33.asc`: A Digital Elevation Model (DEM) file for the Etna volcano at 10m resolution (Tarquini et al., 2007), in ASCII grid format.
*   `union_diff.py`: Python script with functions for comparing geospatial data, enabling evaluation of simulation results.

#### vi) Install Required Python Libraries
Within your activated `MrLavaLoba` conda environment, install the necessary Python libraries:
```bash
conda install pandas scipy numba
```

### 3.3. Input Parameters and Code Calibration

Running the MrLavaLoba code requires configuration of the input files.

Table 1 illustrates the basic input parameters contained in the `input_data.py` file, which allows the user to manage the output of a simulation. Some of these parameters are very basic and intuitive, such as the **run_name**, the **source** (i.e., the DEM of the volcano), the coordinates of the **vent**, and the **total_volume** (i.e., the amount of erupted lava). It is easy to imagine that similar parameters can be common to almost any other lava flow simulation code. Other parameters, on the other hand, are specific to the MrLavaLoba code and depend on the algorithms and unique emplacement strategies it implements. It is noteworthy to remember that the code calibration mentioned above is essentially performed by modifying the values of the MrLavaLoba-specific parameters set in this file. Table 1 describes all the input parameters in detail.

However, it may be useful to briefly recall the main parameters that need to be tuned during the calibration process:
*   The parameter **n_flows** defines the number of computational lobe chains.
*   The two parameters **min_n_lobes** and **max_n_lobes** set the number of lobes within each lobe chain. As a result, **n_flows** combined with **min_n_lobes** and **max_n_lobes** determines the total number of lobes into which the discharged lava is distributed.
*   If **volume_flag** and **fixed_dimension_flag** are set to `1`, the area of the computational lobes is constant (set by the **lobe_area** parameter), and then the thickness of each lobe is also known if the parameter **thickness_ratio** is also set to `1`.
*   The parameter **max_n_lobes** provides an estimation of the lava flow runout, the latter being approximately given by **max_n_lobes** times the length of one lobe. We also remind you that the geometry of the lobe is provided by **lobe_area** plus other parameters set in the `advanced_input_data.py` file.

The above may look like a somewhat complicated layout of settings, but, as a matter of fact, many parameter values can be taken as constant to default values. As for the above-mentioned parameters, the key values for calibration are essentially **n_flows**, and **min_n_lobes** / **max_n_lobes**.

While the above parameters deal with the lava flow runout, other parameters rule the spreading vs. lengthening of the flow, and its thickening:
*   **lobe_exponent** determines if lobe chains extend steadily downflow (promoting lengthening) or instead branch laterally, creating bunches (promoting spreading).
*   **max_slope_prob**, instead, determines how closely the propagation of the lobe chains downhill follows the steepest descent path.
*   The **thickening_parameter** rules the propensity of the lobe chains to pile up (promoting thickening) or instead to spread laterally.

As a rule of thumb, it is recommended to vary one parameter at a time and then check the results, in order to understand the effect of the selected parameter change.

**Table 1 – Input parameters from the `input_data.py` file.**

| Input Parameter        | Description                                                                                                                                                                                                                                                                                                                        |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `run_name`             | This text defines the common root name assigned to all simulation outputs, as well as to all inputs automatically saved at the end of each simulation. This name is therefore used to uniquely identify the inputs and outputs of a given simulation. The code adds a suffix-counter to the root name “run_name” to distinguish different repetitions of the same simulation. |
| `source`               | Specifies the ASCII file representing the Digital Elevation Model (DEM), used as the topographic input for the simulation.                                                                                                                                                                                                         |
| `vent_flag`            | Defines 4 different initial conditions for the eruptive vents and their coordinates:<br>• `vent_flag = 0` → The initial lobes are located exactly at the coordinates of the vents, and the flow starts procedurally from the first to the last vent.<br>• `vent_flag = 1` → The eruptive vent from which the initial lobes emerge is randomly selected from a set of vents, each with equal probability.<br>• `vent_flag = 2` → The flow starts from any point along a polyline connecting two vents. Each point along the polyline has equal probability. This allows simulating scenarios where lava may emerge not only from main emission points but also from fractures.<br>• `vent_flag = 3` → There is not a single polyline but multiple segments, each with the same probability. |
| `x_vent` <br> `y_vent`   | Defines the coordinates of the eruptive vents. Depending on the `vent_flag` value, the coordinates to be entered will differ:<br>• If `vent_flag = 0` or `1` → specify one or more vent positions:<br>  `x_vent = [“x coordinate”]`<br>  `y_vent = [“y coordinate”]`<br>• If `vent_flag = 2` → specify start and end of the polyline:<br>  `x_vent = [“initial x”, “final x”]`<br>  `y_vent = [“initial y”, “final y”]`<br>• If `vent_flag = 3` → indicate the presence of multiple segments using:<br>  `x_vent = [“initial x”, “0”]`<br>  `y_vent = [“initial y”, “0”]` |
| `east_to_vent` <br> `west_to_vent` <br> `south_to_vent` <br> `north_to_vent` | The four values (in meters) define a box around the vent used to crop the input DEM. This cropped DEM is used during the simulation. A smaller DEM allows faster execution. Two things must be ensured: the box must not exceed the original DEM, and the simulated flow must not reach the edge of the cropped DEM. |
| `hazard_flag`          | If set to `1`, a raster map is saved representing the probability of each cell being covered by the flow.                                                                                                                                                                                                                            |
| `masking_threshold`    | By convention, this parameter is set to `0.95` and defines the fraction of the invaded area or volume that is actually saved in the output file `run_name_thickness_masked_0_95.asc`. This filters out areas with very low thickness or probability without compromising output quality.<br>*Note: along with the masked file, an unfiltered output file is also created.* |
| `n_flows`              | Specifies the number of computational “lobe chains” to simulate.                                                                                                                                                                                                                                                                     |
| `min_n_lobes`          | Defines the minimum number of lobes generated per flow. The number of lobes forming chains influences the resulting runout.                                                                                                                                                                                                    |
| `max_n_lobes`          | Defines the maximum number of lobes generated per flow.                                                                                                                                                                                                                                                                              |
| `volume_flag`          | When set to `1`, this parameter indicates that the total lava volume is provided as input.                                                                                                                                                                                                                                          |
| `total_volume`         | Specifies the total lava flow volume in cubic meters.                                                                                                                                                                                                                                                                              |
| `fixed_dimension_flag` | This parameter indicates which dimension of the lobe is fixed:<br>• If `fixed_dimension_flag = 1` → the lobe area is fixed<br>• If `fixed_dimension_flag = 2` → the lobe thickness is fixed                                                                                                                                            |
| `lobe_area`            | Determines the area of each lobe in square meters (valid when `volume_flag = 0` or `fixed_dimension_flag = 1`).                                                                                                                                                                                                                      |
| `avg_lobe_thickness`   | Defines the thickness of each lobe (valid only when `volume_flag = 0` or `fixed_dimension_flag = 2`).                                                                                                                                                                                                                             |
| `thickness_ratio`      | Defines the ratio between the thickness of the first and the last lobe in a flow:<br>• If `thickness_ratio = 1` → all lobes have the same thickness<br>• If `thickness_ratio < 1` → thickness increases with the number of lobes<br>• If `thickness_ratio > 1` → thickness decreases with the number of lobes                               |
| `topo_mod_flag`        | This parameter indicates whether the emplacement of new lobes modifies the topography, and thus whether the slope is altered (affecting subsequent flows):<br>• If `topo_mod_flag = 0` → the slope does not change<br>• If `topo_mod_flag = 1` → the slope changes every time a new flow is generated<br>• If `topo_mod_flag = 2` → the slope changes every time a lobe and a new flow are generated |
| `n_flows_counter`      | Defines the number of flows after which the topography and slope are modified. Valid only when `topo_mod_flag = 1`.                                                                                                                                                                                                                 |
| `n_lobes_counter`      | Defines the number of lobes after which the topography and slope are modified. Valid only when `topo_mod_flag = 2`.                                                                                                                                                                                                                 |
| `thickening_parameter` | Parameter ranging from `0` to `1` that controls the degree of flow thickening, while simultaneously modifying topography and slope. The lower the value of the thickening parameter, the greater the lateral spread of the flow and the lower the final lava deposit thickness.                                                       |
| `lobe_exponent`        | Influences the likelihood that a new lobe is generated from a young or old parent lobe. This parameter ranges from `0` to `1`. The closer it is to `0`, the higher the probability that new lobes will originate from a recently formed lobe.<br>This means that:<br>• If `lobe_exponent = 0`, the next lobe will form only from the most recently generated lobe, resulting in a single-chain formation.<br>• If `lobe_exponent = 1`, the next lobe will form from any previously formed lobe with equal probability. In this case, overlapping between lobes and flow dispersion increase, producing multiple branches. |
| `max_slope_prob`       | Controls the probability that the direction of a new lobe is aligned with the steepest slope direction. This parameter ranges from `0` to `1`:<br>• If `max_slope_prob = 0`, all directions have the same probability and the direction of maximum slope is not favored, resulting in greater areal dispersion.<br>• If `max_slope_prob = 1`, the new lobe direction always follows the steepest slope, favoring highly channeled lava flows along narrow paths. |
| `inertial_exponent`    | Parameter that controls how much the propagation direction of a new lobe inherits from its parent lobe. It ranges from `0` to `1`:<br>• If `inertial_exponent = 0` → the most probable direction is that of the steepest slope<br>• If `inertial_exponent > 0` → the direction also takes into account the orientation of the parent lobe |
| `union_diff_file`      | Command that runs the executable file calculating the difference between the area invaded by flows from a specific simulation and the area covered by any other simulation (or the real lava flow area, as in this case). This file can be used to compare results from different simulations or to assess model result convergence. Notice that running this command implies the availability of the ASC file representing the real lava flow deposit. |


## 5. Installing and Running the Fortran Version

For users seeking maximum performance, particularly for large or numerous simulations, a Fortran version of MrLavaLoba is available. This version is significantly faster than the Python version but requires a manual compilation step.

The following instructions are for a Linux environment (including WSL on Windows).

### 5.1. Compilation Steps

#### Step 1: Install a Fortran Compiler and NetCDF Library

The compilation requires a Fortran compiler (`gfortran`) and the NetCDF library for Fortran, which is used for handling scientific data formats. The easiest way to install both is using Conda, preferably within the same environment you created for the Python version.

1.  Activate your conda environment (if not already active):
    ```bash
    conda activate MrLavaLoba
    ```

2.  Install `gfortran` and `netcdf-fortran` from the `conda-forge` channel:
    ```bash
    conda install conda-forge::gfortran
    conda install conda-forge::netcdf-fortran
    ```

#### Step 2: Locate the NetCDF Library Path

The compiler needs to know where the NetCDF library files are located. You must find the path to your active conda environment's library directory.

1.  If you are unsure of the exact path, you can list your conda environments:
    ```bash
    conda info --envs
    ```
    The output will show the path to your `MrLavaLoba` environment. It will look something like this:
    ```
    # conda environments:
    #
    base                     /home/user/anaconda3
    MrLavaLoba            *  /home/user/anaconda3/envs/MrLavaLoba
    ```

2.  The library path you need is the environment path plus `/lib`. Based on the example above, the path would be:
    `/home/user/anaconda3/envs/MrLavaLoba/lib`

    > **Note:** If you installed the packages in your `base` conda environment, the path would be `/home/user/anaconda3/lib`. It is highly recommended to use a dedicated environment.

#### Step 3: Edit the Makefile

The `Makefile` is a script that contains instructions for the `make` command to compile the source code. You need to edit it to point to the NetCDF library path you found in the previous step.

1.  Navigate to the Fortran source code directory:
    ```bash
    cd MrLavaLoba2-main/FORTRAN/src/
    ```

2.  Open the `Makefile` with a text editor (e.g., `nano`):
    ```bash
    nano Makefile
    ```

3.  Inside the file, look for a variable that defines the NetCDF path. It might be named `NETCDF_PATH`, `NETCDF`, or similar. You need to change its value to the full path of your conda environment. For example, you might change a line like:
    
    `NETCDF = /usr/local/netcdf`
    
    to:
    
    `NETCDF = /home/user/anaconda3/envs/MrLavaLoba`
    
    **Important:** Make sure the path points to the main directory of the environment (e.g., `/.../MrLavaLoba`), not the `lib` sub-directory, as the Makefile will likely add `/lib` and `/include` itself. Check the Makefile's syntax to be sure. Save the file and exit the editor.

#### Step 4: Set the Library Path Environment Variable

Before compiling, you must also tell your system where to find the shared libraries at runtime. You do this by setting the `LD_LIBRARY_PATH` environment variable.

1.  In your terminal, run the following command, replacing the example path with your actual library path from Step 2:
    ```bash
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/user/anaconda3/envs/MrLavaLoba/lib"
    ```

    > This command is temporary and only applies to your current terminal session. If you close the terminal, you will need to run it again before executing the compiled code.

#### Step 5: Compile the Code

Now you are ready to compile.

1.  Ensure you are still in the `MrLavaLoba2-main/FORTRAN/src/` directory.
2.  Run the `make` command:
    ```bash
    make
    ```
    If all steps were done correctly, the compilation will proceed without errors. An executable file (e.g., `mr_lava_loba.x`) will be created in the `src` directory or a parent directory.

### 5.2. Running a Fortran Simulation

Unlike the Python version, you run the compiled executable directly from the command line.

1.  The Fortran version will likely require an input file, similar to the `input_data.py` file but in a simple text format. Check the `FORTRAN/EXAMPLES` directory for examples of how to structure this input file.
2.  To run a simulation, you would typically execute a command like:
    ```bash
    ./mr_lava_loba.x name_of_your_input_file.txt
    ```
    (The exact command and executable name may vary. Refer to the specific examples provided with the Fortran code.)

Remember to set the `LD_LIBRARY_PATH` (Step 4) in any new terminal session before running the executable.
