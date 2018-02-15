classdef  PredictTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;

        pnlPlotSettings;
        
        
        ddlNewSet;

        
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;

    end
    
    methods
        
        function ttab = PredictTab(tabgroup)
            
            ttab = ttab@BasicTab(tabgroup, 'Prediction');
            
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Prediction','Units', 'normalized', ...
                'Position', [0.05   0.79   0.9  0.2]);

            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.5   0.9  0.28]);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'New DataSet', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlNewSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.4 0.67 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ModelTab.SelectCalibratinSet);

            
                        
             uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'pushbutton', 'String', 'Predict',...
                'Units', 'Normalized', 'Position', [0.3 0.15 0.35 0.25], ...
                'callback', @DataTab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
                      
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.18], ...
                'callback', @ModelTab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.18], ...
                'callback', @ModelTab.CopyPlotToClipboard);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1]);%, 'callback', @DataTab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.1]);%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 1', ...
                'Units', 'normalized','Position', [0.05 0.58 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'1'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.6 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 2', ...
                'Units', 'normalized','Position', [0.05 0.38 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'2'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.4 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            

            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx),1);
                for i = 1:length(idx)
                    vardisplay{i} = varnames{idx(i)};
                end
                set(ttab.ddlNewSet, 'String', vardisplay);
            end
            
            
                       
        end
        
    end
    
    methods (Static)
        
      
        
        function Recalibrate(src, ~)
            
        end
        
        function SaveModel(src, ~)
            
        end
        
        function SavePlot(src, ~)
            
        end
        
        function CopyPlotToClipboard(src, ~)
            
        end
        
        function Finalize(src, ~)
            
        end
        
        function Input_Gamma(src, ~)
            
        end
        
        function Callback_CrossValidationType(src, ~)
            
        end
        
        function Callback_UseCrossValidation(src, ~)
            
        end
        
        function SelectValidationSet(src, ~)
            
        end
        
        function SelectCalibratinSet(src, ~)
            
        end
        
        function Input_ModelParameters(src, ~)
            val = get(src,'Value');
            if ~isempty(val) && ~isnan(val)
                
            end
        end
        
        function CheckPC()
            
            %TBD
        end
        
        function Input_NumPC(src, ~)
            str=get(src,'String');
            %TBD
        end
        
        function Input_Alpha(src, ~)
            str=get(src,'String');
            val = str2double(str);
            if isempty(val) || isnan(val)
                set(src,'string','0.01');
                warndlg('Input must be numerical');
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Type I error (Alpha) should be greater than 0 and less than 1!');
                else
                    %TBD
                end
            end
        end
        
    end
    
end