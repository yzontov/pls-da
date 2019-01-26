classdef DataSet < handle
    %DataSet class
    
    properties
        Name;
        RawData;
        RawClasses;
        
        ObjectNames;
        
        Variables;
        VariableNames;
        ClassLabels;
        
        SelectedSamples;
        
        Centering = false;
        Scaling = false;
        
        Training = false;
        Validation = false;
        
        Mean;
        Std;
        
        PCAScores;
        PCALoadings;
        PCAStats;
        
        HasPCA = false;
    end
    
    properties (Access = private)
        Data_;
        Classes_;
    end
    
    properties (Dependent = true)
        
        Classes;
        ProcessedData;
        SelectedObjectNames;
        NumberOfClasses;
        
    end
    
    events
        Deleting;
    end
    
    methods
        
        function newObj = DataSet(oldObj)
            if nargin == 1 && isa(oldObj,'DataSet')
                newObj.Name = oldObj.Name;
                newObj.RawData= oldObj.RawData;
                newObj.RawClasses= oldObj.RawClasses;
                
                newObj.ObjectNames= oldObj.ObjectNames;
                
                newObj.Variables= oldObj.Variables;
                newObj.VariableNames= oldObj.VariableNames;
                newObj.ClassLabels= oldObj.ClassLabels;
                
                newObj.SelectedSamples= oldObj.SelectedSamples;
                
                newObj.Centering = oldObj.Centering;
                newObj.Scaling = oldObj.Scaling;
                
                newObj.Training = oldObj.Training;
                newObj.Validation = oldObj.Validation;
            end
        end
        
        function delete(obj)
            %disp([obj.Name ' deleted']);
            notify(obj,'Deleting');
        end
        
        function Y = DummyMatrix(self)
            
            if ~isempty(self.Classes)
                class_number = self.NumberOfClasses;
                Y = zeros(length(self.Classes), class_number);
                
                cls = unique(self.Classes);
                for cl = 1:class_number
                    Y(:,cl) = (self.Classes == cls(cl));
                end
            else
                Y = [];
            end
        end
        
        function fig = scatter(self, axes, var1, var2, showClasses, showObjectNames)
            
            if showClasses
                
                trc = unique(self.Classes);
                names = cell(1,self.NumberOfClasses);
                color = PLSDAModel.colors_rgb(self.NumberOfClasses);
                for i = 1:self.NumberOfClasses
                    %colors = [colors; repmat(color(i,:), sum(self.Classes == i), 1)];
                    %colors = repmat(color(i,:), sum(self.Classes == i), 1);
                    hold on;
                    fig = plot(axes, self.ProcessedData(self.Classes == trc(i),var1),self.ProcessedData(self.Classes == trc(i),var2),'o','color',color(i,:));
                    
                    if isempty(self.ClassLabels)
                        names{i} = sprintf('class %d', trc(i));
                    else
                        names{i} = self.ClassLabels{trc(i)};
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
                fig = scatter(axes, self.ProcessedData(:,var1),self.ProcessedData(:,var2));
            end
            
            if (~isempty(self.VariableNames))
                xlabel(self.VariableNames{var1}); % x-axis label
                ylabel(self.VariableNames{var2});% y-axis label
            else
                if (~isempty(self.Variables))
                    xlabel(sprintf('%.2f', self.Variables(var1))); % x-axis label
                    ylabel(sprintf('%.2f', self.Variables(var2)));% y-axis label
                else
                    xlabel(sprintf('Variable %d', var1)); % x-axis label
                    ylabel(sprintf('Variable %d', var2));% y-axis label
                end
            end
            
            title(axes, ['Dataset: ' self.Name ' - Scatter plot'], 'interpreter', 'none');
        end
        
        function fig = line(self, axes)
            
            if isempty(self.Variables)
                x = 1:size(self.ProcessedData,2);
            else
                x = self.Variables;
            end
            
            y = self.ProcessedData;
            
            fig = plot(axes, x,y);
            
            if isempty(self.Variables)
                xlabel(axes,'Variables');
            else
                xlabel(axes,'Wavelengths');
            end
            
            if(~isempty(self.VariableNames))
                loadings_labels = self.VariableNames;
                vars = length(self.VariableNames);
            else
                if(~isempty(self.Variables))
                    vars = length(self.Variables);
                    loadings_labels = strread(num2str(self.Variables),'%s');
                else
                    vars = size(self.ProcessedData, 2);
                    loadings_labels = strread(num2str(1:size(self.ProcessedData, 2)),'%s');
                end
            end
            
            if vars <= 30
                xticks(axes,1:vars);
                if ~isempty(self.VariableNames)
                    xtickangle(axes,45);
                end
                xticklabels(axes,loadings_labels);
            end
            
            title(axes, ['Dataset: ' self.Name ' - Line plot'], 'interpreter', 'none');
            ylabel(axes,'Values');
            
        end
        
        function fig = histogram(self, axes, var1)
            
            fig = histogram(axes, self.ProcessedData(:, var1),'Normalization','count' );
            
            varname = sprintf('Variable: %d', var1);
            if ~isempty(self.VariableNames)
                varname = sprintf('Variable: %s', self.VariableNames{var1});
            end
            
            title(axes, ['Dataset: ' self.Name ' - Histogram plot - ' varname], 'interpreter', 'none');
            
            xlabel(axes,'Values');
            ylabel(axes,'Occurrences');
        end
        
        function value = Description(self)
            %Mean get/set
            
            if(~isempty(self.ObjectNames))
                objnames_s = ' - [obj.names]';
            else
                objnames_s = '';
            end
            
            if(~isempty(self.VariableNames))
                varnames_s = ' - [var.names]';
            else
                varnames_s = '';
            end
            
            if(~isempty(self.ClassLabels))
                labels_s = ' - [cls.labels]';
            else
                labels_s = '';
            end
            
            if(~isempty(self.Classes))
                cls_s = ' - [clases]';
            else
                cls_s = '';
            end
            
            if(self.Training)
                training_s = ' - training set';
                if(self.Validation)
                    training_s = ' - training & validation set';
                end
            else
                if(self.Validation)
                    training_s = ' - validation set';
                else
                    training_s = '';
                end
            end
            
            
            if(self.Scaling && self.Centering)
                preprocess_s = ' - autoscaled';
            else
                preprocess_s = '';
                if(self.Centering)
                    preprocess_s = ' - centered';
                end
                
                if(self.Scaling)
                    preprocess_s = ' - scaled';
                end
            end
            
            value = sprintf('[%d x %d]%s%s%s%s%s%s', size(self.ProcessedData, 1), ...
                size(self.ProcessedData, 2), cls_s, training_s, preprocess_s, labels_s, objnames_s, varnames_s);
        end
        
        function value = get.Mean(self)
            %Mean get/set
            
            value = self.Mean;
        end
        
        function value = get.Std(self)
            %Std get/set
            
            value = self.Std;
        end
        
        function value = get.ProcessedData(self)
            
            value = self.Data_;
            
        end
        
        function value = get.NumberOfClasses(self)
            
            value = length(unique(self.Classes));
            
        end
        
        function set.Classes(self, value)
            
            self.RawClasses = value;
            
            [~, ai] = sort(self.RawClasses);
            
            if ~isempty(self.RawData)
                self.RawData = self.RawData(ai,:);
            end
            
            if ~isempty(self.ObjectNames)
                self.ObjectNames = self.ObjectNames(ai);
            end
            
        end
        
        function value = get.Classes(self)
            
            %value = size(self.DummyMatrix(), 2);
            if isempty(self.RawClasses)
                value = [];
            else
                value = self.RawClasses(logical(self.SelectedSamples),:);
            end
            
        end
        
        function value = get.SelectedObjectNames(self)
            
            if isempty(self.ObjectNames)
                value = [];
            else
                value = self.ObjectNames(logical(self.SelectedSamples),:);
            end
            
        end
        
        function set.RawData(self,value)
            %RawData get/set
            
            self.RawData = value;
            self.Data_ = value;
            self.SelectedSamples = ones(size(self.Data_, 1),1);
            
            if self.Centering == true
                self.Mean = mean(self.Data_);
                self.Data_ = bsxfun(@minus, self.Data_, self.Mean);
            end
            
            if self.Scaling == true
                temp = std(self.Data_,0,1);
                temp(temp == 0) = 1;
                self.Std = temp;
                self.Data_ = bsxfun(@rdivide, self.Data_, temp);
            end
            
            %self.PCA();
            self.HasPCA = false;
            
        end
        
        function set.SelectedSamples(self,value)
            
            self.SelectedSamples = value;
            
            self.Data_ = self.RawData(logical(self.SelectedSamples),:);
            
            if self.Centering == true
                self.Mean = mean(self.Data_);
                self.Data_ = bsxfun(@minus, self.Data_, self.Mean);
            end
            
            if self.Scaling == true
                temp = std(self.Data_,0,1);
                temp(temp == 0) = 1;
                self.Std = temp;
                self.Data_ = bsxfun(@rdivide, self.Data_, self.Std);
            end
            
            %self.PCA();
            self.HasPCA = false;
        end
        
        function set.Centering(self,value)
            %Centering get/set
            
            self.Centering = value;
            
            self.Data_ = self.RawData(logical(self.SelectedSamples),:);
            
            if self.Centering == true
                self.Mean = mean(self.Data_);
                self.Data_ = bsxfun(@minus, self.Data_, self.Mean);
            end
            
            if self.Scaling == true
                temp = std(self.Data_,0,1);
                temp(temp == 0) = 1;
                self.Std = temp;
                self.Data_ = bsxfun(@rdivide, self.Data_, self.Std);
            end
            
            %self.PCA();
            self.HasPCA = false;
            
        end
        
        function set.Scaling(self,value)
            %Scaling get/set
            
            self.Scaling = value;
            
            self.Data_ = self.RawData(logical(self.SelectedSamples),:);
            
            if self.Centering == true
                self.Mean = mean(self.Data_);
                self.Data_ = bsxfun(@minus, self.Data_, self.Mean);
            end
            
            if self.Scaling == true
                temp = std(self.Data_,0,1);
                temp(temp == 0) = 1;
                self.Std = temp;
                self.Data_ = bsxfun(@rdivide, self.Data_, self.Std);
            end
            
            %self.PCA();
            self.HasPCA = false;
        end
        
        function PCA(self, NumPC)
            
            if nargin == 0
                NumPC = min(size(self.ProcessedData));
                
                if self.Centering
                    NumPC = NumPC - 1;
                end
                
                if self.Scaling
                    NumPC = NumPC - 1;
                end
            end
            
            [V,D,P] = svd(self.ProcessedData);
            T = V*D;
            self.PCAScores = T(:,1:NumPC);
            self.PCALoadings = P(:,1:NumPC);
            
            self.HasPCA = true;
        end
    end
    
end

