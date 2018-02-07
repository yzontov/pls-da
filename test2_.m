function test2_



% clc
% clear
% close all
% load juices

K = [38,1];
n = 1;
list = evalin('base','whos');
%arrayfun(@(x)fun(x,K),list)
{list(arrayfun(@(x)fun(x,K(n),n),list)).Name}


end


function r = fun(x, k, n)
    s = x.size;
    if isequal(x.class,'double') && s(n) == k
        r = true;
    else
        r = false;
    end
    
end
