6% QIDA: Quick IDA by Joe
% Excel to OSN-MAT file loader (write Geometry, ElementType, GeoTrans, Loads and Disp)

%%%%%%%%%% By Tianyang Joe Qiao %%%%%%%%%%%%%%%
%%%%%%%%% Updated April 2, 2019 %%%%%%%%%%%%%%%
%%%%%%%%%%%% tyjoe@foxmail.com %%%%%%%%%%%%%%%%

% ONLY writes model geometry from an excel file!!

%% Define path constants
% ================================================================
% ================================================================
% Set model name
MODEL_NAME = 'RCW_190408_3.mat';
GEO_EXCEL_NAME = 'ModelGeometry.xlsx';
LOAD_EXCEL_NAME = 'ModelLoads.xlsx';

% Set home path
HOME_PATH = pwd;

% Set Opensees.exe folder path
% Please use '\'
DIR_MODEL = HOME_PATH;

% Write element type?
WRITE_ELEM_TYPE = false;
% Write loads and disps?
WRITE_LOAD_DISP = true;

% Open in OSN?
OPEN_IN_OSN = true;

% =========================================================================
%% Load excel file
% Initialize session
myOsnLoader = osnLoaderSession(HOME_PATH, GEO_EXCEL_NAME, MODEL_NAME);

% Check if the model .mat file exists, if not:
% Call OpenSees Navigator to Initialize model
myOsnLoader = myOsnLoader.new(MODEL_NAME);

% Load model
myOsnLoader = myOsnLoader.load();

% Write NDM, NDF
NDM = 2;        % Dimension: 2, 3
NDF = 3;        % Degree of freedom: 3, 6
myOsnLoader = myOsnLoader.writeNDF(NDM,NDF);

% Write Node
SHEET_NAME = 'Node';     % sheet name for Nodes
CLEAR_DATA = false;      % Clear data before write?
myOsnLoader = myOsnLoader.writeNode(SHEET_NAME,CLEAR_DATA);

% Write Element
SHEET_NAME = 'Elem';     % sheet name for Nodes
CLEAR_DATA = false;      % Clear data before write?
myOsnLoader = myOsnLoader.writeElem(SHEET_NAME,CLEAR_DATA);

% Write Element Type
SHEET_NAME = 'ElemType';     % sheet name for Nodes
CLEAR_DATA = true;      % Clear data before write?
if WRITE_ELEM_TYPE
    myOsnLoader = myOsnLoader.writeElemType(SHEET_NAME,CLEAR_DATA);
end

% Write Loads
% put load pattern name here
% !!!! make sure that load pattern name is same as the excel sheet name
SHEET_NAME = 'Grav';
if WRITE_LOAD_DISP
    myOsnLoader = myOsnLoader.writeLoad(LOAD_EXCEL_NAME,SHEET_NAME);
end

% Write Time Series


% Save model
myOsnLoader = myOsnLoader.save();

% Load model to work space
[Model,Library,UserDef] = myOsnLoader.loadModel();

% Plot model
if OPEN_IN_OSN
    [Model,Library,UserDef] = myOsnLoader.plotModel();
end
