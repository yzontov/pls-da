classdef  DataSetWindow<handle
    properties
        dataTab;
        modelTab;
        predictTab;
        tgroup;
    end
    methods
        
        function win = DataSetWindow(tabs)
            
            %get version year
            v = version('-release');
            vyear = str2double(v(1:4));
            
            data = struct;
            
            %gui
            f = figure;
            set(f,'Visible','on');
            set(f, 'MenuBar', 'none');
            set(f, 'ToolBar', 'none');
            set(f,'name','PLS-DA Tool','numbertitle','off');
            %set(f, 'Resize', 'off');
            set(f, 'Units', 'Normalized');
            set(f, 'Position', [0.1 0.1 0.8 0.8]);
            
            if vyear < 2014
                win.tgroup = uitabgroup('v0','Parent', f);
            else
                win.tgroup = uitabgroup('Parent', f);
            end
            
            data.window = win;
            guidata(gcf, data);

            if tabs(1)
                win.dataTab = DataTab(win.tgroup);
            end
            
            if tabs(2)
                win.modelTab = ModelTab(win.tgroup);
            end
            
            if tabs(3)
                win.predictTab = BasicTab(win.tgroup, 'Prediction');
            end
            
        end
        
    end
   
    
end