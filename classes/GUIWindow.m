classdef  GUIWindow<handle
    properties
        
        dataTab;
        modelTab;
        predictTab;
        cvTab;
        tgroup;
        
        fig;
        
        selected_tab = GUIWindow.DataTabSelected;
        selected_panel = GUIWindow.DataGraph;
        selected_text_panel = GUIWindow.ModelTableAllocation;
        selected_panel_pca = GUIWindow.DataPCAScores;
        
        selected_dataset;
        
    end
    
    properties (Constant)
        DataTabSelected = -1;
        ModelTabSelected = -2;
        PredictTabSelected = -3;
        CVTabSelected = -4;
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
        CVData = 16;
        CVResults = 17;
    end
    
    methods
        
        function my_closereq(self,src,callbackdata)
            % Close request function
            % to display a question dialog box
            if ~isempty(self.modelTab) && ~isempty(self.modelTab.Model) && ~self.modelTab.model_was_saved
                selection = questdlg(sprintf('The current model will be lost!\nDo want to exit without saving it?'),...
                   'Confirm Close',...
                    'Yes','No','No');
                switch selection
                    case 'Yes'
                        delete(gcf)
                    case 'No'
                        return
                end
            else
                delete(gcf)
            end
        end
        
        function deleteDataset(obj, src)
            obj.dataTab.FillDataSetList();
            
            if (~isempty(obj.modelTab))
                tmp = obj.modelTab.ddlCalibrationSet.String;
                selected_name = tmp{obj.modelTab.ddlCalibrationSet.Value};
                
                if(strcmp(src.Name, selected_name))
                    obj.dataTab.RefreshModel();
                else
                    if(~isempty(obj.cvTab))
                        obj.cvTab.FillDataSetList(true);
                    end
                end
            end
            
            if(~isempty(obj.cvTab) && isempty(obj.modelTab))
                
                ind = arrayfun(@(x)isequal(x.Title ,'Cross-validation'),obj.tgroup.Children);
                cvtab = obj.tgroup.Children(ind);
                delete(cvtab);
                delete(obj.cvTab);
                obj.cvTab = [];
            end
            
            
        end
        
        function handleDatasetDelete(obj,src,~)
            %disp([src.Name ' deleted']);
            obj.deleteDataset(src);
            
        end
        
        function TabSelected(self, obj, param)
            
            var = [];
            PlotType = [];
            
            switch obj.SelectedTab.Title
                case 'Data'
                    var = self.dataTab.chkPlotShowObjectNames.Value;
                    PlotType = get(self.dataTab.ddlPlotType, 'Value');
                    self.selected_tab = GUIWindow.DataTabSelected;
                    
                    if self.selected_panel == GUIWindow.DataPCA || strcmp(self.dataTab.pnlPCASettings.Visible, 'on')
                        var = self.dataTab.chkPlotShowObjectNamesPCA.Value;
                        self.dataTab.chkTraining.Enable = 'off';
                        self.dataTab.chkValidation.Enable = 'off';
                    else
                        self.dataTab.chkTraining.Enable = 'on';
                        self.dataTab.chkValidation.Enable = 'on';
                    end
                    
                case 'Model'
                    var = self.modelTab.chkPlotShowObjectNames.Value;
                    self.selected_tab = GUIWindow.ModelTabSelected;
                    
                    idx = find(strcmp(self.modelTab.ddlCalibrationSet.String, self.selected_dataset));
                    if(~isempty(idx) && self.modelTab.ddlCalibrationSet.Value ~= idx)
                        self.modelTab.ddlCalibrationSet.Value = idx;
                        self.modelTab.innerSelectCalibratinSet(self.selected_dataset);
                    end
                    
                case 'Prediction'
                    var = self.predictTab.chkPlotShowObjectNames.Value;
                    self.selected_tab = GUIWindow.PredictTabSelected;
                case 'Cross-validation'
                    %var = self.predictTab.chkPlotShowObjectNames.Value;
                    self.selected_tab = GUIWindow.CVTabSelected;
            end
            
            if(~isempty(var))
                if(var == 1)
                    pan off
                    datacursormode on
                    dcm_obj = datacursormode(self.fig);
                    if isprop(dcm_obj, 'Interpreter')
                        dcm_obj.Interpreter = 'none';
                    end
                    set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                else
                    datacursormode off
                    if isempty(PlotType) || PlotType == 1 && self.selected_panel == GUIWindow.DataGraph
                        pan on
                    else
                        pan off
                    end
                    
                    if get(self.dataTab.ddlPlotTypePCA,'value')==2 && self.selected_panel_pca == GUIWindow.DataPCALoadings
                        pan on
                    else
                        pan off
                    end
                end
            end
        end
        
        function ActiveTabSelected(self, obj, param)
            
            var = [];
            PlotType = [];
            
            switch self.selected_tab
                case GUIWindow.DataTabSelected
                    switch obj.SelectedTab.Title
                        case 'Graphical view'
                            self.selected_panel = GUIWindow.DataGraph;
                            var = self.dataTab.chkPlotShowObjectNames.Value;
                            PlotType = get(self.dataTab.ddlPlotType, 'Value');
                        case 'Table view'
                            self.selected_panel = GUIWindow.DataTable;
                        case 'PCA'
                            self.selected_panel = GUIWindow.DataPCA;
                            var = self.dataTab.chkPlotShowObjectNamesPCA.Value;
                        case 'Scores'
                            self.selected_panel_pca = GUIWindow.DataPCAScores;
                        case 'Loadings'
                            self.selected_panel_pca = GUIWindow.DataPCALoadings;
                            var = get(self.dataTab.chkPlotShowObjectNamesPCA,'value');
                    end
                case GUIWindow.ModelTabSelected
                    switch obj.SelectedTab.Title
                        case 'Classification plot'
                            self.selected_panel = GUIWindow.ModelGraph;
%                         case 'Classification table'
%                             self.selected_panel = GUIWindow.ModelTable;
                        case 'Allocation table'
                            self.selected_panel = GUIWindow.ModelTable;
                            self.selected_text_panel = GUIWindow.ModelTableAllocation;
                        case 'Confusion matrix'
                            self.selected_panel = GUIWindow.ModelTable;
                            self.selected_text_panel = GUIWindow.ModelTableConfusion;
                        case 'Figures of merit'
                            self.selected_panel = GUIWindow.ModelTable;
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
                case GUIWindow.CVTabSelected
                    switch obj.SelectedTab.Title
                        case 'Data'
                            self.selected_panel = GUIWindow.CVData;
                        case 'Results'
                            %self.cvTab.ShowResults();
                            self.cvTab.Redraw();
                            self.selected_panel = GUIWindow.CVResults;
                    end
            end
            
            %if self.selected_tab == GUIWindow.DataTabSelected
            if self.selected_panel == GUIWindow.DataTable
                set(self.dataTab.pnlPlotSettings,'visible','off');
                set(self.dataTab.pnlTableSettings,'visible','on');
                set(self.dataTab.pnlPCASettings,'visible','off');
                self.dataTab.vbox.Heights=[40,30,40,40,0,160,0];
                
                self.dataTab.chkTraining.Enable = 'on';
                self.dataTab.chkValidation.Enable = 'on';
            end
            
            if self.selected_panel == GUIWindow.DataGraph
                set(self.dataTab.pnlPlotSettings,'visible','on');
                set(self.dataTab.pnlTableSettings,'visible','off');
                set(self.dataTab.pnlPCASettings,'visible','off');
                if ispc
                    self.dataTab.vbox.Heights=[40,30,40,40,170,0,0];
                else
                    self.dataTab.vbox.Heights=[40,30,40,40,160,0,0];
                end
                
                self.dataTab.chkTraining.Enable = 'on';
                self.dataTab.chkValidation.Enable = 'on';
            end
            
            if self.selected_panel == GUIWindow.DataPCA
                set(self.dataTab.pnlPlotSettings,'visible','off');
                set(self.dataTab.pnlTableSettings,'visible','off');
                set(self.dataTab.pnlPCASettings,'visible','on');
                
                index_selected = get(self.dataTab.listbox,'Value');
                names = get(self.dataTab.listbox,'String');
                selected_name = names{index_selected};
                
                if index_selected > 1
                    d = evalin('base', selected_name);
                    if d.HasPCA
                        param = 'on';
                        self.dataTab.DrawPCA();
                    else
                        param = 'off';
                    end
                else
                    param = 'off';
                end
                
                self.dataTab.chkTraining.Enable = 'off';
                self.dataTab.chkValidation.Enable = 'off';
                
                
                self.dataTab.enablePCAPanel(param);
                
                self.dataTab.vbox.Heights=[40,30,40,40,0,0,150];
                
            end
            
            if self.selected_panel_pca == GUIWindow.DataPCAScores
                set(self.dataTab.hbox_pca_plot_type,'visible','off');
                set(self.dataTab.hbox_pca_plot_options,'visible','on');
                self.dataTab.vbox_pca.Heights=[20,20,0,25];
                set(self.dataTab.chkPlotShowClassesPCA,'enable','on');
                
                %self.dataTab.chkTraining.Enable = 'off';
                %self.dataTab.chkValidation.Enable = 'off';

                obj_index_selected = get(self.dataTab.listbox,'Value');
                names = get(self.dataTab.listbox,'String');
                selected_name = names{obj_index_selected};
                
                if obj_index_selected > 1
                    d = evalin('base', selected_name);
                    
                    if(d.HasPCA)
                        set(self.dataTab.chkPlotShowObjectNamesPCA,'enable','on');
                    else
                        set(self.dataTab.chkPlotShowObjectNamesPCA,'enable','off');
                    end
                    
                    if isempty(d.Classes) || ~d.HasPCA
                        set(self.dataTab.chkPlotShowClassesPCA, 'value', 0);
                        set(self.dataTab.chkPlotShowClassesPCA, 'enable', 'off');
                    end
                end
                
                
            end
            
            if self.selected_panel_pca == GUIWindow.DataPCALoadings
                set(self.dataTab.hbox_pca_plot_type,'visible','on');
                set(self.dataTab.chkPlotShowClassesPCA,'enable','off');
                self.dataTab.vbox_pca.Heights=[20,20,25,0];
                
                %self.dataTab.chkTraining.Enable = 'off';
                %self.dataTab.chkValidation.Enable = 'off';
                
                if(self.dataTab.ddlPlotTypePCA.Value == 2)%line
                    set(self.dataTab.chkPlotShowObjectNamesPCA,'enable','off');

                    self.dataTab.ddlPCApc1.Enable = 'off';
                    self.dataTab.ddlPCApc2.Enable = 'off';
                end
                
            end
            
            %end
            
            %if self.selected_tab == GUIWindow.ModelTabSelected
            if self.selected_panel == GUIWindow.ModelTable
                set(self.modelTab.pnlPlotSettings,'visible','off');
                set(self.modelTab.pnlTableSettings,'visible','on');
                self.modelTab.vbox.Heights=[40,180,0,50];
            end
            
            if self.selected_panel == GUIWindow.ModelGraph
                set(self.modelTab.pnlPlotSettings,'visible','on');
                set(self.modelTab.pnlTableSettings,'visible','off');
                
                if ispc
                    self.modelTab.vbox.Heights=[40,180,120,0];
                else
                    self.modelTab.vbox.Heights=[40,180,110,0];
                end
            end
            
            %end
            
            %if self.selected_tab == GUIWindow.PredictTabSelected
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
            
            %end
            
            %if self.selected_tab == GUIWindow.CVTabSelected
            if self.selected_panel == GUIWindow.CVResults
                set(self.cvTab.pnlResultsSettings,'visible','on');
                
                
                self.cvTab.pnlDataSettings.Visible = 'off';
                self.cvTab.pnlCrossValidationSettings.Visible  = 'off';
                self.cvTab.pnlModelSettings.Visible = 'off';
                
                if self.cvTab.ddlResultViewMode.Value == 1 % Graphics
                    self.cvTab.vbox.Heights=[0,0,0,200,100,0];
                    set(self.cvTab.pnlPlotSettings,'visible','on');
                    set(self.cvTab.pnlTableSettings,'visible','off');
                else
                    self.cvTab.vbox.Heights=[0,0,0,200,0,60];
                    set(self.cvTab.pnlPlotSettings,'visible','off');
                    set(self.cvTab.pnlTableSettings,'visible','on');
                end
                    
            end
            
            if self.selected_panel == GUIWindow.CVData
                set(self.cvTab.pnlResultsSettings,'visible','off');
                
                self.cvTab.pnlDataSettings.Visible = 'on';
                self.cvTab.pnlCrossValidationSettings.Visible  = 'on';
                self.cvTab.pnlModelSettings.Visible = 'on';
                
                if ispc
                    self.cvTab.vbox.Heights=[40,130,150,0,0,0];
                else
                    self.cvTab.vbox.Heights=[40,120,150,0,0,0];
                end
            end
            
            %end
            
            if(~isempty(var))
                if(var == 1)
                    pan off
                    datacursormode on
                    dcm_obj = datacursormode(self.fig);
                    if isprop(dcm_obj, 'Interpreter')
                        dcm_obj.Interpreter = 'none';
                    end
                    set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                else
                    datacursormode off
                    if (isempty(PlotType) || PlotType == 1) && self.selected_panel == GUIWindow.DataGraph
                        pan on
                    else
                        pan off
                    end
                    
                    if get(self.dataTab.ddlPlotTypePCA,'value')==2 && self.selected_panel_pca == GUIWindow.DataPCALoadings
                        set(self.dataTab.chkPlotShowObjectNamesPCA,'enable','off');
                        set(self.dataTab.chkPlotShowObjectNamesPCA,'value', 0);
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
        
        function win = GUIWindow(tabs, extra_title, model)
            
            if nargin == 1
                extra_title = '';
            else
                extra_title = [' - Model: ' extra_title];
            end
            
            if nargin < 3
                model = [];
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
            set(f,'CloseRequestFcn',@win.my_closereq);
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
                
                if ~isempty(model)
                    win.modelTab.Model = model;
                end
            end
            
            if tabs(3) && isempty(win.predictTab)
                win.predictTab = PredictTab(win.tgroup, win);
            end
            
            if tabs(4) && isempty(win.cvTab)
                win.cvTab = CVTab(win.tgroup, win);
            end
            
            set(win.tgroup, 'SelectionChangedFcn', @win.TabSelected);
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                names = varnames(idx);
                %dataset_list = cell(1, length(names));
                for i = 1:length(names)
                    d = evalin('base', names{i});
                    %dataset_list{i} = d;
                    addlistener(d,'Deleting',@win.handleDatasetDelete);
                end
                
            end
            
        end
        
    end
    
    methods (Static)
        
        function r = filter_data(x)
            d = evalin('base', x.name);
            r = isequal(x.class,'DataSet') && d.NumberOfClasses > 1;
        end
        
        function output_txt = DataCursorFunc(obj,event_obj)
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
                is_num = false;
                if isa(str,'double')
                    str = {sprintf('%.2f', str)};
                    is_num = true;
                end
                
                if ~isempty(classes)
                    cls = classes(index);
                    class_labels = event_obj.Target.Parent.UserData{5};
                    
                    if isempty(flag)
                        if isempty(class_labels)
                            output_txt = sprintf('Object: %s\nClass: %d', str{1}, cls);
                        else
                            output_txt = sprintf('Object: %s\nClass: %s', str{1}, class_labels{cls});
                        end
                    else
                        if is_num
                            output_txt = sprintf('Wavelength: %s', str{1});
                        else
                            output_txt = sprintf('Variable: %s', str{1});
                        end
                    end
                    
                else
                    
                    if isempty(flag)
                        output_txt = sprintf('Object: %s', str{1});
                    else
                        if is_num
                            output_txt = sprintf('Wavelength: %s', str{1});
                        else
                            output_txt = sprintf('Variable: %s', str{1});
                        end
                    end
                    
                end
                
            else
                output_txt = 'not an object';
            end
            
            
        end
        
    end
    
end