classdef (ConstructOnLoad) DatasetCreatedEventData < event.EventData
   properties
      VariableName
   end
   
   methods
      function data = DatasetCreatedEventData(VariableName)
         data.VariableName = VariableName;
      end
   end
end