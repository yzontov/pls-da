classdef  DataTab < BasicTab
    properties
        Data = struct;
        Preprocessing = struct;
        %Training = struct;
        listbox;
        lbox_mnu_train;
        lbox_mnu_val;
        
        data_plot_axes;
        data_plot;
        
        pnlDataSettings;
        pnlPlotSettings;
        
        ddlPlotType;
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames
        
        chkCentering;
        chkScaling;
    end
    methods
        
        function ttab = DataTab(tabgroup)
            ttab = ttab@BasicTab(tabgroup, 'Data');
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'Add dataset',...
                'Units', 'Normalized','FontUnits', 'Normalized', 'Position', [0.05 0.95 0.4 0.05], ...
                'callback', @DataTab.btnAdd_Callback);
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'New dataset',...
                'Units', 'Normalized','FontUnits', 'Normalized', 'Position', [0.51 0.95 0.4 0.05], ...
                'callback', @DataTab.btnNew_Callback);
            
            yourcell=fieldnames(ttab.Data);
            ttab.listbox = uicontrol('Parent', ttab.left_panel,'Style', 'listbox','Units', 'Normalized', ...
                'Position', [0.05 0.65 0.9 0.30], ...
                'string',yourcell,'Callback',@DataTab.listClick);
            
            %preprocessing
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Data','Units', 'normalized', ...
                'Position', [0.05   0.52   0.9  0.12]);
            ttab.chkCentering = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Centering',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @DataTab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'checkbox', 'String', 'Scaling',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @DataTab.Input_Scaling);
            
            
            %lblPlotType
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.01   0.9  0.5]);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotType = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Redraw);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.05], 'callback', @DataTab.Redraw);
             ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.65 0.85 0.05], 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'X-axis', ...
                'Units', 'normalized','Position', [0.05 0.55 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.55 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'Y-axis', ...
                'Units', 'normalized','Position', [0.05 0.45 0.35 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.45 0.35 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Redraw);

            
            %             uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'Labels',...
            %                 'Units', 'Normalized','FontUnits', 'Normalized', 'Position', [0.25 0.65 0.5 0.05], ...
            %                 'callback', @DataTab.btnLabels_Callback);
            
            c = uicontextmenu;
            
            % Assign the uicontextmenu to the lisbox
            ttab.listbox.UIContextMenu = c;
            
            % Create child menu items for the uicontextmenu
            m1 = uimenu(c,'Label','Delete','Callback',@DataTab.listDelete,'Checked','off');
            ttab.lbox_mnu_train = uimenu(c,'Label','Use for training','Callback',@DataTab.listTraining,'Checked','off');
            ttab.lbox_mnu_val = uimenu(c,'Label','Use for validation','Callback',@DataTab.listValidation,'Checked','off');
            
            ttab = DataTab.resetRightPanel(ttab);
            ttab = DataTab.enableRightPanel(ttab, 'off');
            
            data = guidata(gcf);
            data.datatab = ttab;
            guidata(gcf, data);
        end
        
        
        
    end
    
    methods (Static)
        
        function Redraw(obj, ~)
            data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                data.datatab = ttab;
                guidata(obj, data);
        end
        
        function Input_Centering(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                ttab.Data.(selected_name).Centering = val;
                lst = DataTab.redrawListbox(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                set(ttab.listbox, 'String', lst);
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
                names = fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                ttab.Data.(selected_name).Scaling = val;
                lst = DataTab.redrawListbox(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function btnAdd_Callback(obj, ~)
            
            [tvar, ~] = GUIWindow.uigetvariables({'Pick a DataSet object:'}, ...
                'ValidationFcn',{@(x) isa(x, 'DataSet')});
            if ~isempty(tvar)
                
                data = guidata(obj);
                ttab = data.datatab;
                
                d = tvar{1};
                ttab.Data.(d.Name) = d;
                
                lst = DataTab.redrawListbox(ttab);
                
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
                
                set(ttab.listbox, 'String', lst);
                
                win = data.window;
            
                if sum(structfun(@(x) x.Training,ttab.Data)) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup);
                    data.window = win;
                end
                
                data.datatab = ttab;
                guidata(obj, data);
                
            end
            
        end
        
        function btnNew_Callback(obj, ~)
            
            [tvar, ~] = GUIWindow.uigetvariables({'Name of DataSet (string):','Data (matrix):', ...
                'Classes (vector) - optional:','Object names (cell of string) - optional:', ...
                'Variables names (cell of string) - optional:','Variables (row-vector) - optional:', ...
                'Classes labels (cell of string) - optional:'}, ...
                'InputDimensions',[Inf 2 1 1 1 1 1], ...
                'Introduction','Input all necessary fields of the DataSet', ...
                'InputTypes',{'textedit', 'numeric', 'numeric', 'string', 'string', 'numeric', 'string'});
            if ~isempty(tvar)
                
                Name = tvar{1};
                Data = tvar{2};
                Classes = tvar{3};
                ObjNames = tvar{4};
                VarNames = tvar{5};
                Variables = tvar{6};
                ClassLabels = tvar{7};
                
                [data_rows,data_cols]=size(Data);
                [cla_rows,cla_cols]=size(Classes);
                [objn_rows,objn_cols]=size(ObjNames);
                [var_rows,var_cols]=size(VarNames);
                [vars_rows,vars_cols]=size(Variables);
                [lbl_rows,lbl_cols]=size(ClassLabels);
                
                if ~isempty(Name) && ~isempty(Data) %&& ~isempty(Classes)
                    
                    d = DataSet();
                    d.RawData = Data;
                    d.Name = Name;
                else
                    errordlg('You should indicate Name, Data and Classes to create a DataSet!');
                    return;
                end
                
                if ~isempty(Classes)
                    if ((cla_rows ~= data_rows) || (cla_rows == data_rows && cla_cols ~= 1))
                        warndlg(sprintf('Classes should be a [%d x 1] vector of positive integers', data_rows));
                        return;
                    end
                    d.Classes = Classes;
                end
                
                if ~isempty(ObjNames)
                    if ((data_rows ~= objn_rows) || (data_rows == objn_rows && objn_cols ~= 1))
                        warndlg(sprintf('ObjectNames should be a [%d x 1] cell array of strings', data_rows));
                        return;
                    end
                    d.ObjectNames = ObjNames;
                end
                
                if ~isempty(VarNames)
                    if ((data_cols ~= var_rows) || (data_cols == var_rows && var_cols ~= 1))
                        warndlg(sprintf('VariableNames should be a [%d x 1] cell array of strings', data_cols));
                        return;
                    end
                    d.VariableNames = VarNames;
                end
                
                if ~isempty(Variables)
                    if ((data_cols ~= vars_cols) || (data_cols == vars_cols && vars_rows ~= 1))
                        warndlg(sprintf('Variables should be a [1 x %d] numeric vector', data_cols));
                        return;
                    end
                    d.Variables = Variables;
                end
                
                if ~isempty(ClassLabels)
                    if ((cla_rows ~= lbl_rows) || (cla_rows == lbl_rows && lbl_cols ~= 1))
                        warndlg(sprintf('ClassLabels should be a [%d x 1] cell array of strings', cla_rows));
                        return;
                    end
                    d.ClassLabels = ClassLabels;
                end
                
                try
                    assignin('base', Name, d)
                catch
                    errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore for the name of DataSet!');
                    d.Name = Name;
                    assignin('base',regexprep(Name, '[^a-zA-Z0-9_]', '_'),d);
                end
                
                data = guidata(obj);
                ttab = data.datatab;
                
                ttab.Data.(d.Name) = d;
                
                lst = DataTab.redrawListbox(ttab);
                
                set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function lst = redrawListbox(ttab)
            
            function r = celldraw(itm)
                d = ttab.Data.(itm);
                r = d.Description();
            end
            
            lst = cellfun(@(itm) sprintf('%s - %s', itm, celldraw(itm)), ...
                fieldnames(ttab.Data) , 'UniformOutput' ,false);
        end
        
        
        function listClick(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(obj,'Value');
            
            if(index_selected > 0)
                % extract all children
                ttab = DataTab.enableRightPanel(ttab, 'on');
                
                names = fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = ttab.Data.(selected_name);
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
                
                ttab = DataTab.fillRightPanel(ttab);
                
                ttab = DataTab.drawPlot(ttab, selected_name);
            else
                
            end
            
            data.datatab = ttab;
            guidata(obj, data);
        end
        
        function tab =resetRightPanel(ttab)
            set(ttab.chkCentering, 'Value', 0);
            set(ttab.chkScaling, 'Value', 0);
            set(ttab.ddlPlotType, 'Value', 2);
            
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
            
            d = ttab.Data.(selected_name);
            
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
            names = fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            d = ttab.Data.(selected_name);
            
            set(ttab.chkCentering, 'Value', d.Centering);
            set(ttab.chkScaling, 'Value', d.Scaling);
            set(ttab.ddlPlotType, 'Value', d.PlotType);
            
            tab = ttab;
        end
        
        function tab = enableRightPanel(ttab, param)
            children = get(ttab.pnlDataSettings,'Children');
            children1 = get(ttab.pnlPlotSettings,'Children');
            
            % only set children which are uicontrols:
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            set(children1(strcmpi ( get (children1,'Type'),'UIControl')),'enable',param);
            tab = ttab;
        end
        
        function listDelete(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(ttab.listbox,'Value');
            names = fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            if isfield(ttab.Data, selected_name)
                ttab.Data = rmfield(ttab.Data, selected_name);
            end
            
            set(ttab.listbox, 'Value', 1);
            lst = DataTab.redrawListbox(ttab);
            set(ttab.listbox, 'String', lst);
            
            set(ttab.lbox_mnu_train, 'Checked', 'off');
            set(ttab.lbox_mnu_val, 'Checked', 'off');
            
            win = data.window;
            
            if(length(win.tgroup.Children)>1 && sum(structfun(@(x) x.Training,ttab.Data)) == 0)
                mtab = win.tgroup.Children(2);
                delete(mtab);
                win.modelTab = [];
            end
            
            data.window = win;
            
            ttab = DataTab.resetRightPanel(ttab);
            ttab = DataTab.enableRightPanel(ttab, 'off');
            
            delete(ttab.data_plot);
            delete(ttab.data_plot_axes);
            
            data.datatab = ttab;
            guidata(obj, data);
        end
        
        function listTraining(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(ttab.listbox,'Value');
            names = fieldnames(ttab.Data);
            selected_name = names{index_selected};
            if ~ttab.Data.(selected_name).Training
                ttab.Data.(selected_name).Training = true;
                set(ttab.lbox_mnu_train, 'Checked', 'on');
            else
                ttab.Data.(selected_name).Training = false;
                set(ttab.lbox_mnu_train, 'Checked', 'off');
                
                win = data.window;                
                if(length(win.tgroup.Children)>1 && sum(structfun(@(x) x.Training,ttab.Data)) == 0)
                    mtab = win.tgroup.Children(2);
                    delete(mtab);
                    win.modelTab = [];
                end
            end
            
            lst = DataTab.redrawListbox(ttab);
            set(ttab.listbox, 'String', lst);
            
            win = data.window;
            
            if sum(structfun(@(x) x.Training,ttab.Data)) > 0 && isempty(win.modelTab)
                win.modelTab = ModelTab(win.tgroup);
                data.window = win;
            end
            
            data.datatab = ttab;
            guidata(obj, data);
            
        end
        
        function listValidation(obj, ~)
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(ttab.listbox,'Value');
            names = fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            if ~ttab.Data.(selected_name).Validation
                ttab.Data.(selected_name).Validation = true;
                set(ttab.lbox_mnu_val, 'Checked', 'on');
            else
                ttab.Data.(selected_name).Validation = false;
                set(ttab.lbox_mnu_val, 'Checked', 'off');
            end
            
            
            lst = DataTab.redrawListbox(ttab);
            set(ttab.listbox, 'String', lst);
            
            data.datatab = ttab;
            guidata(obj, data);
            
        end
    end
    
end