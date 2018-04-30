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
    
    methods
        
        function r = set.Model(self,value)
            self.Model = value;
            
            if self.Model.Finalized
                set(self.chkFinalizeModel,'value',1);
            end
            
            G = self.Model.TrainingDataSet.Name;
            idx = find(cell2mat(cellfun(@(x) strcmp(x, G), get(self.ddlCalibrationSet,'string'), 'UniformOutput',false)));
            set(self.ddlCalibrationSet,'value',idx);
            
            set(self.tbNumPCpls,'string',sprintf('%d',self.Model.NumPC));
            set(self.tbNumPCpca, 'String', sprintf('%d', max(2, size(self.Model.TrainingDataSet.DummyMatrix(),2)-1)));%%temp
            set(self.tbAlpha,'string',sprintf('%.2f',self.Model.Alpha));
            set(self.tbGamma,'string',sprintf('%.2f',self.Model.Gamma));
            
            data = guidata(gcf);
            data.modeltab = self;
            guidata(gcf, data);
            r = self;
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
                'Units', 'normalized','Value',1, 'Position', [0.65 0.7 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC);
            
            %PCA PCs
            uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'text', 'String', 'Number of PCA PCs', 'Enable', 'off', ...
                'Units', 'normalized','Position', [0.05 0.55 0.85 0.1], 'HorizontalAlignment', 'left');
            ttab.tbNumPCpca = uicontrol('Parent', ttab.pnlModelSettings, 'Style', 'edit', 'String', '2', 'Enable', 'off',...
                'Units', 'normalized','Value',1, 'Position', [0.65 0.55 0.25 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Input_NumPC);
            
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
                'callback', @ttab.SavePlot);
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'pushbutton', 'String', 'Copy to clipboard',...
                'Units', 'Normalized', 'Position', [0.51 0.1 0.4 0.18], ...
                'callback', @ttab.CopyPlotToClipboard);
            
            ttab.chkPlotShowClasses = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show classes',...
                'Units', 'normalized','Position', [0.05 0.85 0.85 0.1], 'Enable', 'off');%, 'callback', @DataTab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'checkbox', 'String', 'Show object names',...
                'Units', 'normalized','Position', [0.05 0.75 0.85 0.1], 'Enable', 'off');%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 1', ...
                'Units', 'normalized','Position', [0.05 0.58 0.35 0.1], 'Enable', 'off', 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', ttab.pnlPlotSettings, 'Enable', 'off', 'Style', 'popupmenu', 'String', {'1'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.6 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            
            uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'text', 'String', 'PC 2', 'Enable', 'off', ...
                'Units', 'normalized','Position', [0.05 0.38 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', ttab.pnlPlotSettings, 'Style', 'popupmenu', 'Enable', 'off', 'String', {'2'},...
                'Units', 'normalized','Value',1, 'Position', [0.45 0.4 0.35 0.1], 'BackgroundColor', 'white');%, 'callback', @DataTab.Redraw);
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            tab_txt = uitab('Parent', tg, 'Title', 'Table view');
            
            %             ttab.tbTextResult = uicontrol('Parent', tab_txt, 'Style', 'edit', 'String', '', ...
            %                 'Units', 'normalized','Position', [0 0 1 1], 'HorizontalAlignment', 'left', 'Max', 2);
            %
            ttab.tblTextResult = uitable(tab_txt);
            ttab.tblTextResult.Units = 'normalized';
            ttab.tblTextResult.Position = [0 0 1 1];
            
            if ~isempty(ttab.Model)
                
                Labels = cell(size(ttab.Model.TrainingDataSet.ProcessedData, 1),1);
                for i = 1:size(ttab.Model.TrainingDataSet.ProcessedData, 1)
                    Labels{i} = sprintf('Object No.%d', i);
                end
                
                if(~isempty(ttab.Model.TrainingDataSet.ObjectNames))
                    Labels = ttab.Model.TrainingDataSet.ObjectNames;
                end
                
                ttab.tblTextResult.Data = {Labels, num2cell(logical(ttab.Model.AllocationMatrix))};
                
                ttab.tblTextResult.ColumnName = {'Sample',1:size(ttab.Model.AllocationMatrix, 2)};
                
                %set(tbTextResult, 'String', ttab.Model.AllocationTable);
            end
            
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
                    set(ttab.tbNumPCpca, 'String', sprintf('%d', max(2, size(m.DummyMatrix(),2)-1)));%%temp
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
            
            %             data = guidata(gcf);
            %             data.modeltab = ttab;
            %             guidata(gcf, data);
            
        end

        function Redraw(self)
            
            %delete(ttab.model_plot);
            delete(self.model_plot_axes);
            %             ax = get(gcf,'CurrentAxes');
            %             cla(ax);
            ha2d = axes('Parent', self.tab_img,'Units', 'normalized','Position', [0 0 1 1]);
            %set(gcf,'CurrentAxes',ha2d);
            self.model_plot_axes = ha2d;
            
            if ~isempty(self.Model)
                self.Model.Plot(self.model_plot_axes);
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
            
            self.tblTextResult.ColumnName = {'Sample',1:size(self.Model.AllocationMatrix, 2)};
            
            
            Labels = cell(size(self.Model.TrainingDataSet.ProcessedData, 1),1);
            for i = 1:size(self.Model.TrainingDataSet.ProcessedData, 1)
                Labels{i} = sprintf('Object No.%d', i);
            end
            
            if(~isempty(self.Model.TrainingDataSet.ObjectNames))
                Labels = self.Model.TrainingDataSet.ObjectNames;
            end
            
            self.tblTextResult.Data = [Labels, num2cell(logical(self.Model.AllocationMatrix))];
            
            self.tblTextResult.ColumnWidth = num2cell([150, 30*ones(1,size(self.Model.AllocationMatrix, 2))]);
            
            %d = {'Male',52,true;'Male',40,true;'Female',25,false};
            %self.tblTextResult.Data = d;
            %self.tblTextResult.Position = [20 20 258 78];
            
            self.Redraw();
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
        
        function Input_Gamma(self, src, ~)
            
        end
        
        function Callback_CrossValidationType(self, src, ~)
            
        end
        
        function Callback_UseCrossValidation(self, src, ~)
            
        end
        
        function SelectValidationSet(self, src, ~)
            
        end
        
        function SelectCalibratinSet(self, src, ~)
            
        end
        
        function Input_ModelParameters(self, src, ~)
            val = get(src,'Value');
            if ~isempty(val) && ~isnan(val)
                
            end
        end
        
        function CheckPC(self)
            
            %TBD
        end
        
        function Input_NumPC(self, src, ~)
            str=get(src,'String');
            %TBD
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
                    %TBD
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