classdef  ModelTab < BasicTab
    
    methods
        
        function ttab = ModelTab(tabgroup)
            ttab = ttab@BasicTab(tabgroup, 'Model');
            
            %lblModelType
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'Type of model', ...
                'Units', 'normalized','Position', [0.05 0.9 0.85 0.05], 'HorizontalAlignment', 'left');
            ddlModelType = uicontrol('Parent', ttab.left_panel, 'Style', 'popupmenu', 'String', {'hard pls-da','soft pls-da'},...
                'Units', 'normalized','Value',2, 'Position', [0.35 0.9 0.45 0.05], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_ModelParameters);
            
            %model params
            %lblNumPC
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'Number of PLS PCs', ...
                'Units', 'normalized','Position', [0.05 0.80 0.85 0.05], 'HorizontalAlignment', 'left');
            tbNumPC = uicontrol('Parent', ttab.left_panel, 'Style', 'edit', 'String', '2',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.80 0.25 0.05], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_NumPC);
            
            %lblAlpha
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'Type I error (alpha)', ...
                'Units', 'normalized','Position', [0.05 0.70 0.85 0.05], 'HorizontalAlignment', 'left');
            tbAlpha = uicontrol('Parent', ttab.left_panel, 'Style', 'edit', 'String', '0.01',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.70 0.25 0.05], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_Alpha);
            
            %lblGamma
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'Outlier significance (gamma)', ...
                'Units', 'normalized','Position', [0.05 0.60 0.5 0.05], 'HorizontalAlignment', 'left');
            tbGamma = uicontrol('Parent', ttab.left_panel, 'Style', 'edit', 'String', '0.01',...
                'Units', 'normalized','Value',1, 'Position', [0.55 0.60 0.25 0.05], 'BackgroundColor', 'white', 'callback', @ModelTab.Input_Gamma);
        end
        
    end
    
    methods (Static)
        
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