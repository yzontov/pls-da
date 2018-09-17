function PLSDAGUI(varargin)

addpath('classes');
addpath('utils');

ShowStartScreen();

    function ShowStartScreen()
        
        v = ver;
        if ~any(strcmp({v.Name},'GUI Layout Toolbox'))
            warndlg(sprintf('Please install the GUI Layout Toolbox first!\nhttps://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox'));
            fprintf('Please install the GUI Layout Toolbox first!\nhttps://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox\n');
        else
            
            allvars = evalin('base','whos');
            
            if isempty(allvars)
                warndlg('You should load all neccessary data as variables into the current Matlab workspace first!');
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
                
                if(sum(idx) > 1)
                    set(btnSelectModel, 'Enable', 'on');
                end
                
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
            
            win = GUIWindow(vect, tvarname{1});
            win.modelTab.Model = Model;
            
        end
        
    end

end



