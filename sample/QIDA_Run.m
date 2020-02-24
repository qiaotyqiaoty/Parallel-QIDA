%% Run this file to quickly run IDA

%========================= By Tianyang Joe Qiao ===========================
%========================= Updated Feb 23, 2020 ===========================
%========================== tyjoe@foxmail.com =============================

% Requirements:
% 1. MATLAB r2017a+
% 2. MATLAB Parallel Computing Toolbox
% 3. OpenSees.exe version 2.5

% IMPORTANT:
%   Please add OpenSees Navigator P-Code to your MATLAB search path!


%% User defined constants
clear; clc; close all;
% =========================================================================
%                     PLEASE SET THE FOLLOWING CONSTANTS
% =========================================================================
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

% =========================================================================
%                        END OF USER DEFINED CONSTANTS
% =========================================================================



%% Create IDA session
% Add search paths to MATLAB
addpath(genpath(DIR_SRC));
addpath(DIR_MODEL);
addpath(DIR_GM);

% Initialize myIDASession object
myIDASession = IDASession(DIR_MODEL, DIR_GM, NAME_MODEL, IDA_AMPLITUDES);

% Load model
myIDASession = myIDASession.load;

% Set OpenSees path
myIDASession = myIDASession.setOpenSeesPath(DIR_SRC);

% Read analysis cases in the model, with a unique string in the name
myIDASession = myIDASession.readAnalysisCases(IDA_IDENTIFIER);  % The unique string to identify analysis cases

% Create folder structures
myIDASession = myIDASession.createDirs(false);

% Set active range of GMs and Amps
myIDASession = myIDASession.setActiveJobs(GMMin, GMMax, AmpMin, AmpMax);

% Set job matrix
myIDASession = myIDASession.jobMat(NUM_WORKERS,'local');

% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Successfully loaded model %s \n', NAME_MODEL);
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);

% Save Session
save(fullfile(myIDASession.dirModel, 'myIDASession.mat'), 'myIDASession')
fprintf('IDA session saved ... \n');

% Scale GMs and write TCL files into the structured folders
myIDASession = myIDASession.writeTclFiles;

% Set up job matrix
myIDASession = myIDASession.jobMat(NUM_WORKERS,CLUSTER_NAME);

% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);
fprintf('Successfully loaded the session! \n\n');
fprintf('Mode: Parallel \n');
fprintf('Parallel workers: %d \n', NUM_WORKERS);
fprintf('Parallel cluster: %s \n', CLUSTER_NAME);

%% Run IDA jobs
myIDASession = myIDASession.runIDA;

rmpath(genpath(DIR_SRC));
rmpath(DIR_MODEL);
rmpath(DIR_GM);