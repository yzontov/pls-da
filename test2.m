function test2

clc
clear
close all
load juices

K = [38,1];
list = whos;
list(arrayfun(@(x)fun(x,K),list)).name


end

function r = fun(x, k)
    s = x.size;
    if isequal(x.class,'double') && s(1) == k(1) && s(2) == k(2)
        r = true;
    else
        r = false;
    end
    
end