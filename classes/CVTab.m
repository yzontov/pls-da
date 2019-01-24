classdef CVTab < BasicTab
    
    properties
        
        vbox;
        
        pnlDataSettings;
        pnlCrossValidationSettings;
        pnlModelSettings
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
    end
    
    methods
        function obj = CVTab(tabgroup, parent)
            
            obj = obj@BasicTab(tabgroup, 'Cross-validation', parent);
            
            obj.vbox = uix.VBox( 'Parent', obj.left_panel, 'Padding', 15, 'Spacing', 5 );
            
            obj.pnlDataSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Data', 'TitlePosition', 'LeftTop');
            
            obj.pnlModelSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Model settings', 'TitlePosition', 'LeftTop');
            
            obj.pnlCrossValidationSettings = uiextras.Panel('Parent', obj.vbox, 'Title', 'Cross-validation settings', 'TitlePosition', 'LeftTop');
            
            obj.pnlPlotSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Plot settings', 'TitlePosition', 'LeftTop','visible','off');
            obj.pnlTableSettings = uiextras.Panel( 'Parent', obj.vbox, 'Title', 'Table view options', 'TitlePosition', 'LeftTop','visible','off');
            
            
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
            
            hboxm4 = uiextras.HButtonBox( 'Parent', vbox_mod, 'ButtonSize', [120 30]);
            %lblAlpha
            uicontrol('Parent', hboxm4, 'Style', 'text', 'String', 'Type I error');
            hboxm4_ = uix.Grid( 'Parent', hboxm4);
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
            
            obj.chkShuffle = uicontrol('Parent', hboxm5, 'Style', 'checkbox', 'value', 1, 'String', 'Shuffle',...
                'callback', @obj.Callback_Shuffle);
            hboxm5.Widths = [-1 -2 -1];
            
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
            
            obj.vbox.Heights=[40,120,150,0,0];
            
            obj.FillDataSetList();
            
            obj.tg = uitabgroup('Parent', obj.middle_panel);
            
            w = obj.parent;
            set(obj.tg, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            obj.tab_split = uitab('Parent', obj.tg, 'Title', 'Data');
            %obj.tab_result = uitab('Parent', tg, 'Title', 'Results');
            
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
        
        function FillTableViewWithSplit(self, selected_name)
            
            d = evalin('base', selected_name);
            
            k = size(d.ProcessedData, 1);
            Labels = cell(k,1);
            
            v = 1:size(d.RawData, 1);
            v = v(logical(d.SelectedSamples));
            
            for i = 1:length(v)
                Labels{i} = sprintf('Object No.%d', v(i));
            end
            
            if(~isempty(d.SelectedObjectNames))
                Labels = d.SelectedObjectNames;
            end
            
            number_of_splits = 1;
            
            switch(self.ddlCrossValidationType.Value)
                case 1 %leave-one-out
                    number_of_splits = k;
                case 2 %k-fold
                    folds = str2double(self.tbCVParamValue.String);
                    number_of_splits = folds;
                    [val_start, val_stop] = CVTask.crossval_indexes( k, folds );
                case 3 %holdout
                    number_of_splits = 1;  
                    proc = str2double(self.tbCVParamValue.String)/100;
                case 4 %monte-carlo
                    proc = str2double(self.tbCVParamValue.String)/100;
                    iters = str2double(self.tbCVIterations.String);
                    number_of_splits = iters;
            end
            
            
            names_ = cell(1,number_of_splits);
            Splits = zeros(k, number_of_splits);
            
            e = 1:k;
            se = e';
            
            if (self.chkShuffle.Value)
                se = CVTask.shuffle(se);
            end
            
            for i = 1:number_of_splits
                names_{i} = sprintf('Split #%d', i);
                
                split = zeros(size(se));
                
                
                switch(self.ddlCrossValidationType.Value)
                    case 1 %leave-one-out
                        split(se(i)) = 1;
                    case 2 %k-fold
                        split(se(val_start(i):val_stop(i))) = 1;
                    case 3 %holdout
                        split(se(1:round(k*proc))) = 1;
                    case 4 %monte-carlo
                        se = CVTask.shuffle(se);
                        split(se(1:round(k*proc))) = 1;
                end
                
                Splits(:,i) = split;
            end
            
            cv = arrayfun(@self.bool2cv, logical(Splits),'UniformOutput', false);
                    
            
            self.tblTextResult.ColumnName = [{'Sample', 'Class'}, names_];
            self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'char'},1,number_of_splits)];
            
            if ~isempty(d.ClassLabels)
                self.tblTextResult.Data = [Labels, {d.ClassLabels{d.Classes}}' cv];
                self.tblTextResult.ColumnWidth = num2cell([100 max(60, max(strlength(d.ClassLabels))*7) max(60, 7*max(strlength(names_)))*ones(1,number_of_splits)]);
            else
                self.tblTextResult.Data = [Labels, num2cell(d.Classes) cv];
                self.tblTextResult.ColumnWidth = num2cell([100 60 max(60, 7*max(strlength(names_)))*ones(1,number_of_splits)]);
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
            
        end
        
        function Callback_LoadCVTask(self, src, param)
            [tvar, tvarname] = uigetvariables({'Pick a CVTask object:'}, ...
                'ValidationFcn',{@(x) isa(x, 'CVTask')});
            if ~isempty(tvar)
                
                
                cv_task = tvar{1};
                
                
                
                %assignin('base', Model.TrainingDataSet.Name, Model.TrainingDataSet);
                
                
            end
        end
        
        function Callback_CVRun(self, src, param)
            
        end
        
        function Callback_Split(self, src, param)
            
            index_selected = get(self.ddlDataSet,'Value');
            
            names = get(self.ddlDataSet, 'String');
            
            selected_name = names{index_selected};
            
            self.FillTableViewWithSplit(selected_name);
            
            self.btnCVRun.Enable = 'on';
            self.btnCVSave.Enable = 'on';
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
                    end
                    set(src,'string', sprintf('%d', k));
                    warndlg(sprintf('Input must be a positive integer not greater than %d', NumberOfSamples),'Warning',opts);

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
            
            self.FillTableView(selected_name);
            
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
        
        function Input_ModelParameters(self, src, param)
            
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
            
%             index_selected = get(self.ddlDataSet,'Value');
%             names = get(self.ddlDataSet,'String');
%             selected_name = names{index_selected};
%             
%             self.FillTableView(selected_name);
            
            alphaMin = str2double(get(self.tbAlphaMin,'String'));
            
            alphaMax = str2double(get(self.tbAlphaMax,'String'));
            
            if(alphaMin ~= alphaMax)
               self.tbAlphaStep.Enable = 'on';
            else
                self.tbAlphaStep.Enable = 'off';
                self.tbAlphaStep.String = sprintf('%f','0.01');
            end
            
            if(alphaMin > alphaMax)
               set(self.tbAlphaMin,'String', sprintf('%.2f',alphaMax));
               set(self.tbAlphaMax,'String', sprintf('%.2f',alphaMin));
            end
            
            val=str2double(get(self.tbAlphaStep,'string'));
            tt = round((alphaMax - alphaMin)/val);
                if  (tt*val + alphaMin) ~= alphaMax
                    set(self.tbAlphaStep,'string',sprintf('%.2f',max(0.01,(alphaMax-alphaMin)/5)));
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
            
            if isempty(val) || isnan(val) || val<=0
                set(src,'string',sprintf('%.2f',max(0.01,(alphaMax-alphaMin)/5)));
                warndlg('Input must be a positive decimal fraction','Warning',opts);
            else
                
                tt = round((alphaMax - alphaMin)/val);
                if  (tt*val + alphaMin) ~= alphaMax
                    set(src,'string',sprintf('%.2f',max(0.01,(alphaMax-alphaMin)/5)));
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