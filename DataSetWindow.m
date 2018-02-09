classdef  DataSetWindow<handle
    properties
        tbName;
        ddlData;
        ddlClasses;
        ddlObjectNames;
        ddlVariableNames;
        ddlVariables;
        ddlClassLabels;
        
        Name;
        Data;
        Classes;
        ObjectNames;
        VariableNames;
        Wavelengths;
        ClassLabels;
    end
    
    methods
        
        function win = DataSetWindow()
            
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
                'Units', 'normalized','Value',1, 'Position', [0.35 0.85 0.55 0.05], 'BackgroundColor', 'white', 'callback', @DataTab.Check_Name);
            
            
            
            
            uicontrol('Parent', input_win, 'Style', 'text', 'String', 'Data', ...
                'Units', 'normalized','Position', [0.05 0.75 0.35 0.05], 'HorizontalAlignment', 'left');
            win.ddlData = uicontrol('Parent', input_win, 'Style', 'popupmenu',...
                'String', {'-'}, ...
                'Units', 'normalized','Value',1, 'Position', [0.35 0.75 0.55 0.05], 'BackgroundColor', 'white', 'callback', @DataSetWindow.Callback_Data);
            
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
                'Units', 'normalized','Value',1, 'Position', [0.35 0.65 0.55 0.05], 'BackgroundColor', 'white', 'callback', @DataSetWindow.Callback_Classes);
            
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
            
            
            
            data = guidata(gcf);
            data.win = win;
            guidata(gcf, data);
        end
        
    end
    
    events
        DataUpdated
    end
    
    methods (Static)
        
        function r = type_size_filter(x, k, n, k2, n2, t)
            s = x.size;
            if isequal(x.class,t) && ((~isempty(k) && ~isempty(n) && s(n) == k || isempty(k) && isempty(n))) && (~isempty(k2) && ~isempty(n2) && (k2 >=1 && s(n2) == k2 || k2 == -1 && s(n2) > 1) || isempty(k2) && isempty(n2))
                r = true;
            else
                r = false;
            end
        end
        
        
        function Callback_Data(obj, ~)
            
            list = evalin('base','whos');
            
            
            data = guidata(obj);
            
            win = data.win;
            
            K = get(win.ddlData, 'Value');
            
            if K > 1
                ll = get(win.ddlData, 'String');
                mm = ll{K};
                t = evalin('base',mm(1:strfind(mm, ' ')-1));
                gg = size(t);
                idx = arrayfun(@(x)DataSetWindow.type_size_filter(x,gg(1),1,1,2,'double'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(win.ddlClasses, 'String', vardisplay);
                    if length(get(win.ddlClasses, 'String')) > 1
                        set(win.ddlClasses, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)DataSetWindow.type_size_filter(x,gg(1),1,1,2,'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(win.ddlObjectNames, 'String', vardisplay);
                    if length(get(win.ddlObjectNames, 'String')) > 1
                        set(win.ddlObjectNames, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)DataSetWindow.type_size_filter(x,gg(2),1,[],[],'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(win.ddlVariableNames, 'String', vardisplay);
                    if length(get(win.ddlVariableNames, 'String')) > 1
                        set(win.ddlVariableNames, 'Value', 2)
                    end
                end
                
                idx = arrayfun(@(x)DataSetWindow.type_size_filter(x,gg(2),1,[],[],'double'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(win.ddlClasses, 'String', vardisplay);
                    if length(get(win.ddlClasses, 'String')) > 1
                        set(win.ddlClasses, 'Value', 2)
                    end
                end
                
            else
                set(win.ddlClasses, 'String', {'-'});
                set(win.ddlVariableNames, 'String', {'-'});
                set(win.ddlObjectNames, 'String', {'-'});
                set(win.ddlClassLabels, 'String', {'-'});
                set(win.ddlVariables, 'String', {'-'});
                
                set(win.ddlVariableNames, 'Value', 1);
                set(win.ddlClasses, 'Value', 1);
                set(win.ddlObjectNames, 'Value', 1);
                set(win.ddlVariables, 'Value', 1);
            end
            
            data.dataset_win = win;
            guidata(obj, data);
            
        end
        
        function Callback_Classes(obj, ~)
            
            list = evalin('base','whos');
            
            
            data = guidata(obj);
            
            win = data.win;
            
            K = get(win.ddlClasses, 'Value');
            if K > 1
                ll = get(win.ddlClasses, 'String');
                mm = ll{K};
                t = evalin('base',mm(1:strfind(mm, ' ')-1));
                cl_num = size(unique(t),1);
                idx = arrayfun(@(x)DataSetWindow.type_size_filter(x,cl_num,1,1,2,'cell'),list);
                
                vardisplay={};
                if sum(idx) > 0
                    l = list(idx);
                    %vardisplay = cell(length(idx)+1,1);
                    vardisplay{1} = '-';
                    for i = 1:length(l)
                        ss = l(i).size;
                        vardisplay{i+1} = sprintf('%s (%dx%d)',l(i).name,ss(1),ss(2));
                    end
                    set(win.ddlClassLabels, 'String', vardisplay);
                end
            else
                set(win.ddlClassLabels, 'String', {'-'});
                if length(get(win.ddlClassLabels, 'String')) > 1
                    set(win.ddlClassLabels, 'Value', 2)
                end
            end
            data.dataset_win = win;
            guidata(obj, data);
            
        end
        
    end
    
end


