function PLSDAGUI(varargin)
%PLS-DA Tool GUI
%------------------
%The software implementation of hard and soft approaches to 
%Partial Least Squares Discriminant Analysis (PLS-DA) 
%can be used for both multi-class and two-class classification.
%<a href="matlab:web('help/index.html')">read more</a>
%
%Reference:
%A.L. Pomerantsev, O.Ye. Rodionova, 
%"Multiclass partial least squares discriminant analysis: 
%Taking the right way - A critical tutorial", 
%J. Chemometrics, 32(8): e3030 (2018). 
%<a href="matlab:web('https://onlinelibrary.wiley.com/doi/abs/10.1002/cem.3030')">DOI: 10.1002/cem.3030</a>

addpath(genpath('help'));
addpath('classes');
addpath(genpath('utils'));

ShowStartScreen();

    function ShowStartScreen()
        
            allvars = evalin('base','whos');
            opts = struct('WindowStyle','modal','Interpreter','none');
            if isempty(allvars)
                warndlg('You should load all neccessary data as variables into the current Matlab workspace first!','Warning',opts);
            else
                warning('off','all');
                
                %get version year
                v = version('-release');
                vyear = str2double(v(1:4));
                
                if vyear < 2014
                    screensize = get( 0, 'Screensize' );
                else
                    screensize = get( groot, 'Screensize' );
                end
                
                start_screen = figure;
                set(start_screen,'Visible','on');
                set(start_screen, 'MenuBar', 'none');
                set(start_screen, 'ToolBar', 'none');
                set(start_screen,'name','PLS-DA Tool','numbertitle','off');
                set(start_screen, 'Resize', 'off');
                set(start_screen, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 200 100]);
                
                uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'New model',...
                    'Position', [50 55 100 30], 'callback', @btnNewModel_Callback);
                
                btnSelectModel = uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'Existing model',...
                    'Position', [50 15 100 30], 'Enable', 'off', 'callback', @btnExistingModel_Callback);
                
                allvars = evalin('base','whos');
        
                idx = arrayfun(@(x)filter_model(x), allvars);
                
                if(sum(idx) > 0)
                    set(btnSelectModel, 'Enable', 'on');
                end
                
            end
        
    end

    function btnNewModel_Callback(obj, ~)
        
        close(get(obj,'Parent'));
        
        allvars = evalin('base','whos');
        
        idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
        
        vect = [1 0 0];
        if sum(idx) > 0
            vect = [1 1 0];
        end
        
        win = GUIWindow(vect);
        
    end

    function r = filter_model(x)
            d = evalin('base', x.name);
            if isequal(x.class,'PLSDAModel')
                r = true;
            else
                r = false;
            end
    end

    function btnExistingModel_Callback(obj, ~)
        
        [tvar, tvarname] = uigetvariables({'Pick a PLSDAModel object:'}, ...
            'ValidationFcn',{@(x) isa(x, 'PLSDAModel')});
        if ~isempty(tvar)
            close(get(obj,'Parent'));
            
            Model = tvar{1};
            
            vect = [1 1 0];
            if Model.Finalized
                vect = [1 1 1];
            end
            
            assignin('base', Model.TrainingDataSet.Name, Model.TrainingDataSet);
            
            win = GUIWindow(vect, tvarname{1}, Model);
            
            
        end
        
    end

end



