classdef CVTab < BasicTab
    
    properties
        
        vbox;
        
        pnlDataSettings;
        pnlCrossValidationSettings;
        pnlModelSettings
        pnlResultsSettings;
        
        pnlPlotSettings;
        pnlTableSettings;
        
        ddlDataSet;
        ddlModelType;
        
        tbNumPCplsMin;
        tbNumPCplsStep;
        tbNumPCplsMax;
        
        tbAlphaMin;
        tbAlphaStep;
        tbAlphaMax;
        
        ddlCrossValidationType;
        chkShuffle;
        
        tbCVParamName;
        tbCVParamValue;
        
        tbCVIterationsName;
        tbCVIterations;
        
        tg;
        tab_split;
        tab_result;
        
        tblTextResult;
        
        btnCVRun;
        btnCVSave;
        
        cvtask;
        
        hboxm4;
        
        ddlResultViewMode;
        
        ddlSelectedSplit;
        ddlSelectedAlpha;
        
        lblSelectedSplit;
        lblSelectedAlpha;
        
        ddlResultCategory;
        ddlResultDataSet;
        
        ddlPlotVarY;
        ddlPlotVarX;
        
        btnExamineModel;
        btnSaveDatasets;
     
    end
    
    methods
        
        function Callback_ResultCategory(self, src, param)
            if src.Value == 1 %summary
                self.ddlSelectedSplit.Visible = 'off';
                self.ddlSelectedAlpha.Visible = 'off';
                self.lblSelectedSplit.Visible = 'off';
                self.lblSelectedAlpha.Visible = 'off';
                self.btnExamineModel.Visible = 'off';
                self.btnSaveDatasets.Visible = 'off';
            else
                self.ddlSelectedSplit.Visible = 'on';
                self.ddlSelectedAlpha.Visible = 'on';
                self.lblSelectedSplit.Visible = 'on';
                self.lblSelectedAlpha.Visible = 'on';
                self.btnExamineModel.Visible = 'on';
                self.btnSaveDatasets.Visible = 'on';
            end
        end
        
        function Callback_SelectedSplit(self, src, param)
            
        end
        
        function Callback_ResultViewMode(self, src, param)
            if src.Value == 1 % Graphics
                self.vbox.Heights=[0,0,0,200,100,0];
                set(self.pnlPlotSettings,'visible','on');
                set(self.pnlTableSettings,'visible','off');
            else
                self.vbox.Heights=[0,0,0,200,0,60];
                set(self.pnlPlotSettings,'visible','off');
                set(self.pnlTableSettings,'visible','on');
            end
        end
        
        function Callback_ResultDataSet(self, src, param)

        end
        
        function RedrawCallback(self, src, param)

        end
        
        function SavePlot(self, src, param)

        end
        
        function SaveTable(self, src, param)

        end
        
        function CopyPlotToClipboard(self, src, param)

        end
        
        function CopyTableToClipboard(self, src, param)

        end
        
        function ExamineModel(self, src, param)
            
            if ~isempty(self.cvtask.Results)
                ind = self.ddlSelectedSplit.Value;
                model = self.cvtask.Results(ind).model;
                
                assignin('base', model.TrainingDataSet.Name, model.TrainingDataSet);
                
                if isempty(self.parent.modelTab)
                    self.parent.modelTab = ModelTab(self.parent.tgroup, self.parent);
                end
                
                if ~isempty(self.parent.modelTab)
                    
                    allvars = evalin('base','whos');
                    
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    if sum(idx) > 0
                        l = allvars(idx);
                        vardisplay  = [{'-'}, {l.name}];
                        set(self.parent.modelTab.ddlCalibrationSet, 'String', vardisplay);
                    end
                    
                    
                    self.parent.modelTab.Model = model;
                    ind = arrayfun(@(x)isequal(x.Title ,'Model'),self.parent.tgroup.Children);
                    mtab = self.parent.tgroup.Children(ind);
                    self.parent.tgroup.SelectedTab = mtab;
                end
            else
                
            end
            
        end
            
            
        
        function SaveDatasets(self, src, param)

        end

        
        function obj = CVTab(tabgroup, parent)
            
            obj = obj@BasicTab(tabgroup, 'Cross-validation', parent);
            
            obj.vbox = uix.VBox( 'Parent', obj.left_panel, 'Padding', 15, 'Spacing', 5 );
            
            obj.pnlDataSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Data', 'TitlePosition', 'LeftTop');
            
            obj.pnlModelSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Model settings', 'TitlePosition', 'LeftTop');
            
            obj.pnlCrossValidationSettings = uiextras.Panel('Parent', obj.vbox, 'Title', 'Cross-validation settings', 'TitlePosition', 'LeftTop');
            
            obj.pnlResultsSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Options', 'TitlePosition', 'LeftTop','visible','off');
            
            obj.pnlPlotSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Plot settings', 'TitlePosition', 'LeftTop');
            obj.pnlTableSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Table view options', 'TitlePosition', 'LeftTop','visible','off');
            
            %results view options
            vbox21 = uix.VBox( 'Parent', obj.pnlResultsSettings, 'Padding', 15, 'Spacing', 5 );
            hbox21 = uix.Grid( 'Parent', vbox21,'Spacing', 5);
            uicontrol('Parent', hbox21, 'Style', 'text', 'String', 'Results');
            obj.ddlResultCategory = uicontrol('Parent', hbox21, 'Style', 'popupmenu', 'String', {'Summary','Individual split'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_ResultCategory);
            %uicontrol('Parent', hbox21, 'Style', 'text', 'String', 'View mode');
            hbox21.Widths = [60,120];
            
            hbox22 = uix.Grid( 'Parent', vbox21,'Spacing', 5);
            uicontrol('Parent', hbox22, 'Style', 'text', 'String', 'View mode');
            obj.ddlResultViewMode = uicontrol('Parent', hbox22, 'Style', 'popupmenu', 'String', {'Graphics','Table view'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_ResultViewMode);

            hbox22.Widths = [60,120];
            
            
            
            hbox23 = uix.Grid( 'Parent', vbox21,'Spacing', 5);
            uicontrol('Parent', hbox23, 'Style', 'text', 'String', 'Dataset');
            obj.ddlResultDataSet = uicontrol('Parent', hbox23, 'Style', 'popupmenu', 'String', {'Calibration','Validation'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_ResultDataSet);
            
            hbox23.Widths = [60,120];
            
            hbox222 = uix.Grid( 'Parent', vbox21,'Spacing', 5);
            obj.lblSelectedSplit = uicontrol('Parent', hbox222, 'Style', 'text', 'String', 'Split','Visible','off');
            obj.ddlSelectedSplit = uicontrol('Parent', hbox222, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_SelectedSplit,'Visible','off');
            obj.lblSelectedAlpha = uicontrol('Parent', hbox222, 'Style', 'text', 'String', 'Type 1 error','Visible','off');
            obj.ddlSelectedAlpha = uicontrol('Parent', hbox222, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_SelectedSplit,'Visible','off');
            hbox222.Widths = [60,50,60,50];
            
            hboxp24 = uix.HButtonBox( 'Parent', vbox21, 'ButtonSize', [120 25]);
            obj.btnExamineModel = uicontrol('Parent', hboxp24, 'Style', 'pushbutton', 'String', 'Examine the model',...
                'callback', @obj.ExamineModel, 'Visible','off');
            obj.btnSaveDatasets = uicontrol('Parent', hboxp24, 'Style', 'pushbutton', 'String', 'Save datasets',...
                'callback', @obj.SaveDatasets, 'Visible','off');
            
            
            vbox_plot = uix.VBox( 'Parent', obj.pnlPlotSettings, 'Padding', 5, 'Spacing', 5 );
            
            hboxp3 = uix.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 20], 'Spacing', 5);
            uicontrol('Parent', hboxp3, 'Style', 'text', 'String', 'Y-axis', ...
                 'HorizontalAlignment', 'left');
            obj.ddlPlotVarY = uicontrol('Parent', hboxp3, 'Style', 'popupmenu', 'String', {'-'},...
                 'BackgroundColor', 'white', 'callback', @obj.RedrawCallback);
            
            uicontrol('Parent', hboxp3, 'Style', 'text', 'String', 'X-axis', ...
                 'HorizontalAlignment', 'left');
            obj.ddlPlotVarX = uicontrol('Parent', hboxp3, 'Style', 'popupmenu', 'String', {'-'},...
                 'BackgroundColor', 'white', 'callback', @obj.RedrawCallback);
             
            hboxp1 = uix.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxp1, 'Style', 'pushbutton', 'String', 'Save image to file',...
                'callback', @obj.SavePlot);
            uicontrol('Parent', hboxp1, 'Style', 'pushbutton', 'String', 'Copy image to clipboard',...
                'callback', @obj.CopyPlotToClipboard);
            
            hboxt1 = uix.HButtonBox( 'Parent', obj.pnlTableSettings, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Save tables to file',...
                'callback', @obj.SaveTable);
            uicontrol('Parent', hboxt1, 'Style', 'pushbutton', 'String', 'Copy tables to clipboard',...
                'callback', @obj.CopyTableToClipboard);
            
            
            
            
            
            
            
            
            
            
            
            hbox1 = uiextras.HButtonBox( 'Parent', obj.pnlDataSettings, 'ButtonSize', [120 25]);
            
            uicontrol('Parent', hbox1, 'Style', 'text', 'String', 'Dataset');
            obj.ddlDataSet = uicontrol('Parent', hbox1, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @obj.Callback_SelectDataSet);
            
            vbox_mod = uix.VBox( 'Parent', obj.pnlModelSettings, 'Padding', 10, 'Spacing', 5 );
            %lblModelType
            hboxm1 = uiextras.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 40]);
            uicontrol('Parent', hboxm1, 'Style', 'text', 'String', 'Type of model');
            obj.ddlModelType = uicontrol('Parent', hboxm1, 'Style', 'popupmenu', 'String', {'Hard PLS-DA','Soft PLS-DA'},...
                'value', 2, 'BackgroundColor', 'white', 'callback', @obj.Input_ModelParameters);
            
            hboxm2 = uiextras.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 30]);
            %model params
            %PLS PCs
            uicontrol('Parent', hboxm2, 'Style', 'text', 'String', 'PLS components');
            hboxm2_ = uix.Grid( 'Parent', hboxm2);
            obj.tbNumPCplsMin = uicontrol('Parent', hboxm2_, 'Style', 'edit', 'String', '12',...
                'BackgroundColor', 'white', 'callback', @obj.Input_NumPC_PLS);
            uicontrol('Parent', hboxm2_, 'Style', 'text', 'String', '-', 'HorizontalAlignment', 'center');
            obj.tbNumPCplsStep = uicontrol('Parent', hboxm2_, 'Style', 'edit', 'String', '1',...
                'BackgroundColor', 'white', 'callback', @obj.Input_NumPC_Step, 'enable', 'off');
            uicontrol('Parent', hboxm2_, 'Style', 'text', 'String', '-', 'HorizontalAlignment', 'center');
            obj.tbNumPCplsMax = uicontrol('Parent', hboxm2_, 'Style', 'edit', 'String', '12',...
                'BackgroundColor', 'white', 'callback', @obj.Input_NumPC_PLS);
            hboxm2_.Widths = [30,10,30,10,30];
            
            obj.hboxm4 = uiextras.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 30]);
            %lblAlpha
            uicontrol('Parent', obj.hboxm4, 'Style', 'text', 'String', 'Type I error');
            hboxm4_ = uix.Grid( 'Parent', obj.hboxm4);
            obj.tbAlphaMin = uicontrol('Parent', hboxm4_, 'Style', 'edit', 'String', '0.05',...
                'BackgroundColor', 'white', 'callback', @obj.Input_Alpha);
            uicontrol('Parent', hboxm4_, 'Style', 'text', 'String', '-', 'HorizontalAlignment', 'center');
            obj.tbAlphaStep = uicontrol('Parent', hboxm4_, 'Style', 'edit', 'String', '0.01',...
                'BackgroundColor', 'white', 'callback', @obj.Input_Alpha_Step, 'enable', 'off');
            uicontrol('Parent', hboxm4_, 'Style', 'text', 'String', '-', 'HorizontalAlignment', 'center');
            obj.tbAlphaMax = uicontrol('Parent', hboxm4_, 'Style', 'edit', 'String', '0.05',...
                'BackgroundColor', 'white', 'callback', @obj.Input_Alpha);
            hboxm4_.Widths = [30,10,30,10,30];
            
            vbox_cv = uix.VBox( 'Parent', obj.pnlCrossValidationSettings, 'Padding', 10, 'Spacing', 5 );
            
            hboxm5 = uix.Grid( 'Parent', vbox_cv);
            uicontrol('Parent', hboxm5, 'Style', 'text', 'String', 'Type', ...
                'Units', 'normalized', 'HorizontalAlignment', 'center');
            obj.ddlCrossValidationType = uicontrol('Parent', hboxm5, 'Style', 'popupmenu', 'String', {'Leave-one-Out', 'K-fold', 'Holdout', 'Monte Carlo'},...
                'Units', 'normalized','Value',2, 'BackgroundColor', 'white', 'callback', @obj.Callback_CrossValidationType);
            
            if ispc
                hboxm5.Spacing = 5;
            end
            
            obj.chkShuffle = uicontrol('Parent', hboxm5, 'Style', 'checkbox', 'value', 1, 'String', 'Shuffle',...
                'callback', @obj.Callback_Shuffle);
            
            
            hboxm5.Widths = [-1 -2 -1];
            if ispc
                hboxm5.Widths = [-1 -2 -1];
            else
                hboxm5.Widths = [-1 -2 -1];
            end
            
            hboxm8 = uix.Grid( 'Parent', vbox_cv);
            
            
            obj.tbCVParamName = uicontrol('Parent', hboxm8, 'Style', 'text', 'String', 'Folds');
            obj.tbCVParamValue = uicontrol('Parent', hboxm8, 'Style', 'edit', 'String', '10',...
                'BackgroundColor', 'white', 'callback', @obj.Input_CVParam);
            obj.tbCVIterationsName = uicontrol('Parent', hboxm8, 'Style', 'text', 'visible', 'off', 'String', 'Iterations');
            obj.tbCVIterations = uicontrol('Parent', hboxm8, 'Style', 'edit', 'String', '10',...
                'BackgroundColor', 'white', 'visible', 'off','callback', @obj.Input_CVParamIter);
            %hboxm8.Widths = [-1 -2];
            
            hboxp6 = uiextras.HButtonBox( 'Parent', vbox_cv, 'ButtonSize', [120 25]);
            uicontrol('Parent', hboxp6, 'Style', 'pushbutton', 'String', 'Split',...
                'callback', @obj.Callback_Split);
            obj.btnCVRun = uicontrol('Parent', hboxp6, 'Style', 'pushbutton', 'String', 'Run cross-validation',...
                'callback', @obj.Callback_CVRun, 'enable', 'off');
            
            hboxp7 = uiextras.HButtonBox( 'Parent', vbox_cv, 'ButtonSize', [120 25]);
            obj.btnCVSave = uicontrol('Parent', hboxp7, 'Style', 'pushbutton', 'String', 'Save CV Task',...
                'callback', @obj.Callback_SaveCVTask, 'enable', 'off');
            uicontrol('Parent', hboxp7, 'Style', 'pushbutton', 'String', 'Load CV Task',...
                'callback', @obj.Callback_LoadCVTask);
            
            if ispc
                obj.vbox.Heights=[40,130,150,0,0,0];
            else
                obj.vbox.Heights=[40,120,150,0,0,0];
            end
            
            obj.FillDataSetList();
            
            obj.tg = uitabgroup('Parent', obj.middle_panel);
            
            w = obj.parent;
            set(obj.tg, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            obj.tab_split = uitab('Parent', obj.tg, 'Title', 'Data');
            obj.tab_result = uitab('Parent', obj.tg, 'Title', 'Results');
            obj.tab_result.Parent = [];
            
            obj.tblTextResult = uitable(obj.tab_split);
            obj.tblTextResult.Units = 'normalized';
            obj.tblTextResult.Position = [0 0 1 1];
            
            vardisplay = get(obj.ddlDataSet, 'String');
            selected_name = vardisplay{1};
            
            obj.FillTableView(selected_name);
            
        end
        
        function r = filter_data(self, x)
            d = evalin('base', x.name);
            r = isequal(x.class,'DataSet') && d.NumberOfClasses > 1;
        end
        
        function FillDataSetList(self)
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = arrayfun(@(x)self.filter_data(x), allvars);
            
            if ~isempty(idx)
                vardisplay = varnames(idx);
                set(self.ddlDataSet, 'String', vardisplay);
                
                selected_name = vardisplay{1};
                set(self.ddlDataSet, 'Value', 1);
                
                d = evalin('base', selected_name);
                
                self.FillTableView(selected_name);
                
            end
            
        end
        
        function FillTableView(self, selected_name)
            
            self.ClearResults();
            
            d = evalin('base', selected_name);
            
            Labels = cell(size(d.ProcessedData, 1),1);
            
            v = 1:size(d.RawData, 1);
            v = v(logical(d.SelectedSamples));
            
            for i = 1:length(v)
                Labels{i} = sprintf('Object No.%d', v(i));
            end
            
            if(~isempty(d.SelectedObjectNames))
                Labels = d.SelectedObjectNames;
            end
            
            if ~isempty(d.Classes)
                self.tblTextResult.ColumnName = {'Sample', 'Class'};
                
                if ~isempty(d.ClassLabels)
                    self.tblTextResult.Data = [Labels, {d.ClassLabels{d.Classes}}'];
                    self.tblTextResult.ColumnWidth = num2cell([100 max(60, max(strlength(d.ClassLabels))*7)]);
                else
                    self.tblTextResult.Data = [Labels, num2cell(d.Classes)];
                    self.tblTextResult.ColumnWidth = num2cell([100 60]);
                end
                
                self.tblTextResult.ColumnEditable = [false false];
            end
            
            %self.tblTextResult.CellEditCallback = @self.SelectedSamplesChangedCallback;
            
        end
        
        function FillTableViewWithSplit(self)
            
            if ~isempty(self.cvtask) && ~isempty(self.cvtask.Splits)
                d = self.cvtask.DataSet;
                
                v = 1:size(d.RawData, 1);
                v = v(logical(d.SelectedSamples));
                
                if(~isempty(d.SelectedObjectNames))
                    Labels = d.SelectedObjectNames;
                else
                    Labels = arrayfun(@(i) sprintf('Object No.%d', i), v, 'UniformOutput', false);
                end
                number_of_splits = size(self.cvtask.Splits, 2);
                names_ = arrayfun(@(i) sprintf('Split #%d', i), 1:number_of_splits, 'UniformOutput', false);
                %names_1 = arrayfun(@(i) sprintf('<HTML><TABLE><TD bgcolor="red">Split #%d', i), 1:number_of_splits, 'UniformOutput', false);

                cv = arrayfun(@self.bool2cv, logical(self.cvtask.Splits),'UniformOutput', false);
                
                self.tblTextResult.ColumnName = [{'Sample', 'Class'}, names_];
                self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'char'},1,number_of_splits)];
                
                if ~isempty(d.ClassLabels)
                    self.tblTextResult.Data = [Labels, {d.ClassLabels{d.Classes}}' cv];
                    self.tblTextResult.ColumnWidth = num2cell([100 max(60, max(strlength(d.ClassLabels))*7) max(60, 7*max(strlength(names_)))*ones(1,number_of_splits)]);
                else
                    self.tblTextResult.Data = [Labels, num2cell(d.Classes) cv];
                    self.tblTextResult.ColumnWidth = num2cell([100 60 max(60, 7*max(strlength(names_)))*ones(1,number_of_splits)]);
                end
                
            end
            %self.tblTextResult.ColumnEditable = [false false];
            
            %self.tblTextResult.CellEditCallback = @self.SelectedSamplesChangedCallback;
            
        end
        
        function Callback_SelectDataSet(self, src, param)
            
            index_selected = get(src,'Value');
            
            names = get(self.ddlDataSet, 'String');
            
            selected_name = names{index_selected};
            
            d = evalin('base', selected_name);
            %tbd
            
            self.FillTableView(selected_name);
            
            self.btnCVRun.Enable = 'off';
            self.btnCVSave.Enable = 'off';
        end
        
        function v = bool2cv(self, x)
            
            padding = 4;
            
            if (x)
                c = '#FFC000';
                v = [ repmat(' ', 1, padding ) 'V'];
            else
                c = '#26C000';
                v = [ repmat(' ', 1, padding ) 'C'];
            end
            
            v = ['<html><table border=0 width=100% bgcolor=',c,'><TR><TD>',v,'</TD></TR> </table></html>'];
            
        end
        
        function Callback_SaveCVTask(self, src, param)
            if ~isempty(self.cvtask)
                
                prompt = {'Enter CV Task name:'};
                dlg_title = 'Save CV Task';
                num_lines = 1;
                def = {'CV_TASK'};
                opts = struct('WindowStyle','modal','Interpreter','none');
                answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
                
                if ~isempty(answer)
                    try
                        assignin('base', answer{1}, self.cvtask);
                    catch
                        opts = struct('WindowStyle','modal','Interpreter','none');
                        errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!','Error',opts);
                        tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                        assignin('base',tmp, self.cvtask);
                    end
                end
                
            end
        end
        
        function ClearResults(self)
            if ~isempty(self.cvtask)
                self.cvtask.Results = [];
            end
            self.tab_result.Parent = [];
        end
        
        function ShowResults(self)
            self.tab_result.Parent = self.tg;
            
            if ~isempty(self.cvtask.Results)
                self.ddlSelectedSplit.String = cellstr(string(unique([self.cvtask.Results.split])));
                self.ddlSelectedAlpha.String = cellstr(string(unique([self.cvtask.Results.alpha]))); 
            end
        end
        
        function Callback_LoadCVTask(self, src, param)
            [tvar, tvarname] = uigetvariables({'Pick a CVTask object:'}, ...
                'ValidationFcn',{@(x) isa(x, 'CVTask')});
            if ~isempty(tvar)
                
                
                self.cvtask = tvar{1};
                
                if strcmp(self.cvtask.ModelType,'hard')
                    self.ddlModelType.Value = 1;
                else
                    self.ddlModelType.Value = 2;
                end
        
                self.tbNumPCplsMin.String = sprintf('%d', self.cvtask.MinPC);
                self.tbNumPCplsStep.String = sprintf('%d', self.cvtask.PCStep);
                self.tbNumPCplsMax.String = sprintf('%d', self.cvtask.MaxPC);
                
                min_format = ['%.' sprintf('%d', sigdigits(self.cvtask.MinAlpha)) 'f'];
                step_format = ['%.' sprintf('%d', sigdigits(self.cvtask.AlphaStep)) 'f'];
                max_format = ['%.' sprintf('%d', sigdigits(self.cvtask.MaxAlpha)) 'f'];
                
                self.tbAlphaMin.String = sprintf(min_format, self.cvtask.MinAlpha);
                self.tbAlphaStep.String = sprintf(step_format, self.cvtask.AlphaStep);
                self.tbAlphaMax.String = sprintf(max_format, self.cvtask.MaxAlpha);
                
                if self.cvtask.MinPC == self.cvtask.MaxPC
                    self.tbNumPCplsStep.Enable = 'off';
                else
                    self.tbNumPCplsStep.Enable = 'on';
                end
                
                if self.cvtask.MinAlpha == self.cvtask.MaxAlpha
                    self.tbAlphaStep.Enable = 'off';
                else
                    self.tbAlphaStep.Enable = 'on';
                end
        
                switch(self.cvtask.Type)
                    case 'leave-one-out'
                        self.ddlCrossValidationType.Value = 1;
                        self.tbCVParamName.Visible = 'off';
                        self.tbCVParamValue.Visible = 'off';
                        self.tbCVIterationsName.Visible = 'off';
                        self.tbCVIterations.Visible = 'off';
                        self.chkShuffle.Enable = 'on';
                    case 'k-fold'
                        self.ddlCrossValidationType.Value = 2;
                        self.tbCVParamValue.String = sprintf('%d',self.cvtask.Folds);
                        self.tbCVParamName.String = 'Folds';
                        self.tbCVParamName.Visible = 'on';
                        self.tbCVParamValue.Visible = 'on';
                        self.tbCVIterationsName.Visible = 'off';
                        self.tbCVIterations.Visible = 'off';
                        self.chkShuffle.Enable = 'on';
                    case 'holdout'
                        self.ddlCrossValidationType.Value = 3;
                        self.tbCVParamValue.String = sprintf('%d',self.cvtask.ValidationPercent);
                        self.tbCVParamName.String = 'Test part (%)';
                        self.tbCVParamName.Visible = 'on';
                        self.tbCVParamValue.Visible = 'on';
                        self.tbCVIterationsName.Visible = 'off';
                        self.tbCVIterations.Visible = 'off';
                        self.chkShuffle.Enable = 'on';
                    case 'monte-carlo'
                        self.ddlCrossValidationType.Value = 4;
                        self.tbCVParamValue.String = sprintf('%d',self.cvtask.ValidationPercent);
                        self.tbCVIterations.String = sprintf('%d',self.cvtask.Iterations);
                        self.tbCVParamName.String = 'Test part (%)';
                        self.tbCVParamName.Visible = 'on';
                        self.tbCVParamValue.Visible = 'on';
                        self.tbCVIterationsName.Visible = 'on';
                        self.tbCVIterations.Visible = 'on';
                        self.chkShuffle.Enable = 'off';
                        %self.chkShuffle.Value = 1;
                end
                
                self.chkShuffle.Value = self.cvtask.Shuffle;
                
                %self.cvtask.GenerateSplits();
                assignin('base', self.cvtask.DataSet.Name, self.cvtask.DataSet);
                
                self.FillDataSetList();

                selected_index = find(strcmp(self.ddlDataSet.String, self.cvtask.DataSet.Name));
                
                if isempty(selected_index)
                    selected_index = 2;
                end
                        
                set(self.ddlDataSet, 'Value', selected_index);
                
                self.parent.dataTab.FillDataSetList();
                
                allvars = evalin('base','whos');
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win);
                end
                
                if sum(idx) > 0 && ~isempty(win.modelTab)

                    l = allvars(idx);

                    vardisplay = [{'-'}, {l.name}];
                    set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                    
                    if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                        set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                        
                        m = evalin('base',vardisplay{2});
                        set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                    end
                end
                
                self.FillTableViewWithSplit();
                
                self.btnCVRun.Enable = 'on';
                self.btnCVSave.Enable = 'on';
                
            end
        end
        
        function s = tableTextVal(self, result, train_cls_num)
            s = sprintf('%s\n','Allocation table');
            s = [s sprintf('%s',result.AllocationTable)];
            
            if isfield(self.result,'ConfusionMatrix')
                s = [s sprintf('\n\n%s\n','Confusion matrix')];
                s = [s sprintf([repmat('%d\t',1, length(result.ConfusionMatrix)) '\n'],result.ConfusionMatrix)];
            end
            
            if isfield(result,'FiguresOfMerit')
                s = [s sprintf('\n\n%s\n','Figures of merit')];
                fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
                fom = result.FiguresOfMerit;
                fom_txt = [fields,  {num2str(round(fom.TP)); num2str(round(fom.FP)); ...
                    '';...
                    num2str(round(fom.CSNS)); num2str(round(fom.CSPS)); num2str(round(fom.CEFF)); ...
                    '';...
                    num2str(round(fom.TSNS));...
                    num2str(round(fom.TSPS));...
                    num2str(round(fom.TEFF))...
                    }];
                
                s = [s sprintf('Statistics\t%s\n', sprintf('%d ',1:train_cls_num))];
                for i=1:size(fom_txt,1)
                    s = [s sprintf('%s\t%s\n', fom_txt{i,1}, fom_txt{i,2})];
                end
            end
            
        end
        
        function s = tableTextMod(self, Model)
            s = sprintf('%s\n','Allocation table');
            s = [s sprintf('%s',Model.AllocationTable)];
            
            s = [s sprintf('\n\n%s\n','Confusion matrix')];
            s = [s sprintf([repmat('%d\t',1, length(Model.ConfusionMatrix)) '\n'],Model.ConfusionMatrix)];
            
            s = [s sprintf('\n\n%s\n','Figures of merit')];
            fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
            fom = Model.FiguresOfMerit;
            fom_txt = [fields,  {num2str(round(fom.TP)); num2str(round(fom.FP)); ...
                '';...
                num2str(round(fom.CSNS)); num2str(round(fom.CSPS)); num2str(round(fom.CEFF)); ...
                '';...
                num2str(round(fom.TSNS));...
                num2str(round(fom.TSPS));...
                num2str(round(fom.TEFF))...
                }];
            
            s = [s sprintf('Statistics\t%s\n', sprintf('%d ',1:Model.TrainingDataSet.NumberOfClasses))];
            for i=1:size(fom_txt,1)
                s = [s sprintf('%s\t%s\n', fom_txt{i,1}, fom_txt{i,2})];
            end
            
        end
        
        function Callback_CVRun(self, src, param)
            
            if ~isempty(self.cvtask)
                self.ClearResults()
                num_of_splits = size(self.cvtask.Splits, 2);
                
                index_selected = get(self.ddlDataSet,'Value');
                names = get(self.ddlDataSet, 'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                dat = d.RawData(logical(d.SelectedSamples),:);
                cls = d.RawClasses(logical(d.SelectedSamples),:);
                lbl = [];
                if ~isempty(d.ObjectNames)
                    lbl = d.ObjectNames(logical(d.SelectedSamples),:);
                end
                
                min_pc = str2double(self.tbNumPCplsMin.String);
                pc_step = str2double(self.tbNumPCplsStep.String);
                max_pc = str2double(self.tbNumPCplsMax.String);
                
                min_alpha = str2double(self.tbAlphaMin.String);
                alpha_step = str2double(self.tbAlphaStep.String);
                max_alpha = str2double(self.tbAlphaMax.String);
                
                mode = self.ddlModelType.Value;
                
                gamma = 0.01;
                
                ps_iters = length(min_pc:pc_step:max_pc);%max(round((max_pc - min_pc)/pc_step),1);
                al_iters = length(min_alpha:alpha_step:max_alpha);%max(round((max_alpha - min_alpha)/alpha_step),1);
                h = waitbar(0, 'Please wait...');
                
                k = 0;
                
                if mode == 2
                    N = num_of_splits*ps_iters*al_iters;
                    Results = repmat(struct('numpc',0,'alpha',0,'model',[],'result',[],'split', 0), N, 1 );
                else
                    N = num_of_splits*ps_iters;
                    Results = repmat(struct('numpc',0,'model',[],'result',[],'split', 0), N, 1 );
                end
                
                for split = 1:num_of_splits
                    
                    t = DataSet();
                    t.RawData = dat(self.cvtask.Splits(:,split) == 0,:);
                    t.Centering = d.Centering;
                    t.Scaling = d.Scaling;
                    t.RawClasses = cls(self.cvtask.Splits(:,split) == 0,:);
                    t.Training = true;
                    
                    if ~isempty(lbl)
                        t.ObjectNames = lbl(self.cvtask.Splits(:,split) == 0,:);
                    end
                    
                    v = DataSet();
                    v.RawData = dat(self.cvtask.Splits(:,split) == 1,:);
                    v.RawClasses = cls(self.cvtask.Splits(:,split) == 1,:);
                    v.Validation = true;
                    
                    if ~isempty(lbl)
                        v.ObjectNames = lbl(self.cvtask.Splits(:,split) == 1,:);
                    end
                    
                    t.Name = sprintf('%s_cal_%d', d.Name, split);
                    v.Name = sprintf('%s_val_%d', d.Name, split);
                    
                    for numpc = min_pc:pc_step:max_pc
                        if mode == 2
                            for alpha = min_alpha:alpha_step:max_alpha
                                k = k + 1;
                                m = PLSDAModel(t, numpc, alpha, gamma);
                                res = m.Apply(v);
                                
                                res = rmfield(res,'AllocationTable');
                                res = rmfield(res,'Distances');
                                res = rmfield(res,'Labels');
                                res = rmfield(res,'Mode');
                                                               
                                Results(k).numpc = numpc;
                                Results(k).alpha = alpha;
                                Results(k).model = m;
                                Results(k).result = res;
                                
                                Results(k).split = split;
                                
                                waitbar(k/N, h);
                            end
                        else
                            k = k + 1;
                            m = PLSDAModel(d, numpc, 0.05, gamma);
                            m.Mode = 'hard';
                            m.Rebuild();
                            res = m.Apply(v);
                            
                            res = rmfield(res,'AllocationTable');
                            res = rmfield(res,'Distances');
                            res = rmfield(res,'Labels');
                            res = rmfield(res,'Mode');
                            
                            Results(k).numpc = numpc;
                            Results(k).model = m;
                            Results(k).result = res;
                            
                            Results(k).split = split;
                            
                            waitbar(k/N, h);
                        end
                    end
                end
                
                self.cvtask.Results = Results;
                self.ShowResults()
                %waitbar(1, h);
                delete(h);
            end
        end
        
        function Callback_Split(self, src, param)
            
            index_selected = get(self.ddlDataSet,'Value');
            
            names = get(self.ddlDataSet, 'String');
            
            selected_name = names{index_selected};
            
            d = evalin('base', selected_name);
            
            self.cvtask = CVTask(d);
            
            if self.ddlModelType.Value == 1
                self.cvtask.ModelType  = 'hard';
            else
                self.cvtask.ModelType = 'soft';
            end

            self.cvtask.MinPC = str2double(self.tbNumPCplsMin.String);
            self.cvtask.PCStep = str2double(self.tbNumPCplsStep.String);
            self.cvtask.MaxPC = str2double(self.tbNumPCplsMax.String);
                
            self.cvtask.MinAlpha = str2double(self.tbAlphaMin.String);
            self.cvtask.AlphaStep = str2double(self.tbAlphaStep.String);
            self.cvtask.MaxAlpha = str2double(self.tbAlphaMax.String);
            
            switch(self.ddlCrossValidationType.Value)
                case 1 %leave-one-out
                    self.cvtask.Type = 'leave-one-out';
                case 2 %k-fold
                    self.cvtask.Type = 'k-fold';
                    self.cvtask.Folds = str2double(self.tbCVParamValue.String);
                case 3 %holdout
                    self.cvtask.Type = 'holdout';
                    self.cvtask.ValidationPercent = str2double(self.tbCVParamValue.String);
                case 4 %monte-carlo
                    self.cvtask.Type = 'monte-carlo';
                    self.cvtask.ValidationPercent = str2double(self.tbCVParamValue.String);
                    self.cvtask.Iterations = str2double(self.tbCVIterations.String);
            end
            
            self.cvtask.Shuffle = self.chkShuffle.Value;
            
            self.cvtask.GenerateSplits();
            
            self.FillTableViewWithSplit();
            
            self.btnCVRun.Enable = 'on';
            self.btnCVSave.Enable = 'on';
        end
        
        function Input_ModelParameters(self, src, ~)
           switch (src.Value)
               case 1 %hard
                   self.hboxm4.Visible = 'off';
               case 2 %soft
                   self.hboxm4.Visible = 'on';
           end
        end
        
        function Input_CVParam(self, src, param)
            %self.tbCVParamValue.String
            %self.tbCVIterations.String
            mode = self.ddlCrossValidationType.Value;
            str=get(src,'String');
            val = str2double(str);
            
            opts = struct('WindowStyle','modal','Interpreter','none');
            
            
            index_selected = get(self.ddlDataSet,'Value');
            names = get(self.ddlDataSet,'String');
            selected_name = names{index_selected};
            
            data = evalin('base', selected_name);
            NumberOfSamples = size(data.ProcessedData,1);
            
            if isempty(val) || isnan(val) || floor(val) ~= val || val <= 0
                
                mode = self.ddlCrossValidationType.Value;
                if(mode == 2)%k-fold
                    if NumberOfSamples > 10
                        k = 10;
                    else
                        if NumberOfSamples > 5
                            k = 5;
                        else
                            k = 2;
                        end
                    end
                end
                
                if(mode == 3 || mode == 4)%holdout || monte-carlo
                    k = 30;
                end
                
                set(src,'string', sprintf('%d', k));
                if(mode == 3 || mode == 4)
                    warndlg('Input must be a positive integer between 1 and 100','Warning',opts);
                else
                    warndlg(sprintf('Input must be a positive integer not greater than %d', NumberOfSamples),'Warning',opts);
                end
            else
                
                mode = self.ddlCrossValidationType.Value;
                if(mode == 2)%k-fold
                    k = 10;
                    if(val > NumberOfSamples)
                        if NumberOfSamples > 10
                            k = 10;
                        else
                            if NumberOfSamples > 5
                                k = 5;
                            else
                                k = 2;
                            end
                        end
                        val = k;
                        warndlg(sprintf('Input must be a positive integer not greater than %d', NumberOfSamples),'Warning',opts);
                    end
                    set(src,'string', sprintf('%d', val));                       
                end
                
                if(mode == 3 || mode == 4)%holdout || monte-carlo
                    if(val > 100)
                        set(src,'string', '30');
                        warndlg('Input must be a positive integer between 1 and 100','Warning',opts);
                    end
                end
            end
        end
        
        function Input_CVParamIter(self, src, param)
            str=get(src,'String');
            val = str2double(str);
            
            opts = struct('WindowStyle','modal','Interpreter','none');
            
            if isempty(val) || isnan(val) || floor(val) ~= val || val <= 0
                set(src,'string', '10');
                warndlg('Input must be a positive integer','Warning',opts);
            end
        end
        
        function Input_NumPC_PLS(self, src, param)
            str=get(src,'String');
            opts = struct('WindowStyle','modal','Interpreter','none');
            index_selected = get(self.ddlDataSet,'Value');
            names = get(self.ddlDataSet,'String');
            selected_name = names{index_selected};
            
            data = evalin('base', selected_name);
            
            vmax = min(size(data.ProcessedData));
            
            vmin = data.NumberOfClasses;
            
            if(data.Centering)
                vmax = vmax - 1;
            end
            
            numPC = str2double(str);
            
            if isempty(numPC) || isnan(numPC) || floor(numPC) ~= numPC || numPC <= 0
                set(src,'string', sprintf('%d', vmin));
                warndlg('Input must be a positive integer','Warning',opts);
            else
                if numPC < vmin || numPC > vmax
                    set(src,'string',sprintf('%d',vmin));
                    warndlg(sprintf('Number of PLS Components should be not less than %d and not more than %d!', vmin, vmax),'Warning',opts);
                end
            end
            
            %self.FillTableView(selected_name);
            
            numPCmin = str2double(get(self.tbNumPCplsMin,'String'));
            
            numPCmax = str2double(get(self.tbNumPCplsMax,'String'));
            
            if(numPCmin ~= numPCmax)
                self.tbNumPCplsStep.Enable = 'on';
            else
                self.tbNumPCplsStep.Enable = 'off';
                self.tbNumPCplsStep.String = '1';
            end
            
            if(numPCmin > numPCmax)
                set(self.tbNumPCplsMin,'String', sprintf('%d',numPCmax));
                set(self.tbNumPCplsMax,'String', sprintf('%d',numPCmin));
            end
            
            val = str2double(get(self.tbNumPCplsStep,'String'));
            tt = (numPCmax - numPCmin)/val;
            if  floor(tt) ~= tt
                set(self.tbNumPCplsStep,'string','1');
            end
        end
        
        function Input_Alpha(self, src, param)
            str=get(src,'String');
            val = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            if isempty(val) || isnan(val) || val<=0
                set(src,'string','0.01');
                warndlg('Input must be numerical','Warning',opts);
            else
                if val <= 0 || val >= 1
                    set(src,'string','0.01');
                    warndlg('Type I error (Alpha) should be greater than 0 and less than 1!','Warning',opts);
                end
            end
            
            alphaMin = str2double(get(self.tbAlphaMin,'String'));
            
            alphaMax = str2double(get(self.tbAlphaMax,'String'));
            
            if(alphaMin ~= alphaMax)
                self.tbAlphaStep.Enable = 'on';
            else
                self.tbAlphaStep.Enable = 'off';
                self.tbAlphaStep.String = sprintf('%.2f','0.01');
            end
            
            if(alphaMin > alphaMax)
                min_format = ['%.' sprintf('%d', sigdigits(alphaMin)) 'f'];
                max_format = ['%.' sprintf('%d', sigdigits(alphaMax)) 'f'];
                set(self.tbAlphaMin,'String', sprintf(min_format,alphaMax));
                set(self.tbAlphaMax,'String', sprintf(max_format,alphaMin));
            end
            
            val=str2double(get(self.tbAlphaStep,'string'));

            l = linspace(alphaMin,alphaMax, 5);
            auto_step = l(2) - l(1);
            
            tt = max(alphaMin:val:alphaMax);
            if  tt ~= alphaMax
                auto_format = ['%.' sprintf('%d', sigdigits(auto_step)) 'f'];
                set(self.tbAlphaStep,'string',sprintf(auto_format,auto_step));
            end
        end
        
        function Input_NumPC_Step(self, src, param)
            str=get(src,'String');
            val = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            
            numPCmin = str2double(get(self.tbNumPCplsMin,'String'));
            numPCmax = str2double(get(self.tbNumPCplsMax,'String'));
            
            if isempty(val) || isnan(val) || val<=0 || floor(val) ~= val
                set(src,'string','1');
                warndlg('Input must a positive integer','Warning',opts);
            else
                
                tt = (numPCmax - numPCmin)/val;
                if  floor(tt) ~= tt
                    set(src,'string','1');
                    warndlg('The increment step should produce evenly spaced points!','Warning',opts);
                end
            end
        end
        
        function Input_Alpha_Step(self, src, param)
            str=get(src,'String');
            val = str2double(str);
            opts = struct('WindowStyle','modal','Interpreter','none');
            
            alphaMin = str2double(get(self.tbAlphaMin,'String'));
            alphaMax = str2double(get(self.tbAlphaMax,'String'));
            
            l = linspace(alphaMin,alphaMax, 5);
            auto_step = l(2) - l(1);
            
            if isempty(val) || isnan(val) || val<=0
                set(src,'string',sprintf('%f',auto_step));
                warndlg('Input must be a positive decimal fraction','Warning',opts);
            else
                
                tt = max(alphaMin:val:alphaMax);
                if  tt ~= alphaMax
                    set(src,'string',sprintf('%f',auto_step));
                    warndlg('The increment step should produce evenly spaced points!','Warning',opts);
                end
            end
        end
        
        function Callback_Shuffle(self, src, param)
            index_selected = get(self.ddlDataSet,'Value');
            
            names = get(self.ddlDataSet, 'String');
            
            selected_name = names{index_selected};
            
            
            self.FillTableView(selected_name);
            
            
            self.btnCVRun.Enable = 'off';
            self.btnCVSave.Enable = 'off';
        end
        
        function Callback_CrossValidationType(self, src, param)
            switch (src.Value)
                case 1 %leave-one-out
                    self.tbCVParamName.Visible = 'off';
                    self.tbCVParamValue.Visible = 'off';
                    self.tbCVIterationsName.Visible = 'off';
                    self.tbCVIterations.Visible = 'off';
                    self.chkShuffle.Enable = 'on';
                case 2 %k-fold
                    self.tbCVParamName.String = 'Folds';
                    self.tbCVParamName.Visible = 'on';
                    self.tbCVParamValue.Visible = 'on';
                    self.tbCVParamValue.String = '10';
                    self.tbCVIterationsName.Visible = 'off';
                    self.tbCVIterations.Visible = 'off';
                    self.chkShuffle.Enable = 'on';
                case 3 %holdout
                    self.tbCVParamName.String = 'Test part (%)';
                    self.tbCVParamName.Visible = 'on';
                    self.tbCVParamValue.Visible = 'on';
                    self.tbCVParamValue.String = '30';
                    self.tbCVIterationsName.Visible = 'off';
                    self.tbCVIterations.Visible = 'off';
                    self.chkShuffle.Enable = 'on';
                case 4 %monte-carlo
                    self.tbCVParamName.String = 'Test part (%)';
                    self.tbCVParamName.Visible = 'on';
                    self.tbCVParamValue.Visible = 'on';
                    self.tbCVParamValue.String = '30';
                    self.tbCVIterationsName.Visible = 'on';
                    self.tbCVIterations.Visible = 'on';
                    self.chkShuffle.Enable = 'off';
                    self.chkShuffle.Value = 1;
            end
            
            index_selected = get(self.ddlDataSet,'Value');
            
            names = get(self.ddlDataSet, 'String');
            
            selected_name = names{index_selected};
            
            
            self.FillTableView(selected_name);
            
            self.btnCVRun.Enable = 'off';
            self.btnCVSave.Enable = 'off';
        end
    end
end