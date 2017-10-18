classdef  DataInputWindow<handle
    properties
        dataTab;
        modelTab;
        predictTab;
        tgroup;
    end
    methods
        
        function win = DataInputWindow()
            
        %gui
            f = figure;
            set(f,'Visible','on');
            set(f, 'MenuBar', 'none');
            set(f, 'ToolBar', 'none');
            set(f,'name','PLS-DA Tool. Data Input','numbertitle','off');
            %set(f, 'Resize', 'off');
            set(f, 'Units', 'Normalized');
            set(f, 'Position', [0.1 0.1 0.8 0.8]);
            
            
        end
        
    end
    
end