classdef Data < handle
    %Data class
    %   Detailed explanation goes here
    
    properties
        RawData;
        Labels;
        
        Centering = false;
        Scaling = false;
        Training = false;
        
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
        
        function value = Description(self)
            %Mean get/set
            
            if(~isempty(self.Labels))
                labels_s = ' - has labels';
            else
                labels_s = '';
            end
            
            if(self.Training)
                training_s = ' - training set';
            else
                training_s = '';
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
            
            value = sprintf('[%d x %d]%s%s%s', size(self.ProcessedData, 1), size(self.ProcessedData, 2), training_s, preprocess_s, labels_s);
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

