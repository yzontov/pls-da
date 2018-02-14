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
        chkPlotShowObjectNames
        
        chkCentering;
        chkScaling;
        
        chkTraining;
        chkValidation;
    end
    methods
        
        function ttab = DataTab(tabgroup)
            ttab = ttab@BasicTab(tabgroup, 'Data');
            

            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'New dataset',...
                'Units', 'Normalized', 'Position', [0.3 0.9 0.35 0.05], ...
                'callback', @DataTab.btnNew_Callback);%,'FontUnits', 'Normalized'
            

            
            uicontrol('Parent', ttab.left_panel, 'Style', 'text', 'String', 'DataSet', ...
                'Units', 'normalized','Position', [0.05 0.8 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.listbox = uicontrol('Parent', ttab.left_panel, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.805 0.45 0.05], 'BackgroundColor', 'white', 'callback',@DataTab.listClick);
            
            
            %categories
            ttab.pnlDataCategories = uipanel('Parent', ttab.left_panel, 'Title', 'Categories','Units', 'normalized', ...
                'Position', [0.05   0.65   0.9  0.12]);
            ttab.chkTraining = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'checkbox', 'String', 'Calibration',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @DataTab.Input_Training);
            ttab.chkValidation = uicontrol('Parent', ttab.pnlDataCategories, 'Style', 'checkbox', 'String', 'Validation',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @DataTab.Input_Validation);
            
            
            %preprocessing
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Preprocessing','Units', 'normalized', ...
                'Position', [0.05   0.52   0.9  0.12]);
            ttab.chkCentering = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Centering',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @DataTab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Scaling',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @DataTab.Input_Scaling);
            
            
            %lblPlotType
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.10   0.9  0.4]);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.78 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotType = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Callback_PlotType);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.65 0.85 0.1], 'callback', @DataTab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.55 0.85 0.1], 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'X-axis', ...
                'Units', 'normalized','Position', [0.05 0.45 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.45 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Y-axis', ...
                'Units', 'normalized','Position', [0.05 0.35 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.35 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Redraw);
            
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.1], ...
                'callback', @DataTab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.1], ...
                'callback', @DataTab.CopyPlotToClipboard);
            
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx),1);
                for i = 1:length(idx)
                    vardisplay{i} = varnames{idx(i)};
                end
                set(ttab.listbox, 'String', vardisplay);
                
                % extract all children
                ttab = DataTab.enableRightPanel(ttab, 'on');
                
                names = varnames(idx);%fieldnames(ttab.Data);
                selected_name = names{1};
                
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
                
                ttab = DataTab.resetRightPanel(ttab);
                ttab = DataTab.fillRightPanel(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
            else
                ttab = DataTab.resetRightPanel(ttab);
                ttab = DataTab.enableRightPanel(ttab, 'off');
            end
            
            data = guidata(gcf);
            data.datatab = ttab;
            guidata(gcf, data);
        end
        
        
        
    end
    
    methods (Static)
        
        function obj = GetObject(list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
        end
        
        function Redraw(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(ttab.listbox,'Value');
            names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            ttab = DataTab.drawPlot(ttab, selected_name);
            
            data.datatab = ttab;
            guidata(obj, data);
        end
        
        function SavePlot(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            if ~isempty(ttab.data_plot)
                PlotType = get(ttab.ddlPlotType,'Value');
                
                index_selected = get(ttab.listbox,'Value');
                names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);%ttab.Data.(selected_name);
                
                switch PlotType
                    case 1 %scatter
                        var1 = get(ttab.ddlPlotVar1,'Value');
                        var2 = get(ttab.ddlPlotVar2,'Value');
                        if ~isempty(d.ObjectNames)
                            type = sprintf('scatter_%s_%s_%s', selected_name, d.ObjectNames{var1}, d.ObjectNames{var2});
                        else
                            type = sprintf('scatter_%s_var%d_var%d', selected_name, var1, var2);
                        end
                    case 2 %line
                        type = sprintf('line_%s', selected_name);
                    case 3 %histogram
                        var1 = get(ttab.ddlPlotVar1,'Value');
                        if ~isempty(d.VariableNames)
                            type = sprintf('histogram_%s_%s', selected_name, d.ObjectNames{var1});
                        else
                            type = sprintf('histogram_%s_var%d', selected_name, var1);
                        end
                end
                
                filename = [type,'.png'];
                fig2 = figure('visible','off');
                copyobj(ttab.data_plot_axes,fig2);
                saveas(fig2, filename);
                %print(ttab.data_plot, filename, '-dpng');
            end
        end
        
        function CopyPlotToClipboard(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            fig2 = figure('visible','off');
            copyobj(ttab.data_plot_axes,fig2);
            print(fig2,'-clipboard', '-dbitmap');
        end
        
        function Callback_PlotType(obj, ~)
            PlotType = get(obj,'Value');
            
            data = guidata(obj);
            ttab = data.datatab;
            
            set(ttab.ddlPlotVar1, 'enable', 'on');
            set(ttab.ddlPlotVar2, 'enable', 'on');
            set(ttab.chkPlotShowObjectNames, 'enable', 'off');
            set(ttab.chkPlotShowClasses, 'enable', 'off');
            
            switch PlotType
                case 1 %scatter
                    set(ttab.ddlPlotVar1, 'enable', 'on');
                    set(ttab.ddlPlotVar2, 'enable', 'on');
                    set(ttab.chkPlotShowObjectNames, 'enable', 'on');
                    set(ttab.chkPlotShowClasses, 'enable', 'on');
                case 2 %line
                    set(ttab.ddlPlotVar1, 'enable', 'off');
                    set(ttab.ddlPlotVar2, 'enable', 'off');
                    set(ttab.chkPlotShowObjectNames, 'enable', 'off');
                    set(ttab.chkPlotShowClasses, 'enable', 'off');
                case 3 %histogram
                    set(ttab.ddlPlotVar1, 'enable', 'on');
                    set(ttab.ddlPlotVar2, 'enable', 'off');
                    set(ttab.chkPlotShowObjectNames, 'enable', 'off');
                    set(ttab.chkPlotShowClasses, 'enable', 'off');
                    
            end
            
            data.datatab = ttab;
            guidata(obj, data);
            
            DataTab.Redraw(obj);
        end
        
        function Input_Centering(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Centering = val;
                %ttab.Data.(selected_name).Centering = val;
                %lst = DataTab.redrawListbox(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function Input_Scaling(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Scaling = val;
                %lst = DataTab.redrawListbox(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function Input_Training(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Training = val;
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function Input_Validation(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Validation = val;
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        

        
        function DataSetWindowCloseCallback(obj,callbackdata)


            ttab = obj.datatab;
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx),1);
                for i = 1:length(idx)
                    vardisplay{i} = varnames{idx(i)};
                end
                set(ttab.listbox, 'String', vardisplay);
                
                % extract all children
                ttab = DataTab.enableRightPanel(ttab, 'on');
                
                names = varnames(idx);%fieldnames(ttab.Data);
                selected_name = names{1};
                
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
                
                ttab = DataTab.resetRightPanel(ttab);
                ttab = DataTab.fillRightPanel(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
            end
            
            %ttab = DataTab.resetRightPanel(ttab);
            %ttab = DataTab.enableRightPanel(ttab, 'off');
            
        end
        
        function btnNew_Callback(obj, ~)
            
            win = DataSetWindow();
            
            
            
            data = guidata(obj);
            ttab = data.datatab;
            
            win.datatab = ttab;
            
            addlistener(win,'AddSet',@DataTab.DataSetWindowCloseCallback);

        end
        
        function listClick(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(obj,'Value');
            
            if(index_selected > 0)
                % extract all children
                ttab = DataTab.enableRightPanel(ttab, 'on');
                
                names = get(ttab.listbox, 'String'); %fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);%ttab.Data.(selected_name);
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
                
                ttab = DataTab.resetRightPanel(ttab);
                ttab = DataTab.fillRightPanel(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
            else
                
            end
            
            data.datatab = ttab;
            guidata(obj, data);
        end
        
        function tab =resetRightPanel(ttab)
            set(ttab.chkTraining, 'Value', 0);
            set(ttab.chkValidation, 'Value', 0);
            set(ttab.chkCentering, 'Value', 0);
            set(ttab.chkScaling, 'Value', 0);
            set(ttab.ddlPlotType, 'Value', 2);
            set(ttab.ddlPlotVar1, 'enable', 'off');
            set(ttab.ddlPlotVar2, 'enable', 'off');
            set(ttab.chkPlotShowObjectNames, 'enable', 'off');
            set(ttab.chkPlotShowClasses, 'enable', 'off');
            
            tab = ttab;
        end
        
        function tab = drawPlot(ttab, selected_name)
            delete(ttab.data_plot);
            delete(ttab.data_plot_axes);
            ax = get(gcf,'CurrentAxes');
            cla(ax);
            ha2d = axes('Parent', ttab.middle_panel,'Units', 'normalized','Position', [0.1 0.2 .8 .7]);
            set(gcf,'CurrentAxes',ha2d);
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
            
            tab = ttab;
        end
        
        function tab = fillRightPanel(ttab)
            
            index_selected = get(ttab.listbox,'Value');
            names = get(ttab.listbox,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            %d = ttab.Data.(selected_name);
            d = evalin('base', selected_name);
            
            set(ttab.chkCentering, 'Value', d.Centering);
            set(ttab.chkScaling, 'Value', d.Scaling);
            
            set(ttab.chkTraining, 'Value', d.Training);
            set(ttab.chkValidation, 'Value', d.Validation);
            
            %set(ttab.ddlPlotType, 'Value', d.PlotType);
            
            tab = ttab;
        end
        
        function tab = enableRightPanel(ttab, param)
            children = get(ttab.pnlDataSettings,'Children');
            children1 = get(ttab.pnlPlotSettings,'Children');
            children2 = get(ttab.pnlDataCategories,'Children');
            
            % only set children which are uicontrols:
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            set(children1(strcmpi ( get (children1,'Type'),'UIControl')),'enable',param);
            set(children2(strcmpi ( get (children2,'Type'),'UIControl')),'enable',param);
            tab = ttab;
        end
        
%         function listDelete(obj, ~)
%             data = guidata(obj);
%             ttab = data.datatab;
%             
%             index_selected = get(ttab.listbox,'Value');
%             names = fieldnames(ttab.Data);
%             selected_name = names{index_selected};
%             
%             if isfield(ttab.Data, selected_name)
%                 ttab.Data = rmfield(ttab.Data, selected_name);
%             end
%             
%             set(ttab.listbox, 'Value', 1);
%             lst = DataTab.redrawListbox(ttab);
%             set(ttab.listbox, 'String', lst);
%             
%             set(ttab.lbox_mnu_train, 'Checked', 'off');
%             set(ttab.lbox_mnu_val, 'Checked', 'off');
%             
%             win = data.window;
%             
%             if(length(win.tgroup.Children)>1 && sum(structfun(@(x) x.Training,ttab.Data)) == 0)
%                 mtab = win.tgroup.Children(2);
%                 delete(mtab);
%                 win.modelTab = [];
%             end
%             
%             data.window = win;
%             
%             
%             dat = data.datatab.Data;
%             names = fieldnames(dat);
%             mtab = data.modeltab;
%             
%             train_names = names(structfun(@(x) x.Training == true , dat));
%             val_names = names(structfun(@(x) x.Validation == true , dat));
%             
%             if ~isempty(train_names)
%                 set(mtab.ddlCalibrationSet, 'String', train_names);
%             end
%             
%             if ~isempty(val_names)
%                 set(mtab.ddlValidationSet, 'String', val_names);
%                 set(mtab.ddlValidationSet, 'enable', 'on');
%             else
%                 set(mtab.ddlValidationSet, 'enable', 'off');
%             end
%             
%             data.modeltab = mtab;
%             
%             ttab = DataTab.resetRightPanel(ttab);
%             ttab = DataTab.enableRightPanel(ttab, 'off');
%             
%             delete(ttab.data_plot);
%             delete(ttab.data_plot_axes);
%             
%             data.datatab = ttab;
%             guidata(obj, data);
%         end
%         
%         function listTraining(obj, ~)
%             data = guidata(obj);
%             ttab = data.datatab;
%             
%             index_selected = get(ttab.listbox,'Value');
%             names = fieldnames(ttab.Data);
%             selected_name = names{index_selected};
%             if ~ttab.Data.(selected_name).Training
%                 ttab.Data.(selected_name).Training = true;
%                 set(ttab.lbox_mnu_train, 'Checked', 'on');
%             else
%                 ttab.Data.(selected_name).Training = false;
%                 set(ttab.lbox_mnu_train, 'Checked', 'off');
%                 
%                 win = data.window;
%                 if(length(win.tgroup.Children)>1 && sum(structfun(@(x) x.Training,ttab.Data)) == 0)
%                     mtab = win.tgroup.Children(2);
%                     delete(mtab);
%                     win.modelTab = [];
%                 end
%             end
%             
%             lst = DataTab.redrawListbox(ttab);
%             set(ttab.listbox, 'String', lst);
%             
%             win = data.window;
%             
%             if sum(structfun(@(x) x.Training,ttab.Data)) > 0 && isempty(win.modelTab)
%                 win.modelTab = ModelTab(win.tgroup);
%                 data.window = win;
%             end
%             
%             data = guidata(obj);
%             mtab = data.modeltab;
%             dat = data.datatab.Data;
%             names = fieldnames(dat);
%             
%             train_names = names(structfun(@(x) x.Training == true , dat));
%             
%             if ~isempty(train_names)
%                 set(mtab.ddlCalibrationSet, 'String', train_names);
%             end
%             
%             data.modeltab = mtab;
%             
%             data.datatab = ttab;
%             guidata(obj, data);
%             
%         end
%         
%         function listValidation(obj, ~)
%             data = guidata(obj);
%             ttab = data.datatab;
%             
%             index_selected = get(ttab.listbox,'Value');
%             names = fieldnames(ttab.Data);
%             selected_name = names{index_selected};
%             
%             if ~ttab.Data.(selected_name).Validation
%                 ttab.Data.(selected_name).Validation = true;
%                 set(ttab.lbox_mnu_val, 'Checked', 'on');
%             else
%                 ttab.Data.(selected_name).Validation = false;
%                 set(ttab.lbox_mnu_val, 'Checked', 'off');
%             end
%             
%             
%             lst = DataTab.redrawListbox(ttab);
%             set(ttab.listbox, 'String', lst);
%             
%             mtab = data.modeltab;
%             dat = data.datatab.Data;
%             names = fieldnames(dat);
%             
%             val_names = names(structfun(@(x) x.Validation == true , dat));
%             
%             if ~isempty(val_names)
%                 set(mtab.ddlValidationSet, 'String', val_names);
%                 set(mtab.ddlValidationSet, 'enable', 'on');
%             else
%                 set(mtab.ddlValidationSet, 'enable', 'off');
%             end
%             
%             data.modeltab = mtab;
%             
%             data.datatab = ttab;
%             guidata(obj, data);
%             
%         end
    end
    
end