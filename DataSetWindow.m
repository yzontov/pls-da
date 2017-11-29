classdef  DataSetWindow<handle
    properties
        tbName;
        ddlData;
        ddlClasses;
        ddlObjectNames;
        ddlVariableNames;
        ddlVariables;
        ddlClassLabels;
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
            win.tbName = uicontrol('Parent', input_win, 'Style', 'edit', 'String', '',...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Check_Name);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlData = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClasses = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlObjectNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlVariableNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlVariables = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
           
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClassLabels = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
           
            
        end
        
    end
   
    
end