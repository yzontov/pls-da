d = dir; 
for i=1:length(d) 
str{i,1} = d(i).name; 
str{i,2} = d(i).date; 
str{i,3} = d(i).bytes; 
str{i,4} = d(i).isdir; 
[dummy,dummy,ext] = fileparts ( d(i).name ); 
str{i,5} = strcmp ( ext, '.m' ); 
end 
% create the uimulticollist 
h=uimulticollist ( 'units', 'normalized', 'position', [0 0 1 1], 'string', str ); 
% 
% now add a header 
header = { 'ObjectName' 'Class 1' 'Class2' 'isDir' 'isMFile' }; 
uimulticollist ( h, 'addRow', header, 1 ) 


