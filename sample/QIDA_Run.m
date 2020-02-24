%% Quick Run IDA

%========================= By Tianyang Joe Qiao ===========================
%========================= Updated Feb 23, 2020 ===========================
%========================== tyjoe@foxmail.com =============================

% Requirements:
% 1. MATLAB r2017a+
% 2. OpenSees Navigator p-code 2.5.8 (added to MATLAB paths)
% 3. MATLAB Parallel Computing Toolbox
% 4. OpenSees.exe version 2.5

clear; clc; close all;

%% Define session and constants
% ================================================================
% ================================================================
% Set src folder path
    % (for OpenSees.exe and WriteTCLfiles.p)
DIR_SRC = fullfile(pwd,'src');

% Set model folder path
    % (use pwd if your *.mat model file is in current directory)
DIR_MODEL = pwd;

% Set ground motion folder path
    % (default: '\GroundMotions' under current folder)
DIR_GM = fullfile(pwd, 'GroundMotions');

% Your model name
NAME_MODEL = 'sample.mat';

% IDA amplitudes vector
    % (A vector showing the amplitudes of your IDA)
IDA_AMPLITUDES = 0.2:0.2:1;

% Set active ground motions and amplitudes
    % Example: only run groundmotion no.1, and amplitude no.7~8:
GMMin = 1;
GMMax = 1;
AmpMin = 7;
AmpMax = 8;

% Set number of parallel workers for parallel computing
NUM_WORKERS = 3;
CLUSTER_NAME = 'local';

% ================================================================
% ================================================================
%% Create session
myIDASession = IDASession(DIR_MODEL, DIR_GM, NAME_MODEL, IDA_AMPLITUDES);

%% Load model
myIDASession = myIDASession.load;

% Set OpenSees path
myIDASession = myIDASession.setOpenSeesPath(DIR_SRC);

% Read analysis cases in the model, with a unique string in the name
% Example: put 'RSN' if your analysisCase names are 'RSN111', 'RSN123', ...
myIDASession = myIDASession.readAnalysisCases('RSN');  % The unique string to identify analysis cases

% Create folder structures
myIDASession = myIDASession.createDirs(false);

% Set active range of GMs and Amps
myIDASession = myIDASession.setActiveJobs(GMMin, GMMax, AmpMin, AmpMax);

% Set job matrix
myIDASession = myIDASession.jobMat(NUM_WORKERS,'local');

% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Successfully loaded the model! \n');
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);

% Save Session
save(fullfile(myIDASession.dirModel, 'myIDASession.mat'), 'myIDASession')
fprintf('IDA session saved ... \n');

%% Write TCL files into the structured folders
myIDASession = myIDASession.writeTclFiles;

%% Set up job matrix
myIDASession = myIDASession.jobMat(NUM_WORKERS,CLUSTER_NAME);

%% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);
fprintf('Successfully loaded the session! \n\n');
if 
fprintf('Mode: Parallel \n');
fprintf('Parallel workers: %d \n', NUM_WORKERS);
fprintf('Parallel cluster: %s \n', CLUSTER_NAME);

%% Run IDA jobs
%myIDASession = myIDASession.runIDA;
