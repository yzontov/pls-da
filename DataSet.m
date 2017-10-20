classdef DataSet < handle
    %DataSet class
    
    properties
        Name;
        RawData;
        ObjectNames;
        Classes;
        Variables;
        VariableNames;
        ClassLabels;
        
        Centering = false;
        Scaling = false;
        
        Training = false;
        Validation = false;
        
        PlotType = 2;
        
        Mean;
        Std;
    end
    
    properties (Access = private)
        Data_;
    end
    
    properties (Dependent = true)
        
        ProcessedData;
        
    end
    
    methods
        
        function fig = scatter(self, axes, var1, var2, showClasses, showObjectNames)
            
            fig = scatter(axes, self.ProcessedData(:,var1),self.ProcessedData(:,var2));
            
            if(showObjectNames)
                labels = strread(num2str(1:size(self.ProcessedData, 1)),'%s');
                if(~isempty(self.ObjectNames))
                    labels = self.ObjectNames;
                end
                
                dx = 0.01; dy = 0.01; % displacement so the text does not overlay the data points
                text(axes, self.ProcessedData(:,var1)+dx, self.ProcessedData(:,var2)+dy, labels, 'Interpreter', 'none');
            end
            
            if(showClasses)
                labels = strread(num2str(1:size(self.Classes, 1)),'%s');
                if(~isempty(self.ClassLabels))
                    labels = self.ClassLabels;
                end
                
                dx = 0.01; dy = -0.02; % displacement so the text does not overlay the data points
                text(axes, self.ProcessedData(:,var1)+dx, self.ProcessedData(:,var2)+dy, labels, 'Interpreter', 'none');
            end
            
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
            %ProcessedData get/set
            
            value = self.Data_;
        end
        
        
        
        function set.RawData(self,value)
            %RawData get/set
            
            self.RawData = value;
            self.Data_ = value;
            
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
            
        end
        
        function set.Centering(self,value)
            %Centering get/set
            
            self.Centering = value;
            
            self.Data_ = self.RawData;
            
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
            
        end
        
        function set.Scaling(self,value)
            %Scaling get/set
            
            self.Scaling = value;
            
            self.Data_ = self.RawData;
            
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
            
        end
    end
    
end

