classdef  ModelTab < BasicTab
    
    properties
        Model;
        
        pnlDataSettings;
        pnlCrossValidationSettings;
        pnlModelSettings
        pnlPlotSettings;
        
        ddlModelType;
        tbNumPCpls;
        tbNumPCpca;
        tbAlpha;
        tbGamma;
        
        %tbTextResult;
        tblTextResult;
        
        chkFinalizeModel;
        
        ddlCalibrationSet;
        ddlValidationSet;
        
        chkCrossValidation;
        ddlCrossValidationType;
        
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;
        
        btnSaveModel;
        
        model_plot_axes;
        %model_plot;
        tab_img;
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
                set(self.tbNumPCpca, 'String', sprintf('%d', max(2, self.Model.TrainingDataSet.NumberOfClasses-1)));%%temp
                set(self.tbAlpha,'string',sprintf('%.2f',self.Model.Alpha));
                set(self.tbGamma,'string',sprintf('%.2f',self.Model.Gamma));
            
                
                Labels = cell(size(self.Model.TrainingDataSet.ProcessedData, 1),1);
                for i = 1:size(self.Model.TrainingDataSet.ProcessedData, 1)
                    Labels{i} = sprintf('Object No.%d', i);
                end
                
                if(~isempty(self.Model.TrainingDataSet.SelectedObjectNames))
                    Labels = self.Model.TrainingDataSet.SelectedObjectNames;
                end
                
                self.tblTextResult.Data = [Labels, num2cell(logical(self.Model.AllocationMatrix))];
                
                self.tblTextResult.ColumnName = {'Sample',1:size(self.Model.AllocationMatrix, 2)};
                
                pcs = arrayfun(@(x) sprintf('%d', x), 1:max(2,self.Model.TrainingDataSet.NumberOfClasses), 'UniformOutput', false);
                
                set(self.ddlPlotVar1, 'String', pcs);
                set(self.ddlPlotVar2, 'String', pcs);
                set(self.ddlPlotVar1, 'Value', 1);
                set(self.ddlPlotVar2, 'Value', 2);
                
                self.chkFinalizeModel.Enable = 'on';
                self.btnSaveModel.Enable = 'on';
                self.enablePanel(self.pnlPlotSettings, 'on');
                
                self.Redraw();
                
                r = self;

            end
        end
        
        function enablePanel(self, panel, param)
            
            children = get(panel,'Children');
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            
        end
        
        function ttab = ModelTab(tabgroup, parent)
            
            ttab = ttab@BasicTab(tabgroup, 'Model', parent);
            
            ttab.pnlDataSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Data','Units', 'normalized', ...
                'Position', [0.05   0.85   0.9  0.14]);
            
            ttab.pnlCrossValidationSettings = uipanel('Parent', ttab.left_panel, 'Title', 'CrossValidation','Units', 'normalized', ...
                'Position', [0.05   0.71   0.9  0.14]);
            
            ttab.pnlModelSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Model','Units', 'normalized', ...
                'Position', [0.05   0.29   0.9  0.42]);
            
            ttab.pnlPlotSettings = uipanel('Parent', ttab.left_panel, 'Title', 'Plot','Units', 'normalized', ...
                'Position', [0.05   0.01   0.9  0.28]);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'Calibration', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.25], 'HorizontalAlignment', 'left');
            ttab.ddlCalibrationSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.4 0.67 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ttab.SelectCalibratinSet);
            
            uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'text', 'String', 'Validation', ...
                'Units', 'normalized','Position', [0.05 0.25 0.35 0.25], 'HorizontalAlignment', 'left', 'Enable', 'off');
            ttab.ddlValidationSet = uicontrol('Parent', ttab.pnlDataSettings, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.4 0.27 0.55 0.2], 'BackgroundColor', 'white', 'callback', @ttab.SelectValidationSet, 'Enable', 'off');
            
            
            
            %CrossValidation
            ttab.chkCrossValidation = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'checkbox', 'String', 'Use cross-validation',...
                'Units', 'normalized','Position', [0.05 0.7 0.85 0.2], 'callback', @ttab.Callback_UseCrossValidation, 'Enable', 'off');
            uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'text', 'String', 'Cross-validation type', ...
                'Units', 'normalized','Position', [0.05 0.3 0.85 0.25], 'HorizontalAlignment', 'left', 'Enable', 'off');
            ttab.ddlCrossValidationType = uicontrol('Parent', ttab.pnlCrossValidationSettings, 'Style', 'popupmenu', 'String', {'Leave-one-Out', 'K-fold', 'Holdout', 'Monte Carlo'},...
                'Units', 'normalized','Value',2, 'Position', [0.47 0.325 0.45 0.2], 'BackgroundColor', 'white', 'callback', @ttab.Callback_CrossValidationType, 'Enable', 'off');
            
            %lblModelType
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Type of model', ...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlModelType = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'popupmenu', 'String', {'Hard PLS-DA','Soft PLS-DA'},...
                'Units', 'normalized','Value',2, 'Position', [0.45 0.87 0.45 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_ModelParameters);
            
            %model params
            %PLS PCs
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Number of PLS PCs', ...
                'Units', 'normalized','Position', [0.05 0.7 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbNumPCpls = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '12',...
                'Units', 'normalized','Value',1, 'Position', [0.65 0.7 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC_PLS);
            
            %PCA PCs
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Number of PCA PCs', 'Enable', 'on', ...
                'Units', 'normalized','Position', [0.05 0.55 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbNumPCpca = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '2', 'Enable', 'on',...
                'Units', 'normalized','Value',1, 'Position', [0.65 0.55 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC_PCA);
            
            %lblAlpha
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Type I error (alpha)', ...
                'Units', 'normalized','Position', [0.05 0.4 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbAlpha = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '0.05',...
                'Units', 'normalized','Value',1, 'Position', [0.65 0.4 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_Alpha);
            
            %lblGamma
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Outlier significance (gamma)', ...
                'Units', 'normalized','Position', [0.05 0.25 0.6 0.1], 'HorizontalAlignment', 'left');
            ttab.tbGamma = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '0.01',...
                'Units', 'normalized','Value',1, 'Position', [0.65 0.25 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_Gamma);
            
            ttab.chkFinalizeModel = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'checkbox', 'String', 'Finalized',...
                'Units', 'normalized','Position', [0.05 0.17 0.45 0.1], 'callback', @ttab.Finalize, 'Enable', 'off');
            
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'pushbutton', 'String', 'Recalibrate',...
                'Units', 'Normalized', 'Position', [0.05 0.05 0.4 0.12], ...
                'callback', @ttab.Recalibrate);
            ttab.btnSaveModel = uicontrol('Parent', ttab.pnlModelSettings,'Enable','off', 'Style', 'pushbutton', 'String', 'Save model',...
                'Units', 'Normalized', 'Position', [0.51 0.05 0.4 0.12], ...
                'callback', @ttab.SaveModel);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'Normalized', 'Position', [0.05 0.1 0.4 0.18], ...
                'callback', @ttab.SavePlot, 'enable', 'off');
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.18], ...
                'callback', @ttab.CopyPlotToClipboard, 'enable', 'off');
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1], 'Enable', 'off', 'callback', @ttab.RedrawCallback);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.1], 'Enable', 'off', 'callback', @ttab.RedrawCallback);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 1', ...
                'Units', 'normalized','Position', [0.05 0.58 0.35 0.1], 'Enable', 'off', 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Enable', 'off', 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.6 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 2', 'Enable', 'off', ...
                'Units', 'normalized','Position', [0.05 0.38 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'Enable', 'off', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.4 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.RedrawCallback);
            
            
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            tab_txt = uitab('Parent', tg, 'Title', 'Table view');

            ttab.tblTextResult = uitable(tab_txt);
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
                    set(ttab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses));
                end
            end
            
            idx = arrayfun(@(x)ModelTab.filter_validation(x), allvars);
            vardisplay={};
            if sum(idx) > 0
                l = allvars(idx);
                vardisplay{1} = '-';
                for i = 1:length(l)
                    vardisplay{i+1} = l(i).name;
                end
                set(ttab.ddlValidationSet, 'String', vardisplay);
                if length(get(ttab.ddlValidationSet, 'String')) > 1
                    set(ttab.ddlValidationSet, 'Value', 2)
                    set(ttab.ddlValidationSet, 'enable', 'on');
                else
                    set(ttab.ddlValidationSet, 'enable', 'off');
                end
            end
            
            if isempty(ttab.Model)
                pcs = arrayfun(@(x) sprintf('%d', x), 1:str2double(get(ttab.tbNumPCpca,'string')), 'UniformOutput', false);
            
                set(ttab.ddlPlotVar1, 'String', pcs);
                set(ttab.ddlPlotVar2, 'String', pcs);
                set(ttab.ddlPlotVar1, 'Value', 1);
                set(ttab.ddlPlotVar2, 'Value', 2);

            end
            
        end
        
        function RedrawCallback(self, obj, param)
            
            prev_x = self.pc_x;
            prev_y = self.pc_y;
            
            if (self.ddlPlotVar1.Value == self.ddlPlotVar2.Value)
                self.ddlPlotVar1.Value = prev_y;
                self.ddlPlotVar2.Value = prev_x;
            end
            
            self.pc_x = self.ddlPlotVar1.Value;
            self.pc_y = self.ddlPlotVar2.Value;
            
            self.Redraw();
        end
        
        function Redraw(self)
            
            %delete(ttab.model_plot);
            delete(self.model_plot_axes);
            %             ax = get(gcf,'CurrentAxes');
            %             cla(ax);
            ha2d = axes('Parent', self.tab_img,'Units', 'normalized');
            %set(gcf,'CurrentAxes',ha2d);
            self.model_plot_axes = ha2d;
            
            pc1 = self.pc_x;%self.ddlPlotVar1.Value;
            pc2 = self.pc_y;%self.ddlPlotVar2.Value;
            
            if ~isempty(self.Model)
                self.Model.Plot(self.model_plot_axes, pc1, pc2);
                
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
            
            if ~isempty(self.Model)
                
                self.Model.TrainingDataSet = d;
                self.Model.Mode = mode;
                self.Model.Alpha = alpha;
                self.Model.Gamma = gamma;
                self.Model.NumPC = numPC;
                
                self.Model.Rebuild();
            else
                self.Model = PLSDAModel(d, numPC, alpha, gamma);
                
                if strcmp(mode, 'hard')
                    self.Model.Mode = mode;
                    self.Model.Rebuild();
                end
                
            end
            
            set(self.chkFinalizeModel,'enable','on');
            set(self.btnSaveModel,'enable','on');
            %set(self.tbTextResult, 'String', self.Model.AllocationTable);
            %mm = self.Model.AllocationMatrix;
            %[mm_rows, mm_cols] = size(mm);
            %self.tblTextResult.Data = mat2cell(mm, ones(1, mm_rows), ones(1, mm_cols));
            
            self.tblTextResult.ColumnName = {'Sample',1:self.Model.TrainingDataSet.NumberOfClasses};
            
            
            Labels = cell(size(self.Model.TrainingDataSet.ProcessedData, 1),1);
            for i = 1:size(self.Model.TrainingDataSet.ProcessedData, 1)
                Labels{i} = sprintf('Object No.%d', i);
            end
            
            if(~isempty(self.Model.TrainingDataSet.SelectedObjectNames))
                Labels = self.Model.TrainingDataSet.SelectedObjectNames;
            end
            
            self.tblTextResult.Data = [Labels, num2cell(logical(self.Model.AllocationMatrix(:,1:self.Model.TrainingDataSet.NumberOfClasses)))];
            
            self.tblTextResult.ColumnWidth = num2cell([150, 30*ones(1,size(self.Model.AllocationMatrix(:,1:self.Model.TrainingDataSet.NumberOfClasses), 2))]);
            
            %d = {'Male',52,true;'Male',40,true;'Female',25,false};
            %self.tblTextResult.Data = d;
            %self.tblTextResult.Position = [20 20 258 78];
            
            self.Redraw();
            self.enablePanel(self.pnlPlotSettings, 'on');
        end
        
        function SaveModel(self, src, ~)
            
            if ~isempty(self.Model)
                
                prompt = {'Enter model name:'};
                dlg_title = 'Save model';
                num_lines = 1;
                def = {'PLS_DA'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                
                if ~isempty(answer)
                    try
                        self.Model.Name = answer{1};
                        assignin('base', answer{1}, self.Model)
                    catch
                        errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!');
                        tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                        self.Model.Name = tmp;
                        assignin('base',tmp, self.Model);
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
                copyobj(self.model_plot_axes,fig2);
                saveas(fig2, filename);
            end
        end
        
        function CopyPlotToClipboard(self, obj, ~)
            fig2 = figure('visible','off');
            copyobj(self.model_plot_axes,fig2);
            
            if ispc
                print(fig2,'-clipboard', '-dmeta');
            else
                print(fig2,'-clipboard', '-dpng');
            end
            
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
        
        function Callback_CrossValidationType(self, src, ~)
            
        end
        
        function Callback_UseCrossValidation(self, src, ~)
            
        end
        
        function SelectValidationSet(self, src, ~)
            
        end
        
        function SelectCalibratinSet(self, src, ~)
            
            index_selected = get(src,'Value');
            
            if(index_selected > 1)
                names = get(src,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
            
                set(self.tbNumPCpca, 'String', sprintf('%d', max(2,d.NumberOfClasses)));

            else
                self.ClearModel();
            end
        end
        
        function ClearModel(self)
            self.chkFinalizeModel.Enable = 'off';
            self.chkFinalizeModel.Value = 0;
            self.btnSaveModel.Enable = 'off';
            self.enablePanel(self.pnlPlotSettings, 'off');
            
            self.Model = [];
            delete(self.model_plot_axes);
            self.tblTextResult.Data = [];
            
            if ~isempty(self.parent.predictTab)
                mtab = self.parent.tgroup.Children(3);
                delete(mtab);
                self.parent.predictTab = [];
                
            end
        end
        
        function Input_ModelParameters(self, src, ~)
            if ~isempty(self.Model)
                self.ClearModel();
            end
        end
        
        function Input_NumPC_PLS(self, src, ~)
            str=get(src,'String');
            
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
                warndlg('Input must be numerical');
            else
                if numPC < vmin || numPC > vmax
                    set(src,'string',sprintf('%d',vmin));
                    warndlg(sprintf('Number of PLS Components should be not less than %d and not more than %d!', vmin, vmax));
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
            
            if isempty(numPC) || isnan(numPC)
                set(src,'string','2');
                warndlg('Input must be numerical');
            else
                if numPC > max(2, data.NumberOfClasses) || numPC < min(2, data.NumberOfClasses)
                    set(src,'string',sprintf('%d',max(2, data.NumberOfClasses)));
                    
                    pcs = arrayfun(@(x) sprintf('%d', x), 1:max(2,self.Model.TrainingSet.NumberOfClasses), 'UniformOutput', false);
                
                    set(self.ddlPlotVar1, 'String', pcs);
                    set(self.ddlPlotVar2, 'String', pcs);
                    set(self.ddlPlotVar1, 'Value', 1);
                    set(self.ddlPlotVar2, 'Value', 2);
                    
                    
                    warndlg(sprintf('Number of Principal Components should be not less than %d and not more than %d!', min(2, data.NumberOfClasses), max(2, data.NumberOfClasses)));
                else
                   self.ClearModel();
                end
            end
            
            str=get(src,'String');
            pcs = arrayfun(@(x) sprintf('%d', x), 1:str2double(str), 'UniformOutput', false);
            
            set(self.ddlPlotVar1, 'String', pcs);
            set(self.ddlPlotVar2, 'String', pcs);
            set(self.ddlPlotVar1, 'Value', 1);
            set(self.ddlPlotVar2, 'Value', 2);
            self.pc_y = 2;
            self.pc_x = 1;
            
            self.Redraw();
            
        end
        
        function Input_Alpha(self, src, ~)
            str=get(src,'String');
            val = str2double(str);
            if isempty(val) || isnan(val)
                set(src,'string','0.01');
                warndlg('Input must be numerical');
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Type I error (Alpha) should be greater than 0 and less than 1!');
                else
                    self.ClearModel();
                end
            end
        end
        
        function Input_Gamma(self, src, ~)
            str=get(src,'String');
            val = str2double(str);
            if isempty(val) || isnan(val)
                set(src,'string','0.01');
                warndlg('Input must be numerical');
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Outlier significance (Gamma) should be greater than 0 and less than 1!');
                else
                    self.ClearModel();
                end
            end
        end
    end
    
    methods (Static)
        
        function r = filter_training(x)
            d = evalin('base', x.name);
            if isequal(x.class,'DataSet') && d.Training
                r = true;
            else
                r = false;
            end
        end
        
        function r = filter_validation(x)
            d = evalin('base', x.name);
            if isequal(x.class,'DataSet') && d.Validation
                r = true;
            else
                r = false;
            end
        end
        
        function r = filter_model(x)
            d = evalin('base', x.name);
            if isequal(x.class,'PLSDAModel') && d.Finalized
                r = true;
            else
                r = false;
            end
        end
        
    end
    
end