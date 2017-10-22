classdef  ModelTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;
        pnlCrossValidationSettings;
        pnlModelSettings
        pnlPlotSettings;
        
        ddlModelType;
        tbNumPC;
        tbAlpha;
        tbGamma;
        
        chkFinalizeModel;
        
        ddlCalibrationSet;
        ddlValidationSet;
        
        chkCrossValidation;
        ddlCrossValidationType;
    end
    
    methods
        
        function ttab = ModelTab(tabgroup)
            
            ttab = ttab@BasicTab(tabgroup, 'Model');
            
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Data','Units', 'normalized', ...
                'Position', [0.05   0.84   0.9  0.15]);
            
            ttab.pnlCrossValidationSettings = uipanel('Parent', ttab.left_panel, 'Title', 'CrossValidation','Units', 'normalized', ...
                'Position', [0.05   0.68   0.9  0.15]);
            
            ttab.pnlModelSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Model','Units', 'normalized', ...
                'Position', [0.05   0.32   0.9  0.35]);
            
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.01   0.9  0.3]);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'Calibration', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlCalibrationSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.65 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ModelTab.SelectCalibratinSet);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'Validation', ...
                'Units', 'normalized','Position', [0.05 0.25 0.35 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlValidationSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.25 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ModelTab.SelectValidationSet);
            
            %CrossValidation
            ttab.chkCrossValidation = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'checkbox', 'String', 'Use cross-validation',...
                'Units', 'normalized','Position', [0.05 0.7 0.85 0.2], 'callback', @ModelTab.Callback_UseCrossValidation);
            uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'text', 'String', 'Cross-validation type', ...
                'Units', 'normalized','Position', [0.05 0.3 0.85 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlCrossValidationType = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'popupmenu', 'String', {'Leave-one-Out', 'K-fold', 'Holdout', 'Monte Carlo'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.3 0.45 0.2], 'BackgroundColor', 'white', 'callback', @ModelTab.Callback_CrossValidationType);
            
            %lblModelType
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Type of model', ...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlModelType = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'popupmenu', 'String', {'hard pls-da','soft pls-da'},...
                'Units', 'normalized','Value',2, 'Position', [0.35 0.85 0.45 0.1], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_ModelParameters);
            
            %model params
            %lblNumPC
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Number of PLS PCs', ...
                'Units', 'normalized','Position', [0.05 0.7 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbNumPC = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '2',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.7 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_NumPC);
            
            %lblAlpha
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Type I error (alpha)', ...
                'Units', 'normalized','Position', [0.05 0.55 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbAlpha = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '0.01',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.55 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_Alpha);
            
            %lblGamma
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Outlier significance (gamma)', ...
                'Units', 'normalized','Position', [0.05 0.4 0.5 0.1], 'HorizontalAlignment', 'left');
            ttab.tbGamma = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '0.01',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.4 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_Gamma);
            
            ttab.chkFinalizeModel = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'checkbox', 'String', 'Finalized',...
                'Units', 'normalized','Position', [0.05 0.25 0.85 0.15], 'callback', @ModelTab.Finalize);
            
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'pushbutton', 'String', 'Recalibrate',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.15], ...
                'callback', @ModelTab.Recalibrate);
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'pushbutton', 'String', 'Save Model',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.15], ...
                'callback', @ModelTab.SaveModel);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.25 0.4 0.18], ...
                'callback', @ModelTab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.25 0.4 0.18], ...
                'callback', @ModelTab.CopyPlotToClipboard);
            
            data = guidata(gcf);
            
            dat = data.datatab.Data;
            names = fieldnames(dat);
            
            train_names = names(structfun(@(x) x.Training == true , dat));
            val_names = names(structfun(@(x) x.Validation == true , dat));
            
            if ~isempty(train_names)
                set(ttab.ddlCalibrationSet, 'String', train_names);
            end
            
            if ~isempty(val_names)
                set(ttab.ddlValidationSet, 'String', val_names);
                set(ttab.ddlValidationSet, 'enable', 'on');
            else
                set(ttab.ddlValidationSet, 'enable', 'off');
            end
            
            data.modeltab = ttab;
            guidata(gcf, data);
            
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