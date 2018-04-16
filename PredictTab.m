classdef  PredictTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;

        pnlPlotSettings;
        
        
        ddlNewSet;

        
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;

        predict_plot_axes;
        tab_img;
        
        tbTextEdit;
    end
    
    methods
        
        function ttab = PredictTab(tabgroup, parent)
            
            ttab = ttab@BasicTab(tabgroup, 'Prediction', parent);
            
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Prediction','Units', 'normalized', ...
                'Position', [0.05   0.79   0.9  0.2]);

            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.5   0.9  0.28]);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'New DataSet', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlNewSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.4 0.67 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ttab.SelectCalibratinSet);

            
                        
             uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'pushbutton', 'String', 'Predict',...
                'Units', 'Normalized', 'Position', [0.3 0.15 0.35 0.25], ...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
                      
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.18], ...
                'callback', @ttab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.18], ...
                'callback', @ttab.CopyPlotToClipboard);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings,'Enable','off', 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1]);%, 'callback', @DataTab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings,'Enable','off', 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.1]);%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 1','Enable','off', ...
                'Units', 'normalized','Position', [0.05 0.58 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu','Enable','off', 'String', {'1'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.6 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 2','Enable','off', ...
                'Units', 'normalized','Position', [0.05 0.38 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu','Enable','off', 'String', {'2'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.4 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            

            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = cell(length(idx),1);
                for i = 1:length(idx)
                    vardisplay{i} = varnames{idx(i)};
                end
                set(ttab.ddlNewSet, 'String', vardisplay);
            end
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            tab_txt = uitab('Parent', tg, 'Title', 'Text view');
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            
            ttab.tbTextEdit = uicontrol('Parent', tab_txt, 'Style', 'edit', 'String', '', ...
                'Units', 'normalized','Position', [0 0 1 1], 'HorizontalAlignment', 'left', 'Max', 2);
            
            %
            data = guidata(gcf);
            data.predicttab = ttab;
            guidata(gcf, data);
        end
        
    end
    
    methods 
        
        function btnNew_Callback(self, obj, ~)
            
            idx = get(self.ddlNewSet, 'value');
            if idx > 0
            list = get(self.ddlNewSet, 'string');
            
            set = evalin('base',list{idx});

            res = self.parent.modelTab.Model.Apply(set);
            %
            ff = res.AllocationTable;
            
            self.Redraw();
            
            %set(ttab.tbTextEdit, 'max', 2);
            self.tbTextEdit.String = ff;

            end
        end
        
        function Redraw(self)

            %delete(ttab.model_plot);
            delete(self.predict_plot_axes);
            ax = get(gcf,'CurrentAxes');
            cla(ax);
            ha2d = axes('Parent', self.tab_img,'Units', 'normalized','Position', [0 0 1 1]);
            set(gcf,'CurrentAxes',ha2d);
            self.predict_plot_axes = ha2d;
            
            if ~isempty(self.parent.modelTab.Model)
                self.parent.modelTab.Model.PlotNewSet(self.predict_plot_axes);
            end
        end
        
        function SavePlot(self, obj, ~)

            if ~isempty(self.predict_plot_axes)
                
                idx = get(self.ddlNewSet, 'value');
            
                list = get(self.ddlNewSet, 'string');
            
             type = list{idx};
                
                filename = [type,'.png'];
                if ispc
                    filename = [type,'.emf'];
                end

                fig2 = figure('visible','off');
                copyobj(self.predict_plot_axes,fig2);
                saveas(fig2, filename);
            end
        end
        
        function CopyPlotToClipboard(self, obj, ~)

            fig2 = figure('visible','off');
            copyobj(self.predict_plot_axes,fig2);
            
            if ispc
               print(fig2,'-clipboard', '-dmeta');
            else
               print(fig2,'-clipboard', '-dpng'); 
            end
            
        end
  
    end
    
end