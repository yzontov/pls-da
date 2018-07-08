classdef  BasicTab < handle
    properties
        parent;
    end
    
    properties (Access = protected)
        tab;
        left_panel;
        middle_panel;
        %right_panel;
        statusbar_panel;
        
        data_plot_axes;
        data_plot;
        
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
            
            ttab.left_panel = uipanel('Parent', ttab.tab, 'Title', '', 'Units', 'normalized',  'Position', [0.0   0.05   0.3  0.95]);
            ttab.middle_panel = uipanel('Parent', ttab.tab, 'Title', '', 'Units','normalized', 'Position', [0.3   0.05   0.7  0.95]);
            %ttab.right_panel = uipanel('Parent', ttab.tab, 'Title', 'Right', 'Units','normalized', 'Position', [0.8   0.05   0.2  0.95]);
            ttab.statusbar_panel = uipanel('Parent', ttab.tab, 'Title', '', 'Units','normalized', 'Position', [0.0   0.0   1  0.05]);
            
        end
        
    end
    
end