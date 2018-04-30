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
        
        win;
        datatab;
        
        Name;
        Data;
        Classes;
        ObjectNames;
        VariableNames;
        Wavelengths;
        ClassLabels;
    end
    
    methods
        
        function win = DataSetWindow(parent)
            
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
            set(input_win,'Visible','on');
            set(input_win, 'MenuBar', 'none');
            set(input_win, 'ToolBar', 'none');
            set(input_win,'name','Create New DataSet','numbertitle','off');
            set(input_win, 'Resize', 'off');
            set(input_win, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 300 400]);
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Name', ...
                'Units', 'normalized','Position', [0.05 0.85 0.35 0.05], 'HorizontalAlignment', 'left');
            win.tbName = uicontrol('Parent', input_win, 'Style', 'edit', 'String', '', ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.85 0.55 0.05], 'BackgroundColor', 'white');
            
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Data', ...
                'Units', 'normalized','Position', [0.05 0.75 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlData = uicontrol('Parent', input_win, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.75 0.55 0.05], 'BackgroundColor', 'white', 'callback', @win.Callback_Data);
            
            allvars = evalin('base','whos');
            varnames = {allvars.name};
            varsizes = {allvars.size};
            
            idx = find(cellfun(@(x)isequal(x,'double'),{allvars.class}));
            
            if ~isempty(idx)
                vardisplay = {};%cell(length(idx)+1,1);
                vardisplay{1} = '-';
                k = 2;
                for i = 1:length(idx)
                    ss = varsizes{idx(i)};
                    if(ss(2) > 1)
                        vardisplay{k} = sprintf('%s (%dx%d)',varnames{idx(i)},ss(1),ss(2));
                        k = k+1;
                    end
                end
                set(win.ddlData, 'String', vardisplay);
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
            
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Wavelengths', ...
                'Units', 'normalized','Position', [0.05 0.25 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlVariables = uicontrol('Parent', input_win, 'Style', 'popupmenu', 'String', {'-'},...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.25 0.55 0.05], 'BackgroundColor', 'white');
            
            uicontrol('Parent', input_win, 'Style', 'pushbutton', 'String', 'Add dataset',...
                'Units', 'Normalized', 'Position', [0.3 0.07 0.4 0.1], ...
                'callback', @win.btnAdd_Callback);
            
            win.win = input_win;
            %             data = guidata(gcf);
            %             data.win = win;
            %             guidata(gcf, data);
        end
        
        function obj = GetObject(self, list, idx)
            mm = list{idx};
            obj = evalin('base',mm(1:strfind(mm, ' ')-1));
        end
        
    end
    
    events
        DataUpdated
    end
    
    methods
        
        function r = type_size_filter(self, x, k, n, k2, n2, t)
            s = x.size;
            if isequal(x.class,t) && ((~isempty(k) && ~isempty(n) && s(n) == k || isempty(k) && isempty(n))) && (~isempty(k2) && ~isempty(n2) && (k2 >=1 && s(n2) == k2 || k2 == -1 && s(n2) > 1) || isempty(k2) && isempty(n2))
                r = true;
            else
                r = false;
            end
        end
        
        
        function Callback_Data(self,obj, ~)
            
            list = evalin('base','whos');
            
            K = get(self.ddlData, 'Value');
            
            if K > 1
                ll = get(self.ddlData, 'String');
                mm = ll{K};
                t = evalin('base',mm(1:strfind(mm, ' ')-1));
                gg = size(t);
                idx = arrayfun(@(x)self.type_size_filter(x,gg(1),1,1,2,'double'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(self.ddlClasses, 'String', vardisplay);
                    if length(get(self.ddlClasses, 'String')) > 1
                        set(self.ddlClasses, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)self.type_size_filter(x,gg(1),1,1,2,'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(self.ddlObjectNames, 'String', vardisplay);
                    if length(get(self.ddlObjectNames, 'String')) > 1
                        set(self.ddlObjectNames, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)self.type_size_filter(x,gg(2),1,[],[],'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(self.ddlVariableNames, 'String', vardisplay);
                    if length(get(self.ddlVariableNames, 'String')) > 1
                        set(self.ddlVariableNames, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)self.type_size_filter(x,gg(2),1,[],[],'double'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(self.ddlClasses, 'String', vardisplay);
                    if length(get(self.ddlClasses, 'String')) > 1
                        set(self.ddlClasses, 'Value', 2)
                    end
                end
                
            else
                set(self.ddlClasses, 'String', {'-'});
                set(self.ddlVariableNames, 'String', {'-'});
                set(self.ddlObjectNames, 'String', {'-'});
                set(self.ddlClassLabels, 'String', {'-'});
                set(self.ddlVariables, 'String', {'-'});
                
                set(self.ddlVariableNames, 'Value', 1);
                set(self.ddlClasses, 'Value', 1);
                set(self.ddlObjectNames, 'Value', 1);
                set(self.ddlVariables, 'Value', 1);
            end
            
        end
        
        function Callback_Classes(self,obj, ~)
            
            list = evalin('base','whos');
            
            K = get(self.ddlClasses, 'Value');
            if K > 1
                ll = get(self.ddlClasses, 'String');
                mm = ll{K};
                t = evalin('base',mm(1:strfind(mm, ' ')-1));
                cl_num = size(unique(t),1);
                idx = arrayfun(@(x)self.type_size_filter(x,cl_num,1,1,2,'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(self.ddlClassLabels, 'String', vardisplay);
                end
            else
                set(self.ddlClassLabels, 'String', {'-'});
                if length(get(self.ddlClassLabels, 'String')) > 1
                    set(self.ddlClassLabels, 'Value', 2)
                end
            end
            
        end
        
        function btnAdd_Callback(self,obj, ~)
            
            name = get(self.tbName, 'String');
            
            if ~isempty(name)
                
                if get(self.ddlData, 'Value') > 1 && get(self.ddlClasses, 'Value') > 1
                    d = DataSet();
                    d.RawData = self.GetObject(get(self.ddlData, 'String'), get(self.ddlData, 'Value'));
                    d.Name = name;
                    
                    d.Classes = self.GetObject(get(self.ddlClasses, 'String'), get(self.ddlClasses, 'Value'));
                    
                    if get(self.ddlVariableNames, 'Value') > 1
                        d.VariableNames = self.GetObject(get(self.ddlVariableNames, 'String'), get(self.ddlVariableNames, 'Value'));
                    end
                    
                    if get(self.ddlVariables, 'Value') > 1
                        d.Variables = self.GetObject(get(self.ddlVariables, 'String'), get(self.ddlVariables, 'Value'));
                    end
                    
                    if get(self.ddlObjectNames, 'Value') > 1
                        d.ObjectNames = self.GetObject(get(self.ddlObjectNames, 'String'), get(self.ddlObjectNames, 'Value'));
                    end
                    
                    if get(self.ddlClassLabels, 'Value') > 1
                        d.ClassLabels = self.GetObject(get(self.ddlClassLabels, 'String'), get(self.ddlClassLabels, 'Value'));
                    end
                    
                    try
                        assignin('base', name, d)
                    catch
                        errordlg('The invalid characters have been replaced. Please use only latin characters, numbers and underscore for the name of DataSet!');
                        d.Name = name;
                        assignin('base',regexprep(name, '[^a-zA-Z0-9_]', '_'),d);
                        name = regexprep(name, '[^a-zA-Z0-9_]', '_');
                    end
                    
                    evtdata = DatasetCreatedEventData(name);
                    notify(self, 'DataUpdated',evtdata);
                    
                else
                    waitfor(errordlg('You should indicate at least Data and Classes matrices!'));
                end
                
            else
                waitfor(errordlg('You should indicate a name of the DataSet!'));
                %return;
            end
            
            close;
        end
        
    end
    
end


