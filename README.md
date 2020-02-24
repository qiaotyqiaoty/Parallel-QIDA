# Parallel QIDA for OpenSees Navigator

By: Tianyang Joe Qiao 

作者：乔天扬

For a quick trial, download all and run `QIDA_Run.m` in MATLAB.


## Important files

See `sample` for all codes.

This program includes the following important files:

- IDASession.m      (for class definition of IDA Session)
- QIDA_Run.m        (setup and run this to quickly run IDA)
- OpenSees.exe      (OpenSees version 2.5)
- OpenSeesNavigator-pcode-2.5.8    (from OSN 2.5.8)



## Analysis cases

When you create your model in OpenSees Navigator, it is recommended that you name your IDA-related `time series`, `load patterns` and `analysis cases` with a unique string in the beginning, like `RSN111`, `RSN342`, `RSN604`, ..., and other unrelated names as `Gravity`, `Cyclic`, etc.

![ts](https://github.com/qiaotyqiaoty/Parallel-QIDA/blob/master/fig/ts-1.png)

![lp](https://github.com/qiaotyqiaoty/Parallel-QIDA/blob/master/fig/lp-1.png)

![ac](https://github.com/qiaotyqiaoty/Parallel-QIDA/blob/master/fig/ac-1.png)


For example:

If you named your `time series`, `load patterns` and `analysis cases` as follows:

- Gravity    (not related to IDA, may be used as a previous step)
- Pushover    (not related to IDA)
- Cyclic1    (not related to IDA)
- Cyclic2    (not related to IDA)
- RSN101       (used in IDA)
- RSN243       (used in IDA)
- RSN450       (used in IDA)


Then set `IDA_IDENTIFIER = 'RSN'` in `QIDA_run.m`. The program will automatically find RSN101, RSN243, RSN450, and run IDA analyses.



## Tutorial

1. Put your model .MAT file into `sample` folder

2. Open `QIDA_Run.m` and change the following user defined constants:

   - Set `src` folder path `DIR_SRC`, where `OpenSees.exe` and `OpenSeesNavigator-pcode-2.5.8` are included
   - Set your model directory `DIR_MODEL`
   - Set your ground motion thf files path `DIR_GM`
   - Set your model name `NAME_MODEL`
   - Set amplitude for IDA at `IDA_AMPLITUDES`
     - The `IDA_AMPLITUDES` should be a vector or a number
     - If `IDA_AMPLITUDES = 0.1:0.1:2`, the ground motions will be scaled 0.1x, 0.2x, 0.3x, ..., 2.0x for IDA analysis
     - If `IDA_AMPLITUDES = 1`, IDA mode is disabled, each ground motion will only run once.
   - Set active ground motions and amplitudes in case you want only part of them to be included in IDA
   - Set numbers of parallel workers (cores of CPU) for IDA and cluster name, if your set this as 1, it will not be parallel
   - Set `IDA_IDENTIFIER`, if you have named your time series, load patterns and analysis cases followed the above procedures, you don't need to change it
     
     Example:

   ```matlab
   % Set src folder path
   %    for OpenSees.exe and WriteTCLfiles.p
   %    default: '\src' under current folder
   DIR_SRC = fullfile(pwd,'src');

   % Set model folder path
   %    default: current folder (pwd)
   DIR_MODEL = pwd;

   % Set ground motion folder path
   %    default: '\GroundMotions' under current folder
   DIR_GM = fullfile(pwd, 'GroundMotions');

   % Your model name
   NAME_MODEL = 'sample.mat';

   % IDA amplitudes vector
   %   A vector showing the amplitudes of your IDA
   IDA_AMPLITUDES = 0.2:0.2:1;

   % Set active ground motions and amplitudes
   %   Example: only run groundmotion no.1~2, and amplitude no.7~8:
   GMMin = 1;
   GMMax = 2;
   AmpMin = 2;
   AmpMax = 3;

   % Set number of parallel workers for parallel computing
   NUM_WORKERS = 3;
   CLUSTER_NAME = 'local';

   % AnalysisCase, LoadPattern, TimeSeries identifier
   %   A unique string to identify your AnalysisCases
   %   Example: 'RSN' if your AnalysisCase names are 'RSN56','RSN106', ...
   IDA_IDENTIFIER = 'RSN';
   ```

2. Run `QIDA_Run.m` in MATLAB, and check the printed information



## Requirements

This program only works on Windows system.

If error occurs, please check the following step by step:

1. MATLAB version? - MATLAB r2017a or later

2. MATLAB toolbox exist? - Parallel Computing Toolbox

3. OpenSees Navigator model version? - Your OpenSees Navigator model must be created in version 2.5.8

4. OpenSees version? - Your opensees.exe must be version 2.5

5. ActiveTcl version? Ensure that ActiveTcl has been installed and compatible to OpenSees Navigator 2.5.8 (x64 recommended)

6. Check if you put your model file in the right folder and put correct constants in `QIDA_run.m`



## Further information

Here is some further information for the main body of the program `IDASession.m`

### Properties

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
