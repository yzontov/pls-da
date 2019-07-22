classdef  DataSetWindow<handle
    properties
        parent;
        
        tbName;
        ddlData;
        ddlClasses;
        ddlObjectNames;
        ddlVariableNames;
        ddlVariables;
        ddlClassLabels;
        btnAdd;
        
        win;
        datatab;
        dataset_name;
        dataset;
        
        Name;
        Data;
        Classes;
        ObjectNames;
        VariableNames;
        Wavelengths;
        ClassLabels;
    end
    
    methods
        
        function win = DataSetWindow(parent, dataset_name)
            
            if nargin == 1
                dataset_name = [];
            end
            
            win.dataset_name = dataset_name;
            win.parent = parent;
            
            %get version year
            v = version('-release');
            vyear = str2double(v(1:4));
            
            if vyear < 2014
                screensize = get( 0, 'Screensize' );
            else
                screensize = get( groot, 'Screensize' );
            end
            
            input_win = figure;
            
            set(input_win, 'WindowStyle', 'Modal');
            
            set(input_win,'Visible','on');
            set(input_win, 'MenuBar', 'none');
            set(input_win, 'ToolBar', 'none');
            set(input_win,'name','Create New Data Set','numbertitle','off');
            set(input_win, 'Resize', 'off');
            set(input_win, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 300 400]);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Name', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.tbName = uicontrol('Parent', input_win, 'Style', 'edit', 'String', '', ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.85 0.55 0.05], 'BackgroundColor', 'white');
            
            if ~isempty(win.dataset_name)
                set(win.tbName, 'String', win.dataset_name);
                set(win.tbName, 'Enable', 'off');
                set(input_win,'name','Edit Data Set');
            else
                set(win.tbName, 'Enable', 'on');
            end
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Data', ...
                'Units', 'normalized','Position', [0.05 0.75 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlData = uicontrol('Parent', input_win, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.75 0.55 0.05], 'BackgroundColor', 'white', 'callback', @win.Callback_Data);
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            varsizes = {allvars.size};
            
            idx = find(cellfun(@(x)isequal(x,'double'),{allvars.class}));
            
            vardisplay = {};
            vardisplay{1} = '-';
            if ~isempty(idx)
                
                if ~isempty(win.dataset_name)
                    k = 3;
                    vardisplay{2} = '-';
                else
                    k = 2;
                end
                
                for i = 1:length(idx)
                    ss = varsizes{idx(i)};
                    if(ss(2) > 1)
                        vardisplay{k} = sprintf('%s (%dx%d)',varnames{idx(i)},ss(1),ss(2));
                        k = k+1;
                    end
                end
            end
            
            if ~isempty(win.dataset_name)
                d = evalin('base', win.dataset_name);
                win.dataset = d;
                ss = size(d.RawData);
                vardisplay{2} = sprintf('%s.Data (%dx%d)',win.dataset_name,ss(1),ss(2));
            end
            
            set(win.ddlData, 'String', vardisplay);
            
            if ~isempty(win.dataset_name)
                set(win.ddlData, 'Value', 2);
            end
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Classes', ...
                'Units', 'normalized','Position', [0.05 0.65 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClasses = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.65 0.55 0.05], 'BackgroundColor', 'white', 'callback', @win.Callback_Classes);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Object names', ...
                'Units', 'normalized','Position', [0.05 0.55 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlObjectNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.55 0.55 0.05], 'BackgroundColor', 'white');
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Variable names', ...
                'Units', 'normalized','Position', [0.05 0.45 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlVariableNames = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.45 0.55 0.05], 'BackgroundColor', 'white');
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Class labels', ...
                'Units', 'normalized','Position', [0.05 0.35 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlClassLabels = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.35 0.55 0.05], 'BackgroundColor', 'white');
            
%             uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Wavelengths', ...
%                 'Units', 'normalized','Position', [0.05 0.25 0.35 0.05], 'HorizontalAlignment', 'left');
%             win.ddlVariables = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'},...
%                 'Units', 'normalized','Value',1, 'Position', [0.35 0.25 0.55 0.05], 'BackgroundColor', 'white');
            
            win.btnAdd = uicontrol('Parent', input_win, 'Style', 'pushbutton', 'String', 'Add data set',...
                'Units', 'Normalized', 'Position', [0.3 0.07 0.4 0.1], ...
                'callback', @win.btnAdd_Callback);
            
            if ~isempty(win.dataset_name)
                set(win.btnAdd, 'String', 'Save');

                list = evalin('base','whos');
                
                t = win.dataset.RawData;
                
                gg = size(t);
                idx = arrayfun(@(x)win.type_size_filter(x,gg(1),1,1,2,'double'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                
                if ~isempty(win.dataset.RawClasses)
                    ss = size(win.dataset.RawClasses);
                    vardisplay{2} = sprintf('%s.Classes (%dx%d)',win.dataset_name,ss(1),ss(2));
                end
                
                if sum(idx) > 0
                    l = list(idx);
                    
                    if ~isempty(win.dataset.RawClasses)
                        offset = 2;
                    else
                        offset = 1;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                end
                
                cl_var = [];
                set(win.ddlClasses, 'String', vardisplay);
                if length(get(win.ddlClasses, 'String')) > 1
                    if ~isempty(win.dataset.RawClasses)
                        set(win.ddlClasses, 'Value', 2);
                        cl_var = win.dataset.RawClasses;
                    else
                        set(win.ddlClasses, 'Value', 1);
                    end
                end
                
                idx = arrayfun(@(x)win.type_size_filter(x,gg(1),1,1,2,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(win.dataset.ObjectNames)
                    ss = size(win.dataset.ObjectNames);
                    vardisplay{2} = sprintf('%s.ObjectNames (%dx%d)',win.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    if ~isempty(win.dataset.ObjectNames)
                        offset = 2;
                    else
                        offset = 1;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end

                end
                
                
                set(win.ddlObjectNames, 'String', vardisplay);
                if length(get(win.ddlObjectNames, 'String')) > 1
                    if ~isempty(win.dataset.ObjectNames)
                        set(win.ddlObjectNames, 'Value', 2);
                    else
                        set(win.ddlObjectNames, 'Value', 1);
                    end
                end
                
                idx = arrayfun(@(x)win.type_size_filter(x,1,1,gg(2),2,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(win.dataset.VariableNames)
                    ss = size(win.dataset.VariableNames);
                    vardisplay{2} = sprintf('%s.VariableNames (%dx%d)',win.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    if ~isempty(win.dataset.VariableNames)
                        offset = 2;
                    else
                        offset = 1;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    
                    set(win.ddlVariableNames, 'String', vardisplay);
                    if length(get(win.ddlVariableNames, 'String')) > 1
                        if ~isempty(win.dataset.VariableNames)
                            set(win.ddlVariableNames, 'Value', 2);
                        else
                            set(win.ddlVariableNames, 'Value', 1);
                        end
                    end
                else
                    
                    idx = arrayfun(@(x)win.type_size_filter(x,1,1,gg(2),2,'double'),list);
                    
                    %vardisplay={};
                    %vardisplay{1} = '-';
                    if ~isempty(win.dataset.Variables)
                        ss = size(win.dataset.Variables);
                        vardisplay{2} = sprintf('%s.Variables (%dx%d)',win.dataset_name,ss(1),ss(2));
                    end
                    if sum(idx) > 0
                        l = list(idx);
                        
                        if ~isempty(win.dataset.Variables)
                            offset = 2;
                        else
                            offset = 1;
                        end
                        
                        for i = 1:length(l)
                            ss = l(i).size;
                            vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                        end
                        
                    end
                    
                    set(win.ddlVariableNames, 'String', vardisplay);
                    if length(get(win.ddlVariableNames, 'String')) > 1
                        if ~isempty(win.dataset.Variables)
                            set(win.ddlVariableNames, 'Value', 2);
                        else
                            set(win.ddlVariableNames, 'Value', 1);
                        end
                    end    
                    
                end
                
                
                cl_var_size = max(cl_var);
                idx = arrayfun(@(x)win.type_size_filter(x,cl_var_size,2,1,1,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(win.dataset.ClassLabels)
                    ss = size(win.dataset.ClassLabels);
                    vardisplay{2} = sprintf('%s.ClassLabels (%dx%d)',win.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    if ~isempty(win.dataset.ClassLabels)
                        offset = 2;
                    else
                        offset = 1;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    
                end
                
                set(win.ddlClassLabels, 'String', vardisplay);
                if length(get(win.ddlClassLabels, 'String')) > 1
                    if ~isempty(win.dataset.ClassLabels)
                        set(win.ddlClassLabels, 'Value', 2);
                    else
                        set(win.ddlClassLabels, 'Value', 1);
                    end
                end
                 
            end
            
            win.win = input_win;
            
        end
        
        function obj = GetObject(self, list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
        end
        
       
        function r = type_size_filter(self, x, k, n, k2, n2, t)
            s = x.size;
            if isequal(x.class,t) && ((~isempty(k) && ~isempty(n) && s(n) == k || isempty(k) && isempty(n))) && ...
                    (~isempty(k2) && ~isempty(n2) && (k2 >=1 && s(n2) == k2 || k2 == -1 && s(n2) > 1) || ...
                    isempty(k2) && isempty(n2))
                r = true;
            else
                r = false;
            end
        end
        
        
        function Callback_Data(self,obj, ~)
            
            list = evalin('base','whos');
            
            K = get(self.ddlData, 'Value');
            
            if K > 1
                
                if ~isempty(self.dataset) && ~isempty(self.dataset.RawData) && K == 2
                    t = self.dataset.RawData;
                else
                    ll = get(self.ddlData, 'String');
                    mm = ll{K};
                    t = evalin('base',mm(1:strfind(mm, ' ')-1));
                end
                
                gg = size(t);
                idx = arrayfun(@(x)self.type_size_filter(x,gg(1),1,1,2,'double'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                
                if ~isempty(self.dataset) && ~isempty(self.dataset.RawClasses)
                    ss = size(self.dataset.RawClasses);
                    vardisplay{2} = sprintf('%s.Classes (%dx%d)',self.dataset_name,ss(1),ss(2));
                end
                
                cl_var = [];
                if sum(idx) > 0
                    l = list(idx);
                    
                    offset = 1;
                    if ~isempty(self.dataset_name) && ~isempty(self.dataset.RawClasses)
                        offset = 2;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                end
                
                
                set(self.ddlClasses, 'String', vardisplay);
                if length(get(self.ddlClasses, 'String')) > 1
                    set(self.ddlClasses, 'Value', 2);
                    
                    if ~isempty(self.dataset) && ~isempty(self.dataset.RawClasses)
                        cl_var = self.dataset.RawClasses;
                    else
                        l = list(idx);
                        cl_var = evalin('base', l(1).name);
                    end
                    
                end
                
                idx = arrayfun(@(x)self.type_size_filter(x,gg(1),1,1,2,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(self.dataset) && ~isempty(self.dataset.ObjectNames)
                    ss = size(self.dataset.ObjectNames);
                    vardisplay{2} = sprintf('%s.ObjectNames (%dx%d)',self.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    offset = 1;
                    if ~isempty(self.dataset_name) && ~isempty(self.dataset.ObjectNames)
                        offset = 2;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    
                end
                
                set(self.ddlObjectNames, 'String', vardisplay);
                if length(get(self.ddlObjectNames, 'String')) > 1
                    set(self.ddlObjectNames, 'Value', 2)
                end
                
                idx = arrayfun(@(x)self.type_size_filter(x,1,1,gg(2),2,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(self.dataset) && ~isempty(self.dataset.VariableNames)
                    ss = size(self.dataset.VariableNames);
                    vardisplay{2} = sprintf('%s.VariableNames (%dx%d)',self.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    offset = 1;
                    if ~isempty(self.dataset_name) && ~isempty(self.dataset.VariableNames)
                        offset = 2;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    
                else
                    
                    idx = arrayfun(@(x)self.type_size_filter(x,1,1,gg(2),2,'double'),list);
                    
                    vardisplay={};
                    vardisplay{1} = '-';
                    if ~isempty(self.dataset) && ~isempty(self.dataset.Variables)
                        ss = size(self.dataset.Variables);
                        vardisplay{2} = sprintf('%s.Variables (%dx%d)',self.dataset_name,ss(1),ss(2));
                    end
                    if sum(idx) > 0
                        l = list(idx);
                        
                        offset = 1;
                        if ~isempty(self.dataset_name) && ~isempty(self.dataset.Variables)
                            offset = 2;
                        end
                        
                        for i = 1:length(l)
                            ss = l(i).size;
                            vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                        end
                        
                    end
                    
                    
                end
                
                set(self.ddlVariableNames, 'String', vardisplay);
                if length(get(self.ddlVariableNames, 'String')) > 1
                    set(self.ddlVariableNames, 'Value', 2)
                end
                
                cl_var_size = max(cl_var);
                idx = arrayfun(@(x)self.type_size_filter(x,cl_var_size,2,1,1,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(self.dataset) && ~isempty(self.dataset.ClassLabels)
                    ss = size(self.dataset.ClassLabels);
                    vardisplay{2} = sprintf('%s.ClassLabels (%dx%d)',self.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    offset = 1;
                    if ~isempty(self.dataset_name) && ~isempty(self.dataset.ClassLabels)
                        offset = 2;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    
                end
                
                set(self.ddlClassLabels, 'String', vardisplay);
                if length(get(self.ddlClassLabels, 'String')) > 1
                    set(self.ddlClassLabels, 'Value', 2)
                end
                
                
                
            else
                set(self.ddlClasses, 'String', {'-'});
                set(self.ddlVariableNames, 'String', {'-'});
                set(self.ddlObjectNames, 'String', {'-'});
                set(self.ddlClassLabels, 'String', {'-'});
                %set(self.ddlVariables, 'String', {'-'});
                
                set(self.ddlVariableNames, 'Value', 1);
                set(self.ddlClasses, 'Value', 1);
                set(self.ddlObjectNames, 'Value', 1);
                %set(self.ddlVariables, 'Value', 1);
            end
            
        end
        
        function Callback_Classes(self,obj, ~)
            
            list = evalin('base','whos');
            
            K = get(self.ddlClasses, 'Value');
            if K > 1
                
                if ~isempty(self.dataset) && ~isempty(self.dataset.RawClasses) && K == 2
                    t = self.dataset.RawClasses;
                else
                    ll = get(self.ddlClasses, 'String');
                    mm = ll{K};
                    t = evalin('base',mm(1:strfind(mm, ' ')-1));
                end
                
                cl_num = size(unique(t),1);
                idx = arrayfun(@(x)self.type_size_filter(x,cl_num,2,1,1,'cell'),list);
                
                vardisplay={};
                vardisplay{1} = '-';
                if ~isempty(self.dataset) && ~isempty(self.dataset.ClassLabels)
                    ss = size(self.dataset.ClassLabels);
                    vardisplay{2} = sprintf('%s.ClassLabels (%dx%d)',self.dataset_name,ss(1),ss(2));
                end
                if sum(idx) > 0
                    l = list(idx);
                    
                    offset = 1;
                    if ~isempty(self.dataset_name) && ~isempty(self.dataset.ClassLabels)
                        offset = 2;
                    end
                    
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+offset} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                else
                    set(self.ddlClassLabels, 'Value', 1);
                end
                set(self.ddlClassLabels, 'String', vardisplay);
                
            else
                set(self.ddlClassLabels, 'String', {'-'});
                set(self.ddlClassLabels, 'Value', 1);
            end
            
        end
        
        function btnAdd_Callback(self,obj, ~)
            
            name = get(self.tbName, 'String');
            opts = struct('WindowStyle','modal','Interpreter','none');
            ok = true;
            
            if ~isempty(name)
                
                if get(self.ddlData, 'Value') > 1 %&& get(self.ddlClasses, 'Value') > 1
                    d = DataSet([], self.parent.parent);
                    
                    if ~isempty(self.dataset_name) && get(self.ddlData, 'Value') == 2
                        d.RawData = self.dataset.RawData;
                    else
                        d.RawData = self.GetObject(get(self.ddlData, 'String'), get(self.ddlData, 'Value'));
                    end
                    
                    d.Name = name;
                    
                    if(~isempty(self.dataset))
                        d.Training = self.dataset.Training;
                        d.Validation = self.dataset.Validation;
                    end
                    
                    if get(self.ddlClasses, 'Value') > 1
                        
                        if ~isempty(self.dataset_name) && ~isempty(self.dataset.RawClasses) && get(self.ddlClasses, 'Value') == 2
                            d.RawClasses = self.dataset.RawClasses;
                        else
                            d.RawClasses = self.GetObject(get(self.ddlClasses, 'String'), get(self.ddlClasses, 'Value'));
                        end
                    else
                        d.Training = false;
                        d.Validation = true;
                    end
                    
                    if get(self.ddlVariableNames, 'Value') > 1
                        
                        if ~isempty(self.dataset_name) && ~isempty(self.dataset.VariableNames) && get(self.ddlVariableNames, 'Value') == 2
                            d.VariableNames = self.dataset.VariableNames;
                            if isa(d.VariableNames, 'double')
                                d.Variables = d.VariableNames;
                            end
                        else
                            
                            d.VariableNames = self.GetObject(get(self.ddlVariableNames, 'String'), get(self.ddlVariableNames, 'Value'));
                            if(isa(d.VariableNames(1), 'cell'))
                                d.VariableNames = cellstr(d.VariableNames);
                            else
                                if ~isempty(self.dataset_name) && ~isempty(self.dataset.Variables) && get(self.ddlVariableNames, 'Value') == 2
                                    d.Variables = self.dataset.Variables;
                                    d.VariableNames = d.Variables;
                                else
                                    d.Variables = self.GetObject(get(self.ddlVariableNames, 'String'), get(self.ddlVariableNames, 'Value'));
                                    d.VariableNames = d.Variables;
                                end
                            end
                            
                        end

                    end
                    
%                     if get(self.ddlVariables, 'Value') > 1
%                         
%                         if ~isempty(self.dataset_name) && ~isempty(self.dataset.Variables) && get(self.ddlVariables, 'Value') == 2
%                             d.Variables = self.dataset.Variables;
%                         else
%                             d.Variables = self.GetObject(get(self.ddlVariables, 'String'), get(self.ddlVariables, 'Value'));
%                         end
%                     end
                    
                    if get(self.ddlObjectNames, 'Value') > 1
                        
                        if ~isempty(self.dataset_name) && ~isempty(self.dataset.ObjectNames) && get(self.ddlObjectNames, 'Value') == 2
                            d.ObjectNames = self.dataset.ObjectNames;
                        else
                            d.ObjectNames = self.GetObject(get(self.ddlObjectNames, 'String'), get(self.ddlObjectNames, 'Value'));
                            if(isa(d.ObjectNames(1), 'cell'))
                                d.ObjectNames = cellstr(d.ObjectNames);
                            end
                            
                        end
                        
                    end
                    
                    if get(self.ddlClassLabels, 'Value') > 1
                        
                        if ~isempty(self.dataset_name) && ~isempty(self.dataset.ClassLabels) && get(self.ddlClassLabels, 'Value') == 2
                            d.ClassLabels = self.dataset.ClassLabels;
                        else
                            d.ClassLabels = self.GetObject(get(self.ddlClassLabels, 'String'), get(self.ddlClassLabels, 'Value'));
                            if(isa(d.ClassLabels(1), 'cell'))
                                d.ClassLabels = cellstr(d.ClassLabels);
                            end
                            
                        end
                        
                    end
                    
                    if(~isempty(self.dataset))
                        d.Centering = self.dataset.Centering;
                        d.Scaling = self.dataset.Scaling;
                    end
                    
                    try
                        s = regexprep(name, '[^a-zA-Z0-9_]', '_');

                        if(~isempty(regexp(s,'^\d+', 'once')))
                            s = ['dataset_' s];
                        end
                        
                        if(~isempty(regexp(s,'^_+', 'once')))
                            s = ['dataset_' s];
                        end
                        
                        d.Name = s;
                        name = s;
                        
                        
                        %addlistener(d,'Deleting',@self.parent.parent.handleDatasetDelete);
                        assignin('base', name, d);
                        
                        %dd = evalin('base', d.Name);
                        
                        
                    catch
                        waitfor(errordlg('The name contains invalid characters. Please use only latin characters, numbers and underscore for the name of DataSet!','Error', opts));
                        ok = false;
                    end
                    
                    if ok

                        if isempty(self.dataset_name)
                            evtdata = DatasetCreatedEventData(name, false);
                            self.parent.DataSetWindowCloseCallback(self,evtdata);
                        else
                            evtdata = DatasetCreatedEventData(name, true);
                            self.parent.DataSetWindowCloseCallback(self,evtdata);
                        end
                    end
                    
                else
                    waitfor(errordlg('You should indicate at least Data matrix!','Error', opts));
                    ok = false;
                end
                
            else
                waitfor(errordlg('You should indicate a name of the DataSet!','Error', opts));
                ok = false;
                %return;
            end
            
            if ok
                close;
            end
        end
        
    end
    
end


