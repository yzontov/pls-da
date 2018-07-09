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
        
        %tbTextEdit;
        tblTextResult;
        tblTextConfusion;
        tblTextFoM;
    end
    
    properties (Access = private)
        pc_x = 1;
        pc_y = 2;
        
        tg2;
        tab_confusion;
        tab_fom;
    end
    
    methods
        
        function enablePanel(self, panel, param)
            
            children = get(panel,'Children');
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            
            if isequal(self.parent.modelTab.Model.Mode, 'hard')
                self.chkPlotShowClasses.Value = 0;
                self.chkPlotShowClasses.Enable = 'off';
            end
            
        end
        
        function ttab = PredictTab(tabgroup, parent)
            
            ttab = ttab@BasicTab(tabgroup, 'Prediction', parent);
            
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Prediction','Units', 'normalized', ...
                'Position', [0.05   0.79   0.9  0.2]);
            
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.5   0.9  0.28]);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'New or Test Data Set', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.2], 'HorizontalAlignment', 'left');
            ttab.ddlNewSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.4 0.67 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ttab.SelectNewSet);
            
            
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'pushbutton', 'String', 'Predict',...
                'Units', 'Normalized', 'Position', [0.3 0.15 0.35 0.25], ...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.18], 'Enable', 'off', ...
                'callback', @ttab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.18], 'Enable', 'off', ...
                'callback', @ttab.CopyPlotToClipboard);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings,'Enable','off', 'Style', 'checkbox', 'Value', 1, 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1], 'callback', @ttab.RedrawCallback);%, 'callback', @DataTab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings,'Enable','off', 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.1], 'callback', @ttab.RedrawCallback);%, 'callback', @DataTab.Redraw);
            

            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 1','Enable','off', ...
                'Units', 'normalized','Position', [0.05 0.58 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu','Enable','off', 'String', {'1'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.6 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 2','Enable','off', ...
                'Units', 'normalized','Position', [0.05 0.38 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu','Enable','off', 'String', {'2'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.4 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);%, 'callback', @DataTab.Redraw);
            
            
            
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
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            tab_txt = uitab('Parent', tg, 'Title', 'Table view');
            
            %ttab.tbTextEdit = uicontrol('Parent', tab_txt, 'Style', 'edit', 'String', '', ...
            %    'Units', 'normalized','Position', [0 0 1 1], 'HorizontalAlignment', 'left', 'Max', 2);
            
            ttab.tg2 = uitabgroup('Parent', tab_txt);
            tab_alloc = uitab('Parent', ttab.tg2, 'Title', 'Allocation table');

            ttab.tblTextResult = uitable(tab_alloc);
            ttab.tblTextResult.Units = 'normalized';
            ttab.tblTextResult.Position = [0 0 1 1];
            
            m = ttab.parent.modelTab.Model;
            
            if ~isempty(m)
                pcs = arrayfun(@(x) sprintf('%d', x), 1:m.TrainingDataSet.NumberOfClasses-1, 'UniformOutput', false);
            
                set(ttab.ddlPlotVar1, 'String', pcs);
                set(ttab.ddlPlotVar2, 'String', pcs);
                set(ttab.ddlPlotVar1, 'Value', 1);
                
                
                if(length(pcs) == 1)
                    set(ttab.ddlPlotVar2, 'Value', 1);
                else
                    set(ttab.ddlPlotVar2, 'Value', 2);
                end

            end

        end
        
        function btnNew_Callback(self, obj, ~)
            
            idx = get(self.ddlNewSet, 'value');
            if idx > 0
                list = get(self.ddlNewSet, 'string');
                
                set = evalin('base',list{idx});
                
                res = self.parent.modelTab.Model.Apply(set);
                %
                %ff = res.AllocationTable;
                
                self.Redraw();
                
                %set(ttab.tbTextEdit, 'max', 2);
                %self.tbTextEdit.String = ff;
                if ~isempty(self.tab_confusion) && ~isempty(self.tab_fom)
                    mtab = self.tg2.Children(2);
                    delete(mtab);
                    self.tab_confusion = [];
                    
                    mtab = self.tg2.Children(2);
                    delete(mtab);
                    
                    self.tab_fom = [];
                end
                    
                if isempty(set.Classes)
                    self.tblTextResult.ColumnName = {'Sample',1:size(res.AllocationMatrix, 2)};
                
                    self.tblTextResult.Data = [res.Labels, num2cell(logical(res.AllocationMatrix))];
                
                    self.tblTextResult.ColumnWidth = num2cell([150, 30*ones(1,size(res.AllocationMatrix, 2))]);
                    self.tblTextResult.ColumnFormat = ['char' repmat({'logical'},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses)];

                    
                else
                   self.tblTextResult.ColumnName = {'Sample','Class', 1:size(res.AllocationMatrix, 2)};
                
                    self.tblTextResult.Data = [res.Labels, num2cell(set.Classes), num2cell(logical(res.AllocationMatrix))];
                    self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'logical'},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses)];

                    self.tblTextResult.ColumnWidth = num2cell([150, 60, 30*ones(1,size(res.AllocationMatrix, 2))]); 
                
                    
                    self.tab_confusion = uitab('Parent', self.tg2, 'Title', 'Confusion matrix');
                    self.tab_fom = uitab('Parent', self.tg2, 'Title', 'Figures of merit');

                    self.tblTextConfusion = uitable(self.tab_confusion);
                    self.tblTextConfusion.Units = 'normalized';
                    self.tblTextConfusion.Position = [0 0 1 1];
            
                    self.tblTextFoM = uitable(self.tab_fom);
                    self.tblTextFoM.Units = 'normalized';
                    self.tblTextFoM.Position = [0 0 1 1];
                    
                    self.tblTextFoM.ColumnName = {'Statistics',1:self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses};
                    self.tblTextFoM.ColumnWidth = num2cell([120, 30*ones(1,size(res.AllocationMatrix(:,1:self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses), 2))]);
                    self.tblTextFoM.ColumnFormat = ['char' repmat({'numeric'},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses)];
                    
                    self.tblTextConfusion.Data = res.ConfusionMatrix;
                    
                    fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
                    fom = res.FiguresOfMerit;
                    
                    self.tblTextFoM.Data = [fields,  [num2cell(round([fom.TP; fom.FP])); ...
                        repmat({''},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses);...
                        num2cell(round([fom.CSNS; fom.CSPS; fom.CEFF])); ...
                        repmat({''},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses);...
                        [round(fom.TSNS) repmat({''},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses-1)];...
                        [round(fom.TSPS) repmat({''},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses-1)];...
                        [round(fom.TEFF) repmat({''},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses-1)]...
                        ]];
                
                
                end
                
                self.enablePanel(self.pnlPlotSettings, 'on');
                
                if isequal(self.parent.modelTab.Model.Mode, 'hard')
                    self.chkPlotShowClasses.Value = 0;
                    self.chkPlotShowClasses.Enable = 'off';
                else
                    self.chkPlotShowClasses.Enable = 'on';
                end
                
            else
                self.enablePanel(self.pnlPlotSettings, 'off');
            end
        end
        
        function Redraw(self)
            
            %delete(ttab.model_plot);
            delete(self.predict_plot_axes);
            %ax = get(gcf,'CurrentAxes');
            %cla(ax);
            ha2d = axes('Parent', self.tab_img,'Units', 'normalized');%,'Position', [0 0 1 1]);
            %set(gcf,'CurrentAxes',ha2d);
            self.predict_plot_axes = ha2d;
            
            pc1 = self.pc_x;%self.ddlPlotVar1.Value;
            pc2 = self.pc_y;%self.ddlPlotVar2.Value;
            
            if ~isempty(self.parent.modelTab.Model)
                self.parent.modelTab.Model.PlotNewSet(self.predict_plot_axes, pc1, pc2, self.chkPlotShowClasses.Value);
                
                if(self.chkPlotShowObjectNames.Value == 1)
                    pan off
                    datacursormode on
                    dcm_obj = datacursormode(self.parent.fig);
                    set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                else
                    datacursormode off
                    pan on
                end
                
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
        
        function RedrawCallback(self, obj, param)
            
        if self.pc_x ~= self.pc_y
            prev_x = self.pc_x;
            prev_y = self.pc_y;
            
            if (self.ddlPlotVar1.Value == self.ddlPlotVar2.Value)
                self.ddlPlotVar1.Value = prev_y;
                self.ddlPlotVar2.Value = prev_x;
            end
            
            self.pc_x = self.ddlPlotVar1.Value;
            self.pc_y = self.ddlPlotVar2.Value;
        end    
            self.Redraw();
        
        end
        
        function SelectNewSet(self,obj, ~)
            self.enablePanel(self.pnlPlotSettings, 'off');
            
            delete(self.predict_plot_axes);
            self.tblTextResult.Data = [];
            self.tblTextConfusion.Data = [];
            self.tblTextFoM.Data = [];
        end
        
    end
    
end