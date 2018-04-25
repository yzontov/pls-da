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
    end
    methods
        
        function ttab = DataTab(tabgroup, parent)
            ttab = ttab@BasicTab(tabgroup, 'Data', parent);
            
            
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'New dataset',...
                'Units', 'Normalized', 'Position', [0.3 0.9 0.35 0.05], ...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'DataSet', ...
                'Units', 'normalized','Position', [0.05 0.8 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.listbox = uicontrol('Parent', ttab.left_panel, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.805 0.45 0.05], 'BackgroundColor', 'white', 'callback',@ttab.listClick);
            
            %categories
            ttab.pnlDataCategories = uipanel('Parent', ttab.left_panel, 'Title', 'Categories','Units', 'normalized', ...
                'Position', [0.05   0.65   0.9  0.12]);
            ttab.chkTraining = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'checkbox', 'String', 'Calibration',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @ttab.Input_Training);
            ttab.chkValidation = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'checkbox', 'String', 'Validation',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @ttab.Input_Validation, 'Enable', 'off');%temp
            
            %preprocessing
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Preprocessing','Units', 'normalized', ...
                'Position', [0.05   0.52   0.9  0.12]);
            ttab.chkCentering = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Centering',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @ttab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Scaling',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @ttab.Input_Scaling);
            
            
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
            
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx)+1,1);
                vardisplay{1} = '-';
                for i = 1:length(idx)
                    vardisplay{i+1} = varnames{idx(i)};
                end
                set(ttab.listbox, 'String', vardisplay);
                
                % extract all children
                ttab.enableRightPanel('on');
                
                names = varnames(idx);%fieldnames(ttab.Data);
                selected_name = names{1};
                set(ttab.listbox, 'Value', 2);
                
                %d = ttab.Data.(selected_name);
                d = evalin('base', selected_name);
                
                if d.Training
                    set(ttab.lbox_mnu_train, 'Checked', 'on');
                else
                    set(ttab.lbox_mnu_train, 'Checked', 'off');
                end
                
                if d.Validation
                    set(ttab.lbox_mnu_val, 'Checked', 'on');
                else
                    set(ttab.lbox_mnu_val, 'Checked', 'off');
                end
                
                if(isempty(d.VariableNames))
                    names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                else
                    names = d.VariableNames;
                end
                set(ttab.ddlPlotVar1, 'String', names);
                set(ttab.ddlPlotVar2, 'String', names);
                
                ttab.resetRightPanel();
                ttab.fillRightPanel();
                
                ttab.drawPlot(selected_name);
                
            else
                ttab.resetRightPanel();
                ttab.enableRightPanel('off');
            end
            
%             data = guidata(gcf);
%             data.datatab = ttab;
%             guidata(gcf, data);
        end
        
        function obj = GetObject(self,list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
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
                        if ~isempty(d.ObjectNames)
                            type = sprintf('scatter_%s_%s_%s', selected_name, d.ObjectNames{var1}, d.ObjectNames{var2});
                        else
                            type = sprintf('scatter_%s_var%d_var%d', selected_name, var1, var2);
                        end
                    case 2 %line
                        type = sprintf('line_%s', selected_name);
                    case 3 %histogram
                        var1 = get(self.ddlPlotVar1,'Value');
                        if ~isempty(d.VariableNames)
                            type = sprintf('histogram_%s_%s', selected_name, d.ObjectNames{var1});
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
                    set(self.chkPlotShowClasses, 'enable', 'on');
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
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                
                allvars = evalin('base','whos');
                
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win); 
                    
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
                
                %d = ttab.Data.(selected_name);
                d = evalin('base', selected_name);
                
                if d.Training
                    set(self.lbox_mnu_train, 'Checked', 'on');
                else
                    set(self.lbox_mnu_train, 'Checked', 'off');
                end
                
                if d.Validation
                    set(self.lbox_mnu_val, 'Checked', 'on');
                else
                    set(self.lbox_mnu_val, 'Checked', 'off');
                end
                
                if(isempty(d.VariableNames))
                    names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                else
                    names = d.VariableNames;
                end
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
            end
            
            %ttab = DataTab.resetRightPanel(ttab);
            %ttab = DataTab.enableRightPanel(ttab, 'off');
            
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
                if d.Training
                    set(self.lbox_mnu_train, 'Checked', 'on');
                else
                    set(self.lbox_mnu_train, 'Checked', 'off');
                end
                
                if d.Validation
                    set(self.lbox_mnu_val, 'Checked', 'on');
                else
                    set(self.lbox_mnu_val, 'Checked', 'off');
                end
                
                if(isempty(d.VariableNames))
                    names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                else
                    names = d.VariableNames;
                end
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                self.drawPlot(selected_name);
            else
                self.resetRightPanel();
                self.enableRightPanel('off');
                delete(self.data_plot);
                delete(self.data_plot_axes);
            end

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
            
            ttab = self;
            delete(ttab.data_plot);
            delete(ttab.data_plot_axes);
            %ax = get(gcf,'CurrentAxes');
            %cla(ax);
            %subplot
            ha2d = axes('Parent', ttab.middle_panel,'Units', 'normalized','Position', [0.1 0.2 .8 .7]);
            %set(gcf,'CurrentAxes',ha2d);
            ttab.data_plot_axes = ha2d;
            
            d = evalin('base', selected_name);%ttab.Data.(selected_name);
            
            var1 = get(ttab.ddlPlotVar1, 'Value');
            var2 = get(ttab.ddlPlotVar2, 'Value');
            showObjectNames = get(ttab.chkPlotShowObjectNames, 'Value');
            showClasses = get(ttab.chkPlotShowClasses, 'Value');
            PlotType = get(ttab.ddlPlotType, 'Value');
            
            switch PlotType
                case 1 %scatter
                    ttab.data_plot = d.scatter(ttab.data_plot_axes, var1, var2, showClasses, showObjectNames);
                case 2 %line
                    ttab.data_plot = d.line(ttab.data_plot_axes);
                case 3 %histogram
                    ttab.data_plot = d.histogram(ttab.data_plot_axes, var1);
                    
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
            
            children2(1).Enable = 'off';% temporary disable validation set selection
        end
        
        
    end
    
end