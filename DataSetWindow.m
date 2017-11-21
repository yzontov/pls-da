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
            
            start_screen = figure;
            set(start_screen,'Visible','on');
            set(start_screen, 'MenuBar', 'none');
            set(start_screen, 'ToolBar', 'none');
            set(start_screen,'name','Create New DataSet','numbertitle','off');
            set(start_screen, 'Resize', 'off');
            set(start_screen, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 300 400]);
            
            
        end
        
    end
   
    
end