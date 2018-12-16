classdef CVTask < handle
    
    properties
        DataSet;
        Type;
        
        Training;
        Validation;
    end
    
    methods (Access = private)
        function v=shuffle(v)
            v=v(randperm(length(v)));
        end
        
        function [val_start, val_stop] = crossval_indexes( N, fold )
            %Generate indexes for k-fold cross-validation
            % N - number of samples
            % fold - number of partitions (i.e. 3, 5, 10)
            
            k = N;
            if(mod(k, fold) == 0)
                x = 1:k;
                rows = k / fold;
                y = reshape (x, [rows, fold]);
                start = y(1,:);
                stop = y(end,:);
            else
                rows = fix(k / fold);
                x = 1:rows*fold;
                y = reshape (x, [rows, fold]);
                start = y(1,:);
                stop = y(end,:);
                
                for i = 1:mod(k, fold)
                    stop(i) = stop(i) + 1;
                    start(i+1:end) = start(i+1:end) + 1;
                    stop(i+1:end) = stop(i+1:end) + 1;
                end
            end
            
            val_start = start;
            val_stop = stop;
            
        end
    end
    
    
    methods
        function obj = CVTask(ds, type)
            %CVTask Construct an instance of this class
            obj.DataSet = ds;
            obj.Type = type;
        end
        
        function [training, validation] = Split(obj, type)

            obj.Type = type;
            
            if ~isempty(obj.DataSet)
                
                switch(type)
                    case ''
                    
                end
                
                
            end
            
            training = obj.Training;
            validation = obj.Vaildation;
        end
        
        function set.DataSet(self,value)
            %DataSet get/set
            
            self.DataSet = value;
        end
        
        function set.Type(self,value)
            %Type get/set
            
            self.Type = value;
            
        end
        
        function value = get.Training(self)
            %Training get/set
            
            value = self.Training;
        end
        
        function value = get.Validation(self)
            %Validation get/set
            
            value = self.Validation;
        end
        
    end
end

