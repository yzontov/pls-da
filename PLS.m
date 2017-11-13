classdef PLS < handle
    %PLS decomposition class
    
    properties
        XScores;
        XLoadings;
        YScores;
        Weights
    end
    
    methods
        
        function obj = PLS(X,Y,NumPC)
            [obj.XScores,obj.XLoadings,obj.YScores,obj.Weights]=plsnipals(X,Y,NumPC);
        end
        
    end
    
    methods (Access = private)
        
        function [T,P,Q,W]=plsnipals(X,Y,A)
            %+++ The NIPALS algorithm for both PLS-1 (a single y) and PLS-2 (multiple Y)
            %+++ X: n x p matrix
            %+++ Y: n x m matrix
            %+++ A: number of latent variables
            %+++ Code: Hongdong Li, lhdcsu@gmail.com, Feb, 2014
            %+++ reference: Wold, S., M. Sj?str?m, and L. Eriksson, 2001. PLS-regression: a basic tool of chemometrics,
            %               Chemometr. Intell. Lab. 58(2001)109-130.
            
            for i=1:A
                error=1;
                u=Y(:,1);
                niter=0;
                while (error>1e-8 && niter<1000)  % for convergence test
                    w=X'*u/(u'*u);
                    w=w/norm(w);
                    t=X*w;
                    q=Y'*t/(t'*t);  % regress Y against t;
                    u1=Y*q/(q'*q);
                    error=norm(u1-u)/norm(u);
                    u=u1;
                    niter=niter+1;
                end
                p=X'*t/(t'*t);
                X=X-t*p';
                Y=Y-t*q';
                
                %+++ store
                W(:,i)=w;
                T(:,i)=t;
                P(:,i)=p;
                Q(:,i)=q;
                
            end
            
            %+++
        end
        
        %         function plotScores(self, type)% - Scores (scatter, bar, line)
        %         end
        %
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
