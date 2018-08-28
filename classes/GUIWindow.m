classdef  GUIWindow<handle
    properties
        dataTab;
        modelTab;
        predictTab;
        tgroup;
        
        fig;
    end
    methods
        
        function TabSelected(self, obj, param)

            var = [];
            PlotType = [];
            
            switch obj.SelectedTab.Title
                case 'Data'
                    var = self.dataTab.chkPlotShowObjectNames.Value;
                    PlotType = get(self.dataTab.ddlPlotType, 'Value');
                case 'Model'
                    var = self.modelTab.chkPlotShowObjectNames.Value;
                case 'Prediction'
                    var = self.predictTab.chkPlotShowObjectNames.Value;
            end
            
            if(~isempty(var))
                if(var == 1)
                    pan off
                    datacursormode on
                    dcm_obj = datacursormode(self.fig);
                    set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                else
                    datacursormode off
                    if isempty(PlotType) || PlotType == 1
                        pan on
                    else
                        pan off
                    end
                end
            end
        end
        
        function Help_Callback(self, obj, param)
            web('help/index.html')
        end
        
        function win = GUIWindow(tabs, extra_title)
            
            if nargin == 1
                extra_title = '';
            else
                extra_title = [' - Model: ' extra_title];
            end
            
            %get version year
            v = version('-release');
            vyear = str2double(v(1:4));
            
            if vyear < 2014
                screensize = get( 0, 'Screensize' );
            else
                screensize = get( groot, 'Screensize' );
            end        
            
            %gui
            f = figure;
            set(f,'Visible','on');
            set(f, 'MenuBar', 'none');
            set(f, 'ToolBar', 'none');
            set(f,'name',['PLS-DA Tool' extra_title],'numbertitle','off');
            %set(f, 'Resize', 'off');
            %set(f, 'Units', 'pixels');
            set(f, 'OuterPosition', [screensize(3)/2 - 400 screensize(4)/2 - 200 800 400]);
            
            LimitFigSize(f, 'min', [800, 400]);
            
            mh = uimenu(f,'Label','Help');
            uimenu(mh,'Label','Help on PLSDAGUI','Callback', @win.Help_Callback);
            
            if vyear < 2014
                win.tgroup = uitabgroup('v0','Parent', f);
            else
                win.tgroup = uitabgroup('Parent', f);
            end
            
            win.fig = f;
            
            if tabs(1)
                win.dataTab = DataTab(win.tgroup, win);
            end
            
            if tabs(2)
                win.modelTab = ModelTab(win.tgroup, win);
            end
            
            if tabs(3)
                win.predictTab = PredictTab(win.tgroup, win);
            end
            
            
            
            set(win.tgroup, 'SelectionChangedFcn', @win.TabSelected);
            
        end
        
    end
    
    methods (Static)
        function output_txt = DataCursorFunc(~,event_obj)
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % output_txt   Data cursor text
        if (isa(event_obj.Target, 'matlab.graphics.chart.primitive.Scatter') || ~isequal(event_obj.Target.LineStyle,'-') && ~isequal(event_obj.Target.LineStyle,'--')&& ~isequal(event_obj.Target.LineStyle,'+'))
            data = event_obj.Target.Parent.UserData{1};
            d = data;
            
            if(size(data,2) == 1)
                d = [d zeros(size(d))];
            end
            
            Xdata = d(:,1);%get(event_obj.Target,'xdata');
            Ydata = d(:,2);%get(event_obj.Target,'ydata');
            
            Xdiff = Xdata - event_obj.Position(1);
            Ydiff = Ydata - event_obj.Position(2);
            
            distnce = sqrt(Xdiff.^2+Ydiff.^2);
            
            labels = event_obj.Target.Parent.UserData{2};
            classes = event_obj.Target.Parent.UserData{3};
            
            flag = event_obj.Target.Parent.UserData{4};
            
            index = distnce == min(distnce);
            
            str = labels(index);
            
            if ~isempty(classes)
                cls = classes(index);
                
                if isempty(flag)
                    output_txt = sprintf('Object: %s\nClass: %d', str{1}, cls);
                else
                    output_txt = sprintf('Variable: %s', str{1});
                end
                
            else
                
                if isempty(flag)
                    output_txt = sprintf('Object: %s', str{1});
                else
                    output_txt = sprintf('Variable: %s', str{1});
                end
                
            end
            
        else
            output_txt = 'not an object';
        end
        end
        
    end
    
end