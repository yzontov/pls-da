classdef  GUIWindow<handle
    properties
        dataTab;
        modelTab;
        predictTab;
        tgroup;
        
        fig;
        selected_tab = GUIWindow.DataTabSelected;
        selected_panel = GUIWindow.DataGraph;
        selected_text_panel = GUIWindow.ModelTableAllocation;
        selected_panel_pca = GUIWindow.DataPCAScores;
    end
    
    properties (Constant)
        DataTabSelected = -1;
        ModelTabSelected = -2;
        PredictTabSelected = -3;
        DataGraph = 1;
        DataTable = 2;
        DataPCA = 13;
        DataPCAScores = 3;
        DataPCALoadings = 4;
        ModelGraph = 5;
        ModelTable = 14;
        ModelTableAllocation = 6;
        ModelTableConfusion = 7;
        ModelTableFoM = 8;
        PredictGraph = 9;
        PredictTable = 15;
        PredictTableAllocation = 10;
        PredictTableConfusion = 11;
        PredictTableFoM = 12;
    end
    
    
    methods
        
        function TabSelected(self, obj, param)

            var = [];
            PlotType = [];
            
            switch obj.SelectedTab.Title
                case 'Data'
                    var = self.dataTab.chkPlotShowObjectNames.Value;
                    PlotType = get(self.dataTab.ddlPlotType, 'Value');
                    self.selected_tab = GUIWindow.DataTabSelected;
                case 'Model'
                    var = self.modelTab.chkPlotShowObjectNames.Value;
                    self.selected_tab = GUIWindow.ModelTabSelected;
                case 'Prediction'
                    var = self.predictTab.chkPlotShowObjectNames.Value;
                    self.selected_tab = GUIWindow.PredictTabSelected;
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
        
        function ActiveTabSelected(self, obj, param)

            var = [];
            str = obj.SelectedTab.Title;
            
            switch self.selected_tab
                case GUIWindow.DataTabSelected
                    switch obj.SelectedTab.Title
                        case 'Graphical view'
                            self.selected_panel = GUIWindow.DataGraph;
                        case 'Table view'
                            self.selected_panel = GUIWindow.DataTable;
                        case 'PCA'
                            self.selected_panel = GUIWindow.DataPCA;
                        case 'Scores'
                            self.selected_panel_pca = GUIWindow.DataPCAScores;
                        case 'Loadings'
                            self.selected_panel_pca = GUIWindow.DataPCALoadings;
                    end
                case GUIWindow.ModelTabSelected
                    switch obj.SelectedTab.Title
                        case 'Graphical view'
                            self.selected_panel = GUIWindow.ModelGraph;
                        case 'Table view'
                            self.selected_panel = GUIWindow.ModelTable;
                        case 'Allocation table'
                            self.selected_text_panel = GUIWindow.ModelTableAllocation;
                        case 'Confusion matrix'
                            self.selected_text_panel = GUIWindow.ModelTableConfusion;
                        case 'Figures of merit'
                            self.selected_text_panel = GUIWindow.ModelTableFoM;
                    end
                case GUIWindow.PredictTabSelected
                    switch obj.SelectedTab.Title
                        case 'Graphical view'
                            self.selected_panel = GUIWindow.PredictGraph;
                        case 'Table view'
                            self.selected_panel = GUIWindow.PredictTable;
                        case 'Allocation table'
                            self.selected_text_panel = GUIWindow.PredictTableAllocation;
                        case 'Confusion matrix'
                            self.selected_text_panel = GUIWindow.PredictTableConfusion;
                        case 'Figures of merit'
                            self.selected_text_panel = GUIWindow.PredictTableFoM;
                    end
            end
%             disp(self.selected_tab)
%             disp(self.selected_panel)
%             disp(self.selected_text_panel)
%             disp(self.selected_panel_pca)
        
        if self.selected_tab == GUIWindow.DataTabSelected
            if self.selected_panel == GUIWindow.DataTable
                set(self.dataTab.pnlPlotSettings,'visible','off');
                set(self.dataTab.pnlTableSettings,'visible','on');
                set(self.dataTab.pnlPCASettings,'visible','off');
                self.dataTab.vbox.Heights=[40,30,40,40,0,150,0];
            end
        
            if self.selected_panel == GUIWindow.DataGraph
                set(self.dataTab.pnlPlotSettings,'visible','on');
                set(self.dataTab.pnlTableSettings,'visible','off');
                set(self.dataTab.pnlPCASettings,'visible','off');
                self.dataTab.vbox.Heights=[40,30,40,40,160,0,0];
            end
        
            if self.selected_panel == GUIWindow.DataPCA
                set(self.dataTab.pnlPlotSettings,'visible','off');
                set(self.dataTab.pnlTableSettings,'visible','off');
                set(self.dataTab.pnlPCASettings,'visible','on');
                
                self.dataTab.vbox.Heights=[40,30,40,40,0,0,150];
                
                if self.selected_panel_pca == GUIWindow.DataPCAScores
                    set(self.dataTab.hbox_pca_plot_type,'visible','off');
                    set(self.dataTab.hbox_pca_plot_options,'visible','on');
                    self.dataTab.vbox_pca.Heights=[20,20,0,25];
                end
                
                if self.selected_panel_pca == GUIWindow.DataPCALoadings
                    set(self.dataTab.hbox_pca_plot_type,'visible','on');
                    %set(self.dataTab.hbox_pca_plot_options,'visible','off');
                    self.dataTab.vbox_pca.Heights=[20,20,25,0];
                end
            end
        
        end
        
        if self.selected_tab == GUIWindow.ModelTabSelected
            if self.selected_panel == GUIWindow.ModelTable
                set(self.modelTab.pnlPlotSettings,'visible','off');
                set(self.modelTab.pnlTableSettings,'visible','on');
                self.modelTab.vbox.Heights=[40,180,0,50];
            end
        
            if self.selected_panel == GUIWindow.ModelGraph
                set(self.modelTab.pnlPlotSettings,'visible','on');
                set(self.modelTab.pnlTableSettings,'visible','off');
                self.modelTab.vbox.Heights=[40,180,120,0];
            end
        
        end
        
        if self.selected_tab == GUIWindow.PredictTabSelected
            if self.selected_panel == GUIWindow.PredictTable
                set(self.predictTab.pnlPlotSettings,'visible','off');
                set(self.predictTab.pnlTableSettings,'visible','on');
                self.predictTab.vbox.Heights=[100,0,50];
            end
        
            if self.selected_panel == GUIWindow.PredictGraph
                set(self.predictTab.pnlPlotSettings,'visible','on');
                set(self.predictTab.pnlTableSettings,'visible','off');
                self.predictTab.vbox.Heights=[100,120,0];
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