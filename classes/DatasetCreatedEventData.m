classdef (ConstructOnLoad) DatasetCreatedEventData < event.EventData
   properties
      VariableName;
      EditMode = false;
   end
   
   methods
      function data = DatasetCreatedEventData(VariableName, Mode)
         data.VariableName = VariableName;
         data.EditMode = Mode;
      end
   end
end