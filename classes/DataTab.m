classdef  DataTab < BasicTab
    properties
        Data = struct;
        Preprocessing = struct;
        %Training = struct;
        listbox;
        lbox_mnu_train;
        lbox_mnu_val;
        
        %data_plot_axes;
        %data_plot;
        
        btnRefreshDatasetList;
        
        pca_tabgroup;
        
        pnlDataSettings;
        pnlPlotSettings;
        pnlDataCategories;
        pnlTableSettings;
        pnlPCASettings;
        
        ddlPlotType;
        ddlPlotVar1;
        ddlPlotVar2;
        chkPlotShowClasses;
        chkPlotShowObjectNames;
        
        chkCentering;
        chkScaling;
        
        chkTraining;
        chkValidation;
        
        tblTextResult;
        tab_img;
        tab_txt;
        tab_pca;
        
        datasetwin;
        
        tblPCATextResult;
        tab_pca_scores;
        tab_pca_loadings;
        tab_pca_scores_axes;
        tab_pca_loadings_axes;
        
        ddlSamplesRange1
        ddlSamplesRange2
        ddlSamplesClasses;
        btnSamplesClasses;
        
        txtPCApcnumber;
        btnPCABuild;
        ddlPCApc1;
        ddlPCApc2;
        
        ddlPlotTypePCA;
        chkPlotShowClassesPCA;
        chkPlotShowObjectNamesPCA;
        
        btnDataSetEdit;
        btnDataSetDelete;
        btnSavePlotToFile;
        btnSavePlotToClipboard;
        
        vbox;
        hbox_pca_plot_type;
        hbox_pca_plot_options;
        vbox_pca;
    end
    
    properties (Access = private)
        pc_x = 1;
        pc_y = 2;
    end
    
    methods
        
        function RefreshDatasetList(self)
            self.FillDataSetList();
            self.RefreshModel();
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
        
            idx_data = arrayfun(@(x)GUIWindow.filter_data(x), allvars);
            if(isempty(self.parent.cvTab) && sum(idx_data) > 0)
                self.parent.cvTab = CVTab(self.parent.tgroup, self.parent);
            end
            
            if(~isempty(self.parent.cvTab) && sum(idx_data) == 0)
                ind = arrayfun(@(x)isequal(x.Title ,'Cross-validation'),self.parent.tgroup.Children);
                cvtab = self.parent.tgroup.Children(ind);
                delete(cvtab);
                delete(self.parent.cvTab);
                self.parent.cvTab = [];
            end
            
            if (~isempty(self.parent.cvTab) && sum(idx_data) > 0)
                self.parent.cvTab.FillDataSetList(true);
            end
            
        end
        
        function RefreshDatasetListCallback(self, src, param)
            self.RefreshDatasetList();
        end
        
        function ttab = DataTab(tabgroup, parent)
            ttab = ttab@BasicTab(tabgroup, 'Data', parent);
            
            ttab.vbox = uix.VBox( 'Parent', ttab.left_panel, 'Padding', 15, 'Spacing', 5 );
            
            btn_box = uiextras.HButtonBox('Parent',ttab.vbox,'ButtonSize', [200 25]);
            uicontrol('Parent', btn_box, 'Style', 'pushbutton', 'String', 'New dataset',...
                'Position', [90 360 100 20], ...
                'callback', @ttab.btnNew_Callback);%,'FontUnits', 'Normalized'
            uicontrol('Parent', btn_box, 'Style', 'pushbutton', 'String', 'Refresh dataset list',...
                'Position', [90 360 100 20], ...
                'callback', @ttab.RefreshDatasetListCallback);
            
            %hbox_input = uix.HBox( 'Parent', vbox);
            hbox_input_g = uix.Grid( 'Parent', ttab.vbox);%, 'ButtonSize', [120 25] );
            uicontrol('Parent', hbox_input_g, 'Style', 'text', 'String', 'Dataset', ...
                'HorizontalAlignment', 'left');
            ttab.listbox = uicontrol('Parent', hbox_input_g, 'Style', 'popupmenu',...
                'String', {'-'}, 'enable', 'off', ...
                'Value',1, 'BackgroundColor', 'white', 'callback',@ttab.listClick);
            %hbox_input_g_sub = uiextras.HBox( 'Parent', hbox_input_g);%, 'ButtonSize', [50 25] );
            ttab.btnDataSetEdit = uicontrol('Parent', hbox_input_g, 'Style', 'pushbutton', 'String', 'Edit',...
                'callback', @ttab.btnSetEdit_Callback);%,'FontUnits', 'Normalized'
            
            ttab.btnDataSetDelete = uicontrol('Parent', hbox_input_g, 'Style', 'pushbutton', 'String', 'Delete',...
                'callback', @ttab.btnSetDelete_Callback);%,'FontUnits', 'Normalized'
            
            set( hbox_input_g, 'Widths', [45 110 40 40]);
            %set( hbox_input_g, 'Heights', [25]);
            set( hbox_input_g, 'Padding', 2.5 );
            set( hbox_input_g, 'Spacing', 5 );
            
            %categories
            ttab.pnlDataCategories = uibuttongroup('Parent', ttab.vbox, 'Title', 'Categories');
            hbox_cat = uiextras.HButtonBox( 'Parent', ttab.pnlDataCategories, 'ButtonSize', [120 25]);
            
            %             bg = uibuttongroup('Parent',ttab.pnlDataCategories,...
            %                   'Position',[0 0 1 1],...
            %                   'SelectionChangedFcn',@bselection);
            
            ttab.chkTraining = uicontrol('Parent', hbox_cat, 'Style', 'radiobutton', 'String', 'Calibration',...
                'Position', [0.1 0.4 0.45 0.4], 'callback', @ttab.Input_Training);
            ttab.chkValidation = uicontrol('Parent', hbox_cat, 'Style', 'radiobutton', 'String', 'New or Test',...
                'Position', [0.55 0.4 0.45 0.4], 'callback', @ttab.Input_Validation);
            
            %preprocessing
            ttab.pnlDataSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Preprocessing', 'TitlePosition', 'LeftTop');
            %uipanel('Parent', vbox, 'Title', 'Preprocessing', ...
            %    'Position', [0.05   0.52   0.9  0.12]);
            hbox_set = uix.HButtonBox( 'Parent', ttab.pnlDataSettings, 'ButtonSize', [120 25]);
            ttab.chkCentering = uicontrol('Parent', hbox_set, 'Style', 'checkbox', 'String', 'Centering',...
                'Position', [0.1 0.4 0.45 0.4], 'callback', @ttab.Input_Centering);
            ttab.chkScaling = uicontrol('Parent', hbox_set, 'Style', 'checkbox', 'String', 'Scaling',...
                'Position', [0.55 0.4 0.45 0.4], 'callback', @ttab.Input_Scaling);
            
            %lblPlotType
            ttab.pnlPlotSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Plot settings', 'TitlePosition', 'LeftTop');
            %uipanel('Parent', vbox, 'Title', 'Plot', ...
            %'Position', [0.05   0.01   0.9  0.5]);
            vbox_plot = uiextras.VBox( 'Parent', ttab.pnlPlotSettings);
            hbox1_plot = uiextras.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox1_plot, 'Style', 'text', 'String', 'Plot type', ...
                'Position', [0.05 0.78 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotType = uicontrol('Parent', hbox1_plot, 'Style', 'popupmenu', 'String', {'Scatter', 'Line', 'Histogram'},...
                'Value',2, 'Position', [0.45 0.85 0.35 0.05], 'BackgroundColor', 'white', 'callback', @ttab.Callback_PlotType);
            
            hbox2_plot = uiextras.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            ttab.chkPlotShowClasses = uicontrol('Parent', hbox2_plot, 'Style', 'checkbox', 'String', 'Show classes',...
                'Position', [0.05 0.65 0.85 0.1], 'callback', @ttab.Redraw);
            ttab.chkPlotShowObjectNames = uicontrol('Parent', hbox2_plot, 'Style', 'checkbox', 'String', 'Show object names',...
                'Position', [0.05 0.55 0.85 0.1], 'callback', @ttab.Redraw);
            
            hbox3_plot = uiextras.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox3_plot, 'Style', 'text', 'String', 'X-axis', ...
                'Position', [0.05 0.35 0.35 0.1], 'HorizontalAlignment', 'left');
            ttab.ddlPlotVar1 = uicontrol('Parent', hbox3_plot, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'Position', [0.45 0.35 0.35 0.1], 'BackgroundColor', 'white', 'callback', @ttab.Redraw);
            
            hbox4_plot = uiextras.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox4_plot, 'Style', 'text', 'String', 'Y-axis', ...
                'HorizontalAlignment', 'left');
            ttab.ddlPlotVar2 = uicontrol('Parent', hbox4_plot, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1,'BackgroundColor', 'white', 'callback', @ttab.Redraw);
            
            hbox5_plot = uiextras.HButtonBox( 'Parent', vbox_plot, 'ButtonSize', [120 25]);
            ttab.btnSavePlotToFile = uicontrol('Parent', hbox5_plot, 'Style', 'pushbutton', 'String', 'Save image to file',...
                'callback', @ttab.SavePlot);
            ttab.btnSavePlotToClipboard = uicontrol('Parent', hbox5_plot, 'Style', 'pushbutton', 'String', 'Copy image to clipboard',...
                'callback', @ttab.CopyPlotToClipboard);
            
            vbox_plot.Heights=[30,30,30,30,30];
            %set( hbox_plot, 'RowSizes', [50 50 50 50], 'ColumnSizes', [100 100]);
            
            %Table view settings
            ttab.pnlTableSettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'Table view options', 'TitlePosition', 'LeftTop','visible', 'off');
            vbox_txt = uiextras.VBox( 'Parent', ttab.pnlTableSettings);
            hbox1_txt = uiextras.HButtonBox( 'Parent', vbox_txt, 'ButtonSize', [120 25]);
            
            uicontrol('Parent', hbox1_txt, 'Style', 'pushbutton', 'String', 'Select all',...
                'callback', @ttab.SamplesSelectAll);
            
            uicontrol('Parent', hbox1_txt, 'Style', 'pushbutton', 'String', 'Select none',...
                'callback', @ttab.SamplesSelectNone);
            
            hbox2_txt = uiextras.HButtonBox( 'Parent', vbox_txt, 'ButtonSize', [120 25]);
            uicontrol('Parent', hbox2_txt, 'Style', 'pushbutton', 'String', 'Inverse selection',...
                'callback', @ttab.SamplesInverseSelection);
            
            uicontrol('Parent', hbox2_txt, 'Style', 'pushbutton', 'String', 'Remove selected',...
                'callback', @ttab.SamplesRemoveSelection);
            
            hbox3_txt = uiextras.HButtonBox( 'Parent', vbox_txt, 'ButtonSize', [120 25]);
            
            uicontrol('Parent', hbox3_txt, 'Style', 'pushbutton', 'String', 'Inverse by range',...
                'callback', @ttab.SamplesInverseByRange);
            if ispc
                hbox3_txt_sub = uiextras.HButtonBox( 'Parent', hbox3_txt, 'ButtonSize', [100 25]);
            else
                hbox3_txt_sub = uiextras.HButtonBox( 'Parent', hbox3_txt, 'ButtonSize', [120 25]);
            end
            hbox3_txt_sub2 = uiextras.Grid( 'Parent', hbox3_txt_sub);
            ttab.ddlSamplesRange1 = uicontrol('Parent', hbox3_txt_sub2, 'Style', 'popupmenu', 'String', {'-'});
            uicontrol('Parent', hbox3_txt_sub2, 'Style', 'text', 'String', '-', 'HorizontalAlignment', 'center');
            ttab.ddlSamplesRange2 = uicontrol('Parent', hbox3_txt_sub2, 'Style', 'popupmenu', 'String', {'-'});
            
            if ispc
                hbox3_txt_sub2.Widths = [45 10 45];
            else
                hbox3_txt_sub2.Widths = [60 5 60];
            end
            hbox4_txt = uiextras.HButtonBox( 'Parent', vbox_txt, 'ButtonSize', [120 25]);
            ttab.btnSamplesClasses = uicontrol('Parent', hbox4_txt, 'Style', 'pushbutton', 'String', 'Inverse by class',...
                'callback', @ttab.SamplesInverseByClass);
            
            hbox4_txt_sub = uiextras.HButtonBox( 'Parent', hbox4_txt, 'ButtonSize', [80 25]);
            ttab.ddlSamplesClasses = uicontrol('Parent', hbox4_txt_sub, 'Style', 'popupmenu', 'String', {'-'});
            
            hbox5_txt = uiextras.HButtonBox( 'Parent', vbox_txt, 'ButtonSize', [200 25]);
            uicontrol('Parent', hbox5_txt, 'Style', 'pushbutton', 'String', 'Copy to new DataSet',...
                'callback', @ttab.SamplesCopyToNewDataSet);
            uicontrol('Parent', hbox5_txt, 'Style', 'pushbutton', 'String', 'Move to new DataSet',...
                'callback', @ttab.SamplesMoveToNewDataSet);
            
            
            %PCA settings
            ttab.pnlPCASettings = uiextras.Panel( 'Parent', ttab.vbox, 'Title', 'PCA settings', 'TitlePosition', 'LeftTop','visible', 'off');
            
            vbox_pca = uiextras.VBox( 'Parent', ttab.pnlPCASettings, 'Padding', 10, 'Spacing', 5);
            grid1_pca = uiextras.HButtonBox( 'Parent', vbox_pca, 'ButtonSize', [120 25]);
            uicontrol('Parent', grid1_pca, 'Style', 'text', 'String', 'Number of PCs', ...
                'HorizontalAlignment', 'left');
            ttab.txtPCApcnumber = uicontrol('Parent', grid1_pca, 'Style', 'edit', 'String', '2',...
                'BackgroundColor', 'white', 'callback', @ttab.Callback_PCApcnumber);
            
            ttab.btnPCABuild = uicontrol('Parent', grid1_pca, 'Style', 'pushbutton', 'String', 'Build',...
                'callback', @ttab.DoPCA);
            %set( grid1_pca, 'ColumnSizes', [100 50 60], 'RowSizes', [23]);
            
            grid2_pca = uiextras.Grid( 'Parent', vbox_pca, 'Spacing', 10);
            uicontrol('Parent', grid2_pca, 'Style', 'text', 'String', 'PC 1', 'HorizontalAlignment', 'left');
            ttab.ddlPCApc1 = uicontrol('Parent', grid2_pca, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @ttab.Callback_PCApc);
            
            uicontrol('Parent', grid2_pca, 'Style', 'text', 'String', 'PC 2', 'HorizontalAlignment', 'left');
            ttab.ddlPCApc2 = uicontrol('Parent', grid2_pca, 'Style', 'popupmenu', 'String', {'-'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @ttab.Callback_PCApc);
            set( grid2_pca, 'ColumnSizes', [30 60 30 60]);
            
            ttab.hbox_pca_plot_options = uiextras.HButtonBox( 'Parent', vbox_pca, 'ButtonSize', [120 20]);
            ttab.chkPlotShowClassesPCA = uicontrol('Parent', ttab.hbox_pca_plot_options, 'Style', 'checkbox', 'String', 'Show classes',...
                'callback', @ttab.RedrawPCA);
            ttab.chkPlotShowObjectNamesPCA = uicontrol('Parent', ttab.hbox_pca_plot_options, 'Style', 'checkbox', 'String', 'Show object names',...
                'callback', @ttab.RedrawPCA);
            
            ttab.hbox_pca_plot_type = uiextras.HButtonBox( 'Parent', vbox_pca, 'ButtonSize', [120 25],'visible','off');
            uicontrol('Parent', ttab.hbox_pca_plot_type, 'Style', 'text', 'String', 'Plot type', ...
                'HorizontalAlignment', 'left');
            ttab.ddlPlotTypePCA = uicontrol('Parent', ttab.hbox_pca_plot_type, 'Style', 'popupmenu', 'String', {'Scatter', 'Line'},...
                'Value',1, 'BackgroundColor', 'white', 'callback', @ttab.Callback_PCALoadingsPlotType);
            
            ttab.vbox_pca.Heights=[20,20,0,25];
            
            if ispc
                ttab.vbox.Heights=[40,30,40,40,170,0,0];
            else
                ttab.vbox.Heights=[40,30,40,40,160,0,0];
            end
            
            tg = uitabgroup('Parent', ttab.middle_panel);
            
            w = ttab.parent;
            set(tg, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            ttab.tab_img = uitab('Parent', tg, 'Title', 'Graphical view');
            ttab.tab_txt = uitab('Parent', tg, 'Title', 'Table view');
            
            ttab.tab_pca = uitab('Parent', tg, 'Title', 'PCA');
            
            
            tg2 = uitabgroup('Parent', ttab.tab_pca,'Position', [0 0 1 1]);
            ttab.pca_tabgroup = tg2;
            
            w = ttab.parent;
            set(tg2, 'SelectionChangedFcn', @w.ActiveTabSelected);
            
            ttab.tab_pca_scores = uitab('Parent', tg2, 'Title', 'Scores');
            ttab.tab_pca_loadings = uitab('Parent', tg2, 'Title', 'Loadings');
            
            ttab.tblTextResult = uitable(ttab.tab_txt);
            ttab.tblTextResult.Units = 'normalized';
            ttab.tblTextResult.Position = [0 0 1 1];
            
            
            ttab.FillDataSetList();
            
            
        end
        
        function DoPCA(self,~,~)
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
                
                str=get(self.txtPCApcnumber,'String');
                numPC = str2double(str);
                
                d.PCA(numPC);
                
                self.FillPCApcDDL(numPC);
                self.enablePCAPanel('off');
                
                self.enablePCAPanel('on');
                self.pca_tabgroup.Visible = 'on';
                
                self.DrawPCA();
                self.btnPCABuild.String = 'Rebuild';
            else
                self.enablePCAPanel('off');
                self.pca_tabgroup.Visible = 'off';
            end
            
        end
        
        function DrawPCA(self)
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
                delete(self.tab_pca_scores_axes);
                delete(self.tab_pca_loadings_axes);
                
                ha2d_s = axes('Parent', self.tab_pca_scores);
                ha2d_l = axes('Parent', self.tab_pca_loadings);
                
                self.tab_pca_scores_axes = ha2d_s;
                self.tab_pca_loadings_axes = ha2d_l;
                
                pc1 = self.pc_x;
                pc2 = self.pc_y;
                hold(self.tab_pca_scores_axes, 'on');
                trc = unique(d.Classes);
                if get(self.chkPlotShowClassesPCA,'Value') == 1 && ~isempty(trc)
                    
                    names_ = cell(1,d.NumberOfClasses);
                    color_ = PLSDAModel.colors_rgb(d.NumberOfClasses);
                    for i = 1:d.NumberOfClasses
                        
                        plot(self.tab_pca_scores_axes,d.PCAScores(d.Classes == trc(i),pc1), d.PCAScores(d.Classes == trc(i),pc2), 'o','color',color_(i,:));
                        
                        if isempty(d.ClassLabels)
                            names_{i} = sprintf('class %d', trc(i));
                        else
                            names_{i} = d.ClassLabels{trc(i)};
                        end
                    end
                    
                    legend(self.tab_pca_scores_axes, names_);
                    legend(self.tab_pca_scores_axes,'location','northeast');
                    legend(self.tab_pca_scores_axes,'boxon');
                else
                    plot(self.tab_pca_scores_axes,d.PCAScores(:,pc1), d.PCAScores(:,pc2), 'o');
                end
                
                xlabel(self.tab_pca_scores_axes,sprintf('PC %d', pc1));
                ylabel(self.tab_pca_scores_axes,sprintf('PC %d', pc2));
                
                title(self.tab_pca_scores_axes,'PCA Scores');
                
                if(~isempty(d.SelectedObjectNames))
                    score_labels= d.SelectedObjectNames;
                else
                    score_labels = strread(num2str(1:size(d.ProcessedData, 1)),'%s');
                end
                
                if get(self.chkPlotShowObjectNamesPCA,'value') == 1
                    pan off
                    datacursormode on
                    dcm_obj = datacursormode(self.parent.fig);
                    if isprop(dcm_obj, 'Interpreter')
                        dcm_obj.Interpreter = 'none';
                    end
                    set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                else
                    datacursormode off
                    pan on
                end
                
                %                 dcm_obj = datacursormode(self.parent.fig);
                %                 set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                
                %                 if ~isempty(d.Classes)
                set(self.tab_pca_scores_axes,'UserData', {[d.PCAScores(:,pc1), d.PCAScores(:,pc2)], score_labels, d.Classes, [], d.ClassLabels});
                %                 else
                %                     set(self.tab_pca_scores_axes,'UserData', {[d.PCAScores(:,pc1), d.PCAScores(:,pc2)], score_labels, [], [], []});
                %                 end
                
                
                loadings_plot_type = get(self.ddlPlotTypePCA, 'value');
                
                
                if(~isempty(d.VariableNames))
                    loadings_labels = d.VariableNames;
                else
                    if(~isempty(d.Variables))
                        loadings_labels = strread(num2str(d.Variables),'%s');
                    else
                        loadings_labels = strread(num2str(1:size(d.ProcessedData, 2)),'%s');
                    end
                end
                
                
                
                if(loadings_plot_type == 1)%scatter
                    
                    plot(self.tab_pca_loadings_axes,d.PCALoadings(:,pc1), d.PCALoadings(:,pc2), 'o');
                    
                    xlabel(self.tab_pca_loadings_axes,sprintf('PC %d', pc1));
                    ylabel(self.tab_pca_loadings_axes,sprintf('PC %d', pc2));
                    
                    set(self.tab_pca_loadings_axes,'UserData', {[d.PCALoadings(:,pc1), d.PCALoadings(:,pc2)], loadings_labels, [], true, []});
                    
                else %line
                    
                    %plot(self.tab_pca_loadings_axes,loadings_labels, d.PCALoadings', '-');
                    pcs = size(d.PCALoadings,2);
                    vars = size(d.PCALoadings,1);
                    
                    names_ = cell(1,pcs);
                    hold on;
                    color_ = PLSDAModel.colors_rgb(pcs);
                    for i = 1:pcs
                        
                        plot(self.tab_pca_loadings_axes,1:vars, d.PCALoadings(:,i), '-','color',color_(i,:));
                        
                        names_{i} = sprintf('PC %d', i);
                        
                    end
                    
                    if vars <= 30
                        xticks(1:vars);
                        
                        if ~isempty(d.VariableNames)
                            xtickangle(45);
                        end
                        xticklabels(loadings_labels);
                        
                    end
                    
                    legend(self.tab_pca_loadings_axes, names_);
                    legend(self.tab_pca_loadings_axes,'location','northeast');
                    legend(self.tab_pca_loadings_axes,'boxon');
                    
                    xlabel(self.tab_pca_loadings_axes,'Variables');
                    ylabel(self.tab_pca_loadings_axes,'Loadings');
                    
                    
                end
                
                title(self.tab_pca_scores_axes,['Dataset: ' d.Name ' - PCA Scores'], 'interpreter', 'none');
                title(self.tab_pca_loadings_axes,['Dataset: ' d.Name ' - PCA Loadings'], 'interpreter', 'none');
                hold off;
            end
        end
        
        function FillPCAStat(self)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
            end
        end
        
        function ClearPCA(self)
            self.pc_x = 1;
            self.pc_y = 2;
            set(self.txtPCApcnumber, 'String', 2);
            set(self.btnDataSetEdit, 'value', 1);
            self.FillPCApcDDL(0);
            
            delete(self.tab_pca_scores_axes);
            delete(self.tab_pca_loadings_axes);
            self.enablePCAPanel('off');
            self.pca_tabgroup.Visible = 'off';
        end
        
        function FillPCApcDDL(self, numPC)
            
            if numPC == 0
                pcs = {'-'};
            else
                pcs = arrayfun(@(x) sprintf('%d', x), 1:numPC, 'UniformOutput', false);
            end
            
            set(self.ddlPCApc1, 'String', pcs);
            set(self.ddlPCApc2, 'String', pcs);
            set(self.ddlPCApc1, 'Value', 1);
            
            if numPC == 0
                set(self.ddlPCApc2, 'Value', 1);
            else
                set(self.ddlPCApc2, 'Value', 2);
            end
        end
        
        function Callback_PCApcnumber(self,src,~)
            str=get(src,'String');
            
            opts = struct('WindowStyle','modal','Interpreter','none');
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
                vmax = min(size(d.ProcessedData));
                
                if d.Centering
                    vmax = vmax - 1;
                end
                
                if d.Scaling
                    vmax = vmax - 1;
                end
                
                val = str2double(str);
                if isempty(val) || isnan(val) || floor(val) ~= val || val <= 0
                    set(src,'string','2');
                    warndlg('Input must be a positive integer','Warning', opts);
                else
                    if val < 2 || val > vmax
                        set(src,'string','2');
                        warndlg(sprintf('Number of Principal Components should not less than 2 and not greater than %d!', vmax),'Warning', opts);
                    end
                end
                
                str=get(src,'String');
                numPC = str2double(str);
                
                self.ClearPCA();
                
                set(src,'string', int2str(numPC));
                
                self.FillPCApcDDL(numPC);
                
            else
                set(src,'string','2');
                warndlg('You should select the Data Set first!','Warning', opts);
            end
        end
        
        function Callback_PCApc(self,src,~)
            str = get(src,'String');
            val = get(src,'Value');
            
            if(~isequal(str{val},'-'))
                if self.pc_x ~= self.pc_y
                    prev_x = self.pc_x;
                    prev_y = self.pc_y;
                    
                    if (self.ddlPCApc1.Value == self.ddlPCApc2.Value)
                        self.ddlPCApc1.Value = prev_y;
                        self.ddlPCApc2.Value = prev_x;
                    end
                    
                    self.pc_x = self.ddlPCApc1.Value;
                    self.pc_y = self.ddlPCApc2.Value;
                end
                
                self.DrawPCA();
            end
        end
        
        function FillDataSetList(self)
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(idx)
                %vardisplay = cell(length(idx)+1,1);
                %vardisplay{1} = '-';
                %                 for i = 1:length(idx)
                %                     vardisplay{i+1} = varnames{idx(i)};
                %                 end
                vardisplay = [{'-'}, varnames(idx)];
                
                set(self.listbox, 'String', vardisplay);
                
                % extract all children
                self.enableRightPanel('on');
                
                names = varnames(idx);%fieldnames(ttab.Data);
                selected_name = names{1};
                
                self.parent.selected_dataset = selected_name;
                
                set(self.listbox, 'Value', 2);
                
                %d = ttab.Data.(selected_name);
                d = evalin('base', selected_name);
                
                if (d.HasPCA)
                    self.pca_tabgroup.Visible = 'on';
                    self.btnPCABuild.String = 'Rebuild';
                else
                    self.pca_tabgroup.Visible = 'off';
                    self.btnPCABuild.String = 'Build';
                end
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                set(self.ddlPlotVar1, 'Value', 1);
                set(self.ddlPlotVar2, 'Value', 2);
                
                
                
                if isempty(d.Classes)
                    set(self.chkPlotShowClasses, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'value', 0);
                    set(self.chkTraining, 'enable', 'off');
                    set(self.chkTraining, 'value', 0);
                end
                
                if ~isempty(d.Classes) && d.NumberOfClasses == 1
                    set(self.chkTraining, 'enable', 'off');
                    set(self.chkTraining, 'value', 0);
                end
                
                self.drawPlot(selected_name);
                self.FillTableView(selected_name);
                self.FillPCApcDDL(2);
                %self.DrawPCA();
            else
                self.resetRightPanel();
                self.enableRightPanel('off');
                
                self.parent.selected_dataset = [];
                
                set(self.listbox, 'String', '-');
                set(self.listbox, 'Value', 1);
            end
            
        end
        
        function SelectedSamplesChangedCallback(self,hObject,callbackdata)
            numval = callbackdata.EditData;
            r = callbackdata.Indices(1);
            %c = callbackdata.Indices(2)
            %hObject.Data{r,c} = numval;
            
            index_selected = get(self.listbox,'Value');
            names = get(self.listbox,'String');
            selected_name = names{index_selected};
            d = evalin('base', selected_name);
            
            d.SelectedSamples(r) = double(numval);
            
            self.Redraw();
            
            self.RefreshModel();
            
            self.ClearPCA();
        end
        
        function obj = GetObject(self,list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
        end
        
        function SamplesSelectAll(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = ones(size(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                self.Redraw();
                
                self.RefreshModel();
                %self.DrawPCA();
                self.ClearPCA();
            end
        end
        
        function SamplesSelectNone(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = zeros(size(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                delete(self.data_plot_axes);
                
                self.RefreshModel();
                %self.DrawPCA();
                self.ClearPCA();
            end
        end
        
        function SamplesInverseSelection(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                d.SelectedSamples = double(not(d.SelectedSamples));
                
                self.FillTableView(selected_name);
                self.Redraw();
                
                self.RefreshModel();
                %self.DrawPCA();
                self.ClearPCA();
            end
        end
        
        function SamplesInverseByClass(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                if (~isempty(d.RawClasses))
                    class_selected = get(self.ddlSamplesClasses,'Value');
                    
                    class_names = unique(d.RawClasses);
                    selected_class = class_names(class_selected);
                    
                    d.SelectedSamples(d.RawClasses == selected_class) = double(not(d.SelectedSamples(d.RawClasses == selected_class)));
                    
                    self.FillTableView(selected_name);
                    self.Redraw();
                    
                    self.RefreshModel();
                    self.ClearPCA();
                end
                %self.DrawPCA();
            end
        end
        
        function SamplesInverseByRange(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                r1 = min([self.ddlSamplesRange1.Value, self.ddlSamplesRange2.Value]);
                r2 = max([self.ddlSamplesRange1.Value, self.ddlSamplesRange2.Value]);
                
                d.SelectedSamples(r1:r2) = double(not(d.SelectedSamples(r1:r2)));
                
                self.FillTableView(selected_name);
                self.Redraw();
                
                self.RefreshModel();
                self.ClearPCA();
                %self.DrawPCA();
            end
        end
        
        function SamplesCopyToNewDataSet(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1 )
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                if(sum(d.SelectedSamples) > 0)
                    prompt = {'Enter new data set name:'};
                    dlg_title = 'Save';
                    num_lines = 1;
                    def = {'new_dataset'};
                    
                    if(sum(d.SelectedSamples) == size(d.RawData,1))
                        def = {[d.Name '_copy']};
                    end
                    opts = struct('WindowStyle','modal','Interpreter','none');
                    answer = inputdlg(prompt,dlg_title,num_lines,def, opts);
                    
                    if ~isempty(answer)
                        
                        new_d = DataSet([], self.parent);
                        new_d.RawData = d.RawData(logical(d.SelectedSamples),:);
                        new_d.Centering = d.Centering;
                        new_d.Scaling = d.Scaling;
                        new_d.RawClasses = d.RawClasses(logical(d.SelectedSamples),:);
                        new_d.VariableNames = d.VariableNames;
                        new_d.Variables = d.Variables;
                        
                        if(~isempty(d.ObjectNames))
                            new_d.ObjectNames = d.ObjectNames(logical(d.SelectedSamples),:);
                        end
                        
                        new_d.ClassLabels = d.ClassLabels;
                        
                        %addlistener(new_d,'Deleting',@self.parent.handleDatasetDelete);
                        
                        try
                            new_d.Name = answer{1};
                            assignin('base', answer{1}, new_d)
                        catch
                            %opts = struct('WindowStyle','modal','Interpreter','none');
                            %errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!','Error',opts);
                            tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                            
                            if(~isempty(regexp(tmp,'^\d+', 'once')))
                                tmp = ['dataset_' tmp];
                            end
                            
                            if(~isempty(regexp(tmp,'^_+', 'once')))
                                tmp = ['dataset_' tmp];
                            end
                            
                            new_d.Name = tmp;
                            assignin('base',tmp, new_d);
                        end
                        
                        d.SelectedSamples = ones(size(d.SelectedSamples));
                        
                        self.FillTableView(selected_name);
                        self.Redraw();
                        
                        self.RefreshModel();
                        
                        self.FillDataSetList();
                    end
                    
                else
                    opts = struct('WindowStyle','modal','Interpreter','none');
                    errordlg('It is not possible to create an empty DataSet!','Error',opts);
                end
            end
        end
        
        function SamplesMoveToNewDataSet(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1 )
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                t = d.SelectedSamples;
                if(sum(t) > 0)
                    
                    if sum(t) < size(d.RawData, 1)
                        prompt = {'Enter new data set name:'};
                        dlg_title = 'Save';
                        num_lines = 1;
                        def = {'new_dataset'};
                        
                        if(sum(d.SelectedSamples) == size(d.RawData,1))
                            def = {[d.Name '_copy']};
                        end
                        opts = struct('WindowStyle','modal','Interpreter','none');
                        answer = inputdlg(prompt,dlg_title,num_lines,def, opts);
                        
                        if ~isempty(answer)
                            
                            new_d = DataSet([], self.parent);
                            new_d.RawData = d.RawData(logical(d.SelectedSamples),:);
                            new_d.Centering = d.Centering;
                            new_d.Scaling = d.Scaling;
                            new_d.RawClasses = d.RawClasses(logical(d.SelectedSamples),:);
                            new_d.VariableNames = d.VariableNames;
                            new_d.Variables = d.Variables;
                            
                            if(~isempty(d.ObjectNames))
                                new_d.ObjectNames = d.ObjectNames(logical(d.SelectedSamples),:);
                            end
                            
                            new_d.ClassLabels = d.ClassLabels;
                            
                            %addlistener(new_d,'Deleting',@self.parent.handleDatasetDelete);
                            
                            try
                                new_d.Name = answer{1};
                                assignin('base', answer{1}, new_d)
                            catch
                                %opts = struct('WindowStyle','modal','Interpreter','none');
                                %errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore!','Error',opts);
                                tmp = regexprep(answer{1}, '[^a-zA-Z0-9_]', '_');
                                
                                if(~isempty(regexp(tmp,'^\d+', 'once')))
                                    tmp = ['dataset_' tmp];
                                end
                                
                                if(~isempty(regexp(tmp,'^_+', 'once')))
                                    tmp = ['dataset_' tmp];
                                end
                                
                                new_d.Name = tmp;
                                assignin('base',tmp, new_d);
                            end                         
                            
                            d.RawData = d.RawData(not(t),:);
                            d.RawClasses = d.RawClasses(not(t),:);
                            if ~isempty(d.ObjectNames)
                                d.ObjectNames = d.ObjectNames(not(t),:);
                            end
                            self.FillTableView(selected_name);
                            self.Redraw();
                            
                            self.RefreshModel();
                            
                            self.FillDataSetList();
                              
                        end
                    else
                        opts = struct('WindowStyle','modal','Interpreter','none');
                        warndlg('The current dataset will be empty!','Warning',opts);
                    end
                    
                    
                else
                    opts = struct('WindowStyle','modal','Interpreter','none');
                    errordlg('It is not possible to create an empty DataSet!','Error',opts);
                end
            end
        end
        
        function SamplesRemoveSelection(self,obj, ~)
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                opts = struct('WindowStyle','modal','Interpreter','none','Default', 'No');
                answer = questdlg('Do you want to delete selected rows from the dataset?', ...
                    'Delete selected rows', ...
                    'Yes','No',opts);
                
                if isequal(answer, 'Yes')
                    
                    t = d.SelectedSamples;
                    if sum(t) < size(d.RawData, 1)
                        d.RawData = d.RawData(not(t),:);
                        d.RawClasses = d.RawClasses(not(t),:);
                        if ~isempty(d.ObjectNames)
                            d.ObjectNames = d.ObjectNames(not(t),:);
                        end
                        self.FillTableView(selected_name);
                        self.Redraw();
                    else
                        opts = struct('WindowStyle','modal','Interpreter','none');
                        warndlg('The resulting dataset will be empty!','Warning',opts);
                    end
                end
            end
        end
        
        function RedrawPCA(self,obj, ~)
            
            self.DrawPCA();
        end
        
        function Redraw(self,obj, ~)
            
            index_selected = get(self.listbox,'Value');
            names = get(self.listbox,'String');%fieldnames(ttab.Data);
            selected_name = names{index_selected};
            
            self.drawPlot(selected_name);
            
            %self.DrawPCA();
        end
        
        function SavePlot(self,obj, ~)
            if ~isempty(self.data_plot)
                PlotType = get(self.ddlPlotType,'Value');
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);%ttab.Data.(selected_name);
                
                switch PlotType
                    case 1 %scatter
                        var1 = get(self.ddlPlotVar1,'Value');
                        var2 = get(self.ddlPlotVar2,'Value');
                        if ~isempty(d.VariableNames)
                            type = sprintf('scatter_%s_%s_%s', selected_name, d.VariableNames{var1}, d.VariableNames{var2});
                        else
                            type = sprintf('scatter_%s_var%d_var%d', selected_name, var1, var2);
                        end
                    case 2 %line
                        type = sprintf('line_%s', selected_name);
                    case 3 %histogram
                        var1 = get(self.ddlPlotVar1,'Value');
                        if ~isempty(d.VariableNames)
                            type = sprintf('histogram_%s_%s', selected_name, d.VariableNames{var1});
                        else
                            type = sprintf('histogram_%s_var%d', selected_name, var1);
                        end
                end
                
                filename = [type,'.png'];
                if ispc
                    filename = [type,'.emf'];
                end
                
                fig2 = figure('visible','off');
                copyobj([self.data_plot_axes.Legend, self.data_plot_axes],fig2);
                
                dcm_obj = datacursormode(fig2);
                if isprop(dcm_obj, 'Interpreter')
                    dcm_obj.Interpreter = 'none';
                end
                
                [file,path] = uiputfile(filename,'Save image file');
                
                if ~(isnumeric(file) && (file == 0) && isnumeric(path) && (path == 0))
                    saveas(fig2, [path file]);
                end
                
            end
        end
        
        function CopyPlotToClipboard(self,obj, ~)
            fig2 = figure('visible','off');
            copyobj([self.data_plot_axes.Legend, self.data_plot_axes],fig2);
            
            dcm_obj = datacursormode(fig2);
            if isprop(dcm_obj, 'Interpreter')
                dcm_obj.Interpreter = 'none';
            end
            
            if ispc
                print(fig2,'-clipboard', '-dmeta');
            else
                print(fig2,'-clipboard', '-dbitmap');
            end
        end
        
        function Callback_PlotType(self,obj, ~)
            PlotType = get(obj,'Value');
            
            set(self.ddlPlotVar1, 'enable', 'on');
            set(self.ddlPlotVar2, 'enable', 'on');
            set(self.chkPlotShowObjectNames, 'enable', 'off');
            set(self.chkPlotShowClasses, 'enable', 'off');
            
            switch PlotType
                case 1 %scatter
                    set(self.ddlPlotVar1, 'enable', 'on');
                    set(self.ddlPlotVar2, 'enable', 'on');
                    set(self.chkPlotShowObjectNames, 'enable', 'on');
                    
                    index_selected = get(self.listbox,'Value');
                    names = get(self.listbox,'String');
                    selected_name = names{index_selected};
                    
                    d = evalin('base', selected_name);
                    
                    if isempty(d.Classes)
                        set(self.chkPlotShowClasses, 'enable', 'off');
                        set(self.chkPlotShowClasses, 'value', 0);
                    else
                        set(self.chkPlotShowClasses, 'enable', 'on');
                    end
                    
                case 2 %line
                    set(self.ddlPlotVar1, 'enable', 'off');
                    set(self.ddlPlotVar2, 'enable', 'off');
                    set(self.chkPlotShowObjectNames, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'enable', 'off');
                case 3 %histogram
                    set(self.ddlPlotVar1, 'enable', 'on');
                    set(self.ddlPlotVar2, 'enable', 'off');
                    set(self.chkPlotShowObjectNames, 'enable', 'off');
                    set(self.chkPlotShowClasses, 'enable', 'off');
                    
            end
            
            self.Redraw();
        end
        
        function Input_Centering(self,obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Centering = val;
                
                self.ClearPCA();
                %ttab.Data.(selected_name).Centering = val;
                %lst = DataTab.redrawListbox(ttab);
                
                self.drawPlot(selected_name);
                
                st1 = self.parent.selected_tab;
                st2 = self.parent.selected_panel;
                st3 = self.parent.selected_text_panel;
                st4 = self.parent.selected_panel_pca;
                
                if ~isempty(self.parent.modelTab)
                    names = get(self.parent.modelTab.ddlCalibrationSet, 'String');
                    sel = get(self.parent.modelTab.ddlCalibrationSet, 'Value');
                    
                    if (isequal(names{sel}, selected_name))
                        self.parent.modelTab.ClearModel();
                    end
                end
                
                self.parent.selected_tab = st1;
                self.parent.selected_panel = st2;
                self.parent.selected_text_panel = st3;
                self.parent.selected_panel_pca = st4;
            end
        end
        
        function Input_Scaling(self,obj, ~)
            val = get(obj,'Value');
            if ~isempty(val) && ~isnan(val)
                
                index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Scaling = val;
                %lst = DataTab.redrawListbox(ttab);
                
                self.ClearPCA();
                
                self.drawPlot(selected_name);
                
                %set(ttab.listbox, 'String', lst);
                
                st1 = self.parent.selected_tab;
                st2 = self.parent.selected_panel;
                st3 = self.parent.selected_text_panel;
                st4 = self.parent.selected_panel_pca;
                
                if ~isempty(self.parent.modelTab)
                    names = get(self.parent.modelTab.ddlCalibrationSet, 'String');
                    sel = get(self.parent.modelTab.ddlCalibrationSet, 'Value');
                    
                    if (isequal(names{sel}, selected_name))
                        self.parent.modelTab.ClearModel();
                    end
                end
                
                self.parent.selected_tab = st1;
                self.parent.selected_panel = st2;
                self.parent.selected_text_panel = st3;
                self.parent.selected_panel_pca = st4;
                
                %self.DrawPCA();
                
            end
        end
        
        function Input_Training(self,obj, ~)
            val = get(obj,'Value');
            
            
            if val == 1
                set(self.chkValidation, 'Value', 0);
            else
                set(self.chkValidation, 'Value', 1);
            end
            
            index_selected = get(self.listbox,'Value');
            
            if ~isempty(val) && ~isnan(val) && index_selected > 1
                
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                
                d.Training = val;
                d.Validation = 0;
                
                allvars = evalin('base','whos');
                
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win);
                end
                
                if sum(idx) > 0 && ~isempty(win.modelTab)
                    
                    %idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    %vardisplay={};
                    %if sum(idx) > 0
                    l = allvars(idx);
                    %                     vardisplay{1} = '-';
                    %                     for i = 1:length(l)
                    %                         vardisplay{i+1} = l(i).name;
                    %                     end
                    vardisplay = [{'-'}, {l.name}];
                    set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                    
                    if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                        set(win.modelTab.ddlCalibrationSet, 'Value', 2);
                        
                        m = evalin('base',vardisplay{2});
                        set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                    end
                    %end
                end
                
                %                 if sum(idx) == 0 && ~isempty(win.modelTab)
                %                     mtab = win.tgroup.Children(2);
                %                     delete(mtab);
                %                     win.modelTab = [];
                %
                %                     if ~isempty(win.predictTab)
                %                         ptab = win.tgroup.Children(2);
                %                         delete(ptab);
                %                         win.predictTab = [];
                %                     end
                %                     win.selected_tab = GUIWindow.DataTabSelected;
                %                     win.selected_panel = GUIWindow.DataGraph;
                %                     win.selected_text_panel = GUIWindow.ModelTableAllocation;
                %                     %win.selected_panel_pca = GUIWindow.DataPCAScores;
                %
                %                 end
                
            end
        end
        
        function Input_Validation(self,obj, ~)
            val = get(obj,'Value');
            index_selected = get(self.listbox,'Value');
            
            if val == 1
                set(self.chkTraining, 'Value', 0);
            else
                set(self.chkTraining, 'Value', 1);
            end
            
            if ~isempty(val) && ~isnan(val) && index_selected > 1
                
                
                names = get(self.listbox,'String');%fieldnames(ttab.Data);
                selected_name = names{index_selected};
                
                d = evalin('base', selected_name);
                d.Validation = val;
                d.Training = 0;
                
                allvars = evalin('base','whos');
                idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                
                win = self.parent;
                if sum(idx) > 0 && isempty(win.modelTab)
                    win.modelTab = ModelTab(win.tgroup, win);
                end
                
                if sum(idx) > 0 && ~isempty(win.modelTab)
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    %vardisplay={};
                    if sum(idx) > 0
                        l = allvars(idx);
                        %                         vardisplay{1} = '-';
                        %                         for i = 1:length(l)
                        %                             vardisplay{i+1} = l(i).name;
                        %                         end
                        vardisplay = [{'-'}, {l.name}];
                        set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                        if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                            set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                            
                            m = evalin('base',vardisplay{2});
                            set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                        end
                    end
                end
                
                if sum(idx) == 0 && ~isempty(win.modelTab)
                    ind = arrayfun(@(x)isequal(x.Title ,'Model'),win.tgroup.Children);
                    mtab = win.tgroup.Children(ind);
                    delete(mtab);
                    delete(win.modelTab);
                    win.modelTab = [];
                    
                    if ~isempty(win.predictTab)
                        ind = arrayfun(@(x)isequal(x.Title ,'Prediction'),win.tgroup.Children);
                        ptab = win.tgroup.Children(ind);
                        delete(ptab);
                        delete(win.predictTab);
                        win.predictTab = [];
                    end
                    
                    win.selected_tab = GUIWindow.DataTabSelected;
                    win.selected_panel = GUIWindow.DataGraph;
                    win.selected_text_panel = GUIWindow.ModelTableAllocation;
                    %win.selected_panel_pca = GUIWindow.DataPCAScores;
                    
                end
                
                %lst = DataTab.redrawListbox(ttab);
                
                %ttab = DataTab.drawPlot(ttab, selected_name);
                
                %set(ttab.listbox, 'String', lst);
            end
        end
        
        function DataSetWindowCloseCallback(self,obj,callbackdata)
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            
            idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
            
            if ~isempty(self.parent.modelTab)
                names = get(self.parent.modelTab.ddlCalibrationSet, 'String');
                sel = get(self.parent.modelTab.ddlCalibrationSet, 'Value');
                
                if (isequal(names{sel}, callbackdata.VariableName) && callbackdata.EditMode)
                    self.parent.modelTab.ClearModel();
                end
            end
            
%             if ~isempty(idx)
%             	names = varnames(idx);
%                 %dataset_list = cell(1, length(names));
%                 for i = 1:length(names)
%                    d = evalin('base', names{i});
%                    %dataset_list{i} = d;
%                    addlistener(d,'Deleting',@self.parent.handleDatasetDelete);  
%                 end
%             
%             end
            
            if ~isempty(idx)
                selected_name = callbackdata.VariableName;
                
                
                
                
                %                 selected_index = 2;
                %
                %                 vardisplay = cell(length(idx)+1,1);
                %                 vardisplay{1} = '-';
                %                 for i = 1:length(idx)
                %                     vardisplay{i+1} = varnames{idx(i)};
                %                     if(isequal(selected_name, varnames{idx(i)}))
                %                         selected_index = i+1;
                %                     end
                %                 end
                vardisplay = [{'-'}, varnames(idx)];
                selected_index = find(strcmp(vardisplay, selected_name ));
                
                if(isempty(selected_index))
                    selected_index = 2;
                end
                
                set(self.listbox, 'String', vardisplay);
                set(self.listbox, 'Value', selected_index);
                
                if (~isempty(self.parent.predictTab))
                    
                    allvarsp = evalin('base','whos');
                    
                    idx = arrayfun(@(x)self.parent.predictTab.filter_test(x), allvarsp);
                    
                    if sum(idx) > 0
                        %                         vardisplay = {};
                        l = allvars(idx);
                        %                         for i = 1:length(l)
                        %                             vardisplay{i} = l(i).name;
                        %                         end
                        vardisplay = {l.name};
                        set(self.parent.predictTab.ddlNewSet, 'String', vardisplay);
                    end
                    
                    
                end
                
                % extract all children
                self.enableRightPanel('on');
                
                d = evalin('base', selected_name);
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                if isempty(d.Classes)
                    set(self.chkTraining, 'Enable', 'off');
                    set(self.chkTraining, 'Value', 0);
                    set(self.chkValidation, 'Value', 1);
                    set(self.chkPlotShowClasses, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Value', 0);
                end
                
                if ~isempty(d.Classes) && d.NumberOfClasses == 1
                    set(self.chkTraining, 'enable', 'off');
                    set(self.chkTraining, 'value', 0);
                end
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                set(self.ddlPlotVar1, 'Value', 1);
                set(self.ddlPlotVar2, 'Value', 2);
                
                self.Redraw();
                self.FillTableView(selected_name);
                
                self.FillPCApcDDL(2);
                
                self.ClearPCA();
                %self.DrawPCA();
                
                %if(isempty(self.parent.cvTab) && d.NumberOfClasses > 1)
                %    self.parent.cvTab = CVTab(self.parent.tgroup, self.parent);
                %end
            end
            
            self.RefreshModel();
            
            
            idx_data = arrayfun(@(x)GUIWindow.filter_data(x), allvars);
            
            if (~isempty(self.parent.cvTab) && sum(idx_data) > 0)
                self.parent.cvTab.FillDataSetList();
            end
            
            if(~isempty(self.parent.cvTab) && sum(idx_data) == 0)
                ind = arrayfun(@(x)isequal(x.Title ,'Cross-validation'),self.parent.tgroup.Children);
                cvtab = self.parent.tgroup.Children(ind);
                delete(cvtab);
                delete(self.parent.cvTab);
                self.parent.cvTab = [];
            end
            
        end
        
        function RefreshModel(self)
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                if(sum(d.SelectedSamples) == 0 || length(unique(d.Classes)) <= 1)
                    d.Training = false;
                    d.Validation = true;
                    set(self.chkTraining,'Value', 0);
                    set(self.chkValidation,'Value', 1);
                    set(self.chkTraining,'Enable', 'off');
                else
                    set(self.chkTraining,'Enable', 'on');
                end
                
                if isempty(d.Classes)
                    %set(self.chkTraining, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Value', 0);
                else
                    %                     if d.NumberOfClasses > 1
                    %                         set(self.chkTraining, 'Enable', 'on');
                    %                     end
                    if get(self.ddlPlotType, 'Value') == 1
                        set(self.chkPlotShowClasses, 'Enable', 'on');
                    end
                end
            end
            
            allvars = evalin('base','whos');
            win = self.parent;
            idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
            
            if sum(idx) > 0 && isempty(win.modelTab)
                win.modelTab = ModelTab(win.tgroup, win);
            end
            
            if sum(idx) > 0 && ~isempty(win.modelTab)
                
                %idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                %vardisplay={};
                if sum(idx) > 0
                    l = allvars(idx);
                    %                     vardisplay{1} = '-';
                    %                     for i = 1:length(l)
                    %                         vardisplay{i+1} = l(i).name;
                    %                     end
                    
                    vardisplay = [{'-'}, {l.name}];
                    set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                    
                    if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                        set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                        
                        if strcmp(vardisplay{2}, selected_name)
                            
                            m = evalin('base',vardisplay{2});
                            set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                            set(win.modelTab.tbNumPCpls, 'String', sprintf('%d', min(max(m.NumberOfClasses, 12), size(m.ProcessedData, 2))));
                            win.modelTab.ClearModel();
                            
                        end
                        
                    end
                end
            end
            
            if sum(idx) == 0 && ~isempty(win.modelTab)
                ind = arrayfun(@(x)isequal(x.Title ,'Model'),win.tgroup.Children);
                mtab = win.tgroup.Children(ind);
                delete(mtab);
                delete(win.modelTab);
                win.modelTab = [];
                
                if ~isempty(win.predictTab)
                    ind = arrayfun(@(x)isequal(x.Title ,'Prediction'),win.tgroup.Children);
                    ptab = win.tgroup.Children(ind);
                    delete(ptab);
                    delete(win.predictTab);
                    win.predictTab = [];
                end
                
                win.selected_tab = GUIWindow.DataTabSelected;
                win.selected_panel = GUIWindow.DataGraph;
                win.selected_text_panel = GUIWindow.ModelTableAllocation;
                %win.selected_panel_pca = GUIWindow.DataPCAScores;
            end
            
        end
        
        function btnSetEdit_Callback(self,obj, ~)
            
            index_selected = get(self.listbox,'Value');
            
            if index_selected > 1
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                
                self.datasetwin = DataSetWindow(self, selected_name);
                %delete(self.evthandler);
                %self.evthandler = addlistener(self.datasetwin,'DataEdited', @self.DataSetWindowCloseEditCallback);
            end
            
        end
        
        function btnSetDelete_Callback(self,obj, ~)
            
            index_selected = get(self.listbox,'Value');
            
            if(index_selected > 1)
                names = get(self.listbox,'String');
                selected_name = names{index_selected};
                d = evalin('base', selected_name);
                
                opts = struct('WindowStyle','modal','Interpreter','none','Default', 'No');
                answer = questdlg('Do you want to delete selected dataset?', ...
                    'Delete dataset', ...
                    'Yes','No',opts);
                
                if isequal(answer, 'Yes')
                    
%                     ff = @self.parent.handleDatasetDelete;
%                     addlistener(d,'Deleting',ff);
%                     delete(d);
                    self.parent.deleteDataset(d);
                    evalin( 'base', ['clear ' selected_name] );
                    %
                    
                    allvars = evalin('base','whos');
                    varnames = {allvars.name};
                    win = self.parent;
                    idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}));
                    
                    if ~isempty(idx)

                        vardisplay  = [{'-'}, varnames(idx)];
                        selected_index = find(strcmp(vardisplay, selected_name));
                        
                        if isempty(selected_index)
                            selected_index = 2;
                        end
                        
                        set(self.listbox, 'String', vardisplay);
                        set(self.listbox, 'Value', selected_index);
                        
                        selected_name = vardisplay{2};
                        
                        if (~isempty(win.predictTab))
                            allvarsp = evalin('base','whos');
                            
                            idx = arrayfun(@(x)self.parent.predictTab.filter_test(x), allvarsp);
                            
                            if sum(idx) > 0

                                l = allvars(idx);

                                vardisplay = {l.name};
                                set(self.parent.predictTab.ddlNewSet, 'String', vardisplay);
                            end
                        end
                        
                        
                        % extract all children
                        self.enableRightPanel('on');
                        
                        d = evalin('base', selected_name);
                        
                        if(isempty(d.VariableNames))
                            if(isempty(d.Variables))
                                names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                            else
                                names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                            end
                        else
                            names = d.VariableNames;
                        end
                        
                        if isempty(d.Classes)
                            set(self.chkTraining, 'Enable', 'off');
                            set(self.chkTraining, 'Value', 0);
                            set(self.chkValidation, 'Value', 1);
                            set(self.chkPlotShowClasses, 'Enable', 'off');
                            set(self.chkPlotShowClasses, 'Value', 0);
                        end
                        
                        if ~isempty(d.Classes) && d.NumberOfClasses == 1
                            set(self.chkTraining, 'enable', 'off');
                            set(self.chkTraining, 'value', 0);
                        end
                        
                        self.resetRightPanel();
                        self.fillRightPanel();
                        
                        set(self.ddlPlotVar1, 'String', names);
                        set(self.ddlPlotVar2, 'String', names);
                        
                        set(self.ddlPlotVar1, 'Value', 1);
                        set(self.ddlPlotVar2, 'Value', 2);
                        
                        self.Redraw();
                        self.FillTableView(selected_name);
                        
                        if(~isempty(self.parent.cvTab))
                            idx_data = arrayfun(@(x)GUIWindow.filter_data(x), allvars);
                            
                            if (sum(idx_data) == 0)
                                ind = arrayfun(@(x)isequal(x.Title ,'Cross-validation'),self.parent.tgroup.Children);
                                cvtab = self.parent.tgroup.Children(ind);
                                delete(cvtab);
                                delete(self.parent.cvTab);
                                self.parent.cvTab = [];
                            else
                                self.parent.cvTab.FillDataSetList();
                            end
                        end
                    else
                        
                        set(self.listbox, 'String', {'-'});
                        set(self.listbox, 'Value', 1);
                        
                        self.resetRightPanel();
                        self.enableRightPanel('off');
                        delete(self.data_plot);
                        delete(self.data_plot_axes);
                        
                        self.tblTextResult.Data = [];
                        self.tblTextResult.ColumnName = [];
                        
                        idx_data = arrayfun(@(x)GUIWindow.filter_data(x), allvars);
                        
                        if (sum(idx_data) == 0)
                            ind = arrayfun(@(x)isequal(x.Title ,'Cross-validation'),self.parent.tgroup.Children);
                            cvtab = self.parent.tgroup.Children(ind);
                            delete(cvtab);
                            delete(self.parent.cvTab);
                            self.parent.cvTab = [];
                        end
                        
                    end
                    
                    idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);
                    
                    if sum(idx) > 0 && ~isempty(win.modelTab)
                        
                        idx = arrayfun(@(x)ModelTab.filter_training(x), allvars);

                        if sum(idx) > 0
                            l = allvars(idx);
  
                            vardisplay  = [{'-'}, {l.name}];
                            
                            set(win.modelTab.ddlCalibrationSet, 'String', vardisplay);
                            
                            if length(get(win.modelTab.ddlCalibrationSet, 'String')) > 1
                                set(win.modelTab.ddlCalibrationSet, 'Value', 2)
                                
                                m = evalin('base',vardisplay{2});
                                set(win.modelTab.tbNumPCpca, 'String', sprintf('%d', m.NumberOfClasses-1));
                            end
                        end
                    end
                    
                    if sum(idx) == 0 && ~isempty(win.modelTab)
                        ind = arrayfun(@(x)isequal(x.Title ,'Model'),win.tgroup.Children);
                        mtab = win.tgroup.Children(ind);
                        delete(mtab);
                        win.modelTab = [];
                        
                        if ~isempty(win.predictTab)
                            ind = arrayfun(@(x)isequal(x.Title ,'Prediction'),win.tgroup.Children);
                            ptab = win.tgroup.Children(ind);
                            delete(ptab);
                            win.predictTab = [];
                        end
                        
                        win.selected_tab = GUIWindow.DataTabSelected;
                        win.selected_panel = GUIWindow.DataGraph;
                        win.selected_text_panel = GUIWindow.ModelTableAllocation;
                        %win.selected_panel_pca = GUIWindow.DataPCAScores;
                    end
                    
                end
                
            end
            
        end
        
        function btnNew_Callback(self,obj, ~)
            
            self.datasetwin = DataSetWindow(self);
            
        end
        
        function Callback_PCALoadingsPlotType(self,obj, ~)
            index_selected = get(obj,'Value');
            if(index_selected > 1)
                set(self.ddlPCApc1,'enable','off');
                set(self.ddlPCApc2,'enable','off');
                
                set(self.chkPlotShowClassesPCA,'enable','off');
                set(self.chkPlotShowObjectNamesPCA,'enable','off');
            else
                set(self.ddlPCApc1,'enable','on');
                set(self.ddlPCApc2,'enable','on');
                
                if self.parent.selected_panel_pca == GUIWindow.DataPCAScores
                    set(self.chkPlotShowClassesPCA,'enable','on');
                else
                    set(self.chkPlotShowClassesPCA,'enable','off');
                end
                
                set(self.chkPlotShowObjectNamesPCA,'enable','on');
                
                obj_index_selected = get(self.listbox,'Value');
                names = get(self.listbox,'String');
                selected_name = names{obj_index_selected};
                
                if obj_index_selected > 1
                    d = evalin('base', selected_name);
                    if isempty(d.Classes)
                        set(self.chkPlotShowClassesPCA, 'value', 0);
                        set(self.chkPlotShowClassesPCA, 'enable', 'off');
                        %else
                        %    set(self.chkPlotShowClassesPCA, 'enable', 'on');
                    end
                end
            end
            self.DrawPCA();
        end
        
        function listClick(self,obj, ~)
            
            index_selected = get(obj,'Value');
            
            if(index_selected > 1)
                % extract all children
                self.enableRightPanel('on');
                
                names = get(self.listbox, 'String');
                selected_name = names{index_selected};
                
                self.parent.selected_dataset = selected_name;
                
                d = evalin('base', selected_name);
                
                if(sum(d.SelectedSamples) == 0 || length(unique(d.Classes)) <= 1)
                    d.Training = false;
                    d.Validation = true;
                    set(self.chkTraining,'Value', 0);
                    set(self.chkValidation,'Value', 1);
                    set(self.chkTraining,'Enable', 'off');
                else
                    set(self.chkTraining,'Enable', 'on');
                end
                
                if isempty(d.Classes)
                    %set(self.chkTraining, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Enable', 'off');
                    set(self.chkPlotShowClasses, 'Value', 0);
                else
                    %                     if d.NumberOfClasses > 1
                    %                         set(self.chkTraining, 'Enable', 'on');
                    %                     end
                    
                    set(self.chkPlotShowClasses, 'Enable', 'on');
                end
                
                self.resetRightPanel();
                self.fillRightPanel();
                
                if(isempty(d.VariableNames))
                    if(isempty(d.Variables))
                        names = arrayfun(@(x) sprintf('%d', x), 1:size(d.ProcessedData, 2), 'UniformOutput', false);
                    else
                        names = arrayfun(@(x) sprintf('%.2f', x), d.Variables, 'UniformOutput', false);
                    end
                else
                    names = d.VariableNames;
                end
                
                set(self.ddlPlotVar1, 'String', names);
                set(self.ddlPlotVar2, 'String', names);
                
                set(self.ddlPlotVar1, 'Value', 1);
                set(self.ddlPlotVar2, 'Value', 2);
                
                self.drawPlot(selected_name);
                
                self.FillTableView(selected_name);
                self.FillPCApcDDL(2);
                
                if (d.HasPCA)
                    self.pca_tabgroup.Visible = 'on';
                    param = 'on';
                    set(self.btnPCABuild, 'String', 'Rebuild');
                    self.DrawPCA();
                else
                    self.pca_tabgroup.Visible = 'off';
                    set(self.btnPCABuild, 'String', 'Build');
                    param = 'off';
                end
                
                self.enablePCAPanel(param);
                
            else
                self.resetRightPanel();
                self.enableRightPanel('off');
                delete(self.data_plot);
                delete(self.data_plot_axes);
                
                self.tblTextResult.Data = [];
                self.tblTextResult.ColumnName = [];
                
                self.ClearPCA();
            end
            
        end
        
        function FillTableView(self, selected_name)
            
            d = evalin('base', selected_name);
            
            Labels = cell(size(d.RawData, 1),1);
            for i = 1:size(d.RawData, 1)
                Labels{i} = sprintf('Object No.%d', i);
            end
            
            if(~isempty(d.ObjectNames))
                Labels = d.ObjectNames;
            end
            
            if ~isempty(d.RawClasses)
                self.tblTextResult.ColumnName = {'Sample', 'Class', 'Included'};
                
                if ~isempty(d.ClassLabels)
                    self.tblTextResult.Data = [Labels, {d.ClassLabels{d.RawClasses}}', num2cell(logical(d.SelectedSamples))];
                    self.tblTextResult.ColumnWidth = num2cell([150 max(60, max(strlength(d.ClassLabels))*7) 60]);
                else
                    self.tblTextResult.Data = [Labels, num2cell(d.RawClasses), num2cell(logical(d.SelectedSamples))];
                    self.tblTextResult.ColumnWidth = num2cell([150 60 60]);
                end
                
                self.tblTextResult.ColumnEditable = [false false true];
            else
                self.tblTextResult.Data = [Labels, num2cell(logical(d.SelectedSamples))];
                self.tblTextResult.ColumnName = {'Sample', 'Included'};
                self.tblTextResult.ColumnWidth = num2cell([150 60]);
                self.tblTextResult.ColumnEditable = [false true];
            end
            
            self.tblTextResult.CellEditCallback = @self.SelectedSamplesChangedCallback;
            
        end
        
        function resetRightPanel(self)
            ttab = self;
            set(ttab.chkTraining, 'Value', 0);
            set(ttab.chkValidation, 'Value', 0);
            set(ttab.chkCentering, 'Value', 0);
            set(ttab.chkScaling, 'Value', 0);
            set(ttab.ddlPlotType, 'Value', 2);
            set(ttab.ddlPlotVar1, 'enable', 'off');
            set(ttab.ddlPlotVar2, 'enable', 'off');
            
            set(ttab.ddlPlotVar1, 'string', '-');
            set(ttab.ddlPlotVar2, 'string', '-');
            set(ttab.ddlPlotVar1, 'value', 1);
            set(ttab.ddlPlotVar2, 'value', 1);
            
            set(ttab.chkPlotShowObjectNames, 'enable', 'off');
            set(ttab.chkPlotShowClasses, 'enable', 'off');
            
            set(self.txtPCApcnumber, 'String', 2);
            self.FillPCApcDDL(0);
            set(self.ddlPlotTypePCA,'value',1);
        end
        
        function drawPlot(self, selected_name)
            
            delete(self.data_plot);
            delete(self.data_plot_axes);
            %ax = get(gcf,'CurrentAxes');
            %cla(ax);
            %subplot
            ha2d = axes('Parent', self.tab_img);
            %set(gcf,'CurrentAxes',ha2d);
            self.data_plot_axes = ha2d;
            
            d = evalin('base', selected_name);%ttab.Data.(selected_name);
            
            if sum(d.SelectedSamples) > 0
                var1 = get(self.ddlPlotVar1, 'Value');
                var2 = get(self.ddlPlotVar2, 'Value');
                showObjectNames = get(self.chkPlotShowObjectNames, 'Value');
                showClasses = get(self.chkPlotShowClasses, 'Value');
                PlotType = get(self.ddlPlotType, 'Value');
                
                switch PlotType
                    case 1 %scatter
                        self.data_plot = d.scatter(self.data_plot_axes, var1, var2, showClasses, showObjectNames);
                        set(self.chkPlotShowObjectNames, 'Enable', 'on');
                        
                        labels = strread(num2str(1:size(d.ProcessedData, 1)),'%s');
                        if(~isempty(d.ObjectNames))
                            labels = d.ObjectNames;
                        end
                        %set(axes,'UserData', {YpredT_, labels, self.TrainingDataSet.Classes});
                        %                         if ~isempty(d.Classes)
                        set(self.data_plot_axes,'UserData', {[d.ProcessedData(:,var1), d.ProcessedData(:,var2)], labels, d.Classes, [], d.ClassLabels});
                        %                         else
                        %                             set(self.data_plot_axes,'UserData', {[d.ProcessedData(:,var1), d.ProcessedData(:,var2)], labels, [], [], []});
                        %                         end
                        
                        if showObjectNames
                            pan off
                            datacursormode on
                            dcm_obj = datacursormode(self.parent.fig);
                            if isprop(dcm_obj,'Interpreter')
                                dcm_obj.Interpreter = 'none';
                            end
                            set(dcm_obj, 'UpdateFcn', @GUIWindow.DataCursorFunc);
                        else
                            datacursormode off
                            pan on
                        end
                        
                    case 2 %line
                        self.data_plot = d.line(self.data_plot_axes);
                        pan off
                        datacursormode off
                        set(self.chkPlotShowObjectNames, 'Value', 0);
                        set(self.chkPlotShowObjectNames, 'Enable', 'off');
                    case 3 %histogram
                        self.data_plot = d.histogram(self.data_plot_axes, var1);
                        pan off
                        datacursormode off
                        set(self.chkPlotShowObjectNames, 'Value', 0);
                        set(self.chkPlotShowObjectNames, 'Enable', 'off');
                end
            end
            
        end
        
        function fillRightPanel(self)
            ttab = self;
            index_selected = get(ttab.listbox,'Value');
            names = get(ttab.listbox,'String');
            selected_name = names{index_selected};
            
            if index_selected > 1
                d = evalin('base', selected_name);
                
                set(ttab.chkCentering, 'Value', d.Centering);
                set(ttab.chkScaling, 'Value', d.Scaling);
                
                set(ttab.chkTraining, 'Value', d.Training);
                set(ttab.chkValidation, 'Value', d.Validation);
                
                if (~isempty(d.RawData))
                    set(ttab.ddlSamplesRange1, 'String',cellstr(string(1:size(d.RawData,1))));
                    set(ttab.ddlSamplesRange2, 'String',cellstr(string(1:size(d.RawData,1))));
                else
                    %something is very very wrong
                end
                
                
                if (isempty(d.RawClasses))
                    set(ttab.btnSamplesClasses, 'Enable', 'off');
                    set(ttab.ddlSamplesClasses, 'Enable', 'off');
                    set(ttab.ddlSamplesClasses, 'String', {'-'});
                else
                    set(ttab.btnSamplesClasses, 'Enable', 'on');
                    set(ttab.ddlSamplesClasses, 'Enable', 'on');
                    if(isempty(d.ClassLabels))
                        set(ttab.ddlSamplesClasses, 'String',cellstr(string(unique(d.RawClasses))));
                    else
                        set(ttab.ddlSamplesClasses, 'String',d.ClassLabels(unique(d.RawClasses)));
                    end
                end
                
            end
            
        end
        
        function enablePCAPanel(self, param)
            
            panel = self.pnlPCASettings;
            
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
            
            if(strcmp('off',param))
                self.txtPCApcnumber.Enable = 'on';
                self.btnPCABuild.Enable = 'on';
                self.btnPCABuild.String = 'Build';
                
                self.pca_tabgroup.SelectedTab = self.pca_tabgroup.Children(1);
                self.parent.selected_panel_pca = GUIWindow.DataPCAScores;
                self.vbox_pca.Heights=[20,20,25,0];
                set(self.hbox_pca_plot_type,'visible','off');
            end
            
            index_selected = get(self.listbox,'Value');
            names = get(self.listbox,'String');
            selected_name = names{index_selected};
            
            if index_selected > 1
                d = evalin('base', selected_name);
                if isempty(d.Classes)
                    set(self.chkPlotShowClassesPCA, 'value', 0);
                    set(self.chkPlotShowClassesPCA, 'enable', 'off');
                end
            end
            
        end
        
        function enableRightPanel(self, param)
            ttab = self;
            children = get(get(ttab.pnlDataSettings,'Children'),'Children');
            children1 = get(get(ttab.pnlPlotSettings,'Children'),'Children');
            children2 = get(get(ttab.pnlDataCategories,'Children'),'Children');
            
            % only set children which are uicontrols:
            set(children(strcmpi ( get (children,'Type'),'UIControl')),'enable',param);
            set(children1(strcmpi ( get (children1,'Type'),'UIControl')),'enable',param);
            set(children2(strcmpi ( get (children2,'Type'),'UIControl')),'enable',param);
            
            set(self.btnDataSetEdit,'enable',param);
            set(self.btnDataSetDelete,'enable',param);
            set(self.ddlPlotType,'enable',param);
            set(self.btnSavePlotToFile,'enable',param);
            set(self.btnSavePlotToClipboard,'enable',param);
            
            
            set(self.listbox,'enable',param);
            
            tg = self.tab_img.Parent;
            tg.Visible = param;
            
            if(strcmp('off',param))
                
                allvars = evalin('base','whos');
                
                idx = find(cellfun(@(x)isequal(x,'DataSet'),{allvars.class}), 1);
                
                if ~isempty(idx)
                    set(self.listbox,'enable','on');
                end
                
                tg.SelectedTab = tg.Children(1);
                self.pca_tabgroup.SelectedTab = self.pca_tabgroup.Children(1);
                
                set(self.pnlPlotSettings,'visible','on');
                set(self.pnlTableSettings,'visible','off');
                set(self.pnlPCASettings,'visible','off');
                
                if ispc
                    self.vbox.Heights=[40,30,40,40,170,0,0];
                else
                    self.vbox.Heights=[40,30,40,40,160,0,0];
                end
                self.parent.selected_tab = GUIWindow.DataTabSelected;
                self.parent.selected_panel = GUIWindow.DataGraph;
                self.parent.selected_text_panel = GUIWindow.ModelTableAllocation;
                self.parent.selected_panel_pca = GUIWindow.DataPCAScores;
            end
            
            
        end
        
        
    end
    
end