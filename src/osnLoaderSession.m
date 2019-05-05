%% OSN-XLS LOADER
% Developed by Joe Tianyang Qiao
% April, 2019

classdef osnLoaderSession
    properties
        dirModel
        xlsName
        modelName
        options
        inputModel
    end
    methods
        % Initialization
        function obj = osnLoaderSession(dirModel,xlsName,matName)
            obj.dirModel = strip(dirModel,'right','\');
            if endsWith(matName,'.mat')
                obj.modelName = matName;
            else
                obj.modelName = [matName, '.mat'];
            end
            if exist([dirModel,'\',xlsName],'file')
                obj.xlsName = xlsName;
            else
                obj.xlsName = '';
                disp('%s does not exist!', xlsName);
                return;
            end
            obj.modelName = matName;
            obj.options = struct( ...
                'loadNode', true, ...
                'loadElem', true, ...
                'loadElemType', false, ...
                'loadGM', false);
        end
        
        % Create new model or skip if model exists
        function obj = new(obj,matName)
            if exist([obj.dirModel,'\',matName],'file')
                fprintf('Successfully found %s\n', matName);
                obj.modelName = matName;
            else
                obj.modelName = matName;
                strInput = input(prompt,'Call OpenSees Navigator to create a new model? ...');
                if strInput == 'y'
                    OpenSeesNavigator;
                end
                %obj.modelName = matName;
                %save(obj.modelName, 'Library', 'Model', 'UserDef');
                %QuitNavigator(0);
            end
        end
        
        function obj = load(obj)
            if exist([obj.dirModel,'\',obj.modelName],'file')
                obj.inputModel = load([obj.dirModel,'\',obj.modelName]);
            else
                disp('Model does not exist.');
            end
        end
        
        function obj = save(obj)
            Model = obj.inputModel.Model;
            Model.filename = obj.modelName;
            Model.pathname = obj.dirModel;
            Library = obj.inputModel.Library;
            UserDef = obj.inputModel.UserDef;
            save([obj.dirModel,'\',obj.modelName], 'Model', 'Library', 'UserDef');
            disp('Model saved:');
            fprintf('%s \n',[obj.dirModel,'\',obj.modelName]);
        end
        
        function obj = writeNDF(obj,ndm,ndf)
            Model = obj.inputModel.Model;
            if ~isfield(Model,'ndm')
                obj.inputModel.Model.ndm = ndm;
            end
            if ~isfield(Model,'ndf')
                obj.inputModel.Model.ndf = ndf;
            end
        end
        
        function obj = writeNode(obj,sheetName,clearNodes)
            excelName = obj.xlsName;
            
            % Read excel File
            [~,~,inpData] = xlsread([obj.dirModel,'\',excelName], sheetName);
            
            % Clear headers
            inpData(:,1) = [];
            inpData(1,:) = [];
            
            % Count data size
            nn = size(inpData,1);
            
            % Change nan to 0
            inpData = obj.clearNan(inpData);
            
            % Read model file
            Model = obj.inputModel.Model;
            
            % Clear struct
            if clearNodes
                Model.Node = [];
            end
            
            % Write nodes
            if isfield(obj.inputModel, 'Node')
                nso = size(obj.inputModel.Node,2);
                nsn = nn - nso;
            else
                nso = 0;
                nsn = nn;
            end
            if nso < 1
                for i=1:nsn
                    Model.Node(i).Tag  = inpData{i,1};
                    Model.Node(i).XYZ  = [inpData{i,2}, inpData{i,3}];
                    Model.Node(i).NDF = 3;
                    Model.Node(i).SPC  = [inpData{i,4},inpData{i,5},inpData{i,6}];
                    Model.Node(i).MPC  = [];
                    Model.Node(i).Mass = [inpData{i,7},inpData{i,8},inpData{i,9}];
                    Model.Node(i).ImpM = [];
                    Model.Node(i).Load = [];
                    Model.Node(i).Disp = [];
                end
            else
                for i=1:nso
                    Model.Node(i).Tag  = inpData{i,1};
                    Model.Node(i).XYZ  = [inpData{i,2}, inpData{i,3}];
                    Model.Node(i).NDF = 3;
                    Model.Node(i).SPC  = [inpData{i,4},inpData{i,5},inpData{i,6}];
                    Model.Node(i).Mass = [inpData{i,7},inpData{i,8},inpData{i,9}];
                end
                for i=nso:nsn
                    Model.Node(i).Tag  = inpData{i,1};
                    Model.Node(i).XYZ  = [inpData{i,2}, inpData{i,3}];
                    Model.Node(i).NDF = 3;
                    Model.Node(i).SPC  = [inpData{i,4},inpData{i,5},inpData{i,6}];
                    Model.Node(i).MPC  = [];
                    Model.Node(i).Mass = [inpData{i,7},inpData{i,8},inpData{i,9}];
                    Model.Node(i).ImpM = [];
                    Model.Node(i).Load = [];
                    Model.Node(i).Disp = [];
                end
            end

            fprintf('Write Nodes: Done\n');
            
            % Delete another nodes (overlength)
            j=nn+1;
            for i=j:size(Model.Node,2)
                Model.Node(j)=[];
            end
            
            % number count
            Model.nn = nn;
            % Write into object
            obj.inputModel.Model = [];
            obj.inputModel.Model = Model;
        end
        
        
        function obj = writeElem(obj,sheetName,clearNodes)
            excelName = obj.xlsName;
            
            % Read excel File
            [~,~,inpData] = xlsread([obj.dirModel,'\',excelName], sheetName);
            
            % Clear headers
            inpData(:,1) = [];
            inpData(1,:) = [];
            
            % Count data size
            nn = size(inpData,1);
            
            % Change nan to 0
            inpData = obj.clearNan(inpData);
            
            % Read model file
            Model = obj.inputModel.Model;
            
            % Clear struct
            if clearNodes
                Model.Node = [];
            end
            
            % Write nodes
            if isfield(obj.inputModel, 'Element')
                nso = size(obj.inputModel.Element,2);
                nsn = nn - nso;
            else
                nso = 0;
                nsn = nn;
            end
            if nso < 1
                for j=1:nsn
                    Model.Element(j).Tag  = inpData{j,1};
                    Model.Element(j).Con  = [inpData{j,2}, inpData{j,3}];
                    Model.Element(j).Ndf = 3;
                    Model.Element(j).Type = 'None';
                    Model.Element(j).GeoT = 'None';
                    Model.Element(j).Rot = [];
                    Model.Element(j).JOff = [];
                    Model.Element(j).Load = [];
                    Model.Element(j).Defo = [];
                    % Assign Element Type
                    if inpData{j,4} == 0
                        Model.Element(j).Type = 'None';
                    else
                        Model.Element(j).Type = inpData{j,4};
                    end
                    % Assign GeoTrans
                    if inpData{j,5} == 0
                        Model.Element(j).GeoT = 'None';
                    else
                        Model.Element(j).GeoT = inpData{j,5};
                    end
                    Model.Element(j).Rot = 0;
                end
            else
                for j=1:nso
                    Model.Element(j).Tag  = inpData{j,1};
                    Model.Element(j).Con  = [inpData{j,2}, inpData{j,3}];
                    Model.Element(j).Ndf = 3;
                    Model.Element(j).Type = 'None';
                    Model.Element(j).GeoT = 'None';
                    % Assign Element Type
                    if inpData{j,4} == 0
                        Model.Element(j).Type = 'None';
                    else
                        Model.Element(j).Type = inpData{j,4};
                    end
                    % Assign GeoTrans
                    if inpData{j,5} == 0
                        Model.Element(j).GeoT = 'None';
                    else
                        Model.Element(j).GeoT = inpData{j,5};
                    end
                end
                for j=nso:nsn
                    Model.Element(j).Tag  = inpData{j,1};
                    Model.Element(j).Con  = [inpData{j,2}, inpData{j,3}];
                    Model.Element(j).Ndf = 3;
                    Model.Element(j).Type = 'None';
                    Model.Element(j).GeoT = 'None';
                    Model.Element(j).Rot = [];
                    Model.Element(j).JOff = [];
                    Model.Element(j).Load = [];
                    Model.Element(j).Defo = [];
                    % Assign Element Type
                    if inpData{j,4} == 0
                        Model.Element(j).Type = 'None';
                    else
                        Model.Element(j).Type = inpData{j,4};
                    end
                    % Assign GeoTrans
                    if inpData{j,5} == 0
                        Model.Element(j).GeoT = 'None';
                    else
                        Model.Element(j).GeoT = inpData{j,5};
                    end
                    Model.Element(j).Rot = 0;
                end
            end

            fprintf('Write Nodes: Done\n');
            
            % Delete another nodes (overlength)
            j = nn+1;
            for i=j:size(Model.Element,2)
                Model.Element(j)=[];
            end
            
            % number count
            Model.ne = nn;
            % Write into object
            obj.inputModel.Model = [];
            obj.inputModel.Model = Model;
        end
        
        
        function obj = writeElemType(obj,sheetName,clearData)
            excelName = obj.xlsName;
            Library = obj.inputModel.Library;
            % Clear Data
            if clearData
                Library.Element = [];
                Library.Element(1).Type = 'ElasticBeamColumn';
                Library.Element(1).Name = 'EBCDefault';
                Library.Element(1).E = 200000;
                Library.Element(1).A = 10000;
                Library.Element(1).Iz = 10000000;
                Library.Element(1).alpha = 0;
                Library.Element(1).d = 0;
                Library.Element(1).massDens = 0;
                Library.Element(1).massType = 0;
            end
            
            % Read excel File
            [~,~,inpData] = xlsread([obj.dirModel,'\',excelName], sheetName);
            inpData = obj.clearNanEmpty(inpData);
            
            % Clear headers
            inpData(1,:) = [];
            
            % Count data size
            nn = size(inpData,1);
            
            % Write Element Types
            j=1;
            for i=1:nn
                Library.Element(i).Type = inpData{j,1};
                Library.Element(i).Name = inpData{j,2};
                Library.Element(i).E = inpData{j,3};
                Library.Element(i).G = inpData{j,4};
                Library.Element(i).A = inpData{j,5};
                Library.Element(i).Iz = inpData{j,6};
                Library.Element(i).Iy = inpData{j,7};
                Library.Element(i).J = inpData{j,8};
                Library.Element(i).alpha = inpData{j,9};
                Library.Element(i).d = inpData{j,10};
                Library.Element(i).massDens = inpData{j,11};
                Library.Element(i).corotTrans = inpData{j,12};
                Empty6 = isempty(inpData{j,13}) && isempty(inpData{j,14}) && isempty(inpData{j,15}) && isempty(inpData{j,16}) && isempty(inpData{j,17}) && isempty(inpData{j,18});
                Empty5 = isempty(inpData{j,14}) && isempty(inpData{j,15}) && isempty(inpData{j,16}) && isempty(inpData{j,17}) && isempty(inpData{j,18});
                Empty3 = isempty(inpData{j,16}) && isempty(inpData{j,17}) && isempty(inpData{j,18});
                if Empty6 == 1
                    Library.Element(i).MatName = [];
                elseif Empty5 == 1
                    Library.Element(i).MatName = inpData{j,13};
                elseif Empty3 == 1
                    Library.Element(i).MatName{1,1} = inpData{j,13};
                    Library.Element(i).MatName{1,2} = inpData{j,14};
                    Library.Element(i).MatName{1,3} = inpData{j,15};
                else
                    Library.Element(i).MatName{1,1} = inpData{j,13};
                    Library.Element(i).MatName{1,2} = inpData{j,14};
                    Library.Element(i).MatName{1,3} = inpData{j,15};
                    Library.Element(i).MatName{1,4} = inpData{j,16};
                    Library.Element(i).MatName{1,5} = inpData{j,17};
                    Library.Element(i).MatName{1,6} = inpData{j,18};
                end
                Library.Element(i).NIP = inpData{j,19};
                Library.Element(i).SecName = inpData{j,20};
                Library.Element(i).maxIters = inpData{j,21};
                Library.Element(i).tol = inpData{j,22};
                Library.Element(i).massType = inpData{j,23};
                Library.Element(i).doRayleigh = inpData{j,24};
                Library.Element(i).intType = inpData{j,25};
                j=j+1;
            end
            
            % Write into object
            obj.inputModel.Library = Library;
            disp('Write Library - Element: Done.');
        end
        
        % Write model loads
        function obj = writeLoad(obj,loadxlsName,sheetName)
            excelName = loadxlsName;
            Model = obj.inputModel.Model;
            nn = size(Model.Node, 2);
            
            % Read excel File
            [~,~,inpData] = xlsread([obj.dirModel,'\',excelName], sheetName);
            inpData(1,:) = [];
            inpData(:,1) = [];
            inpData = obj.clearNan(inpData);
            
            % Write loads and disps
            for i = 1:nn
                if inpData{i,2}==0 && inpData{i,3}==0 && inpData{i,4}==0
                    Model.Node(i).Load = [];
                else
                    loadTemp = struct('Pattern',{},'Value',{});
                    loadTemp(1).Pattern = sheetName;
                    loadTemp(1).Value = [inpData{i,2},inpData{i,3},inpData{i,4}];
                    Model.Node(i).Load = loadTemp;
                end
                if inpData{i,4}==0 && inpData{i,5}==0 && inpData{i,6}==0
                    Model.Node(i).Disp = [];
                else
                    dispTemp = struct('Pattern',{},'Value',{});
                    dispTemp.Pattern = sheetName;
                    dispTemp.Value = [inpData{i,5},inpData{i,6},inpData{i,7}];
                    Model.Node(i).Disp = dispTemp;
                end
            end
            
            % Write into object
            obj.inputModel.Model = Model;
            disp('Write Loads and Disps: Done.');
        end

        
        
        function data = clearNan(~,data)
            for i = 1:size(data,1)
                for j = 1:size(data,2)
                    if isnan(data{i,j})
                        data{i,j} = 0;
                    end
                end
            end
        end
        
        
        function data = clearNanEmpty(~,data)
            for i = 1:size(data,1)
                for j = 1:size(data,2)
                    if isnan(data{i,j})
                        data{i,j} = [];
                    end
                end
            end
        end
        
        function [Model,Library,UserDef] = plotModel(obj)
            temp = load([obj.dirModel,'\',obj.modelName]);
            Model = temp.Model;
            Library = temp.Library;
            UserDef = temp.UserDef;
            handleResults = findobj('Tag','OpenSeesNavigator');
            if ~isempty(handleResults)
                figure(findobj('Tag','OpenSeesNavigator'));
            else
                RunOpenSeesNavigator;
            end
            ClearModel;
            PlotModel(Model,Library,0);
        end
        

        
        % Load model to workspace
        function [Model,Library,UserDef] = loadModel(obj)
            temp = load([obj.dirModel,'\',obj.modelName]);
            Model = temp.Model;
            Library = temp.Library;
            UserDef = temp.UserDef;
        end
    end
end
