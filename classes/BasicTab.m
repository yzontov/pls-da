classdef  BasicTab < handle
    properties
        parent;
    end
    
    properties (Access = protected)
        tab;
        left_panel;
        middle_panel;
        %right_panel;
        %statusbar_panel;
        
        data_plot_axes;
        data_plot;
        layout;
        
    end
    methods
        
                
        
        
        function ttab = BasicTab(tabgroup, title, parent)
            %Model
            
            ttab.parent = parent;
            
            v = version('-release');
            vyear = str2double(v(1:4));
            
            %             width = tabgroup.Position(3);
            %             height = tabgroup.Position(4);
            
            if vyear < 2014
                ttab.tab = uitab('v0', 'Parent', tabgroup, 'Title', title);
            else
                ttab.tab = uitab('Parent', tabgroup, 'Title', title);
            end
            
            ttab.layout = uiextras.HBox( 'Parent', ttab.tab );
            
            ttab.left_panel = uipanel('Parent', ttab.layout, 'Title', '');
            ttab.middle_panel = uipanel('Parent', ttab.layout, 'Title', '');
            %ttab.right_panel = uipanel('Parent', ttab.layout, 'Title', '');
            %ttab.statusbar_panel = uipanel('Parent', layout, 'Title', '', 'Units','normalized', 'Position', [0.0   0.0   1  0.05]);
            ttab.layout.Sizes = [300 -1];
            ttab.layout.MinimumSizes = [300 300];

        end
        
    end
    
end