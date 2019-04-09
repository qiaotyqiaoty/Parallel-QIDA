% QIDA: Quick IDA by Joe
% Excel to OSN-MAT file loader (geometry-only)

%%%%%%%%%% By Tianyang Joe Qiao %%%%%%%%%%%%%%%
%%%%%%%%% Updated April 2, 2019 %%%%%%%%%%%%%%%
%%%%%%%%%%%% tyjoe@foxmail.com %%%%%%%%%%%%%%%%

% ONLY writes model geometry from an excel file!!

%% Define path constants
% ================================================================
% ================================================================
% Set model name
MODEL_NAME = 'RCW_190408.mat';
EXCEL_NAME = 'ModelGeometry.xlsx';

% Set home path
HOME_PATH = pwd;

% Set Opensees.exe folder path
% Don't include 'opensees.exe'!
% Please use '\'
DIR_OPENSEES = HOME_PATH;

% Set Opensees.exe folder path
% Please use '\'
DIR_MODEL = HOME_PATH;

% =========================================================================
%% Load excel file
% Initialize session
myOsnLoader = osnLoaderSession(HOME_PATH, EXCEL_NAME, MODEL_NAME);

% Check if model exists, if not:
% Call OpenSees Navigator to Initialize model
myOsnLoader = myOsnLoader.newModel(MODEL_NAME);

% 
my
