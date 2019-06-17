classdef TabbedView < handle
    
    properties
        
        parent;
        
        tbl_tabgroup;
        
        tab_alloc;
        tab_confusion;
        tab_fom;
        
        tblTextResult;
        tblTextConfusion;
        tblTextFoM;
    end
    
    methods
        function self = TabbedView(parent)
            self.parent = parent;
            
            self.tbl_tabgroup = uitabgroup('Parent', parent);
            
            self.tab_alloc = uitab('Parent', self.tbl_tabgroup, 'Title', 'Allocation table');
            
            self.tblTextResult = uitable(self.tab_alloc);
            self.tblTextResult.Units = 'normalized';
            self.tblTextResult.Position = [0 0 1 1];
            
            self.tab_confusion = uitab('Parent', self.tbl_tabgroup, 'Title', 'Confusion matrix');
            self.tab_fom = uitab('Parent', self.tbl_tabgroup, 'Title', 'Figures of merit');
            
            self.tblTextConfusion = uitable(self.tab_confusion);
            self.tblTextConfusion.Units = 'normalized';
            self.tblTextConfusion.Position = [0 0 1 1];
            
            self.tblTextFoM = uitable(self.tab_fom);
            self.tblTextFoM.Units = 'normalized';
            self.tblTextFoM.Position = [0 0 1 1];
        end
        
        function delete(self)
            
            ptab = self.tbl_tabgroup.Children(1);
            delete(ptab);
            ptab = self.tbl_tabgroup.Children(1);
            delete(ptab);
            ptab = self.tbl_tabgroup.Children(1);
            delete(ptab);
            tg = self.parent.Children(1);
            delete(tg);
        end
        
        function v = bool2v(self, x, padding)
           if nargin == 2
               padding = 4;
           end
            if (x)
                v = [ repmat(' ', 1, padding ) 'V'];
            else
                v = ' ';
            end
            
        end
        
        function ShowTable(self, Result, setClasses, TrainingDataSetList, NumberOfTrainingDataSetClasses, ClassLabels)
            
            
            self.tblTextResult.ColumnFormat = ['char' 'char' repmat({'char'},1,NumberOfTrainingDataSetClasses)];

            res = Result;
            
            for i = 1:length(setClasses)
                c = setClasses(i);
                
                u = TrainingDataSetList;
                ii = 1:NumberOfTrainingDataSetClasses;
                ci = ii(u == c);
                
                if (sum(res.AllocationMatrix(i,:)) == 0)% no classes
                    if ~isempty(ci)
                        res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFC000><TR><TD>',res.Labels{i},'</TD></TR> </table></html>'];
                    end
                else
                    t = res.Labels{i};
                    if (~isempty(ci) && (~res.AllocationMatrix(i,ci))) || isempty(ci)% wrong class
                        res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FF0000><TR><TD>',t,'</TD></TR> </table></html>'];
                    end
                    
                    if (sum(res.AllocationMatrix(i,:)) > 1)% multiple classes
                        res.Labels{i} = ['<html><table border=0 width=100% bgcolor=#FFA0A0><TR><TD>',t,'</TD></TR> </table></html>'];
                    end
                end
            end
            
            padding = 1;
            max_class_label_length = 1;
            
            self.tblTextResult.ColumnWidth = num2cell([150, max(90,max_class_label_length*7), max(30, max_class_label_length*7)*ones(1,size(res.AllocationMatrix, 2))]);
            
            if ~isempty(ClassLabels)
                max_class_label_length = max(strlength(ClassLabels));
                padding = round(max_class_label_length);
            end
            
            v = arrayfun(@self.bool2v ,logical(res.AllocationMatrix), 'UniformOutput', false);
            self.tblTextResult.Data = [res.Labels, num2cell(setClasses),  v];
            %self.tblTextResult.Data = [res.Labels, num2cell(setClasses), num2cell(logical(res.AllocationMatrix))];
            
            self.tblTextResult.ColumnName = {'Sample','Known class', TrainingDataSetList};
            
            
            %if ~isempty(setClasses)
            trc = TrainingDataSetList;
            %tc = unique(setClasses);
            %end
            
            %if ~isempty(setClasses) %%&& length(trc) == length(tc) && sum(trc == tc) == length(tc)
            
            v = arrayfun(@(x) self.bool2v(x, padding) ,logical(res.AllocationMatrix), 'UniformOutput', false);
            self.tblTextResult.Data = [res.Labels, num2cell(setClasses),  v];
            
            if ~isempty(ClassLabels)
                names_ = cell(1,NumberOfTrainingDataSetClasses);
                for i = 1:NumberOfTrainingDataSetClasses
                    names_{i} = ClassLabels{trc(i)};
                end
                self.tblTextResult.ColumnWidth = num2cell([150, max(90,max_class_label_length*7), max(30, max_class_label_length*7)*ones(1,size(res.AllocationMatrix, 2))]);
                
                self.tblTextFoM.ColumnName = [{'Classes'}, names_];
                self.tblTextConfusion.ColumnName = names_;
                self.tblTextConfusion.RowName = names_;
                self.tblTextResult.ColumnName = [{'Sample','Known class'}, names_];
            else
                %padding = 1;
                max_class_label_length = 1;
                self.tblTextConfusion.ColumnName = TrainingDataSetList;
                self.tblTextConfusion.RowName = unique(setClasses);
                self.tblTextFoM.ColumnName = {'Classes',TrainingDataSetList};
            end
            
            self.tblTextFoM.ColumnWidth = num2cell([120, max(30, max_class_label_length*7)*ones(1,size(res.AllocationMatrix(:,1:NumberOfTrainingDataSetClasses), 2))]);
            self.tblTextFoM.ColumnFormat = ['char' repmat({'numeric'},1,NumberOfTrainingDataSetClasses)];
            
            self.tblTextConfusion.Data = res.ConfusionMatrix;
            
            fields = {'True Positive';'False Positive';'';'Class Sensitivity (%)';'Class Specificity (%)';'Class Efficiency (%)';'';'Total Sensitivity (%)';'Total Specificity (%)';'Total Efficiency (%)'};
            fom = res.FiguresOfMerit;
            
            self.tblTextFoM.Data = [fields,  [num2cell(round([fom.TP; fom.FP])); ...
                repmat({''},1,NumberOfTrainingDataSetClasses);...
                num2cell(round([fom.CSNS; fom.CSPS; fom.CEFF])); ...
                repmat({''},1,NumberOfTrainingDataSetClasses);...
                [round(fom.TSNS) repmat({''},1,NumberOfTrainingDataSetClasses-1)];...
                [round(fom.TSPS) repmat({''},1,NumberOfTrainingDataSetClasses-1)];...
                [round(fom.TEFF) repmat({''},1,NumberOfTrainingDataSetClasses-1)]...
                ]];
            %end
        end
        
    end
end

