%% QIDA: Quick IDA by Joe
%% Output NLTHA data (sample code)
% For single amplitude! Loop in different GMs

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

%% Load session
load('myIDASession.mat');
idapath = myIDASession.paths.idaPath;
clear myIDASession;
load([idapath,'\myIDASession.mat']);

%% Output data
% Plot roof disp.
IDAoutput = myIDASession.readOutput('RSN*RoofDrift*Dsp.out', 1, [1 2], {'time','drift'}, '');
figure; hold on;
n = size(IDAoutput, 1);
k = 1;
for i = 3:3
    plot(IDAoutput{i,3}, IDAoutput{i,4});
    legendStr{k,1} = IDAoutput{i,2};
    k = k+1;
end
legend(legendStr);
hold off;

% Plot uplift
IDAoutput = myIDASession.readOutput('RSN*LED_BasDefo.out', 1, [1 2 3], {'time','LED1','LED2'}, '');
figure; hold on;
n = size(IDAoutput, 1);
k = 1;
for i = 3:3
    plot(IDAoutput{i,3}, IDAoutput{i,4});
    legendStr{k,1} = IDAoutput{i,2};
    k = k+1;
end
legend(legendStr);
hold off;

