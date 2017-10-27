classdef LDECOMP < handle
    %LDECOMP class
    
    properties
        Scores;% - матрица (nObj x nComp) со счетами
        Loadings;% - матрица (nVar x nComp) с нагрузками
        Q;% - матрица (nObj x nComp) c Q residuals
        T2;% - матрица (nObj x nComp) c T2 residuals
        ExpVar;% - вектор (1 x nComp) c explained variance
        Eigenvalues%; - вектор (1 x nComp) c eigenvalues
    end
    
    methods
        
        function obj = LDECOMP(X)% - показывает график со счетами (scatter, bar, line)
            
        end
        
        function plotScores(self)% - показывает график со счетами (scatter, bar, line)
        end
        
        function plotExpvar(self)% - показывает график со explained variance (bar, line)
        end
        
        function plotCumExpvar(self)% - показывает график со cumulative explained variance (bar, line)
        end
        
        function plotResiduals(self)% - показывает график c Q vs T2 residuals
        end
        
        function summary(self)% - показывает суммарную статистику по результатам
        end
    end
    
end
