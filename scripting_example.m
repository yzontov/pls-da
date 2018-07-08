function scripting_example()

%add path to classes subfolder
addpath('classes');

%load data
clc
clear
close all
load juices

%Create dataset
d = DataSet();
d.RawData = Data;
d.Centering = true;
d.Scaling = true;
d.Classes = Classes;% 3 classes
d.ObjectNames = ObjectNames;

%for test purpose
d1 = DataSet();
d1.RawData = Data(1:10,:);%(Classes == 1,:);
d1.ObjectNames = ObjectNames(1:10);%(Classes == 1,:);

%setup model
plsPC = 12;
Alpha = 0.05;
Gamma = 0.01;

m = PLSDAModel(d,plsPC,Alpha,Gamma);% Soft PLS-DA by default
%m.Mode = 'hard';
%m.Rebuild();

%show results
m.ConfusionMatrix
m.FiguresOfMerit
m.AllocationTable
m.AllocationMatrix
m.Distances

m.Plot();

Res = m.Apply(d1);
Res.Distances
Res.AllocationTable
Res.AllocationMatrix

m.PlotNewSet()

end
