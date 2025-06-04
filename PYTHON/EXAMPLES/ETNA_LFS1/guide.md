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
