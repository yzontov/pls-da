function PLSDAGUI(varargin)

ShowStartScreen();






function ShowStartScreen()

%get version year
v = version('-release');
vyear = str2double(v(1:4));

if vyear < 2014
    screensize = get( 0, 'Screensize' );
else
    screensize = get( groot, 'Screensize' );
end    
    
start_screen = figure;
set(start_screen,'Visible','on');
set(start_screen, 'MenuBar', 'none');
set(start_screen, 'ToolBar', 'none');
set(start_screen,'name','PLS-DA Tool','numbertitle','off');
set(start_screen, 'Resize', 'off');
set(start_screen, 'Position', [screensize(3)/2 - 100 screensize(4)/2 - 100 200 200]);

uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'New model',...
    'Position', [50 140 100 30], 'callback', @btnNewModel_Callback);

uicontrol('Parent', start_screen, 'Style', 'pushbutton', 'String', 'Existing model',...
    'Position', [50 100 100 30], 'callback', @btnExistingModel_Callback);

end

function btnNewModel_Callback(obj, ~)

close(get(obj,'Parent'));

win = GUIWindow([1 1 1]);


end

function btnExistingModel_Callback(obj, ~)

[tvar, tvarname] = GUIWindow.uigetvariables({'Pick a PLSDAModel object:'}, ...
    'ValidationFcn',{@(x) isa(x, 'PLSDAModel')});
if ~isempty(tvar)
    close(get(obj,'Parent'));
    
    win = GUIWindow([1 1 0]);
end

end



end



