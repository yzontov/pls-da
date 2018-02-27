function test()

clc
clear
close all
load juices

X = Data;
Y = dummy(Classes);

Alpha = 0.05;
Gamma = 0.01;
%Gamma = [];

Xnew = [];
ObjectNamesNew = [];
plsPC = 12;

%plsda(plsPC, X, Y(:,1:2), ObjectNames, Alpha, Gamma, Xnew, ObjectNamesNew);
plsda(plsPC, X, Y, ObjectNames, Alpha, Gamma, Xnew, ObjectNamesNew);

end

function Y = dummy(classes)

class_number = max(classes);
Y = zeros(length(classes), class_number);
for cl = 1:class_number
    Y(:,cl) = (classes == cl);
    
end

end