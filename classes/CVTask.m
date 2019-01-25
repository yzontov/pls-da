classdef CVTask < handle
    
    properties
        DataSet;
        
        Type;
        Folds;
        ValidationPercent;
        Iterations;
        
        Shuffle = true;
        
        Splits;
    end
    
    methods (Access = private)
        
    end
    
    methods (Static)
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
        function obj = CVTask(ds)
            %CVTask Construct an instance of this class
            obj.DataSet = ds;
            %obj.Type = type;
        end
        
        function s = GenerateSplits(obj)
            %             Type;
            %         Folds;
            %         ValidationPercent;
            %         Iterations;
            
            k = size(obj.DataSet.ProcessedData, 1);
            number_of_splits = 1;
            
            if ~isempty(obj.Type)
                switch(obj.Type)
                    case 'leave-one-out'
                        number_of_splits = k;
                    case 'k-fold'
                        if ~isempty(obj.Folds)
                            folds = str2double(obj.Folds);
                            number_of_splits = folds;
                            [val_start, val_stop] = CVTask.crossval_indexes( k, folds );
                        end
                    case '%holdout'
                        number_of_splits = 1;
                        proc = obj.ValidationPercent/100;
                    case 'monte-carlo'
                        proc = obj.ValidationPercent/100;
                        number_of_splits = Iterations;
                end
            end
        end
        
        function [t, v] = SplitDataset(obj, split)

            d = obj.DataSet;
            dat = d.RawData(logical(d.SelectedSamples),:);
            cls = d.RawClasses(logical(d.SelectedSamples),:);
            
            t = DataSet();
            t.RawData = dat(self.Splits(:,split) == 0,:);
            t.Centering = d.Centering;
            t.Scaling = d.Scaling;
             t.RawClasses = cls(self.Splits(:,split) == 0,:);
                    
            v = DataSet();
            v.RawData = dat(self.Splits(:,split) == 1,:);
            v.RawClasses = cls(self.Splits(:,split) == 1,:);
        end
        
        function set.DataSet(self,value)
            %DataSet get/set
            
            self.DataSet = value;
        end
        
        function set.Type(self,value)
            %Type get/set
            
            self.Type = value;
            
        end
        
        
    end
end