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
    
    methods
        
        function Y = DummyMatrix(self)
            
            if ~isempty(self.Classes)
                class_number = max(self.Classes);
                Y = zeros(length(self.Classes), class_number);
                for cl = 1:class_number
                    Y(:,cl) = (self.Classes == cl);
                end
                
                %Y = Y(logical(self.SelectedSamples),:);
            else
                Y = [];
            end
        end
        
        function fig = scatter(self, axes, var1, var2, showClasses, showObjectNames)
            
            if showClasses

                names = cell(1,self.NumberOfClasses);
                color = PLSDAModel.colors_rgb(self.NumberOfClasses);
                for i = 1:self.NumberOfClasses
                    %colors = [colors; repmat(color(i,:), sum(self.Classes == i), 1)];
                    %colors = repmat(color(i,:), sum(self.Classes == i), 1);
                    hold on;
                    fig = plot(axes, self.ProcessedData(self.Classes == i,var1),self.ProcessedData(self.Classes == i,var2),'o','color',color(i,:));
                    names{i} = sprintf('class %d', i);
                    
                    if isempty(self.ClassLabels)
                        names{i} = sprintf('class %d', i);
                    else
                        names{i} = self.ClassLabels{i};
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
                    xlabel(sprintf('Variable %.2f', var1)); % x-axis label
                    ylabel(sprintf('Variable %.2f', var2));% y-axis label
                end
            end
            
            %             if(showObjectNames)
            %                 labels = strread(num2str(1:size(self.ProcessedData, 1)),'%s');
            %                 if(~isempty(self.SelectedObjectNames))
            %                     labels = self.SelectedObjectNames;
            %                 end
            %
            %                 dx = 0.01; dy = 0.01; % displacement so the text does not overlay the data points
            %                 text(axes, self.ProcessedData(:,var1)+dx, self.ProcessedData(:,var2)+dy, labels, 'Interpreter', 'none');
            %
            %
            %             end
            
            %             if(showClasses && ~isempty(self.Classes))
            %                 labels = arrayfun(@(x) sprintf('%d',x),self.Classes(logical(self.SelectedSamples),:),'UniformOutput', false);
            %                 if(~isempty(self.ClassLabels) && ~isempty(self.ClassLabels(logical(self.SelectedSamples),:)))
            %                     labels = self.ClassLabels(logical(self.SelectedSamples),:);
            %                 end
            %
            %                 dx = 0.03; dy = -0.03; % displacement so the text does not overlay the data points
            %                 text(axes, self.ProcessedData(:,var1)+dx, self.ProcessedData(:,var2)+dy, labels, 'Interpreter', 'none');
            %             end
            
        end
        
        function fig = line(self, axes)
            
            if isempty(self.Variables)
                x = 1:size(self.ProcessedData,2);
            else
                x = self.Variables;
            end
            y = self.ProcessedData;
            
            fig = plot(axes, x,y);
            
        end
        
        function fig = histogram(self, axes, var1)
            
            fig = histogram(axes, self.ProcessedData(:, var1));
            
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
            
            %value = size(self.DummyMatrix(), 2);
            value = max(self.Classes);
            
        end
        
        function set.Classes(self, value)
            
            self.RawClasses = value;
            
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
            
            self.PCA();
            
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
            
            self.PCA();
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
            
            self.PCA();
            
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
            
            self.PCA();
            
        end
    end
    
    methods (Access = private)
        function PCA(self)
            
            NumPC = min(size(self.RawData));
                
                if self.Centering
                    NumPC = NumPC - 1;
                end
                
                if self.Scaling
                    NumPC = NumPC - 1;
                end
            
            [V,D,P] = svd(self.ProcessedData);
            T = V*D;
            self.PCAScores = T(:,1:NumPC);
            self.PCALoadings = P(:,1:NumPC);
        end
    end
end

