classdef PLSDAModel < handle
    %PLSDAModel class
    
    properties (Access = private)
        numPC_pls;
        numPC_pca;
        
        Distances_Hard;
        Distances_Soft;
        
        rX;
        rY;
        plsW;
        plsP;
        plsQ;
        Lambda;
        
        YpredT;
        YpredP;
        w;
        v;
        t0;
        K;
        Centers;
        
        YpredTnew;
        
        AllocationMatrixNew;
        
        NewDataSetName;
        
        NewDataSetClassLabels;
        NewDataSetClasses;
        NewDataSetObjectNames;
        
        NewDataSetHasClasses;
        
        IsFinalized = false;
    end
    
    properties
        Name = '';
        Mode = 'soft';
        
        TrainingDataSet;
        NumPC;
        
        Finalized = false;
        
        Alpha;
        Gamma;
    end
    
    properties (Dependent = true)
        
        Distances;
        
        ConfusionMatrix;
        FiguresOfMerit;
        AllocationTable;
        AllocationMatrix;
        
    end
    
    methods
        
        function value = get.Distances(self)
            %Distances get
            
            if strcmp(self.Mode, 'hard')
                value = self.Distances_Hard;
            end
            
            if strcmp(self.Mode, 'soft')
                value = self.Distances_Soft;
            end
        end
        
        function value = get.FiguresOfMerit(self)
            %FiguresOfMerit get
            value = PLSDAModel.FoM(self.ConfusionMatrix, sum(self.TrainingDataSet.DummyMatrix()));
        end
        
        function m = get.AllocationTable(self)
            %AllocationTable get
            Labels = cell(size(self.TrainingDataSet.ProcessedData, 1),1);
            for i = 1:size(self.TrainingDataSet.ProcessedData, 1)
                Labels{i} = sprintf('Object No.%d', i);
            end
            
            if(~isempty(self.TrainingDataSet.ObjectNames))
                Labels = self.TrainingDataSet.ObjectNames;
            end
            
            if strcmp(self.Mode, 'hard')
                m = PLSDAModel.allocation_hard(Labels, self.Distances_Hard, unique(self.TrainingDataSet.Classes));
            end
            
            if strcmp(self.Mode, 'soft')
                m = PLSDAModel.allocation_soft(Labels, self.Alpha, self.Distances_Soft, unique(self.TrainingDataSet.Classes));
            end
        end
        
        function m = get.AllocationMatrix(self)
            if strcmp(self.Mode, 'hard')
                m = self.calculateAllocationMatrix(self.Distances_Hard);
            else
                m = self.calculateAllocationMatrix(self.Distances_Soft);
            end
        end
        
        function set.Alpha(self,value)
            %Alpha get/set
            
            self.Alpha = value;
            
        end
        
        function set.TrainingDataSet(self,value)
            %Alpha get/set
            
            self.TrainingDataSet = value;
            self.numPC_pca = self.TrainingDataSet.NumberOfClasses-1;
            
        end
        
        function set.NumPC(self,value)
            %Alpha get/set
            
            self.numPC_pls = value;
            
        end
        
        function m = get.NumPC(self)
            %Alpha get/set
            
            m = self.numPC_pls;
            
        end
        
        function set.Gamma(self,value)
            %Gamma get/set
            self.Gamma = value;
        end
        
        function m = get.ConfusionMatrix(self)
            %ConfusionMatrix get
            if strcmp(self.Mode, 'hard')
                m = PLSDAModel.confusionMatrix(self.TrainingDataSet.DummyMatrix(),self.Distances_Hard,0);
            end
            
            if strcmp(self.Mode, 'soft')
                m = PLSDAModel.confusionMatrix(self.TrainingDataSet.DummyMatrix(),self.Distances_Soft, 1, self.Alpha);
            end
        end
        
        function obj = PLSDAModel(TrainingDataSet, numPC, Alpha, Gamma)
            
            obj.TrainingDataSet = TrainingDataSet;
            obj.numPC_pls = numPC;
            
            obj.numPC_pca = TrainingDataSet.NumberOfClasses-1;
            
            obj.Alpha = Alpha;
            obj.Gamma = Gamma;
            
            obj.Rebuild();
            
        end
        
        function Rebuild(self)
            
            X = self.TrainingDataSet.RawData(logical(self.TrainingDataSet.SelectedSamples),:);
            Y = self.TrainingDataSet.DummyMatrix();
            
            self.rX.Mat = X;
            
            if self.TrainingDataSet.Centering && ~self.TrainingDataSet.Scaling
                self.rX = PLSDAModel.preprocess(0, X);%center
            end
            
            if ~self.TrainingDataSet.Centering && self.TrainingDataSet.Scaling
                self.rX = PLSDAModel.preprocess(1, X);%scale
            end
            
            if self.TrainingDataSet.Centering && self.TrainingDataSet.Scaling
                self.rX = PLSDAModel.preprocess(2, X);%autoscale
            end
            
            self.rY = PLSDAModel.preprocess(0, self.TrainingDataSet.DummyMatrix());%center
            
            self.K = size(Y, 2);
            I = size(Y, 1);
            
            numPCpls = self.numPC_pls;%12;
            numPCpca = self.numPC_pca;%max(2, K - 1);
            
            [plsT,self.plsP,self.plsQ,self.plsW] = PLSDAModel.plsnipals(self.rX.Mat,self.rY.Mat,numPCpls);
            
            Ypred = plsT*self.plsQ';
            
            %Ypred = postprocess(rY, Ypred);
            
            [self.YpredT, self.YpredP, ~] = PLSDAModel.decomp(Ypred, numPCpca);
            
            self.YpredT = -self.YpredT;%!!!!
            self.YpredP = -self.YpredP;%!!!!
            
            %Hard
            E = eye(self.K);
            E = PLSDAModel.preprocess_newset(self.rY, E);
            
            self.Centers = E*self.YpredP;
            
            self.Lambda = (self.YpredT'*self.YpredT);
            
            self.Distances_Hard = zeros(size(Ypred));
            for k = 1:self.K
                for i = 1:I
                    self.Distances_Hard(i,k) = ((self.YpredT(i,:) - self.Centers(k,:))/self.Lambda)*(self.YpredT(i,:) - self.Centers(k,:))';
                end
            end
            
            self.w = self.Centers/self.Lambda;
            self.v = diag(0.5*(self.Centers/self.Lambda)*self.Centers');
            self.t0 = (self.v'*self.YpredP)*self.Lambda;
            
            %Soft
            self.Distances_Soft = zeros(size(Ypred));
            for k = 1:self.K
                for i = 1:I
                    self.Distances_Soft(i,k) = PLSDAModel.mahdis(self.YpredT(i,:), self.Centers(k,:), self.YpredT(Y(:,k) == 1,:));
                end
            end
            
            
        end
        
        function Result = Apply(self, NewDataSet)
            Xnew_p = PLSDAModel.preprocess_newset(self.rX, NewDataSet.RawData(logical(NewDataSet.SelectedSamples),:));
            
            self.NewDataSetName = NewDataSet.Name;
            
            if ~isempty(NewDataSet.ClassLabels)
                self.NewDataSetClassLabels = NewDataSet.ClassLabels;
            else
                self.NewDataSetClassLabels = [];
            end
            
            if isempty(NewDataSet.Classes)
                self.NewDataSetHasClasses = false;
            else
                self.NewDataSetClasses = NewDataSet.Classes;
                self.NewDataSetHasClasses = true;
            end
            
            I = size(Xnew_p, 1);
            
            Wstar=self.plsW*(self.plsP'*self.plsW)^(-1);
            B=Wstar*self.plsQ';
            Ypred_new = Xnew_p*B;
            
            self.YpredTnew = Ypred_new*self.YpredP;
            
            Result.Mode = self.Mode;
            
            %AllocationTable get
            Labels = cell(size(Xnew_p, 1),1);
            for i = 1:size(Xnew_p, 1)
                Labels{i} = sprintf('New object No.%d', i);
            end
            
            if(~isempty(NewDataSet.ObjectNames))
                Labels = NewDataSet.ObjectNames(logical(NewDataSet.SelectedSamples),:);
            end
            
            self.NewDataSetObjectNames = Labels;
            
            Result.Labels = Labels;
            
            if strcmp(self.Mode, 'hard')
                
                Distances_Hard_New = zeros(size(Ypred_new));
                for k = 1:self.K
                    for i = 1:I
                        Distances_Hard_New(i,k) = ((self.YpredTnew(i,:) - self.Centers(k,:))/self.Lambda)*(self.YpredTnew(i,:) - self.Centers(k,:))';
                    end
                end
                
                Result.Distances = Distances_Hard_New;
                Result.AllocationTable = PLSDAModel.allocation_hard(Labels, Distances_Hard_New, unique(self.TrainingDataSet.Classes));
                Result.AllocationMatrix = self.calculateAllocationMatrix(Distances_Hard_New);
                
                self.AllocationMatrixNew = Result.AllocationMatrix;
                
                if ~isempty(NewDataSet.Classes)
                    Result.ConfusionMatrix = PLSDAModel.confusionMatrix(NewDataSet.DummyMatrix(),Distances_Hard_New,0);
                    Result.FiguresOfMerit = PLSDAModel.FoM(Result.ConfusionMatrix, sum(NewDataSet.DummyMatrix()));
                end
            end
            
            if strcmp(self.Mode, 'soft')
                Y = self.TrainingDataSet.DummyMatrix();
                Distances_Soft_New = zeros(size(Ypred_new));
                for k = 1:self.K
                    for i = 1:I
                        Distances_Soft_New(i,k) = PLSDAModel.mahdis(self.YpredTnew(i,:), self.Centers(k,:), self.YpredT(Y(:,k) == 1,:));
                    end
                end
                Result.Distances = Distances_Soft_New;
                Result.AllocationTable = PLSDAModel.allocation_soft(Labels, self.Alpha, Distances_Soft_New, unique(self.TrainingDataSet.Classes));
                Result.AllocationMatrix = self.calculateAllocationMatrix(Distances_Soft_New);
                
                self.AllocationMatrixNew = Result.AllocationMatrix;
                
                if ~isempty(NewDataSet.Classes)
                    trc = unique(self.TrainingDataSet.Classes);
                    tc = unique(NewDataSet.Classes);
                end
                
                if ~isempty(NewDataSet.Classes) && length(trc) == length(tc) && sum(trc == tc) == length(tc)
                    Result.ConfusionMatrix = PLSDAModel.confusionMatrix(NewDataSet.DummyMatrix(),Distances_Soft_New, 1, self.Alpha);
                    Result.FiguresOfMerit = PLSDAModel.FoM(Result.ConfusionMatrix, sum(NewDataSet.DummyMatrix()));
                end
            end
            
        end
        
        function fig = Plot(self, axes, pc1, pc2, show_legend)
            
            if nargin < 4
                pc1 = 1;
                pc2 = 2;
            end
            
            if nargin < 5
                show_legend = 1;
            end
            
            if nargin < 2
                fig = figure;
                axes = gca;
            end
            
            if (self.TrainingDataSet.NumberOfClasses - 1) == 1
                pc2 = 1;
                pc1 = 1;
            end
            
            [mark, ~] = PLSDAModel.plotsettings(self.K);
            color = PLSDAModel.colors_rgb(self.K);
            
            axis(axes,[-1 1 -1 1]);
            hold on
            
            Y = self.TrainingDataSet.DummyMatrix();
            %samples
            names = cell(1,self.K);
            trc = unique(self.TrainingDataSet.Classes);
            for class = 1:self.K
                temp = self.YpredT(Y(:,class) == 1,:);
                if isempty(self.TrainingDataSet.ClassLabels)
                    names{class} = sprintf('class %d', trc(class));
                else
                    names{class} = self.TrainingDataSet.ClassLabels{trc(class)};
                end
                
                if pc1 ~= pc2
                    plot(axes,temp(:,pc1), temp(:,pc2),mark{class},'color', color(class,:));%,'MarkerFaceColor', color{class});
                else
                    plot(axes,temp, zeros(size(temp)),mark{class},'color', color(class,:));
                end
            end
            
            if show_legend
                if ~isempty(axes)
                    legend(axes, names);
                    legend(axes,'location','northeast');
                    legend(axes,'boxon');
                else
                    legend(names);
                    legend('location','northeast');
                    legend('boxon');
                end
            end
            
            Centers_ = [self.Centers(:,pc1) self.Centers(:,pc2)];
            
            if (pc1 == 1 && pc2 == 1)
                Centers_ = self.Centers;
            end
            
            labels = strread(num2str(1:size(self.TrainingDataSet.ProcessedData, 1)),'%s');
            if(~isempty(self.TrainingDataSet.SelectedObjectNames))
                labels = self.TrainingDataSet.SelectedObjectNames;
            end
            
            %hard
            if strcmp(self.Mode, 'hard')
                w_ = [self.w(:,pc1) self.w(:,pc2)];
                v_ = self.v;
                t0_ = [self.t0(pc1) self.t0(pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    w_ = self.w;
                    v_ = self.v;
                    t0_ = self.t0;
                end
                
                YpredT_ = [self.YpredT(:,pc1) self.YpredT(:,pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    YpredT_ = self.YpredT;
                end
                
                PLSDAModel.hard_plot(axes,w_,v_,t0_,self.K,Centers_,self.TrainingDataSet.NumberOfClasses - 1, false);
                
                if isempty(self.TrainingDataSet.ClassLabels)
                    set(axes,'UserData', {YpredT_, labels, self.TrainingDataSet.Classes,[], []});
                else
                    set(axes,'UserData', {YpredT_, labels, self.TrainingDataSet.Classes,[], []});
                end
                
            end
            
            %soft
            if strcmp(self.Mode, 'soft')
                YpredT_ = [self.YpredT(:,pc1) self.YpredT(:,pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    YpredT_ = self.YpredT;
                end
                
                PLSDAModel.soft_plot(axes, YpredT_, Y,Centers_,color, self.Alpha, self.numPC_pca, self.Gamma, self.K, false);
                
                set(axes,'UserData', {YpredT_, labels, self.TrainingDataSet.Classes,[], self.TrainingDataSet.ClassLabels});
                
            end
            
            %center
            %plot(t0(pc1),t0(pc2), '*');

            xlabel(sprintf('PC %d', pc1)); % x-axis label
            ylabel(sprintf('PC %d', pc2));% y-axis label
            
            if ~isempty(self.Name)
                title(['Classification plot. Model: ' self.Name], 'Interpreter', 'none')
            else
                title('Classification plot');
            end
                
            hold off
            
        end
        
        function fig = PlotNewSet(self, axes, pc1, pc2, show_legend)
            
            if nargin < 4
                pc1 = 1;
                pc2 = 2;
            end
            
            if nargin < 5
                show_legend = 1;
            end
            
            if (self.TrainingDataSet.NumberOfClasses - 1) == 1
                pc2 = 1;
                pc1 = 1;
            end
            
            if nargin < 2
                fig = figure;
                axes = gca;
            end
            
            [mark, ~] = PLSDAModel.plotsettings(self.K);
            color = PLSDAModel.colors_rgb(self.K);
            
            axis(axes,[-1 1 -1 1]);
            hold on
            
            Y = self.AllocationMatrixNew;
            %samples
            for class = 1:self.K
                temp = self.YpredTnew(Y(:,class) == 1,:);
                
                if pc1 ~= pc2
                    plot(axes,temp(:,pc1), temp(:,pc2),mark{class},'color', color(class,:),'HandleVisibility','off');
                else
                    plot(axes,temp, zeros(size(temp)),mark{class},'color', color(class,:),'HandleVisibility','off');
                end
            end

            Centers_ = [self.Centers(:,pc1) self.Centers(:,pc2)];
            
            if (pc1 == 1 && pc2 == 1)
                Centers_ = self.Centers;
            end
            
            labels = strread(num2str(1:size(self.NewDataSetObjectNames, 1)),'%s');
            if(~isempty(self.NewDataSetObjectNames))
                labels = self.NewDataSetObjectNames;
            end
            
            %hard
            if strcmp(self.Mode, 'hard')
                w_ = [self.w(:,pc1) self.w(:,pc2)];
                v_ = self.v;
                t0_ = [self.t0(pc1) self.t0(pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    w_ = self.w;
                    v_ = self.v;
                    t0_ = self.t0;
                end
                
                PLSDAModel.hard_plot(axes,w_,v_,t0_,self.K,Centers_,self.TrainingDataSet.NumberOfClasses - 1, show_legend);
                
                YpredTnew_ = [self.YpredTnew(:,pc1) self.YpredTnew(:,pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    YpredTnew_ = self.YpredTnew;
                end
                
                if ~self.NewDataSetHasClasses
                    set(axes,'UserData', {YpredTnew_, labels, [],[],[]});
                else
                    set(axes,'UserData', {YpredTnew_, labels, self.NewDataSetClasses,[], self.TrainingDataSet.ClassLabels});
                end
            end
            
            %soft
            if strcmp(self.Mode, 'soft')
                Y = self.TrainingDataSet.DummyMatrix();
                YpredT_ = [self.YpredT(:,pc1) self.YpredT(:,pc2)];
                YpredTnew_ = [self.YpredTnew(:,pc1) self.YpredTnew(:,pc2)];
                
                if (pc1 == 1 && pc2 == 1)
                    YpredT_ = self.YpredT;
                    YpredTnew_ = self.YpredTnew;
                end
                
                PLSDAModel.soft_plot(axes, YpredT_, Y,Centers_,color, self.Alpha, self.numPC_pca, self.Gamma, self.K, show_legend);
                
                if ~self.NewDataSetHasClasses
                    set(axes,'UserData', {YpredTnew_, labels, [],[], []});
                else
                    set(axes,'UserData', {YpredTnew_, labels, self.NewDataSetClasses,[], []});
                end
                
            end
            
            if show_legend
                
                names = {};
                trc = unique(self.TrainingDataSet.Classes);
                for i=1:self.K
                    if isempty(self.TrainingDataSet.ClassLabels)
                        names{i} = sprintf('class %d', trc(i));
                    else
                        names{i} = self.TrainingDataSet.ClassLabels{trc(i)};
                    end
                end
                
                if ~isempty(axes)
                    legend(axes, names);
                    legend(axes,'location','northeast');
                    legend(axes,'boxon');
                else
                    legend(names);
                    legend('location','northeast');
                    legend('boxon');
                end
            else
                if ~isempty(axes)
                    legend(axes,'off');
                else
                    legend('off');
                end
            end
            
            %center
            %plot(t0(pc1),t0(pc2), '*');
            
            xlabel(sprintf('PC %d', pc1)); % x-axis label
            ylabel(sprintf('PC %d', pc2));% y-axis label
            
            if ~isempty(self.NewDataSetName)
                title(['Prediction plot. Dataset: ' self.NewDataSetName], 'Interpreter', 'none')
            else
                title('Prediction plot');
            end
            
            hold off
            
            
        end
        
    end
    
    methods (Access = private)
        
        function m = calculateAllocationMatrix(self, Distances)
            m = zeros(size(Distances));
            I = size(Distances,1);
            
            if strcmp(self.Mode, 'hard')
                
                for i = 1:I
                    for k = 1:self.K
                        if Distances(i,k) == min(Distances(i,:))
                            m(i,k) = 1;
                        end
                    end
                end
                
            end
            
            if strcmp(self.Mode, 'soft')
                
                Dcrit = PLSDAModel.chi2inv_(1-self.Alpha, self.K-1);
                
                for i = 1:I
                    for k = 1:self.K
                        if Distances(i,k) < Dcrit
                            m(i,k) = 1;
                        end
                    end
                end
            end
        end
        
    end
    
    methods (Static, Access = private)
        
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
                P = P + 2*(1-PLSDAModel.normcdf_(x));
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
            
            z = PLSDAModel.norminv_(p);
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
            
            p1 = PLSDAModel.chi2cdf_(f, n);
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
                p1=PLSDAModel.chi2cdf_(z,n);
                
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
                p1=PLSDAModel.chi2cdf_(f,n);
                
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
        
        function ret = mahdis(t, c, Tk)
            
            m = size(Tk, 1);
            
            nor = t - c;
            centr = bsxfun(@minus, Tk, c);
            centr = centr/sqrt(m);
            
            mat = centr'*centr;
            tmp = (nor/mat)*nor';
            ret = tmp;
            
        end
        
        function res = preprocess_newset(self, XTest1)
            %apply preprocessing defind by the model to the new set
            XTest = XTest1;
            if isfield(self,'Model') && ~isempty(self.Model.TrainingSet_mean)
                XTest = bsxfun(@minus, XTest, self.Model.TrainingSet_mean);
            end
            if isfield(self,'Model') && ~isempty(self.Model.TrainingSet_std)
                XTest = bsxfun(@rdivide, XTest, self.Model.TrainingSet_std);
            end
            res = XTest;
        end
        
        function res = postprocess(self, XTest1)
            %apply preprocessing defind by the model to the new set
            XTest = XTest1;
            if isfield(self,'Model') && ~isempty(self.Model.TrainingSet_std)
                XTest = bsxfun(@times, XTest, self.Model.TrainingSet_std);
            end
            if isfield(self,'Model') && ~isempty(self.Model.TrainingSet_mean)
                XTest = bsxfun(@plus, XTest, self.Model.TrainingSet_mean);
            end
            res = XTest;
        end
        
        function res = preprocess(mode, XTest1)
            %apply preprocessing
            [~,Nx]=size(XTest1);
            Mean = [];
            Std = [];
            XTest = XTest1;
            if mode == 0 %center
                Mean = mean(XTest1);
                XTest = bsxfun(@minus, XTest, Mean);
                Std = ones(1, Nx);
            end
            if mode == 1 %scale
                temp = std(XTest1,0,1);
                temp(temp == 0) = 1;
                Std = temp;
                XTest = bsxfun(@rdivide, XTest, Std);
            end
            
            if mode == 2 %autoscale
                Mean = mean(XTest1);
                XTest = bsxfun(@minus, XTest, Mean);
                
                temp = std(XTest1,0,1);
                temp(temp == 0) = 1;
                Std = temp;
                XTest = bsxfun(@rdivide, XTest, Std);
            end
            
            res.Mat = XTest;
            res.Model.TrainingSet_mean = Mean;
            res.Model.TrainingSet_std = Std;
        end
        
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
        
        function [T,P,Eig]= decomp (X, NumPC)
            % decomp - PCA decomposition based on X matrix with numPC components
            %----------------------------------------------
            [V,D,P] = svd(X);
            T = V*D;
            T = T(:,1:NumPC);
            P = P(:,1:NumPC);
            Eig = D(1:NumPC,1:NumPC);
            %loads_in{1}=T;
            %loads_in{2}=P;
            %[sgns,loads] = sign_flip(loads_in, X);
            % end of decomp function
        end
        
        function res = combnk2(K)
            res = [];
            
            for i = 1:K
                for j = i+1:K
                    res = [res;[i j]];
                end
            end
        end
        
        function hard_plot(axes,w,v,t0,K,Centers, numPCpca, show_legend)
            delta = 1.5;
            
            x_min = t0(1) - delta;
            x_max = t0(1) + delta;
            
            class_borders_ind = sortrows(PLSDAModel.combnk2(K));
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
                    
                    crit = min_dis < max_dis;
                    
                    if K == 3
                        r = 1;
                        if cl(1) == 1 && cl(2) == 2
                         r = 3;
                        end
                        
                        if cl(1) == 1 && cl(2) == 3
                         r = 2;
                        end
                        
                        if cl(1) == 2 && cl(2) == 3
                         r = 1;
                        end
                        
                        crit = (x_min - t0(1))*(Centers(r,1) - t0(1)) + (y_min - t0(2))*(Centers(r,2) - t0(2)) < 0;
                    end
                    
                    if crit
                        x = x_min;
                        y = y_min;
                    else
                        x = x_max;
                        y = y_max;
                    end
                    
                    if ~isempty(axes)
                        plot(axes, [t0(1) x],[t0(2) y], '-k','HandleVisibility','off');
                    else
                        plot([t0(1) x],[t0(2) y], '-k','HandleVisibility','off');
                    end
                end
                
            else
                wij = w(1,:)-w(2,:);
                vij = v(1)-v(2);
                
                if numPCpca == 1
                    t0 = [t0 t0];
                else
                    y_min = -(x_min*wij(1) - vij)/wij(2);
                    y_max = -(x_max*wij(1) - vij)/wij(2);
                end
                
                if numPCpca > 1
                    if ~isempty(axes)
                        plot(axes,[ x_min t0(1)],[ y_min t0(2)], '-k','HandleVisibility','off');
                        plot(axes,[t0(1) x_max],[t0(2) y_max], '-k','HandleVisibility','off');
                    else
                        plot([ x_min t0(1)],[ y_min t0(2)], '-k','HandleVisibility','off');
                        plot([t0(1) x_max],[t0(2) y_max], '-k','HandleVisibility','off');
                    end
                else
                    if ~isempty(axes)
                        plot(axes,t0,[ -1000 1000], '-k','HandleVisibility','off');
                    else
                        plot(t0,[ -1000 1000], '-k','HandleVisibility','off');
                    end
                end
            end
            
        end
        
        function soft_plot(axes,YpredT, Y,Centers,color, Alpha, numPCpca, Gamma, K, show_legend)
            AcceptancePlot = cell(K,1);
            OutliersPlot = cell(K,1);
            for class = 1:K
                [AcceptancePlot{class}, OutliersPlot{class}] = PLSDAModel.soft_classes_plot(YpredT(Y(:,class) == 1,:), Centers(class,:), Alpha, numPCpca, Gamma, K);
                
                if(numPCpca == 1)
                    x = [AcceptancePlot{class}(2,1) AcceptancePlot{class}(2,1) AcceptancePlot{class}(1,1) AcceptancePlot{class}(1,1) AcceptancePlot{class}(2,1)];
                    y = [0.05 -0.05 -0.05 0.05 0.05];
                    if ~isempty(axes)
                        if show_legend
                            plot(axes, x, y,'-', 'color',color(class,:));
                        else
                            plot(axes, x, y,'-', 'color',color(class,:),'HandleVisibility','off');
                        end
                    else
                        if show_legend
                            plot(x, y,'-', 'color',color(class,:));
                        else
                            plot(x, y,'-', 'color',color(class,:),'HandleVisibility','off');
                        end
                    end
                else
                    if ~isempty(axes)
                        if show_legend
                            plot(axes,AcceptancePlot{class}(:,1), AcceptancePlot{class}(:,2),'-', 'color',color(class,:));
                        else
                            plot(axes,AcceptancePlot{class}(:,1), AcceptancePlot{class}(:,2),'-', 'color',color(class,:),'HandleVisibility','off');
                        end
                    else
                        if show_legend
                            plot(AcceptancePlot{class}(:,1), AcceptancePlot{class}(:,2),'-', 'color',color(class,:));
                        else
                            plot(AcceptancePlot{class}(:,1), AcceptancePlot{class}(:,2),'-', 'color',color(class,:),'HandleVisibility','off');
                        end
                    end
                    
                end
                
                
                if ~isempty(Gamma)
                    if(numPCpca == 1)
                        x = [OutliersPlot{class}(2,1) OutliersPlot{class}(2,1) OutliersPlot{class}(1,1) OutliersPlot{class}(1,1) OutliersPlot{class}(2,1)];
                        y = [0.1 -0.1 -0.1 0.1 0.1];
                        if ~isempty(axes)
                            plot(axes, x, y,'--', 'color',color(class,:),'HandleVisibility','off');
                        else
                            plot( x, y ,'--', 'color',color(class,:),'HandleVisibility','off');
                        end
                    else
                        if ~isempty(axes)
                            plot(axes, OutliersPlot{class}(:,1), OutliersPlot{class}(:,2),'--', 'color',color(class,:),'HandleVisibility','off');
                        else
                            plot(OutliersPlot{class}(:,1), OutliersPlot{class}(:,2),'--', 'color',color(class,:),'HandleVisibility','off');
                        end
                        
                    end
                end
                temp_c =Centers(class,:);
                
                if(numPCpca == 1)
                    temp_c = [temp_c 0];
                end
                
                if ~isempty(axes)
                    plot(axes, temp_c(:,1), temp_c(:,2),'+', 'color',color(class,:),'HandleVisibility','off');
                else
                    plot(temp_c(:,1), temp_c(:,2),'+', 'color',color(class,:),'HandleVisibility','off');
                end
                
            end
        end
        
        function [AcceptancePlot, OutliersPlot] =soft_classes_plot(pcaScoresK, Center, Alpha, numPC, Gamma, K)
            
            len = size(pcaScoresK,1);
            cov = inv(((pcaScoresK-repmat(Center, len, 1))'*(pcaScoresK-repmat(Center, len, 1)))/len);
            
            if numPC > 1
                [~, P, Eig] = PLSDAModel.decomp(cov, 2);%
                P = -P;%!!!!!!
                SqrtSing = diag(sqrt(Eig))';
            else
                SqrtSing = sqrt(cov);
            end
            
            if numPC > 1
                
                fi = zeros(1,91);
                
                for i = 2:91
                    fi(i) = pi/45 + fi(i-1);
                end
                xy = bsxfun(@rdivide, [cos(fi)' sin(fi)'], SqrtSing);
                J = 1:size(xy,1);
                pc = cell2mat(arrayfun(@(i) xy(i,:)*P, J.','UniformOutput', false));
            else
                fi = [0 pi];
                xy = bsxfun(@rdivide, [cos(fi)' sin(fi)'], SqrtSing);
                pc = xy;
            end
            
            sqrtchi = sqrt(PLSDAModel.chi2inv_(1-Alpha, K-1));
            
            if numPC == 1
                Center = [Center 0];
            end
            
            AcceptancePlot = pc*sqrtchi + repmat(Center, size(xy,1), 1);
            
            if ~isempty(Gamma)
                Dout = sqrt(PLSDAModel.chi2inv_((1-Gamma)^(1/len), K-1));
                OutliersPlot = pc*Dout + repmat(Center, size(xy,1), 1);
            end
            
        end
        
        function m = confusionMatrix(Y,Distances,mode, Alpha)
            
            [I,K] = size(Distances);
            
            if nargin == 3 && mode == 0
                Alpha = 0;
            end
            
            if nargin == 4 && mode == 1
                Dcrit = PLSDAModel.chi2inv_(1-Alpha, K-1);
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
            CSPS = 1 - r.FP./(sum(Ik)-Ik);
            r.CSPS = 100*CSPS;
            r.CEFF = 100*sqrt(CSNS.*CSPS);
            TSNS = sum(r.TP)/sum(Ik);
            r.TSNS = 100*TSNS;
            TSPS = 1 - sum(r.FP)/sum(Ik);
            r.TSPS = 100*TSPS;
            r.TEFF = 100*sqrt(TSNS*TSPS);
        end
        
        function r = allocation_hard(Labels, Dist, cls)
            m = max(cellfun(@length, Labels));
            format = ['%-' sprintf('%d', m) 's\t'];
            r = '';
            r = [r, 'Decision Hard\n'];
            [I,K] = size(Dist);
            r = [r,sprintf(format, ' ')];
            r = [r,sprintf('\t%d', cls)];
            r = [r,'\n'];
            for i = 1:I
                r = [r,sprintf(format, Labels{i})];
                for k = 1:K
                    if Dist(i,k) == min(Dist(i,:))
                        r = [r,'\t*'];
                    else
                        r = [r,'\t '];
                    end
                end
                r = [r,'\n'];
            end
            r = [r,'\n\n'];
            r = strrep(r,'\n', newline);
            r = strrep(r,'\t', char(9));
        end
        
        function r = allocation_soft(Labels, Alpha, Dist, cls)
            m = max(cellfun(@length, Labels));
            format = ['%-' sprintf('%d', m) 's\t'];
            r = '';
            r = [r,'Decision Soft\n'];
            [I,K] = size(Dist);
            Dcrit = PLSDAModel.chi2inv_(1-Alpha, K-1);
            
            r = [r,sprintf(format, ' ')];
            r = [r,sprintf('\t%d', cls)];
            r = [r,'\n'];
            for i = 1:I
                r = [r,sprintf(format, Labels{i})];
                for k = 1:K
                    if Dist(i,k) < Dcrit
                        r = [r,'\t*'];
                    else
                        r = [r,'\t '];
                    end
                end
                r = [r,'\n'];
            end
            r = [r,'\n\n'];
            r = strrep(r,'\n', newline);
            r = strrep(r,'\t', char(9));
        end
        
    end
    
    methods (Static)
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
        
        function colors = colors_rgb(class_number)
            %  "FF0000", "00FF00", "0000FF", "FFFF00", "FF00FF", "00FFFF", "000000",
            %  "800000", "008000", "000080", "808000", "800080", "008080", "808080",
            %  "C00000", "00C000", "0000C0", "C0C000", "C000C0", "00C0C0", "C0C0C0",
            %  "400000", "004000", "000040", "404000", "400040", "004040", "404040",
            %  "200000", "002000", "000020", "202000", "200020", "002020", "202020",
            %  "600000", "006000", "000060", "606000", "600060", "006060", "606060",
            %  "A00000", "00A000", "0000A0", "A0A000", "A000A0", "00A0A0", "A0A0A0",
            %  "E00000", "00E000", "0000E0", "E0E000", "E000E0", "00E0E0", "E0E0E0",
            c = [1 0 0; 0 1 0; 0 0 1; 1 0.75 0; 1 0 1; 0 1 1; 0 0 0;...
                0.5 0 0; 0 0.5 0; 0 0 0.5; 0.5 0.5 0; 0.5 0 0.5; 0 0.5 0.5; 0.5 0.5 0.5; ...
                0.75 0 0; 0 0.75 0;0 0 0.75; 0.75 0.75 0; 0.75 0 0.75; 0 0.75 0.75; 0.75 0.75 0.75; ...
                0.25 0 0; 0 0.25 0;0 0 0.25; 0.25 0.25 0; 0.25 0 0.25; 0 0.25 0.25; 0.25 0.25 0.25; ...
                0.125 0 0; 0 0.125 0;0 0 0.125; 0.125 0.125 0; 0.125 0 0.125; 0 0.125 0.125; 0.125 0.125 0.125; ...
                0.375 0 0; 0 0.375 0;0 0 0.375; 0.375 0.375 0; 0.375 0 0.375; 0 0.375 0.375; 0.375 0.375 0.375; ...
                0.625 0 0; 0 0.625 0;0 0 0.625; 0.625 0.625 0; 0.625 0 0.625; 0 0.625 0.625; 0.625 0.625 0.625; ...
                0.875 0 0; 0 0.875 0;0 0 0.875; 0.875 0.875 0; 0.875 0 0.875; 0 0.875 0.875; 0.875 0.875 0.875];
            
            colors = c(1:class_number,:);
            
        end
    end
end

