classdef PLSDAModel < handle
    %PLSDAModel class
    
    properties
        Distances_Hard;
        Distances_Soft;
    end
    
    methods
        
        function obj = PLSDAModel(TraningDataSet, numPC, Alpha, Gamma)
            
        end
        
        function Rebuild(self)
            
        end
        
        function Result = Apply(self, NewDataSet)%Xnew, ObjectNames)
            
        end
        
        function fig = HardPLSDAPlot(self)
            
        end
        
        function fig = SoftPLSDAPlot(self)

        end
        
        function fig = Plot(self, pc1, pc2)

        end
    end
    
    methods (Access = private)
        
        function [mark, color] = plotsettings(class_number)
            mark = cell(1,class_number);
            color = cell(1,class_number);
            marks = 'osd*+.x^v><ph';
            mark_idx = 1;
            color_idx = 0;
            n_marks = length(marks);
            colors = 'rgbmcyk';
            n_colors = length(colors);
            for idx = 1:class_number
                
                color_idx = color_idx + 1;
                if color_idx > n_colors
                    color_idx = 1;
                    mark_idx = mark_idx + 1;
                    if mark_idx > n_marks
                        error('Too many classes');
                    end
                end
                
                mark{idx} = marks(mark_idx);
                color{idx} = colors(color_idx);
                
            end
        end
        
        function r = chi2cdf_(val, dof)
            %Chi-square cumulative distribution function.
            
            %if exist('chi2cdf', 'file')
            %    r = chi2cdf(val, dof);
            %else
            %If Statistics Toolbox is absent
            x1 = val;
            n = dof;
            
            if n<=0 || x1<0
                error('!!!');
            end
            
            if n > 140
                x=sqrt(2*x1)-sqrt(2*n-1);
                P=normcdf_(x);
                r = P;
                return;
            end
            
            x=sqrt(x1);
            if mod(n,2) == 0
                %if n is even
                a=1;
                P=0;
                for i=1:(n-2)/2
                    a = a*x*x/(i*2);
                    P = P + a;
                end
                P = P + 1;
                P = P*exp(-x*x/2);
            else
                %if n is odd
                a=x;
                P=x;
                for i=2:(n-1)/2
                    a = a*x*x/(i*2-1);
                    P = P + a;
                end
                if n==1
                    P=0;
                else
                    P = P*exp(-x*x/2)*2/sqrt(2*pi);
                end
                P = P + 2*(1-normcdf_(x));
            end
            r = 1-P;
        end
        
        function r = chi2inv_(p, dof)
            %Inverse of the chi-square cumulative distribution function (cdf).
            
            %if exist('chi2inv', 'file')
            %    r = chi2inv(p, dof);
            %else
            %If Statistics Toolbox is absent
            n = dof;
            
            if n<=0 || p<0 || p>1
                error('wrong probability value!!');
            end
            
            if p==0
                r = 0;
                return;
            end
            
            if p==1
                r = inf;
                return;
            end
            
            z = norminv_(p);
            dTemp1=2/9/n;
            dTemp=1-dTemp1+z*sqrt(dTemp1);
            
            if dTemp>0
                dTemp1=dTemp*dTemp*dTemp;
                f=n*dTemp1;
            else
                dTemp1=z+sqrt(2*n-1);
                dTemp=dTemp1*dTemp1;
                f=0.5*dTemp;
            end
            if(f < 0)
                error('!!!');
            end
            
            p1 = chi2cdf_(f, n);
            if (abs(p1 - p) < 1e-8)
                r = f;
                return;
            end
            h = 0.01;
            if p1>p
                h=-0.01;
            end
            
            flag = true;
            while flag
                
                z=f+h;
                if z<=0
                    break;
                end
                h = h*2;
                p1=chi2cdf_(z,n);
                
                flag = (p1-p)*h<0;
            end
            
            if (abs(p1 - p) < 1e-8)
                r = z;
                return;
            end
            
            if z<=0
                z=0;
            end
            
            if f<z
                x1=f;
                x2=z;
            else
                x1=z;
                x2=f;
            end
            
            for i=0:50000
                f=(x1+x2)/2.0;
                p1=chi2cdf_(f,n);
                
                if abs(p1-p)<0.001*p*(1-p)&& abs(x1-x2)<0.0001*abs(x1)/(abs(x1)+abs(x2))
                    break;
                end
                
                if p1<p
                    x1=f;
                else
                    x2=f;
                end
            end
            
            r = f;
        end
        
        function r = normcdf_(x)
            %Normal cumulative distribution function (cdf).
            
            %if exist('normcdf', 'file')
            %    r = normcdf(x);
            %else
            %If Statistics Toolbox is absent
            t = 1 /(1 + abs(x)*0.2316419);
            P = 1 - (exp(-x*x/2)/sqrt(2*pi))*t*((((1.330274429*t-1.821255978)*t+1.781477937)*t-0.356563782)*t+0.31938153);
            if x <= 0
                P = 1 - P;
            end
            r = P;
        end
        
        function r = norminv_(P)
            %Inverse of the normal cumulative distribution function (cdf).
            
            %if exist('norminv', 'file')
            %    r = norminv(val);
            %else
            %If Statistics Toolbox is absent
            if P>=1 || P<=0
                error('!!!');
            end
            
            q=P;
            if P>=0.5
                q=1-P;
            end
            t=sqrt(log(1/(q*q)));
            t2=t*t;
            t3=t2*t;
            xp=t-(2.515517+t*0.802853+t2*0.010328)/(1+t*1.432788+t2*0.189269+t3*0.001308);
            if P>=0.5
                r = xp;
            else
                r = -xp;
            end
            
        end
        
        function hard_plot(w,v,t0,K,Centers)
            delta = 1.5;
            
            x_min = t0(1) - delta;
            x_max = t0(1) + delta;
            
            class_borders_ind = sortrows(combnk(1:K,2));
            if K > 2
                
                for i = 1:size(class_borders_ind, 1)
                    cl = class_borders_ind(i,:);
                    wij = w(cl(1),:)-w(cl(2),:);
                    vij = v(cl(1))-v(cl(2));
                    y_min = -(x_min*wij(1) - vij)/wij(2);
                    y_max = -(x_max*wij(1) - vij)/wij(2);
                    middle = (Centers(cl(1),:) + Centers(cl(2),:))/2;
                    min_dis = (x_min - middle(1))^2 + (y_min - middle(2))^2;
                    max_dis = (x_max - middle(1))^2 + (y_max - middle(2))^2;
                    if min_dis < max_dis
                        x = x_min;
                        y = y_min;
                    else
                        x = x_max;
                        y = y_max;
                    end
                    plot([t0(1) x],[t0(2) y], '-k');
                end
                
            else
                wij = w(1,:)-w(2,:);
                vij = v(1)-v(2);
                y_min = -(x_min*wij(1) - vij)/wij(2);
                y_max = -(x_max*wij(1) - vij)/wij(2);
                plot([ x_min t0(1)],[ y_min t0(2)], '-k');
                plot([t0(1) x_max],[t0(2) y_max], '-k');
            end
            
        end
        
        function soft_plot(YpredT, Y,Centers,color, Alpha, numPCpca, Gamma, K)
            AcceptancePlot = cell(3,1);
            OutliersPlot = cell(3,1);
            for class = 1:K
                [AcceptancePlot{class}, OutliersPlot{class}] = soft_classes_plot(YpredT(Y(:,class) == 1,:), Centers(class,:), Alpha, numPCpca, Gamma, K);
                plot(AcceptancePlot{class}(:,1), AcceptancePlot{class}(:,2),['-' color{class}]);
                if ~isempty(Gamma)
                    plot(OutliersPlot{class}(:,1), OutliersPlot{class}(:,2),['--' color{class}]);
                end
                temp_c =Centers(class,:);
                plot(temp_c(:,1), temp_c(:,2),['+' color{class}]);
            end
        end
        
        function [AcceptancePlot, OutliersPlot] =soft_classes_plot(pcaScoresK, Center, Alpha, numPC, Gamma, K)
            
            len = size(pcaScoresK,1);
            cov = inv(((pcaScoresK-repmat(Center, len, 1))'*(pcaScoresK-repmat(Center, len, 1)))/len);
            [~, P, Eig] = decomp(cov, numPC);
            P = -P;%!!!!!!
            SqrtSing = diag(sqrt(Eig))';
            
            fi = zeros(1,91);
            
            for i = 2:91
                fi(i) = pi/45 + fi(i-1);
            end
            
            xy = bsxfun(@rdivide, [cos(fi)' sin(fi)'], SqrtSing);
            J = 1:size(xy,1);
            pc = cell2mat(arrayfun(@(i) xy(i,:)*P, J.','UniformOutput', false));
            sqrtchi = sqrt(chi2inv_(1-Alpha, 2));
            AcceptancePlot = pc*sqrtchi + repmat(Center, size(xy,1), 1);
            
            if ~isempty(Gamma)
                Dout = sqrt(chi2inv_((1-Gamma)^(1/len), K-1));
                OutliersPlot = pc*Dout + repmat(Center, size(xy,1), 1);
            else
                OutliersPlot = [];
            end
            
        end
        
        function m = confusionMatrix(Y,Distances,mode, Alpha)
            
            [I,K] = size(Distances);
            
            if nargin == 3 && mode == 0
                Alpha = 0;
            end
            
            if nargin == 4 && mode == 1
                Dcrit = chi2inv_(1-Alpha, K-1);
            end
            
            
            m = zeros(K);
            Ypred = zeros(size(Distances));
            
            for i = 1:I
                for k = 1:K
                    if mode == 0
                        if Distances(i,k) == min(Distances(i,:))
                            Ypred(i,k) = 1;
                            if(Y(i,k) == 1)
                                m(k,k) = m(k,k) + 1;
                            end
                        end
                    else
                        if mode == 1
                            if Distances(i,k) < Dcrit
                                Ypred(i,k) = 1;
                                if(Y(i,k) == 1)
                                    m(k,k) = m(k,k) + 1;
                                end
                            end
                        end
                    end
                end
            end
            
            tmp = Ypred - Y;
            [rows_t, ~] = find(tmp == -1);
            [rows1, incorr] = find(tmp(rows_t,:) == 1);
            [~, corr] = find(tmp(rows_t,:) == -1);
            
            for i = 1:length(rows1)
                m(corr(rows1(i)), incorr(i)) = m(corr(rows1(i)), incorr(i)) + 1;
            end
            
            if mode == 1
                tmp = Ypred - 2*Y;
                
                [rows_t, ~] = find(tmp == -1);
                [rows1, incorr] = find(tmp(rows_t,:) == 1);
                [~, corr] = find(tmp(rows_t,:) == -1);
                
                for i = 1:length(rows1)
                    m(corr(rows1(i)), incorr(i)) = m(corr(rows1(i)), incorr(i)) + 1;
                end
            end
            
        end
        
        function r = FoM(ConfusionMatrix, Ik)
            r.TP = diag(ConfusionMatrix)';
            r.FP = sum(ConfusionMatrix - diag(diag(ConfusionMatrix)));
            CSNS = r.TP./Ik;
            r.CSNS = 100*CSNS;
            CSPS = 1 - r.FP./(sum(Ik)-r.TP);
            r.CSPS = 100*CSPS;
            r.CEFF = 100*sqrt(CSNS.*CSPS);
            TSNS = sum(r.TP)/sum(Ik);
            r.TSNS = 100*TSNS;
            TSPS = 1 - sum(r.FP)/sum(Ik);
            r.TSPS = 100*TSPS;
            r.TEFF = 100*sqrt(TSNS*TSPS);
        end
        
        function allocation_hard(Labels, Dist)
            m = max(cellfun(@length, Labels));
            format = ['%-' sprintf('%d', m) 's\t'];
            
            fprintf('Decision Hard\n');
            [I,K] = size(Dist);
            fprintf(format, ' ');
            fprintf('\t%d', 1:K);
            fprintf('\n');
            for i = 1:I
                fprintf(format, Labels{i});
                for k = 1:K
                    if Dist(i,k) == min(Dist(i,:))
                        fprintf('\t*');
                    else
                        fprintf('\t ');
                    end
                end
                fprintf('\n');
            end
            fprintf('\n\n');
        end
        
        function allocation_soft(Labels, Alpha, Dist)
            m = max(cellfun(@length, Labels));
            format = ['%-' sprintf('%d', m) 's\t'];
            
            fprintf('Decision Soft\n');
            [I,K] = size(Dist);
            Dcrit = chi2inv_(1-Alpha, K-1);
            
            fprintf(format, ' ');
            fprintf('\t%d', 1:K);
            fprintf('\n');
            for i = 1:I
                fprintf(format, Labels{i});
                for k = 1:K
                    if Dist(i,k) < Dcrit
                        fprintf('\t*');
                    else
                        fprintf('\t ');
                    end
                end
                fprintf('\n');
            end
            fprintf('\n\n');
        end
        
    end
    
end

