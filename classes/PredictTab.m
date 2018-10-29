classdef  PredictTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;
        
        pnlPlotSettings;
        pnlTableSettings;
        
        
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
        
        vbox;
        
        result;
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
            
            children = panel.Children;
            for i = 1:length(children)
                c = children(i).Children;
                set(c(strcmpi ( get (c,'Type'),'UIControl')),'enable',param);
            end
            
            children = panel.Children.Children;
            for i = 1:length(children)
                c = children(i).Children;
                set(c(strcmpi ( get (c,'Type'),'UIControl')),'enable',param);
            end
            
            if isequal(self.parent.modelTab.Model.Mode, 'hard')
                self.chkPlotShowClasses.Value = 0;
                self.chkPlotShowClasses.Enable = 'off';
            end
            
            tg = self.tab_img.Parent;
            tg.Visible = param;
            
            if(strcmp('off',param))
                tg.SelectedTab = tg.Children(1);
            
                self.parent.selected_tab = GUIWindow.PredictTabSelected;
                self.parent.selected_panel = GUIWindow.PredictGraph;
                self.parent.selected_text_panel = GUIWindow.PredictTableAllocation;
            end
            
        end
        
        function ttab = PredictTab(tabgroup, parent)
            
            ttab = ttab@BasicTab(tabgroup, 'Prediction', parent);
            
            ttab.vbox = uix.VBox( 'Parent', ttab.left_panel, 'Padding', 15, 'Spacing', 5 );
            ttab.pnlDataSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Prediction', 'TitlePosition', 'LeftTop');
            
            ttab.pnlPlotSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Plot settings', 'TitlePosition', 'LeftTop');
            
            vbox_dat = uix.VBox( 'Parent', ttab.pnlDataSettings, 'Padding', 10, 'Spacing', 5 );
           hbox_dat = uix.HButtonBox( 'Parent', vbox_dat, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox_dat, 'Style', 'text', 'String', 'New or Test Data Set','HorizontalAlignment', 'left');
            ttab.ddlNewSet = uicontrol('Parent', hbox_dat, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1,'BackgroundColor', 'white', 'callback', @ttab.SelectNewSet);
            
            hbox_dat2 = uix.HButtonBox( 'Parent', vbox_dat, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox_dat2, 'Style', 'pushbutton', 'String', 'Predict',...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            
            
           vbox_plot = uix.VBox( 'Parent', ttab.pnlPlotSettings, 'Padding', 10, 'Spacing', 5 );
            
            hboxp2 = uix.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 20]);
            ttab.chkPlotShowClasses = uicontrol('Parent', hboxp2, 'Style', 'checkbox', 'Value', 1, 'String', 'Show classes',...
                 'Enable', 'off', 'callback', @ttab.RedrawCallback);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', hboxp2, 'Style', 'checkbox', 'String', 'Show object names',...
                'Enable', 'off', 'callback', @ttab.RedrawCallback);
            
            hboxp3 = uix.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 20], 'Spacing', 5);
            uicontrol('Parent', hboxp3, 'Style', 'text', 'String', 'PC 1', ...
                 'Enable', 'off', 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', hboxp3, 'Enable', 'off', 'Style', 'popupmenu', 'String', {'-'},...
                 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);
            
            uicontrol('Parent', hboxp3, 'Style', 'text', 'String', 'PC 2', 'Enable', 'off', ...
                 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', hboxp3, 'Style', 'popupmenu', 'Enable', 'off', 'String', {'-'},...
                 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);
             
            hboxp1 = uix.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxp1, 'Style', 'pushbutton', 'String', 'Save image to file',...
                'callback', @ttab.SavePlot, 'enable', 'off');
            uicontrol('Parent', hboxp1, 'Style', 'pushbutton', 'String', 'Copy image to clipboard',...
                'callback', @ttab.CopyPlotToClipboard, 'enable', 'off');
            
            ttab.pnlTableSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Table view options', 'TitlePosition', 'LeftTop','visible','off');
            hboxt1 = uix.HButtonBox( 'Parent', ttab.pnlTableSettings, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Save tables to file',...
                'callback', @ttab.SaveTable, 'enable', 'off');
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Copy tables to clipboard',...
                'callback', @ttab.CopyTableToClipboard, 'enable', 'off');
            
            ttab.vbox.Heights=[100,120,0];

            
            if isequal(ttab.parent.modelTab.Model.Mode, 'hard')
                ttab.chkPlotShowClasses.Value = 0;
                ttab.chkPlotShowClasses.Enable = 'off';
            end
            
            allvars = evalin('base','whos');
            
            idx = arrayfun(@(x)ttab.filter_test(x), allvars);
            
            if sum(idx) > 0
                vardisplay = {};
                l = allvars(idx);
                for i = 1:length(l)
                    vardisplay{i} = l(i).name;
                end
                set(ttab.ddlNewSet, 'String', vardisplay);
            end
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            tab_txt = uitab('Parent', tg, 'Title', 'Table view');
            
            w = ttab.parent;
            set(tg, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            %ttab.tbTextEdit = uicontrol('Parent', tab_txt, 'Style', 'edit', 'String', '', ...
            %    'Units', 'normalized','Position', [0 0 1 1], 'HorizontalAlignment', 'left', 'Max', 2);
            
            ttab.tg2 = uitabgroup('Parent', tab_txt);
            tab_alloc = uitab('Parent', ttab.tg2, 'Title', 'Allocation table');

            set(ttab.tg2, 'SelectionChangedFcn', @w.ActiveTabSelected);

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
            
            tg = ttab.tab_img.Parent;
                tg.Visible = 'off';

        end
        
        function btnNew_Callback(self, obj, ~)
            
            idx = get(self.ddlNewSet, 'value');
            if idx > 0
                list = get(self.ddlNewSet, 'string');
                
                set = evalin('base',list{idx});
                
                res = self.parent.modelTab.Model.Apply(set);
                
                self.result = res;
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
                
                if ~isempty(set.Classes)
                    trc = unique(self.parent.modelTab.Model.TrainingDataSet.Classes);
                    tc = unique(set.Classes);
                end
                
                if isempty(set.Classes) || ~(length(trc) == length(tc) && sum(trc == tc) == length(tc))
                    self.tblTextResult.ColumnName = {'Sample',1:size(res.AllocationMatrix, 2)};
                    
                    self.tblTextResult.Data = [res.Labels, num2cell(logical(res.AllocationMatrix))];
                
                    self.tblTextResult.ColumnWidth = num2cell([150, 30*ones(1,size(res.AllocationMatrix, 2))]);
                    self.tblTextResult.ColumnFormat = ['char' repmat({'logical'},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses)];

                else
                    self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'logical'},1,self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses)];

                   self.tblTextResult.ColumnName = {'Sample','Class', unique(self.parent.modelTab.Model.TrainingDataSet.Classes)};

                    for i = 1:length(set.Classes)
                        c = set.Classes(i);

                         u = unique(self.parent.modelTab.Model.TrainingDataSet.Classes);
                         ii = 1:self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses;
                         ci = ii(u == c);
                        
                        if (sum(res.AllocationMatrix(i,:)) == 0)% no classes
                            if ~isempty(ci)
                                res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFC000><TR><TD>',res.Labels{i},'</TD></TR> </table></html>'];
                            end
                        else
                            t = res.Labels{i};
                            if (~isempty(ci) && (~res.AllocationMatrix(i,ci))) || isempty(ci)% wrong class
                                res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FF0000><TR><TD>',t,'</TD></TR> </table></html>'];
                            end
                            
                            if (sum(res.AllocationMatrix(i,:)) > 1)% multiple classes
                                res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFA0A0><TR><TD>',t,'</TD></TR> </table></html>'];
                            end
                        end
                    end
                   
                    self.tblTextResult.Data = [res.Labels, num2cell(set.Classes), num2cell(logical(res.AllocationMatrix))];
                    
                    self.tblTextResult.ColumnWidth = num2cell([150, 60, 30*ones(1,size(res.AllocationMatrix, 2))]); 
                
                    if ~isempty(set.Classes)
                        trc = unique(self.parent.modelTab.Model.TrainingDataSet.Classes);
                        tc = unique(set.Classes);
                    end
                
                    if ~isempty(set.Classes) && length(trc) == length(tc) && sum(trc == tc) == length(tc)

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
                
                end
                
                self.enablePanel(self.pnlPlotSettings, 'on');
                self.enablePanel(self.pnlTableSettings, 'on');
                
                tg = self.tab_img.Parent;
                tg.Visible = 'on';
                
                if isequal(self.parent.modelTab.Model.Mode, 'hard')
                    self.chkPlotShowClasses.Value = 0;
                    self.chkPlotShowClasses.Enable = 'off';
                else
                    self.chkPlotShowClasses.Enable = 'on';
                end
                
            else
                self.enablePanel(self.pnlPlotSettings, 'off');
                self.enablePanel(self.pnlTableSettings, 'off');
            end
            
            
        end
        
        function Redraw(self)
            
            %delete(ttab.model_plot);
            delete(self.predict_plot_axes);
            %ax = get(gcf,'CurrentAxes');
            %cla(ax);
            ha2d = axes('Parent', self.tab_img);%,'Position', [0 0 1 1]);
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
                copyobj([self.predict_plot_axes.Legend, self.predict_plot_axes],fig2);
                
                [file,path] = uiputfile(filename,'Save prdiction plot');
                
                if ~(isnumeric(file) && (file == 0) && isnumeric(path) && (path == 0))
                    saveas(fig2, [path file]);
                end
            end
        end
        
        function CopyPlotToClipboard(self, obj, ~)
            
            fig2 = figure('visible','off');
            copyobj([self.predict_plot_axes.Legend, self.predict_plot_axes],fig2);
            
            if ispc
                print(fig2,'-clipboard', '-dmeta');
            else
                print(fig2,'-clipboard', '-dbitmap');
            end
            
        end
        
        function s = tableText(self)
            s = sprintf('%s\n','Allocation table');
            s = [s sprintf('%s',self.result.AllocationTable)];
            
            if isfield(self.result,'ConfusionMatrix')
                s = [s sprintf('\n\n%s\n','Confusion matrix')];
                s = [s sprintf([repmat('%d\t',1, length(self.result.ConfusionMatrix)) '\n'],self.result.ConfusionMatrix)];
            end
            
            if isfield(self.result,'FiguresOfMerit')
                s = [s sprintf('\n\n%s\n','Figures of merit')];
                fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
                fom = self.result.FiguresOfMerit;
                fom_txt = [fields,  {num2str(round(fom.TP)); num2str(round(fom.FP)); ...
                '';...
                num2str(round(fom.CSNS)); num2str(round(fom.CSPS)); num2str(round(fom.CEFF)); ...
                '';...
                num2str(round(fom.TSNS));...
                num2str(round(fom.TSPS));...
                num2str(round(fom.TEFF))...
                }];
            
                s = [s sprintf('Statistics\t%s\n', sprintf('%d ',1:self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses))];
                for i=1:size(fom_txt,1)
                    s = [s sprintf('%s\t%s\n', fom_txt{i,1}, fom_txt{i,2})];
                end
            end

        end
        
        function SaveTable(self, obj, ~)
            
            idx = get(self.ddlNewSet, 'value');
                
            list = get(self.ddlNewSet, 'string');
                
            fname = list{idx};
            
            [file,path] = uiputfile(['result_' fname '.txt'],'Save the prediction table'); 
            
            fileID = -1;
            
            if ~(isnumeric(file) && (file == 0) && isnumeric(path) && (path == 0))
                fileID = fopen([path file],'w');
            end
            
            if fileID ~= -1
                fprintf(fileID, '%s', self.tableText());
                fclose(fileID);
            end
            
        end
        
        function CopyTableToClipboard(self, obj, ~)
            
            clipboard('copy',self.tableText());
            
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
            self.enablePanel(self.pnlTableSettings, 'off');
            
            delete(self.predict_plot_axes);
            self.tblTextResult.Data = [];
            
            if (~isempty(self.tblTextConfusion) && ~isempty(self.tblTextFoM))
                self.tblTextConfusion.Data = [];
                self.tblTextFoM.Data = [];
            end
        end
        
        function r = filter_test(self, x)
            d = evalin('base', x.name);
            if isequal(x.class,'DataSet') && size(d, 2) == size(self.parent.modelTab.Model.TrainingDataSet, 2) 
                %&& (~isempty(d.Classes) && d.NumberOfClasses == self.parent.modelTab.Model.TrainingDataSet.NumberOfClasses || isempty(d.Classes))
                r = true;
            else
                r = false;
            end
        end
        
    end
    
end