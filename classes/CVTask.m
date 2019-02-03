classdef CVTask < handle
    
    properties
        DataSet;
        
        Type = 'k-fold';
        Folds = 10;
        ValidationPercent = 30;
        Iterations = 10;
        
        Shuffle = true;
        
        Splits;
        
        %Model parameters
        ModelType;
        
        MinPC
        PCStep;
        MaxPC;
                
        MinAlpha;
        AlphaStep;
        MaxAlpha;
        
        Results;
    end
    
    methods (Access = private)
        function v=shuffle(~, v)
            v=v(randperm(length(v)));
        end
        
        function [val_start, val_stop] = crossval_indexes(~, N, fold )
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
            obj.DataSet = DataSet(ds);
        end
        
        function s = GenerateSplits(self)
            
            k = size(self.DataSet.ProcessedData, 1);
            number_of_splits = 1;
            
            if ~isempty(self.Type)
                switch(self.Type)
                    case 'leave-one-out'
                        number_of_splits = k;
                    case 'k-fold'
                        if ~isempty(self.Folds)
                            number_of_splits = self.Folds;
                            [val_start, val_stop] = self.crossval_indexes( k, self.Folds );
                        end
                    case 'holdout'
                        if ~isempty(self.ValidationPercent)
                            number_of_splits = 1;
                            proc = self.ValidationPercent/100;
                        end
                    case 'monte-carlo'
                        if ~isempty(self.ValidationPercent) && ~isempty(self.Iterations)
                            proc = self.ValidationPercent/100;
                            number_of_splits = self.Iterations;
                        end
                end
                
                self.Splits = zeros(k, number_of_splits);
                
                e = 1:k;
                se = e';
                
                if (self.Shuffle)
                    se = self.shuffle(se);
                end
                
                for i = 1:number_of_splits
                    split = zeros(size(se));
                                      
                    switch(self.Type)
                        case 'leave-one-out'
                            split(se(i)) = 1;
                        case 'k-fold'
                            split(se(val_start(i):val_stop(i))) = 1;
                        case 'holdout'
                            split(se(1:round(k*proc))) = 1;
                        case 'monte-carlo'
                            se = self.shuffle(se);
                            split(se(1:round(k*proc))) = 1;
                    end
                    
                    self.Splits(:,i) = split;
                end
            end
            s = self.Splits;
        end
        
        function [t, v] = SplitDataset(self, split)
            
            d = self.DataSet;
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
            
            %leave-one-out
            %k-fold
            %holdout
            %monte-carlo
            
            self.Type = value;
            
        end
    end
end