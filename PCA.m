classdef PCA < handle
    %PCA decomposition class
    
    properties
        Scores;% - (nObj x nComp)
        Loadings;% - (nVar x nComp)
        %         Q;% - (nObj x nComp) c Q residuals
        %         T2;% - (nObj x nComp) c T2 residuals
        %         ExpVar;% - (1 x nComp) c explained variance
        Eigenvalues%; - (1 x nComp) c eigenvalues
    end
    
    methods
        
        function obj = PCA(X, NumPC)
            [V,D,P] = svd(X);
            T = V*D;
            obj.Scores = T(:,1:NumPC);
            obj.Loadings = P(:,1:NumPC);
            obj.Eigenvalues = D(1:NumPC,1:NumPC);
        end
        %
        %         function fig = plotScores(self, type)% - Scores (scatter, bar, line)
        %         end
        
        %         function plotExpvar(self, type)% - explained variance (bar, line)
        %         end
        %
        %         function plotCumExpvar(self, type)% - cumulative explained variance (bar, line)
        %         end
        %
        %         function plotResiduals(self)% -  Q vs T2 residuals
        %         end
        %
        %         function summary(self)
        %         end
    end
    
end
