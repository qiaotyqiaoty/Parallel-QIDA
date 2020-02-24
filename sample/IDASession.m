%% IDA session class
classdef IDASession
    
    properties
        dirModel            % directory of model MAT file
        modelName           % name of the model MAT file
        ampsIDA             % a vector indicating the amplitudes for GM scaling
        runOptions          % info struct for analysis cases and options
        paths               % structure for all paths, directories
        inpModel            % the loaded OSN model
        jobs                % IDA jobs requested
        runlog
    end
    
    
    methods
        %% Initialization
        function obj = IDASession(dirModel, dirGM, modelName, amps)
            
            % Model directory
            obj.dirModel = strip(dirModel,'right','\');
            
            % Run options
            obj.runOptions = struct( ...
                'IDAOptions', [], ...
                'IDAon', true, ...
                'activeGMs', [], ...
                'activeAmps', [], ...
                'nAmp', 1, ...
                'nGM', 1, ...
                'uniqueStr', '');

            % OSN model name with mat
            if endsWith(modelName,'.mat')
                obj.modelName = modelName;
            else
                obj.modelName = [modelName, '.mat'];
            end
            
            % read IDA amplitudes
            obj.ampsIDA = amps;
            
            % Detect for IDA
            if length(obj.ampsIDA) == 1
                obj.runOptions.IDAon = false;
            else
                obj.runOptions.IDAon = true;
            end
            
            % Default nAmp and activeAmps
            obj.runOptions.nAmp = length(obj.ampsIDA);
            obj.runOptions.activeAmps = length(obj.ampsIDA);
            
            % IDA options
            obj.runOptions.IDAOptions = struct( ...
                'num', {}, ...
                'AnalysisCases', {}, ...
                'AnalysisCasesNum', {}, ...
                'TimeSeries', {}, ...
                'TimeSeriesNum', {}, ...
                'TimeSeriesScale', {}, ...
                'TimeSeriesPath', {}, ...
                'TimeSeriesDt', {}, ...
                'LoadPatterns', {}, ...
                'LoadPatternsNum', {}, ...
                'LoadPatternsScale', {}, ...
                'outputPath', {}, ...
                'Others', {});
            
            % Paths
            mkdir(fullfile(obj.dirModel,'IDAFiles'));
            mkdir(fullfile(obj.dirModel,'IDAFiles',obj.modelName(1:end-3)));
            obj.paths = struct( ...
                'tclPath',fullfile(obj.dirModel,'TCLFiles'), ...
                'idaPath',fullfile(obj.dirModel,'IDAFiles',obj.modelName(1:end-3)), ...
                'osPath', '', ...
                'gmPath', dirGM);
            mkdir(obj.paths.idaPath);
        end
        
        %% Load model
        function obj = load(obj)
            try
                obj.inpModel = load(fullfile(obj.dirModel,obj.modelName));
                % Update model info
                obj.inpModel.Model.pathname = obj.dirModel;
                obj.inpModel.Model.filename = obj.modelName;
                obj.inpModel.Model.name = obj.modelName;
            catch exception
                fprintf('%s',exception.message);
                fprintf('Unable to read or find the MAT file.\n');
            end
        end
        
        %% Read analysis cases
        function obj = readAnalysisCases(obj, strUnique)
            obj.runOptions.uniqueStr = strUnique;
            
            % Load model
            if isempty(obj.inpModel)
                obj.load;
            end
            
            % Read analysis cases
            j = 1;
            for i = 1:size(obj.inpModel.Library.AnalysisCase, 2)
                if isempty(strfind(obj.inpModel.Library.AnalysisCase(i).Name, strUnique))
                    continue;
                else
                    obj.runOptions.IDAOptions(j).num = j;
                    obj.runOptions.IDAOptions(j).AnalysisCases = obj.inpModel.Library.AnalysisCase(i).Name;
                    obj.runOptions.IDAOptions(j).AnalysisCasesNum = i;
                    obj.runOptions.IDAOptions(j).LoadPatterns = obj.inpModel.Library.AnalysisCase(i).LoadPat;
                    j = j + 1;
                end
            end
            obj.runOptions.nGM = j - 1;
            
            % Read Load Patterns
            j = 1;
            lpTemp = {obj.inpModel.Library.LoadPattern(:).Name};
            for i = 1:size(obj.runOptions.IDAOptions, 2)
                j = find(strcmp(lpTemp, ...
                    obj.runOptions.IDAOptions(i).LoadPatterns));
                obj.runOptions.IDAOptions(i).LoadPatternsNum = j;
                obj.runOptions.IDAOptions(i).LoadPatternsScale = obj.inpModel.Library.LoadPattern(j).factor;
                obj.runOptions.IDAOptions(i).TimeSeries = obj.inpModel.Library.LoadPattern(j).SerName;
            end
            
            % Read Time Series
            tsTemp = {obj.inpModel.Library.TimeSeries(:).Name};
            for i = 1:size(obj.runOptions.IDAOptions, 2)
                j = find(strcmp(tsTemp, ...
                    obj.runOptions.IDAOptions(i).TimeSeries));
                obj.runOptions.IDAOptions(i).TimeSeriesNum = j;
                obj.runOptions.IDAOptions(i).TimeSeriesScale = obj.inpModel.Library.TimeSeries(j).cFactor;
                obj.runOptions.IDAOptions(i).TimeSeriesPath = obj.inpModel.Library.TimeSeries(j).filePath;
                obj.runOptions.IDAOptions(i).TimeSeriesDt = obj.inpModel.Library.TimeSeries(j).dt;
            end
        end
        
        %% Create folder structure
        %  -| IDAFiles
        %  ----| RSN001
        %  --------| AMP_0.1
        %  --------| AMP_0.2
        %  ----| RSN002
        %  --------| AMP_0.1
        %  --------| AMP_0.2
        %  ...................
        function obj = createDirs(obj, clearFile)
            % Load model
            if isempty(obj.inpModel)
                obj.load;
            end
            
            % Clear all subfolders in idaPath
            if clearFile
                dirTemp = dir(obj.paths.idaPath);
                n=length(dirTemp);
                for i=1:n
                    if (dirTemp(i).isdir && ~strcmp(dirTemp(i).name,'.') && ~strcmp(dirTemp(i).name,'..'))
                        rmdir([obj.paths.idaPath, '\', dirTemp(i).name],'s');
                    end
                end
            end
            
            % Make directories
            for i = 1:obj.runOptions.nGM
                pathTemp1 = [obj.paths.idaPath, '\', obj.runOptions.IDAOptions(i).AnalysisCases];
                mkdir(pathTemp1);
                pathCell = cell(obj.runOptions.nAmp, 1);
                for j = 1:obj.runOptions.nAmp
                    pathTemp2 = [pathTemp1, '\AMP_', num2str(obj.ampsIDA(j))];
                    mkdir(pathTemp2);
                    pathCell{j,1} = pathTemp2;
                end
                obj.runOptions.IDAOptions(i).outputPath = pathCell;
            end
        end
        
        
        %% OpenSees.exe Path Setting
        function obj = setOpenSeesPath(obj, OpenSeesPath)
            obj.paths.osPath = strip(OpenSeesPath, 'right', '\');
        end
        
        %% Set active jobs
        function obj = setActiveJobs(obj, GMMin, GMMax, AmpMin, AmpMax)
            obj.runOptions.activeGMs = max(1,GMMin):1:min(GMMax, obj.runOptions.nGM);
            obj.runOptions.activeGMNames = {};
            for i=1:length(obj.runOptions.activeGMs)
                obj.runOptions.activeGMNames{i} = obj.runOptions.IDAOptions(obj.runOptions.activeGMs(i)).AnalysisCases;
            end
            obj.runOptions.activeAmps = max(1,AmpMin):1:min(AmpMax, obj.runOptions.nAmp);
        end
        
        %% Scale GMs and Write TCL files
        function obj = writeTclFiles(obj)
            % default: all active
            if isempty(obj.runOptions.activeGMs)
                obj.runOptions.activeGMs = 1:1:obj.runOptions.nGM;
            end
            if isempty(obj.runOptions.activeAmps)
                obj.runOptions.activeAmps = 1:1:obj.runOptions.nAmp;
            end
            
            % Scale GMs by applying amplitudes to your LoadPattern
            m = length(obj.runOptions.activeAmps);
            n = length(obj.runOptions.activeGMs);
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                lpNum = obj.runOptions.IDAOptions(i).LoadPatternsNum;
                lpfTemp = obj.inpModel.Library.LoadPattern(lpNum).factor;
                for jj = 1:m
                    j = obj.runOptions.activeAmps(jj);
                    cd(obj.dirModel);
                    % scale loadpattern by amplitude
                    obj.inpModel.Library.LoadPattern(lpNum).factor = lpfTemp * obj.ampsIDA(j);
                    % call WriteTCLfiles.p
                    
                    WriteTCLfiles( ...
                        obj.inpModel.Model, ...
                        obj.inpModel.Library, ...
                        obj.inpModel.UserDef, ...
                        obj.runOptions.IDAOptions(i).AnalysisCasesNum);
                    % copy tcl files to IDA path
                    dstPath = obj.runOptions.IDAOptions(i).outputPath{j,1};
                    movefile([obj.paths.tclPath,'\*.tcl'],dstPath);
                    copyfile([obj.paths.gmPath,'\*.thf'],dstPath);
                end
            end
        end
        
        
        %% Set up job matrix
        function obj = jobMat(obj,parWorkers,clusterName)
            % Write parallel settings
            if parWorkers > 1
                obj.jobs.parOptions = struct( ...
                    'parallel',true, ...
                    'parWorkers',parWorkers, ...
                    'clusterName',clusterName);
            else
                obj.jobs.parOptions = struct( ...
                    'parallel',false);
            end
            % Reshape (stretch) job matrix to a vector
            m = length(obj.runOptions.activeAmps);
            n = length(obj.runOptions.activeGMs);
            k = 0;
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                for jj = 1:m
                    j = obj.runOptions.activeAmps(jj);
                    k = k + 1;
                    obj.jobs.paths{k,1} = obj.runOptions.IDAOptions(i).outputPath{j,1};
                    obj.jobs.pathNames{k,1} = [obj.runOptions.IDAOptions(i).outputPath{j,1},'\',strrep(obj.modelName, '.mat', '.tcl')];
                end
            end
        end
        
        %% Run IDA!
        function obj = runIDA(obj)
            parjobPaths = obj.jobs.paths;
            parjobNames = obj.jobs.pathNames;
            dirOpenSees = obj.paths.osPath;
            obj.inpModel = [];
            cmdlog = cell(length(parjobPaths),1);
            % Parallel starts!
            if obj.jobs.parOptions.parallel
                parfor i = 1:length(parjobPaths)
                    Command = strrep(['cd ', parjobPaths{i,1}, ' & @ "', dirOpenSees,'\OpenSees.exe" "', parjobNames{i,1},'"'],'\','/');
                    [~,cmdout] = system(Command,'-echo');
                    cmdlog{i,1} = cmdout;
                end
            else
                for i = 1:length(parjobPaths)
                    Command = strrep(['cd ', parjobPaths{i,1}, ' & @ "', dirOpenSees,'\OpenSees.exe" "', parjobNames{i,1},'"'],'\','/');
                    [~,cmdout] = system(Command,'-echo');
                    cmdlog{i,1} = cmdout;
                end
            end
            
            obj.runlog = cmdlog;
            for i=1:length(obj.runlog)
                if isempty(strfind(obj.runlog{i,1},'WARNING'))
                    obj.runlog{i,2} = true;
                else
                    obj.runlog{i,2} = false;
                end
            end
        end
       
        
        
        %% Read time data
        function outData = readTime(obj, fileName)
            % Loop in active Amps, GMs
            n = length(obj.runOptions.activeGMs);
            outData = cell(n,length(indexCols)+2);
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                iPaths = obj.runOptions.IDAOptions(i).outputPath{1};
                timeFileName = dir([iPaths,'\']);
                timeName = timeFileName(1).name;
                outData{i,1} = obj.runOptions.IDAOptions(i).num;
                outData{i,2} = obj.runOptions.IDAOptions(i).AnalysisCases;
                outData{i,3} = timeName;
            end
        end
        
        %% Read output data
        function outData = readOutput(obj, outFileName, AmpNum, indexCols, fieldNames, flag)
            if length(indexCols) ~= length(fieldNames)
                ME = MException('MATLAB:LoadErr', ...
                    'Dimensions of indexCols and fieldNames should match');
                throw(ME);
            end
            % Loop in active Amps, GMs
            n = length(obj.runOptions.activeGMs);
            outData = cell(n,length(indexCols)+2);
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                iPaths = obj.runOptions.IDAOptions(i).outputPath;
                outData{ii,1} = obj.runOptions.IDAOptions(i).num;
                outData{ii,2} = obj.runOptions.IDAOptions(i).AnalysisCases;
                outFile = dir([iPaths{AmpNum,1}, '\', outFileName]);
                if size(outFile, 1) > 1
                    ME = MException('MATLAB:LoadErr', ...
                        'Ambiguous .out file name, check the expression for outFileName');
                    throw(ME);
                elseif size(outFile, 1) == 0
                    ME = MException('MATLAB:LoadErr', ...
                        'The specified .out file does not exist, check out files');
                    throw(ME);
                end
                tempData = load([iPaths{AmpNum,1}, '\', outFile.name]);
                for j = 1:length(indexCols)
                    outData{ii, j+2} = tempData(:,indexCols(j));
                end
            end
        end
        
        
        %% Read output data - no name
        function outData = readOutput_nn(obj, outFileName, AmpNum, indexCols)

            % Loop in active Amps, GMs
            n = length(obj.runOptions.activeGMs);
            outData = cell(n,length(indexCols)+2);
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                iPaths = obj.runOptions.IDAOptions(i).outputPath;
                outData{ii,1} = obj.runOptions.IDAOptions(i).num;
                outData{ii,2} = obj.runOptions.IDAOptions(i).AnalysisCases;
                outFile = dir([iPaths{AmpNum,1}, '\', outFileName]);
                if size(outFile, 1) > 1
                    ME = MException('MATLAB:LoadErr', ...
                        'Ambiguous .out file name, check the expression for outFileName');
                    throw(ME);
                elseif size(outFile, 1) == 0
                    ME = MException('MATLAB:LoadErr', ...
                        'The specified .out file does not exist, check out files');
                    throw(ME);
                end
                tempData = load([iPaths{AmpNum,1}, '\', outFile.name]);
                for j = 1:length(indexCols)
                    outData{ii, j+2} = tempData(:,indexCols(j));
                end
            end
        end
        
        %% Read output data - max abs value of each column
        function outData = readOutput_maxabs(obj, outFileName, AmpNum, indexCols)

            % Loop in active Amps, GMs
            n = length(obj.runOptions.activeGMs);
            outData = cell(n,length(indexCols)+2);
            for ii = 1:n
                i = obj.runOptions.activeGMs(ii);
                iPaths = obj.runOptions.IDAOptions(i).outputPath;
                outData{ii,1} = obj.runOptions.IDAOptions(i).num;
                outData{ii,2} = obj.runOptions.IDAOptions(i).AnalysisCases;
                outFile = dir([iPaths{AmpNum,1}, '\', outFileName]);
                if size(outFile, 1) > 1
                    ME = MException('MATLAB:LoadErr', ...
                        'Ambiguous .out file name, check the expression for outFileName');
                    throw(ME);
                elseif size(outFile, 1) == 0
                    ME = MException('MATLAB:LoadErr', ...
                        'The specified .out file does not exist, check out files');
                    throw(ME);
                end
                tempData = load([iPaths{AmpNum,1}, '\', outFile.name]);
                for j = 1:length(indexCols)
                    outData{ii, j+2} = max(abs(tempData(:,indexCols(j))));
                end
            end
        end
    end
end