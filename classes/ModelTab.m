classdef  ModelTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;
        pnlCrossValidationSettings;
        pnlModelSettings
        pnlPlotSettings;
        pnlTableSettings;
        
        ddlModelType;
        tbNumPCpls;
        tbNumPCpca;
        tbAlpha;
        tbGamma;
        
        %tbTextResult;
        tblTextResult;
        tblTextConfusion;
        tblTextFoM;
        
        chkFinalizeModel;
        
        ddlCalibrationSet;
        ddlValidationSet;
        
        chkCrossValidation;
        ddlCrossValidationType;
        
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;
        
        btnRecalibrate;
        btnSaveModel;
        
        model_plot_axes;
        %model_plot;
        tab_img;
        vbox;
        
        tbl_tabgroup;
    end
    
    properties (Access = private)
        pc_x = 1;
        pc_y = 2;
    end
    
    methods
        
        function r = set.Model(self,value)
            self.Model = value;
            
            if ~isempty(self.Model)
                if self.Model.Finalized
                    set(self.chkFinalizeModel,'value',1);
                end
                
                G = self.Model.TrainingDataSet.Name;
                idx = find(cell2mat(cellfun(@(x) strcmp(x, G), get(self.ddlCalibrationSet,'string'), 'UniformOutput',false)));
                set(self.ddlCalibrationSet,'value',idx);
                
                set(self.tbNumPCpls,'string',sprintf('%d',self.Model.NumPC));
                set(self.tbNumPCpca, 'String', sprintf('%d', max(1, self.Model.TrainingDataSet.NumberOfClasses-1)));%%temp
                set(self.tbAlpha,'string',sprintf('%.2f',self.Model.Alpha));
                set(self.tbGamma,'string',sprintf('%.2f',self.Model.Gamma));
                
                set(self.btnRecalibrate,'string','Recalibrate');             
                
                Labels = cell(size(self.Model.TrainingDataSet.ProcessedData, 1),1);
                for i = 1:size(self.Model.TrainingDataSet.ProcessedData, 1)
                    Labels{i} = sprintf('Object No.%d', i);
                end
                
                if(~isempty(self.Model.TrainingDataSet.SelectedObjectNames))
                    Labels = self.Model.TrainingDataSet.SelectedObjectNames;
                end
                
                for i = 1:length(self.Model.TrainingDataSet.Classes)
                    c = self.Model.TrainingDataSet.Classes(i);
                    u = unique(self.Model.TrainingDataSet.Classes);
                    ii = 1:self.Model.TrainingDataSet.NumberOfClasses;
                    ci = ii(u == c);
                    
                    if (sum(self.Model.AllocationMatrix(i,:)) == 0)% no classes
                        Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFC000><TR><TD>',Labels{i},'</TD></TR> </table></html>'];
                    else
                        t = Labels{i};
                        if (~self.Model.AllocationMatrix(i,ci))% wrong class
                            Labels{i} = ['<html><table border=0 width=100% bgcolor=#FF0000><TR><TD>',t,'</TD></TR> </table></html>'];
                        end
                        
                        if (sum(self.Model.AllocationMatrix(i,:)) > 1)% multiple classes
                            Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFA0A0><TR><TD>',t,'</TD></TR> </table></html>'];
                        end
                    end
                end
                
                self.tblTextResult.ColumnName = {'Sample', 'Class', unique(self.Model.TrainingDataSet.Classes)};
                self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'char'},1,self.Model.TrainingDataSet.NumberOfClasses)];
                self.tblTextResult.ColumnWidth = num2cell([150, 60, 30*ones(1,size(self.Model.AllocationMatrix(:,1:self.Model.TrainingDataSet.NumberOfClasses), 2))]);

                v = num2cell(arrayfun(@self.bool2v ,logical(self.Model.AllocationMatrix)));
                self.tblTextResult.Data = [Labels, num2cell(self.Model.TrainingDataSet.Classes), v];
                
                self.tblTextConfusion.ColumnName = {unique(self.Model.TrainingDataSet.Classes)};
                self.tblTextConfusion.RowName = {unique(self.Model.TrainingDataSet.Classes)};
                self.tblTextConfusion.Data = self.Model.ConfusionMatrix;
            
                self.tblTextFoM.ColumnName = {'Statistics',unique(self.Model.TrainingDataSet.Classes)};
                self.tblTextFoM.ColumnWidth = num2cell([120, 30*ones(1,size(self.Model.AllocationMatrix(:,1:self.Model.TrainingDataSet.NumberOfClasses), 2))]);
                self.tblTextFoM.ColumnFormat = ['char' repmat({'numeric'},1,self.Model.TrainingDataSet.NumberOfClasses)];

                fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
                fom = self.Model.FiguresOfMerit;
            
                self.tblTextFoM.Data = [fields,  [num2cell(round([fom.TP; fom.FP])); ...
                repmat({''},1,self.Model.TrainingDataSet.NumberOfClasses);...
                num2cell(round([fom.CSNS; fom.CSPS; fom.CEFF])); ...
                repmat({''},1,self.Model.TrainingDataSet.NumberOfClasses);...
                [round(fom.TSNS) repmat({''},1,self.Model.TrainingDataSet.NumberOfClasses-1)];...
                [round(fom.TSPS) repmat({''},1,self.Model.TrainingDataSet.NumberOfClasses-1)];...
                [round(fom.TEFF) repmat({''},1,self.Model.TrainingDataSet.NumberOfClasses-1)]...
                ]];
                
                pcs = arrayfun(@(x) sprintf('%d', x), 1:self.Model.TrainingDataSet.NumberOfClasses-1, 'UniformOutput', false);
                
                set(self.ddlPlotVar1, 'String', pcs);
                set(self.ddlPlotVar2, 'String', pcs);
                set(self.ddlPlotVar1, 'Value', 1);
                set(self.ddlPlotVar2, 'Value', 2);
                
                if (length(pcs) == 1)
                    set(self.ddlPlotVar2, 'Value',1);
                    self.pc_x = 1;
                    self.pc_y = 1;
                end
                
                self.chkFinalizeModel.Enable = 'on';
                self.btnSaveModel.Enable = 'on';
                self.enablePanel(self.pnlPlotSettings, 'on');
                self.enablePanel(self.pnlTableSettings, 'on');
                
                self.Redraw();
                tg = self.tab_img.Parent;
                tg.Visible = 'on';
                
                r = self;
            else
                set(self.btnRecalibrate,'string','Calibrate'); 
            end
        end
        
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
            
            tg = self.tab_img.Parent;
            tg.Visible = param;
            
            if(strcmp('off',param))
                tg.SelectedTab = tg.Children(1);
                self.tbl_tabgroup.SelectedTab = self.tbl_tabgroup.Children(1);
                
                self.parent.selected_tab = GUIWindow.ModelTabSelected;
                self.parent.selected_panel = GUIWindow.ModelGraph;
                self.parent.selected_text_panel = GUIWindow.ModelTableAllocation;
            
                set(self.pnlPlotSettings,'visible','on');
                set(self.pnlTableSettings,'visible','off');
                
                if ispc
                    self.vbox.Heights=[40,180,120,0];
                else
                    self.vbox.Heights=[40,180,110,0];
                end
            end

        end
        
        function ttab = ModelTab(tabgroup, parent)
            
            ttab = ttab@BasicTab(tabgroup, 'Model', parent);
            
            
            ttab.vbox = uix.VBox( 'Parent', ttab.left_panel, 'Padding', 10, 'Spacing', 5 );
            
            ttab.pnlDataSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Data', 'TitlePosition', 'LeftTop');
    
%             ttab.pnlCrossValidationSettings = uipanel('Parent', ttab.left_panel, 'Title', 'CrossValidation','Units', 'normalized', ...
%                 'Position', [0.05   0.71   0.9  0.14],'Visible','off');
            
            ttab.pnlModelSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Model settings', 'TitlePosition', 'LeftTop');
            
            ttab.pnlPlotSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Plot settings', 'TitlePosition', 'LeftTop');
            
            hbox1 = uix.HButtonBox( 'Parent', ttab.pnlDataSettings, 'ButtonSize', [120 25]);
            
            uicontrol('Parent', hbox1, 'Style', 'text', 'String', 'Calibration');
            ttab.ddlCalibrationSet = uicontrol('Parent', hbox1, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @ttab.SelectCalibratinSet);
            
%             uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'Validation', ...
%                 'Units', 'normalized','Position', [0.05 0.25 0.35 0.25], 'HorizontalAlignment', 'left', 'Enable', 'off','Visible','off');
%             ttab.ddlValidationSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},'Visible','off',...
%                 'Units', 'normalized','Value',1, 'Position', [0.4 0.27 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ttab.SelectValidationSet, 'Enable', 'off');

%             %CrossValidation
%             ttab.chkCrossValidation = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'checkbox', 'String', 'Use cross-validation',...
%                 'Units', 'normalized','Position', [0.05 0.7 0.85 0.2], 'callback', @ttab.Callback_UseCrossValidation, 'Enable', 'off');
%             uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'text', 'String', 'Cross-validation type', ...
%                 'Units', 'normalized','Position', [0.05 0.3 0.85 0.25], 'HorizontalAlignment', 'left', 'Enable', 'off');
%             ttab.ddlCrossValidationType = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'popupmenu', 'String', {'Leave-one-Out', 'K-fold', 'Holdout', 'Monte Carlo'},...
%                 'Units', 'normalized','Value',2, 'Position', [0.47 0.325 0.45 0.2], 'BackgroundColor', 'white', 'callback', @ttab.Callback_CrossValidationType, 'Enable', 'off');
            
            vbox_mod = uix.VBox( 'Parent', ttab.pnlModelSettings, 'Padding', 10, 'Spacing', 5 );
            %lblModelType
            hboxm1 = uix.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxm1, 'Style', 'text', 'String', 'Type of model');
            ttab.ddlModelType = uicontrol('Parent', hboxm1, 'Style', 'popupmenu', 'String', {'Hard PLS-DA','Soft PLS-DA'},...
                'value', 2, 'BackgroundColor', 'white', 'callback', @ttab.Input_ModelParameters);
            
            hboxm2 = uix.Grid( 'Parent', vbox_mod);
            %model params
            %PLS PCs
            uicontrol('Parent', hboxm2, 'Style', 'text', 'String', 'Number of PLS components');
            ttab.tbNumPCpls = uicontrol('Parent', hboxm2, 'Style', 'edit', 'String', '12',...
                 'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC_PLS);
            hboxm2.Widths  = [-2, -1];
            
            hboxm3 = uix.Grid( 'Parent', vbox_mod);
            %PCA PCs
            uicontrol('Parent', hboxm3, 'Style', 'text', 'String', 'Number of PCA components', 'Enable', 'on');
            ttab.tbNumPCpca = uicontrol('Parent', hboxm3, 'Style', 'edit', 'String', '2', 'Enable', 'off',...
                'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC_PCA);
            hboxm3.Widths  = [-2, -1];
            
            hboxm4 = uix.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 25]);
            %lblAlpha
            uicontrol('Parent', hboxm4, 'Style', 'text', 'String', 'Type I error');
            ttab.tbAlpha = uicontrol('Parent', hboxm4, 'Style', 'edit', 'String', '0.05',...
                'BackgroundColor', 'white', 'callback', @ttab.Input_Alpha);
            
            %lblGamma
            uicontrol('Parent', hboxm4, 'Style', 'text', 'String', 'Outlier level');
            ttab.tbGamma = uicontrol('Parent', hboxm4, 'Style', 'edit', 'String', '0.01',...
                'BackgroundColor', 'white', 'callback', @ttab.Input_Gamma);
            
            hboxm6 = uix.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 25]);
            ttab.chkFinalizeModel = uicontrol('Parent', hboxm6, 'Style', 'checkbox', 'String', 'Finalized',...
                'callback', @ttab.Finalize, 'Enable', 'off');
            
            ttab.btnRecalibrate = uicontrol('Parent', hboxm6, 'Style', 'pushbutton', 'String', 'Calibrate',...
                'callback', @ttab.Recalibrate);
            ttab.btnSaveModel = uicontrol('Parent',hboxm6,'Enable','off', 'Style', 'pushbutton', 'String', 'Save model',...
                'callback', @ttab.SaveModel);
            
            vbox_plot = uix.VBox( 'Parent', ttab.pnlPlotSettings, 'Padding', 5, 'Spacing', 5 );
            
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
            hboxt1 = uix.HButtonBox( 'Parent', ttab.pnlTableSettings, 'ButtonSize', [120 30]);
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Save tables to file',...
                'callback', @ttab.SaveTable, 'enable', 'off');
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Copy tables to clipboard',...
                'callback', @ttab.CopyTableToClipboard, 'enable', 'off');
            
            ttab.vbox.Heights=[40,180,120,0];
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Classification plot');
            tab_txt = uitab('Parent', tg, 'Title', 'Classification table');
            
            w = ttab.parent;
            set(tg, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            tg2 = uitabgroup('Parent', tab_txt);
            tab_alloc = uitab('Parent', tg2, 'Title', 'Allocation table');
            tab_confusion = uitab('Parent', tg2, 'Title', 'Confusion matrix');
            tab_fom = uitab('Parent', tg2, 'Title', 'Figures of merit');
            
            ttab.tbl_tabgroup = tg2;
            
            w = ttab.parent;
            set(tg2, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            ttab.tblTextConfusion = uitable(tab_confusion);
            ttab.tblTextConfusion.Units = 'normalized';
            ttab.tblTextConfusion.Position = [0 0 1 1];
            
            ttab.tblTextFoM = uitable(tab_fom);
            ttab.tblTextFoM.Units = 'normalized';
            ttab.tblTextFoM.Position = [0 0 1 1];
            
            ttab.tblTextResult = uitable(tab_alloc);
            ttab.tblTextResult.Units = 'normalized';
            ttab.tblTextResult.Position = [0 0 1 1];
            
            allvars = evalin('base','whos');
            
            idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
            vardisplay={};
            if sum(idx) > 0
                l = allvars(idx);
                vardisplay{1} = '-';
                for i = 1:length(l)
                    vardisplay{i+1} = l(i).name;
                end
                set(ttab.ddlCalibrationSet, 'String', vardisplay);
                if length(get(ttab.ddlCalibrationSet, 'String')) > 1
                    set(ttab.ddlCalibrationSet, 'Value', 2)
                    
                    m = evalin('base',vardisplay{2});
                    set(ttab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                    
                    set(ttab.tbNumPCpls, 'String', sprintf('%d', min(max(m.NumberOfClasses, 12), size(m.ProcessedData, 2))));
                end
            end
            
            if isempty(ttab.Model)
                pcs = arrayfun(@(x) sprintf('%d', x), 1:str2double(get(ttab.tbNumPCpca,'string')), 'UniformOutput', false);
                
                set(ttab.ddlPlotVar1, 'String', pcs);
                set(ttab.ddlPlotVar2, 'String', pcs);
                set(ttab.ddlPlotVar1, 'Value', 1);
                set(ttab.ddlPlotVar2, 'Value', 2);
                
                if(length(pcs) == 1)
                    set(ttab.ddlPlotVar2, 'Value', 1);
                end
                
            end
            
            tg = ttab.tab_img.Parent;
            tg.Visible = 'off';
            
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
        
        function Redraw(self)
            
            %delete(ttab.model_plot);
            delete(self.model_plot_axes);
            %             ax = get(gcf,'CurrentAxes');
            %             cla(ax);
            ha2d = axes('Parent', self.tab_img);
            %set(gcf,'CurrentAxes',ha2d);
            self.model_plot_axes = ha2d;
            
            pc1 = self.pc_x;%self.ddlPlotVar1.Value;
            pc2 = self.pc_y;%self.ddlPlotVar2.Value;
            
            if ~isempty(self.Model)
                self.Model.Plot(self.model_plot_axes, pc1, pc2, self.chkPlotShowClasses.Value);
                
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
        
        function Recalibrate(self, src, ~)
            
            index_selected = get(self.ddlCalibrationSet,'Value');
            
            if index_selected > 1
            self.ClearModel();
            
            
            index_selected = get(self.ddlCalibrationSet,'Value');
            names = get(self.ddlCalibrationSet,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            d = evalin('base', selected_name);
            
            numPC = str2double(get(self.tbNumPCpls,'string'));
            
            if get(self.ddlModelType,'value') == 2
                mode = 'soft';
            else
                mode = 'hard';
            end
            
            alpha = str2double(get(self.tbAlpha,'string'));
            gamma = str2double(get(self.tbGamma,'string'));
            
            h = waitbar(0, 'Please wait...');
            
            waitbar(2.5/10, h);
            m = PLSDAModel(d, numPC, alpha, gamma);
            
            if strcmp(mode, 'hard')
                m.Mode = mode;
                m.Rebuild();
            end
            waitbar(5/10, h);
            self.Model = m;
            waitbar(7.5/10, h);
            set(self.chkFinalizeModel,'enable','on');
            set(self.btnSaveModel,'enable','on');

            waitbar(10/10, h);
            %pause(.5);
            delete(h);
            
            self.Redraw();
            self.enablePanel(self.pnlPlotSettings, 'on');
            self.enablePanel(self.pnlTableSettings, 'on');
            
            tg = self.tab_img.Parent;
                tg.Visible = 'on';
            
            end
        end
        
        function SaveModel(self, src, ~)
            
            if ~isempty(self.Model)
                
                prompt = {'Enter model name:'};
                dlg_title = 'Save model';
                num_lines = 1;
                def = {'PLS_DA'};
                opts = struct('WindowStyle','modal','Interpreter','none');
                answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
                
                if ~isempty(answer)
                    try
                        self.Model.Name = answer{1};
                        assignin('base', answer{1}, self.Model)
                        self.Redraw();
                        
                        extra_title = [' - Model: ' self.Model.Name];
                        set(self.parent.fig ,'name',['PLS-DA Tool' extra_title],'numbertitle','off');
                        
                    catch
                        opts = struct('WindowStyle','modal','Interpreter','none');
                        errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!','Error',opts);
                        tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                        self.Model.Name = tmp;
                        assignin('base',tmp, self.Model);
                        self.Redraw();
                        
                        extra_title = [' - Model: ' self.Model.Name];
                        set(self.parent.fig ,'name',['PLS-DA Tool' extra_title],'numbertitle','off');
                    end
                end
                
            end
            
        end
        
        function SavePlot(self, obj, ~)
            if ~isempty(self.model_plot_axes)
                
                type = self.Model.TrainingDataSet.Name;
                
                filename = [type,'.png'];
                if ispc
                    filename = [type,'.emf'];
                end
                
                fig2 = figure('visible','off');
                copyobj([self.model_plot_axes.Legend, self.model_plot_axes],fig2);
                [file,path] = uiputfile(filename,'Save classification plot');
                
                if ~(isnumeric(file) && (file == 0) && isnumeric(path) && (path == 0))
                    saveas(fig2, [path file]);
                end
            end
        end
        
        function CopyPlotToClipboard(self, obj, ~)
            fig2 = figure('visible','off');
            copyobj([self.model_plot_axes.Legend, self.model_plot_axes],fig2);
            
            if ispc
                print(fig2,'-clipboard', '-dmeta');
            else
                print(fig2,'-clipboard', '-dbitmap');
            end
            
        end
        
        function s = tableText(self)
            s = sprintf('%s\n','Allocation table');
            s = [s sprintf('%s',self.Model.AllocationTable)];
            
            s = [s sprintf('\n\n%s\n','Confusion matrix')];
            s = [s sprintf([repmat('%d\t',1, length(self.Model.ConfusionMatrix)) '\n'],self.Model.ConfusionMatrix)];
            
            s = [s sprintf('\n\n%s\n','Figures of merit')];
            fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
            fom = self.Model.FiguresOfMerit;
            fom_txt = [fields,  {num2str(round(fom.TP)); num2str(round(fom.FP)); ...
                '';...
                num2str(round(fom.CSNS)); num2str(round(fom.CSPS)); num2str(round(fom.CEFF)); ...
                '';...
                num2str(round(fom.TSNS));...
                num2str(round(fom.TSPS));...
                num2str(round(fom.TEFF))...
                }];
            
            s = [s sprintf('Statistics\t%s\n', sprintf('%d ',1:self.Model.TrainingDataSet.NumberOfClasses))];
            for i=1:size(fom_txt,1)
                s = [s sprintf('%s\t%s\n', fom_txt{i,1}, fom_txt{i,2})];
            end

        end
        
        function SaveTable(self, obj, ~)
            
            [file,path] = uiputfile(['model_' self.Model.Name '.txt'],'Save the classification table'); 
            
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
        
        function Finalize(self, obj, ~)
            val = get(obj,'value');
            
            self.Model.Finalized = val;
            
            win = self.parent;
            if val && isempty(win.predictTab)
                win.predictTab = PredictTab(win.tgroup, win);
            end
            
            if ~val && ~isempty(win.predictTab)
                mtab = win.tgroup.Children(3);
                delete(mtab);
                win.predictTab = [];
                
            end
        end
        
        function SelectCalibratinSet(self, src, ~)
            
            index_selected = get(src,'Value');
            self.ClearModel();
            
            if(index_selected > 1)
                names = get(src,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                self.btnRecalibrate.Enable = 'on';
                self.tbNumPCpls.Enable = 'on';
                self.tbAlpha.Enable = 'on';
                self.tbGamma.Enable = 'on';
                
                set(self.tbNumPCpca, 'String', sprintf('%d', max(1,d.NumberOfClasses-1)));
            else
                self.btnRecalibrate.Enable = 'off';
                self.tbNumPCpls.Enable = 'off';
                self.tbAlpha.Enable = 'off';
                self.tbGamma.Enable = 'off';
            end
        end
        
        function ClearModel(self)
            self.chkFinalizeModel.Enable = 'off';
            self.chkFinalizeModel.Value = 0;
            self.btnSaveModel.Enable = 'off';
            self.enablePanel(self.pnlPlotSettings, 'off');
            self.enablePanel(self.pnlTableSettings, 'off');
            
            set(self.parent.fig ,'name','PLS-DA Tool','numbertitle','off');
            
            self.Model = [];
            delete(self.model_plot_axes);
            self.tblTextResult.Data = [];
            self.tblTextConfusion.Data = [];
            self.tblTextFoM.Data = [];
            
            if ~isempty(self.parent.predictTab)
                mtab = self.parent.tgroup.Children(3);
                delete(mtab);
                self.parent.predictTab = [];
                
            end
            
            self.pc_x = 1;
            self.pc_y = 2;
        end
        
        function Input_ModelParameters(self, src, ~)
            if ~isempty(self.Model)
                self.ClearModel();
            end
        end
        
        function Input_NumPC_PLS(self, src, ~)
            str=get(src,'String');
            opts = struct('WindowStyle','modal','Interpreter','none');
            index_selected = get(self.ddlCalibrationSet,'Value');
            names = get(self.ddlCalibrationSet,'String');
            selected_name = names{index_selected};
            
            data = evalin('base', selected_name);
            
            vmax = min(size(data.ProcessedData));
            
            vmin = data.NumberOfClasses;
            
            if(data.Centering)
                vmax = vmax - 1;
            end
            
            numPC = str2double(str);
            
            if isempty(numPC) || isnan(numPC)
                set(src,'string', sprintf('%d', vmin));
                warndlg('Input must be numerical','Warning',opts);
            else
                if numPC < vmin || numPC > vmax
                    set(src,'string',sprintf('%d',vmin));
                    warndlg(sprintf('Number of PLS Components should be not less than %d and not more than %d!', vmin, vmax),'Warning',opts);
                else
                    self.ClearModel();
                end
            end
            
        end
        
        function Input_NumPC_PCA(self, src, ~)
            str=get(src,'String');
            
            index_selected = get(self.ddlCalibrationSet,'Value');
            names = get(self.ddlCalibrationSet,'String');
            selected_name = names{index_selected};
            
            data = evalin('base', selected_name);
            numPC = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            if isempty(numPC) || isnan(numPC)
                set(src,'string',sprintf('%d',max(1, self.Model.TrainingDataSet.NumberOfClasses-1)));
                warndlg('Input must be numerical','Warning',opts);
            else
                if (numPC >= 1 && numPC <= self.Model.TrainingDataSet.NumberOfClasses-1)
                    pcs = arrayfun(@(x) sprintf('%d', x), 1:numPC, 'UniformOutput', false);
                    
                    set(self.ddlPlotVar1, 'String', pcs);
                    set(self.ddlPlotVar2, 'String', pcs);
                    set(self.ddlPlotVar1, 'Value', 1);
                    
                    
                    if(length(pcs) == 1)
                        set(self.ddlPlotVar2, 'Value', 1);
                    else
                        set(self.ddlPlotVar2, 'Value', 2);
                    end
                    
                else
                    warndlg(sprintf('Number of Principal Components should be not less than %d and not more than %d!', 1, data.NumberOfClasses-1),'Warning',opts);
                    
                    set(src,'string',sprintf('%d',max(1, self.Model.TrainingDataSet.NumberOfClasses-1)));
                    self.ClearModel();
                    
                end
            end
            
            str=get(src,'String');
            pcs = arrayfun(@(x) sprintf('%d', x), 1:str2double(str), 'UniformOutput', false);
            
            set(self.ddlPlotVar1, 'String', pcs);
            set(self.ddlPlotVar2, 'String', pcs);
            set(self.ddlPlotVar1, 'Value', 1);
            set(self.ddlPlotVar2, 'Value', 2);
            
            if(length(pcs) == 1)
                set(self.ddlPlotVar2, 'Value', 1);
            end
            
            self.pc_y = 2;
            self.pc_x = 1;
            
            if(length(pcs) == 1)
                self.pc_y = 1;
            end
            
            self.Redraw();
            
        end
        
        function Input_Alpha(self, src, ~)
            str=get(src,'String');
            val = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            if isempty(val) || isnan(val)
                set(src,'string','0.01');
                warndlg('Input must be numerical','Warning',opts);
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Type I error (Alpha) should be greater than 0 and less than 1!','Warning',opts);
                else
                    self.ClearModel();
                end
            end
        end
        
        function Input_Gamma(self, src, ~)
            str=get(src,'String');
            val = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            if isempty(val) || isnan(val)
                set(src,'string','0.01');
                warndlg('Input must be numerical','Warning',opts);
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Outlier significance (Gamma) should be greater than 0 and less than 1!','Warning',opts);
                else
                    self.ClearModel();
                end
            end
        end
    end
    
    methods (Static)
        
        function r = filter_training(x)
            d = evalin('base', x.name);
            r = isequal(x.class,'DataSet') && d.Training && d.NumberOfClasses > 1;
        end
        
    end
    
end