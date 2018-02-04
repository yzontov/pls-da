classdef  DataSetWindow<handle
    properties
        tbName;
        ddlData;
        ddlClasses;
        ddlObjectNames;
        ddlVariableNames;
        ddlVariables;
        ddlClassLabels;
        
        Name;
        Data;
        Classes;
        ObjectNames;
        VariableNames;
        Variables;
        ClassLabels;
    end
    methods
        
        function win = DataSetWindow()
            
            %get version year
            v = version('-release');
            vyear = str2double(v(1:4));
            
            if vyear < 2014
                screensize = get( 0, 'Screensize' );
            else
                screensize = get( groot, 'Screensize' );
            end
            
            input_win = figure;
            set(input_win,'Visible','on');
            set(input_win, 'MenuBar', 'none');
            set(input_win, 'ToolBar', 'none');
            set(input_win,'name','Create New DataSet','numbertitle','off');
            set(input_win, 'Resize', 'off');
            set(input_win, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 300 400]);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Name', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.tbName = uicontrol('Parent', input_win, 'Style', 'edit', 'String', '', ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Check_Name);
            
            
            
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Data', ...
                'Units', 'normalized','Position', [0.05 0.75 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlData = uicontrol('Parent', input_win, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.75 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            varsizes = {allvars.size};
            
            idx = find(cellfun(@(x)isequal(x,'double'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx),1);
                for i = 1:length(idx)
                    ss = varsizes{idx(i)};
                    vardisplay{i} = sprintf('%s (%dx%d)',varnames{idx(i)},ss(1),ss(2));
                end
                set(win.ddlData, 'String', vardisplay);
            end
            
            
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Classes', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClasses = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.65 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Object names', ...
                'Units', 'normalized','Position', [0.05 0.55 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlObjectNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.55 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Variable names', ...
                'Units', 'normalized','Position', [0.05 0.45 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlVariableNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.45 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            %             uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Variables', ...
            %                 'Units', 'normalized','Position', [0.05 0.35 0.35 0.05], 'HorizontalAlignment', 'left');
            %             win.ddlVariables = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'},...
            %                 'Units', 'normalized','Value',2, 'Position', [0.45 0.35 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Class labels', ...
                'Units', 'normalized','Position', [0.05 0.35 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClassLabels = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.35 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            
        end
        
        function r = type_size_filter(x, k)
            s = x.size;
            if isequal(x.class,'double') && s(1) == k(1) && s(2) == k(2)
                r = true;
            else
                r = false;
            end
            
        end
        
    end
    
    
end