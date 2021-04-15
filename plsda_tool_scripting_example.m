function ret = plsda_tool_scripting_example()

%add path to classes subfolder
addpath('classes');

%load data
clc
clear
close all
load plsda_tool_demo

%Create dataset for training
d = DataSet();
d.RawData = data_train;
d.Centering = true;
d.Scaling = true;
d.Classes = classes_train;
d.ObjectNames = names_train;
d.Variables = wavelengths;
d.VariableNames = wavelengths;
d.SelectedSamples = ones(size(classes_train));
d.ClassLabels = class_labels;

%and for test purpose
d1 = DataSet();
d1.RawData = data_test;
d1.ObjectNames = names_test;

%setup the model
plsPC = 12;
Alpha = 0.05;
Gamma = 0.01;

m = PLSDAModel(d,plsPC,Alpha,Gamma);% Soft PLS-DA by default
m.Name = 'm';
m.TrainingDataSet.Name = 'test';
%Uncomment the following 2 lines to use the Hard PLS-DA mode:
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

ret = m;

end
