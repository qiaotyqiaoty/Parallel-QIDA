%% QIDA: Quick IDA by Joe
%% Run a parallel IDA session (sample code)

%%%%%%%%%% By Tianyang Joe Qiao %%%%%%%%%%%%%%%
%%%%%%%%% Updated April 2, 2019 %%%%%%%%%%%%%%%
%%%%%%%%%%%% tyjoe@foxmail.com %%%%%%%%%%%%%%%%

% Requirements:
% 1. MATLAB r2017a+
% 2. OpenSees Navigator p-code 2.5.8
% 3. MATLAB Parallel Computing Toolbox

% Mention:
% Please set path for opensees navigator p-code first!
% Will load a defined IDA session

% Output:
% Will create a subfolder '\IDAFiles', find .out files there

clear; clc; close all;

% ================================================================
%% Load session
load('myIDASession.mat');
save([myIDASession.paths.idaPath, '\', 'myIDASession.mat'], 'myIDASession')
fprintf('IDA session saved to \\IDAFiles... \n');

%% Write TCL files into the folder structure
myIDASession = myIDASession.writeTclFiles;

%% Set up job matrix
myIDASession = myIDASession.jobMat;

%% Print job info
nActiveAmps = length(myIDASession.runOptions.activeAmps);
nActiveGMs = length(myIDASession.runOptions.activeGMs);
fprintf('Number of active ground motions: %d \n', nActiveGMs);
fprintf('Number of active IDA amplitudes: %d \n', nActiveAmps);
fprintf('Total number of jobs: %d \n', nActiveAmps * nActiveGMs);
fprintf('Successfully loaded the session! \n\n');

%% Run IDA jobs
fprintf('IDA starts ... \n');
if myIDASession.runOptions.parallelOptions.parallelEnabled
    fprintf('Mode: Parallel \n');
else
    fprintf('Mode: Interactive \n');
end
myIDASession = myIDASession.runIDA;