classdef  DataTab < BasicTab
    properties
        Data = struct;
        Preprocessing = struct;
        %Training = struct;
        listbox;
        
        data_plot_axes;
        data_plot;
        
        pnlSettings;
        
        ddlPlotType;
        chkCentering;
        chkScaling;
    end
    methods
        
        function ttab = DataTab(tabgroup)
            ttab = ttab@BasicTab(tabgroup, 'Data');
            
            uicontrol('Parent', ttab.left_panel, 'Style', 'pushbutton', 'String', 'New data',...
                'Units', 'Normalized','FontUnits', 'Normalized', 'Position', [0.25 0.95 0.5 0.05], ...
                'callback', @DataTab.btnAdd_Callback);
            
            yourcell=fieldnames(ttab.Data);
            ttab.listbox = uicontrol('Parent', ttab.left_panel,'Style', 'listbox','Units', 'Normalized', ...
                'Position', [0 0 1 0.95], ...
                'string',yourcell,'Callback',@DataTab.listClick);
            
            %right tab
            %lblPlotType
            uicontrol('Parent', ttab.right_panel, 'Style', 'text', 'String', 'Type of model', ...
                'Units', 'normalized','Position', [0.05 0.95 0.85 0.05], 'HorizontalAlignment', 'left');
            ttab.ddlPlotType = uicontrol('Parent', ttab.right_panel, 'Style', 'popupmenu', 'String', {'scatter', 'line plot', 'histogram'},...
                'Units', 'normalized','Value',2, 'Position', [0.05 0.90 0.85 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Input_PlotType);
            
            %preprocessing
            ttab.pnlSettings = uipanel('Parent', ttab.right_panel, 'Title', 'Preprocessing','Units', 'normalized', ...
                'Position', [0.05   0.75   0.85  0.12]);
            ttab.chkCentering = uicontrol('Parent', ttab.pnlSettings, 'Style', 'checkbox', 'String', 'Centering',...
                'Units', 'normalized','Position', [0.1 0.45 0.45 0.25], 'callback', @DataTab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', ttab.pnlSettings, 'Style', 'checkbox', 'String', 'Scaling',...
                'Units', 'normalized','Position', [0.55 0.45 0.45 0.25], 'callback', @DataTab.Input_Scaling);
            
            uicontrol('Parent', ttab.right_panel, 'Style', 'pushbutton', 'String', 'Labels',...
                'Units', 'Normalized','FontUnits', 'Normalized', 'Position', [0.25 0.65 0.5 0.05], ...
                'callback', @DataTab.btnLabels_Callback);
            
            c = uicontextmenu;
            
            % Assign the uicontextmenu to the lisbox
            ttab.listbox.UIContextMenu = c;
            
            % Create child menu items for the uicontextmenu
            m1 = uimenu(c,'Label','Delete','Callback',@DataTab.listDelete);
            m2 = uimenu(c,'Label','Use for training','Callback',@DataTab.listTraining);
            
            % extract all children
            children = get(ttab.right_panel,'Children');
            children1 = get(ttab.pnlSettings,'Children');
            
            % only set children which are uicontrols:
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable','off');
            set(children1(strcmpi ( get (children1,'Type'),'UIControl')),'enable','off');
            
            ttab = DataTab.resetRightPanel(ttab);
            ttab = DataTab.enableRightPanel(ttab, 'off');
            
            data = guidata(gcf);
            data.datatab = ttab;
            guidata(gcf, data);
        end
        
        
        
    end
    
    methods (Static)
        
        function Input_PlotType(obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                data = guidata(obj);
                ttab = data.datatab;
                
                index_selected = get(ttab.listbox,'Value');
                names = fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                ttab.Data.(selected_name).PlotType = val;
                
                ttab = DataTab.drawPlot(ttab, selected_name);
                
                data.datatab = ttab;
                guidata(obj, data);
            end
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
            
            [tvar, tvarname] = GUIWindow.uigetvariables({'Pick a matrix:'}, ...
                'InputDimensions',2, 'InputTypes',{'numeric'});
            if ~isempty(tvar)
                SetVal = cell2mat(tvar);
                
                SetName = tvarname{1};
                
                data = guidata(obj);
                ttab = data.datatab;
                
                d = Data();
                d.RawData = SetVal;
                
                ttab.Data.(SetName) = d;
                
                lst = DataTab.redrawListbox(ttab);
                
                set(ttab.listbox, 'String', lst);
                data.datatab = ttab;
                guidata(obj, data);
            end
        end
        
        function btnLabels_Callback(obj, ~)
            
            data = guidata(obj);
            ttab = data.datatab;
            
            index_selected = get(ttab.listbox,'Value');
            names = fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            dataset = ttab.Data.(selected_name);
            
            n_training = 0;
            if ~isempty(dataset.ProcessedData)
                [n_training,~]=size(dataset.ProcessedData);
            end
            
            tvar = GUIWindow.uigetvariables({'Pick a cell array of strings:'},'InputDimensions',1, ...
                'ValidationFcn',{@(x) iscellstr(x) && (n_training > 0 && size(x,1) == n_training || n_training == 0)});
            %'InputDimensions',1, 'InputTypes',{'string'});
            
            if ~isempty(tvar)
                labels = tvar{1};
                [n,m]=size(labels);
                
                [n1,~]=size(dataset.ProcessedData);
                
                if ((n ~= n1) || (n == n1 && m ~= 1))
                    warndlg(sprintf('Labels should be a [%d x 1] cell array of strings', n1));
                else
                    
                    dataset.Labels = labels;
                    
                    ttab.Data.(selected_name) = dataset;
                    
                    lst = DataTab.redrawListbox(ttab);
                    
                    ttab = DataTab.drawPlot(ttab, selected_name);
                    
                    set(ttab.listbox, 'String', lst);
                    
                end
            end

                data.datatab = ttab;
                guidata(obj, data);
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
            
            x = 1:size(d.ProcessedData,2);
            y = d.ProcessedData;
            
            switch d.PlotType
                case 1 %scatter
                    ttab.data_plot = plot(x,y,'o');
                case 2 %line
                    ttab.data_plot = plot(x,y);
                case 3 %histogram
                    ttab.data_plot = histogram(y);
                
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
            children = get(ttab.right_panel,'Children');
            children1 = get(ttab.pnlSettings,'Children');
            
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
            ttab.Data.(selected_name).Training = true;
            
            lst = DataTab.redrawListbox(ttab);
            set(ttab.listbox, 'String', lst);
            
            win = data.window;
            win.modelTab = ModelTab(win.tgroup);
            data.window = win;
            
            data.datatab = ttab;
            guidata(obj, data);
            
        end
    end
    
end