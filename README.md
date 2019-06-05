# Parallel QIDA for OpenSees Navigator

By: Tianyang Joe Qiao 

作者：乔天扬


## Files

The program includes the following M files:

- IDASession.m
- QIDA_DefineIDASession.m
- QIDA_RunIDASession.m
- WriteTclFiles.p   (from OpenSees Navigator P-Code 2.5.8 Version)
- OpenSees.exe      (from OpenSees)


Please put the above files in your model directory and add the directory to MATLAB path.



## Quick Run

For a quick run, just put all the files in your model directory (together with your .mat file and your 'Groundmotions' folder), and run 'QIDA_DefineIDASession.m', and then run 'QIDA_RunIDASession.m'.



## Requirements

Please check the following requirements carefully:

1. MATLAB r2017a or later recommended

   (the code has been tested on MATLAB r2017a, r2019a)

2. MATLAB Parallel Computing Toolbox

3. OpenSees Navigator 2.5.8 P-Code

4. OpenSees (opensees.exe)

5. OpenSees Navigator model database (a .mat file)

Operating system: Windows



## Analysis cases

When modeling in OpenSees Navigator, **name of AnalysisCase** for IDA analyses should be named with a certain shared feature, i.e., a **unique string** is required in the names of the IDA analysis cases, for example:

The names of the analysis cases are:

- Gravity
- Pushover
- Cyclic1
- Cyclic2
- RSN101
- RSN243
- RSN450
- ......

The **unique string** is set as 'RSN'. The program will take RSN101, RSN243, RSN450 and run IDA analysis.



## Tutorial

1. Open `QIDA_DefineIDASession.m` and change the following constants:

   - Put your `opensees.exe` path at `DIR_OPENSEES`
   - Put your model directory at `DIR_MODEL`
   - Put the file name of your OSN model at `NAME_MODEL`
   - Put the scaling amplitude for IDA at `IDA_AMPLITUDES`
     - The `IDA_AMPLITUDES` should be a vector or a number
     - If `IDA_AMPLITUDES = 0.1:0.1:2`, the ground motions will be scaled 0.1x, 0.2x, 0.3x, ..., 2.0x for IDA analysis
     - If `IDA_AMPLITUDES = 1`, IDA mode is disabled, each ground motion will only run once.
     Example:

   ```matlab
   %% Define session and constants
   % ================================================================
   % ================================================================
   % Set Opensees.exe folder path
   % Don't include 'opensees.exe'!
   % Please use '\'
   DIR_OPENSEES = 'C:\Program Files\OpenSees_x64';
   
   % Set Opensees.exe folder path
   % Please use '\'
   DIR_MODEL = 'D:\Research\UBC MASc\Hybrid Simulation\OpenSees Model 190129';
   
   % Set Opensees.exe folder path
   NAME_MODEL = 'ORRRBH_190129.mat';
   
   % IDA amplitudes vector
   IDA_AMPLITUDES = 0.1:0.1:2;
   
   % ================================================================
   % ================================================================
   ```

   

2. Run `QIDA_DefineIDASession.m` in MATLAB, and check the printed information

   ```
   Successfully loaded the model! 
   Number of active ground motions: 14 
   Number of active IDA amplitudes: 20 
   Total number of jobs: 280 
   IDA session saved ... 
   ```

3. Open and run `QIDA_RunIDASession.m` in MATLAB, a parallel pool should be started.

   

## Properties

- dirModel:  directory of the OSN model .MAT file
- modelName:  name of the OSN model .MAT file
- ampsIDA: scaling amplitude vector for IDA analysis
- runOptions:  stores user defined options for IDA options and input infomation
  - parallelOptions: 
  - **IDAOptions**:  Stores detected AnalysisCase, TimeSeries and LoadPattern, with mappings
  - IDAon
  - activeGMs
  - activeAmps
  - nAmp
  - nGM
  - uniqueStr:   Unique string to detect IDA analysis cases
- paths
  - idaPath
  - tclPath
  - osPath
- inpModel:   the loaded OSN model file
  - Model
    - ...
  - Library
    - ...
  - UserDef
    - ...
- jobs:   worklist for IDA parallel computing
  - paths
  - pathNames



## Methods

- IDASession (initialization)
- load
- readAnalysisCase
- createDirs
- setOpenSeesPath
- writeTclFiles
- jobMat
- runIDA
- readOutput
