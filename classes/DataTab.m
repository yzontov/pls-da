classdef  DataTab < BasicTab
    properties
        Data = struct;
        Preprocessing = struct;
        %Training = struct;
        listbox;
        lbox_mnu_train;
        lbox_mnu_val;
        
        %data_plot_axes;
        %data_plot;
        
        pnlDataSettings;
        pnlPlotSettings;
        pnlDataCategories;
        
        ddlPlotType;
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;
        
        chkCentering;
        chkScaling;
        
        chkTraining;
        chkValidation;
        
        tblTextResult;
        tab_img;
        
    end
    methods
        
        
        function ttab = DataTab(tabgroup, parent)
            ttab = ttab@BasicTab(tabgroup, 'Data', parent);
            
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'New dataset',...
                'Units', 'Normalized', 'Position', [0.3 0.9 0.35 0.05], ...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'Data Set', ...
                'Units', 'normalized','Position', [0.05 0.8 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.listbox = uicontrol('Parent', ttab.left_panel, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.21 0.805 0.45 0.05], 'BackgroundColor', 'white', 'callback',@ttab.listClick);
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'Edit',...
                'Units', 'Normalized', 'Position', [0.67 0.815 0.14 0.04], ...
                'callback', @ttab.btnSetEdit_Callback);%,'FontUnits', 'Normalized'
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'Delete',...
                'Units', 'Normalized', 'Position', [0.82 0.815 0.14 0.04], ...
                'callback', @ttab.btnSetDelete_Callback);%,'FontUnits', 'Normalized'
            
            %categories
            ttab.pnlDataCategories = uibuttongroup('Parent', ttab.left_panel, 'Title', 'Categories','Units', 'normalized', ...
                'Position', [0.05   0.65   0.9  0.12]);
            
            %             bg = uibuttongroup('Parent',ttab.pnlDataCategories,...
            %                   'Position',[0 0 1 1],...
            %                   'SelectionChangedFcn',@bselection);
            
            ttab.chkTraining = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'radiobutton', 'String', 'Calibration',...
                'Units', 'normalized','Position', [0.1 0.4 0.45 0.4], 'callback', @ttab.Input_Training);
            ttab.chkValidation = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'radiobutton', 'String', 'New or Test',...
                'Units', 'normalized','Position', [0.55 0.4 0.45 0.4], 'callback', @ttab.Input_Validation);
            
            
            %preprocessing
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Preprocessing','Units', 'normalized', ...
                'Position', [0.05   0.52   0.9  0.12]);
            ttab.chkCentering = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Centering',...
                'Units', 'normalized','Position', [0.1 0.4 0.45 0.4], 'callback', @ttab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Scaling',...
                'Units', 'normalized','Position', [0.55 0.4 0.45 0.4], 'callback', @ttab.Input_Scaling);
            
            %lblPlotType
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.01   0.9  0.5]);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.78 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotType = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'Scatter', 'Line', 'Histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @ttab.Callback_PlotType);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.65 0.85 0.1], 'callback', @ttab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.55 0.85 0.1], 'callback', @ttab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'X-axis', ...
                'Units', 'normalized','Position', [0.05 0.35 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.35 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Y-axis', ...
                'Units', 'normalized','Position', [0.05 0.25 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.25 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Redraw);
            
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.1], ...
                'callback', @ttab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.1], ...
                'callback', @ttab.CopyPlotToClipboard);
            
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            tab_txt = uitab('Parent', tg, 'Title', 'Table view');
            
            %             ttab.tbTextResult = uicontrol('Parent', tab_txt, 'Style', 'edit', 'String', '', ...
            %                 'Units', 'normalized','Position', [0 0 1 1], 'HorizontalAlignment', 'left', 'Max', 2);
            %
            ttab.tblTextResult = uitable(tab_txt);
            ttab.tblTextResult.Units = 'normalized';
            ttab.tblTextResult.Position = [0 0 1 0.9];
            
            uicontrol('Parent', tab_txt, 'Style', 'pushbutton', 'String', 'Select all',...
                'Units', 'Normalized', 'Position', [0.01 0.91 0.1 0.05], ...
                'callback', @ttab.SamplesSelectAll);
            
            uicontrol('Parent', tab_txt, 'Style', 'pushbutton', 'String', 'Select none',...
                'Units', 'Normalized', 'Position', [0.15 0.91 0.1 0.05], ...
                'callback', @ttab.SamplesSelectNone);
            
            uicontrol('Parent', tab_txt, 'Style', 'pushbutton', 'String', 'Inverse selection',...
                'Units', 'Normalized', 'Position', [0.3 0.91 0.15 0.05], ...
                'callback', @ttab.SamplesInverseSelection);
            
            uicontrol('Parent', tab_txt, 'Style', 'pushbutton', 'String', 'Copy selected to new DataSet',...
                'Units', 'Normalized', 'Position', [0.5 0.91 0.25 0.05], ...
                'callback', @ttab.SamplesCopyToNewDataSet);
            
            uicontrol('Parent', tab_txt, 'Style', 'pushbutton', 'String', 'Remove selected',...
                'Units', 'Normalized', 'Position', [0.8 0.91 0.15 0.05], ...
                'callback', @ttab.SamplesRemoveSelection);
            
            ttab.FillDataSetList();
            
            
            
        end
        
        function FillDataSetList(self)
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx)+1,1);
                vardisplay{1} = '-';
                for i = 1:length(idx)
                    vardisplay{i+1} = varnames{idx(i)};
                end
                set(self.listbox, 'String', vardisplay);
                
                % extract all children
                self.enableRightPanel('on');
                
                names = varnames(idx);%fieldnames(ttab.Data);
                selected_name = names{1};
                set(self.listbox, 'Value', 2);
                
                %d = ttab.Data.(selected_name);
                d = evalin('base', selected_name);
                
                
                
                
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                if isempty(d.Classes)
                    set(self.chkPlotShowClasses, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'value', 0);
                    set(self.chkTraining, 'enable', 'off');
                    set(self.chkTraining, 'value', 0);
                end
                
                self.drawPlot(selected_name);
                
                self.FillTableView(selected_name);
                
            else
                self.resetRightPanel();
                self.enableRightPanel('off');
            end
            
        end
        
        function SelectedSamplesChangedCallback(self,hObject,callbackdata)
            numval = callbackdata.EditData;
            r = callbackdata.Indices(1);
            %c = callbackdata.Indices(2)
            %hObject.Data{r,c} = numval;
            
            index_selected = get(self.listbox,'Value');
            names = get(self.listbox,'String');
            selected_name = names{index_selected};
            d = evalin('base', selected_name);
            
            d.SelectedSamples(r) = double(numval);
            
            self.Redraw();
        end
        
        function obj = GetObject(self,list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
        end
        
        function SamplesSelectAll(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = ones(size(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                self.Redraw();
            end
        end
        
        function SamplesSelectNone(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = zeros(size(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                delete(self.data_plot_axes);
                
            end
        end
        
        function SamplesInverseSelection(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = double(not(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                self.Redraw();
            end
        end
        
        function SamplesCopyToNewDataSet(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                prompt = {'Enter new data set name:'};
                dlg_title = 'Save';
                num_lines = 1;
                def = {'new_dataset'};
                
                if(sum(d.SelectedSamples) == size(d.RawData,1))
                    def = {[d.Name '_copy']};
                end
                
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                
                if ~isempty(answer)
                    
                    new_d = DataSet();
                    new_d.RawData = d.RawData(logical(d.SelectedSamples),:);
                    new_d.Centering = d.Centering;
                    new_d.Scaling = d.Scaling;
                    new_d.Classes = d.Classes(logical(d.SelectedSamples),:);
                    new_d.VariableNames = d.VariableNames;
                    new_d.Variables = d.Variables;
                    new_d.ObjectNames = d.ObjectNames(logical(d.SelectedSamples),:);
                    new_d.ClassLabels = d.ClassLabels;
                    
                    try
                        new_d.Name = answer{1};
                        assignin('base', answer{1}, new_d)
                    catch
                        errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!');
                        tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                        new_d.Name = tmp;
                        assignin('base',tmp, new_d);
                    end
                    
                    self.FillDataSetList();
                end
                
                %self.FillTableView(selected_name);
                %self.Redraw();
            end
        end
        
        function SamplesRemoveSelection(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                answer = questdlg('Do you want to delete selected rows from the dataset?', ...
                    'Delete selected rows', ...
                    'Yes','No','No');
                
                if isequal(answer, 'Yes')
                    
                    t = d.SelectedSamples;
                    if sum(t) < size(d.RawData, 1)
                        d.RawData = d.RawData(not(t),:);
                        d.RawClasses = d.RawClasses(not(t),:);
                        if ~isempty(d.ObjectNames)
                            d.ObjectNames = d.ObjectNames(not(t),:);
                        end
                        self.FillTableView(selected_name);
                        self.Redraw();
                    else
                        warndlg('The resulting dataset will be empty!');
                    end
                end
            end
        end
        
        function Redraw(self,obj, ~)
            
            index_selected = get(self.listbox,'Value');
            names = get(self.listbox,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            
            self.drawPlot(selected_name);
        end
        
        function SavePlot(self,obj, ~)
            if ~isempty(self.data_plot)
                PlotType = get(self.ddlPlotType,'Value');
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);%ttab.Data.(selected_name);
                
                switch PlotType
                    case 1 %scatter
                        var1 = get(self.ddlPlotVar1,'Value');
                        var2 = get(self.ddlPlotVar2,'Value');
                        if ~isempty(d.SelectedObjectNames)
                            type = sprintf('scatter_%s_%s_%s', selected_name, d.SelectedObjectNames{var1}, d.SelectedObjectNames{var2});
                        else
                            type = sprintf('scatter_%s_var%d_var%d', selected_name, var1, var2);
                        end
                    case 2 %line
                        type = sprintf('line_%s', selected_name);
                    case 3 %histogram
                        var1 = get(self.ddlPlotVar1,'Value');
                        if ~isempty(d.VariableNames)
                            type = sprintf('histogram_%s_%s', selected_name, d.SelectedObjectNames{var1});
                        else
                            type = sprintf('histogram_%s_var%d', selected_name, var1);
                        end
                end
                
                filename = [type,'.png'];
                if ispc
                    filename = [type,'.emf'];
                end
                
                fig2 = figure('visible','off');
                copyobj(self.data_plot_axes,fig2);
                saveas(fig2, filename);
                %print(ttab.data_plot, filename, '-dpng');
            end
        end
        
        function CopyPlotToClipboard(self,obj, ~)
            fig2 = figure('visible','off');
            copyobj(self.data_plot_axes,fig2);
            print(fig2,'-clipboard', '-dmeta'); %print(fig2,'-clipboard', '-dbitmap');
        end
        
        function Callback_PlotType(self,obj, ~)
            PlotType = get(obj,'Value');
            
            set(self.ddlPlotVar1, 'enable', 'on');
            set(self.ddlPlotVar2, 'enable', 'on');
            set(self.chkPlotShowObjectNames, 'enable', 'off');
            set(self.chkPlotShowClasses, 'enable', 'off');
            
            switch PlotType
                case 1 %scatter
                    set(self.ddlPlotVar1, 'enable', 'on');
                    set(self.ddlPlotVar2, 'enable', 'on');
                    set(self.chkPlotShowObjectNames, 'enable', 'on');
                    
                    index_selected = get(self.listbox,'Value');
                    names = get(self.listbox,'String');
                    selected_name = names{index_selected};
                    
                    d = evalin('base', selected_name);
                    
                    if isempty(d.Classes)
                        set(self.chkPlotShowClasses, 'enable', 'off');
                        set(self.chkPlotShowClasses, 'value', 0);
                    else
                        set(self.chkPlotShowClasses, 'enable', 'on');
                    end
                    
                case 2 %line
                    set(self.ddlPlotVar1, 'enable', 'off');
                    set(self.ddlPlotVar2, 'enable', 'off');
                    set(self.chkPlotShowObjectNames, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'enable', 'off');
                case 3 %histogram
                    set(self.ddlPlotVar1, 'enable', 'on');
                    set(self.ddlPlotVar2, 'enable', 'off');
                    set(self.chkPlotShowObjectNames, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'enable', 'off');
                    
            end
            
            self.Redraw();
        end
        
        function Input_Centering(self,obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Centering = val;
                %ttab.Data.(selected_name).Centering = val;
                %lst = DataTab.redrawListbox(ttab);
                
                self.drawPlot(selected_name);
                
            end
        end
        
        function Input_Scaling(self,obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Scaling = val;
                %lst = DataTab.redrawListbox(ttab);
                
                self.drawPlot(selected_name);
                
                %set(ttab.listbox, 'String', lst);
            end
        end
        
        function Input_Training(self,obj, ~)
            val = get(obj,'Value');
            
            index_selected = get(self.listbox,'Value');
            
            if ~isempty(val) && ~isnan(val) && index_selected > 0
                
                
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
                d.Training = val;
                d.Validation = 0;
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                
                allvars = evalin('base','whos');
                
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win);
                end
                
                if sum(idx) > 0 && ~isempty(win.modelTab)
                    
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    vardisplay={};
                    if sum(idx) > 0
                        l = allvars(idx);
                        vardisplay{1} = '-';
                        for i = 1:length(l)
                            vardisplay{i+1} = l(i).name;
                        end
                        set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                        
                        if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                            set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                            
                            m = evalin('base',vardisplay{2});
                            set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                        end
                    end
                end
                
                if sum(idx) == 0 && ~isempty(win.modelTab)
                    mtab = win.tgroup.Children(2);
                    delete(mtab);
                    win.modelTab = [];
                    
                end
                
            end
        end
        
        function Input_Validation(self,obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Validation = val;
                d.Training = 0;
                
                allvars = evalin('base','whos');
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win);
                end
                
                if sum(idx) > 0 && ~isempty(win.modelTab)
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    vardisplay={};
                    if sum(idx) > 0
                        l = allvars(idx);
                        vardisplay{1} = '-';
                        for i = 1:length(l)
                            vardisplay{i+1} = l(i).name;
                        end
                        set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                        if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                            set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                            
                            m = evalin('base',vardisplay{2});
                            set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                        end
                    end
                end
                
                if sum(idx) == 0 && ~isempty(win.modelTab)
                    mtab = win.tgroup.Children(2);
                    delete(mtab);
                    win.modelTab = [];
                    
                end
                
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
            end
        end
        
        function DataSetWindowCloseCallback(self,obj,callbackdata)
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                selected_name = callbackdata.VariableName;
                selected_index = 2;
                
                vardisplay = cell(length(idx)+1,1);
                vardisplay{1} = '-';
                for i = 1:length(idx)
                    vardisplay{i+1} = varnames{idx(i)};
                    if(isequal(selected_name, varnames{idx(i)}))
                        selected_index = i+1;
                    end
                end
                set(self.listbox, 'String', vardisplay);
                set(self.listbox, 'Value', selected_index);
                
                if (~isempty(self.parent.predictTab))
                    set(self.parent.predictTab.ddlNewSet, 'String', vardisplay);
                end
                
                
                % extract all children
                self.enableRightPanel('on');
                
                d = evalin('base', selected_name);
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                if isempty(d.Classes)
                    set(self.chkTraining, 'Enable', 'off');
                    set(self.chkTraining, 'Value', 0);
                    set(self.chkValidation, 'Value', 1);
                    set(self.chkPlotShowClasses, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Value', 0);
                end
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                self.Redraw();
                self.FillTableView(selected_name);
                
            end
            
        end
        
        function btnSetEdit_Callback(self,obj, ~)
            
            %             win = DataSetWindow(self);
            %
            %             addlistener(win,'DataUpdated', @self.DataSetWindowCloseCallback);
            
        end
        
        function btnSetDelete_Callback(self,obj, ~)
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                answer = questdlg('Do you want to delete selected dataset?', ...
                    'Delete dataset', ...
                    'Yes','No','No');
                
                if isequal(answer, 'Yes')
                    
                    evalin( 'base', ['clear ' selected_name] );
                    
                    allvars = evalin('base','whos');
                    varnames = {allvars.name};
                    win = self.parent;
                    idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
                    
                    if ~isempty(idx)
                        selected_index = 2;
                        
                        vardisplay = cell(length(idx)+1,1);
                        vardisplay{1} = '-';
                        for i = 1:length(idx)
                            vardisplay{i+1} = varnames{idx(i)};
                            if(isequal(selected_name, varnames{idx(i)}))
                                selected_index = i+1;
                            end
                        end
                        set(self.listbox, 'String', vardisplay);
                        set(self.listbox, 'Value', selected_index);
                        
                        selected_name = vardisplay{2};
                        
                        if (~isempty(win.predictTab))
                            set(win.predictTab.ddlNewSet, 'String', vardisplay);
                        end
                        
                        
                        % extract all children
                        self.enableRightPanel('on');
                        
                        d = evalin('base', selected_name);
                        
                        if(isempty(d.VariableNames))
                            if(isempty(d.Variables))
                                names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                            else
                                names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                            end
                        else
                            names = d.VariableNames;
                        end
                        
                        if isempty(d.Classes)
                            set(self.chkTraining, 'Enable', 'off');
                            set(self.chkTraining, 'Value', 0);
                            set(self.chkValidation, 'Value', 1);
                            set(self.chkPlotShowClasses, 'Enable', 'off');
                            set(self.chkPlotShowClasses, 'Value', 0);
                        end
                        
                        set(self.ddlPlotVar1, 'String', names);
                        set(self.ddlPlotVar2, 'String', names);
                        
                        self.resetRightPanel();
                        self.fillRightPanel();
                        
                        self.Redraw();
                        self.FillTableView(selected_name);
                    else
                        
                        set(self.listbox, 'String', {'-'});
                        set(self.listbox, 'Value', 1);
                        
                        self.resetRightPanel();
                        self.enableRightPanel('off');
                        delete(self.data_plot);
                        delete(self.data_plot_axes);
                        
                        self.tblTextResult.Data = [];
                        self.tblTextResult.ColumnName = [];
                        
                        
                    end
                    
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    
                    if sum(idx) > 0 && ~isempty(win.modelTab)
                        
                        idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                        vardisplay={};
                        if sum(idx) > 0
                            l = allvars(idx);
                            vardisplay{1} = '-';
                            for i = 1:length(l)
                                vardisplay{i+1} = l(i).name;
                            end
                            set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                            
                            if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                                set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                                
                                m = evalin('base',vardisplay{2});
                                set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                            end
                        end
                    end
                    
                    if sum(idx) == 0 && ~isempty(win.modelTab)
                        mtab = win.tgroup.Children(2);
                        delete(mtab);
                        win.modelTab = [];
                        
                    end
                    
                end
                
            end
            
        end
        
        function btnNew_Callback(self,obj, ~)
            
            win = DataSetWindow(self);
            
            addlistener(win,'DataUpdated', @self.DataSetWindowCloseCallback);
            
        end
        
        function listClick(self,obj, ~)
            
            index_selected = get(obj,'Value');
            
            if(index_selected > 1)
                % extract all children
                self.enableRightPanel('on');
                
                names = get(self.listbox, 'String'); %fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);%ttab.Data.(selected_name);
                
                if isempty(d.Classes)
                    set(self.chkTraining, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Value', 0);
                else
                    set(self.chkTraining, 'Enable', 'on');
                    set(self.chkPlotShowClasses, 'Enable', 'on');
                end
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                self.drawPlot(selected_name);
                
                
                self.FillTableView(selected_name);
                
                
            else
                self.resetRightPanel();
                self.enableRightPanel('off');
                delete(self.data_plot);
                delete(self.data_plot_axes);
                
                self.tblTextResult.Data = [];
                self.tblTextResult.ColumnName = [];
            end
            
        end
        
        function FillTableView(self, selected_name)
            
            d = evalin('base', selected_name);
            
            Labels = cell(size(d.RawData, 1),1);
            for i = 1:size(d.RawData, 1)
                Labels{i} = sprintf('Object No.%d', i);
            end
            
            if(~isempty(d.ObjectNames))
                Labels = d.ObjectNames;
            end
            
            if ~isempty(d.Classes)
                self.tblTextResult.Data = [Labels, num2cell(d.Classes), num2cell(logical(d.SelectedSamples))];
                self.tblTextResult.ColumnName = {'Sample', 'Class', 'Included'};
                self.tblTextResult.ColumnWidth = num2cell([150 60 60]);
                self.tblTextResult.ColumnEditable = [false false true];
            else
                self.tblTextResult.Data = [Labels, num2cell(logical(d.SelectedSamples))];
                self.tblTextResult.ColumnName = {'Sample', 'Included'};
                self.tblTextResult.ColumnWidth = num2cell([150 60]);
                self.tblTextResult.ColumnEditable = [false true];
            end
            
            self.tblTextResult.CellEditCallback = @self.SelectedSamplesChangedCallback;
            
        end
        
        function resetRightPanel(self)
            ttab = self;
            set(ttab.chkTraining, 'Value', 0);
            set(ttab.chkValidation, 'Value', 0);
            set(ttab.chkCentering, 'Value', 0);
            set(ttab.chkScaling, 'Value', 0);
            set(ttab.ddlPlotType, 'Value', 2);
            set(ttab.ddlPlotVar1, 'enable', 'off');
            set(ttab.ddlPlotVar2, 'enable', 'off');
            set(ttab.chkPlotShowObjectNames, 'enable', 'off');
            set(ttab.chkPlotShowClasses, 'enable', 'off');
        end
        
        function drawPlot(self, selected_name)
            
            delete(self.data_plot);
            delete(self.data_plot_axes);
            %ax = get(gcf,'CurrentAxes');
            %cla(ax);
            %subplot
            ha2d = axes('Parent', self.tab_img,'Units', 'normalized','Position', [0.1 0.2 .8 .7]);
            %set(gcf,'CurrentAxes',ha2d);
            self.data_plot_axes = ha2d;
            
            d = evalin('base', selected_name);%ttab.Data.(selected_name);
            
            if sum(d.SelectedSamples) > 0
                var1 = get(self.ddlPlotVar1, 'Value');
                var2 = get(self.ddlPlotVar2, 'Value');
                showObjectNames = get(self.chkPlotShowObjectNames, 'Value');
                showClasses = get(self.chkPlotShowClasses, 'Value');
                PlotType = get(self.ddlPlotType, 'Value');
                
                switch PlotType
                    case 1 %scatter
                        self.data_plot = d.scatter(self.data_plot_axes, var1, var2, showClasses, showObjectNames);
                        set(self.chkPlotShowObjectNames, 'Enable', 'on');
                        
                        labels = strread(num2str(1:size(d.ProcessedData, 1)),'%s');
                        if(~isempty(d.ObjectNames))
                            labels = d.ObjectNames;
                        end
                        
                        if ~isempty(d.Classes)
                            set(self.data_plot_axes,'UserData', {[self.data_plot.XData', self.data_plot.YData'], labels, d.Classes});
                        else
                            set(self.data_plot_axes,'UserData', {[self.data_plot.XData', self.data_plot.YData'], labels, []});
                        end
                        
                        if showObjectNames
                            pan off
                            datacursormode on
                            dcm_obj = datacursormode(self.parent.fig);
                            set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                        else
                            datacursormode off
                            pan on
                        end
                        
                    case 2 %line
                        self.data_plot = d.line(self.data_plot_axes);
                        pan off
                        datacursormode off
                        set(self.chkPlotShowObjectNames, 'Value', 0);
                        set(self.chkPlotShowObjectNames, 'Enable', 'off');
                    case 3 %histogram
                        self.data_plot = d.histogram(self.data_plot_axes, var1);
                        pan off
                        datacursormode off
                        set(self.chkPlotShowObjectNames, 'Value', 0);
                        set(self.chkPlotShowObjectNames, 'Enable', 'off');
                end
            end
            
        end
        
        function fillRightPanel(self)
            ttab = self;
            index_selected = get(ttab.listbox,'Value');
            names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            %d = ttab.Data.(selected_name);
            if index_selected > 1
                d = evalin('base', selected_name);
                
                set(ttab.chkCentering, 'Value', d.Centering);
                set(ttab.chkScaling, 'Value', d.Scaling);
                
                set(ttab.chkTraining, 'Value', d.Training);
                set(ttab.chkValidation, 'Value', d.Validation);
            end
            %set(ttab.ddlPlotType, 'Value', d.PlotType);
        end
        
        function enableRightPanel(self, param)
            ttab = self;
            children = get(ttab.pnlDataSettings,'Children');
            children1 = get(ttab.pnlPlotSettings,'Children');
            children2 = get(ttab.pnlDataCategories,'Children');
            
            % only set children which are uicontrols:
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            set(children1(strcmpi ( get (children1,'Type'),'UIControl')),'enable',param);
            set(children2(strcmpi ( get (children2,'Type'),'UIControl')),'enable',param);
            
            %children2(1).Enable = 'off';% temporary disable validation set selection
        end
        
        
    end
    
end