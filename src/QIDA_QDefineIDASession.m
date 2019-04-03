%% QIDA: Quick IDA by Joe
%% Define a parallel IDA session (sample code)

%%%%%%%%%% By Tianyang Joe Qiao %%%%%%%%%%%%%%%
%%%%%%%%% Updated April 2, 2019 %%%%%%%%%%%%%%%
%%%%%%%%%%%% tyjoe@foxmail.com %%%%%%%%%%%%%%%%

% Requirements:
% 1. MATLAB r2017a+
% 2. OpenSees Navigator p-code 2.5.8
% 3. MATLAB Parallel Computing Toolbox

% Mention:
% Please set path for opensees navigator p-code first!

clear; clc; close all;


%% Define session and constants
% ================================================================
% ================================================================
HOME_PATH = pwd;

% Set Opensees.exe folder path
% Don't include 'opensees.exe'!
% Please use '\'
DIR_OPENSEES = HOME_PATH;

% Set Opensees.exe folder path
% Please use '\'
DIR_MODEL = HOME_PATH;

% Set ground motion path
% Please use '\'
DIR_GM = [HOME_PATH, '\GM'];

% Set Opensees.exe folder path
NAME_MODEL = 'ORRRBH_190129.mat';

% IDA amplitudes vector
IDA_AMPLITUDES = 1;

% ================================================================
% ================================================================
%% Create session
myIDASession = IDASession(DIR_MODEL, DIR_GM, NAME_MODEL, true, IDA_AMPLITUDES);

%% Load model
myIDASession = myIDASession.load;

% Set OpenSeesPath
myIDASession = myIDASession.setOpenSeesPath(DIR_OPENSEES);

% Read analysis cases in the model, with a unique string in the name
% Example: put 'RSN' if your analysisCase names are 'RSN111', 'RSN123', ...
myIDASession = myIDASession.readAnalysisCases('RSN');  % The unique string to identify analysis cases

% Create folder structures
myIDASession = myIDASession.createDirs(false);

% Set active range of GMs and Amps
GMMin = 1;
GMMax = 99;
AmpMin = 1;
AmpMax = 99;
myIDASession = myIDASession.setActiveJobs(GMMin, GMMax, AmpMin, AmpMax);

% Set job matrix
myIDASession = myIDASession.jobMat;

% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Successfully loaded the model! \n');
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);

% Save Session
save([myIDASession.dirModel, '\', 'myIDASession.mat'], 'myIDASession')
fprintf('IDA session saved ... \n');
