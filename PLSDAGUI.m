function PLSDAGUI(varargin)

ShowStartScreen();

    function ShowStartScreen()
        
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
        set(start_screen,'name','PLS-DA Tool (Beta)','numbertitle','off');
        set(start_screen, 'Resize', 'off');
        set(start_screen, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 200 100]);
        
        uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'New model',...
            'Position', [50 55 100 30], 'callback', @btnNewModel_Callback);
        
        uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'Existing model',...
            'Position', [50 15 100 30], 'callback', @btnExistingModel_Callback);
        
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

    function btnExistingModel_Callback(obj, ~)
        
        [tvar, tvarname] = GUIWindow.uigetvariables({'Pick a PLSDAModel object:'}, ...
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



