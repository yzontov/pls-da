function test()

clc
clear
close all
load juices

Y = dummy(Classes);

Alpha = 0.05;
Gamma = 0.01;
%Gamma = [];

Xnew = [];
LabelsNew = [];
plsPC = 12;

%plsda(X, Y, Labels, Alpha, Gamma, X, Labels);
%plsda(plsPC, X, Y(:,1:2), Labels, Alpha, Gamma, Xnew, LabelsNew);
plsda(plsPC, X, Y, Labels, Alpha, Gamma, Xnew, LabelsNew);

end

function Y = dummy(classes)

class_number = max(classes);
Y = zeros(length(classes), class_number);
for cl = 1:class_number
    Y(:,cl) = (classes == cl);
    
end

end