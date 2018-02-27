Implementation of the Hard and Soft PLS-DA for MATLAB (Beta release)
===========================================

We present the Beta release of a software implementation of hard and soft approaches to Partial Least Squares Discriminant Analysis (PLS-DA). 
The toolbox provides instruments for data pre-processing as well as for interpretation and visualization of classification models. 
The main class, PLSDAModel, is responsible for the logic and contains implementation of both methods and auxiliary algorithms. 
The instance of this class has fields, which represent the actual model, and methods for data visualization and statistics. 
The PLSDAGUI class provides graphical user interface, where user can create and manipulate datasets, calibrate and explore models interactively.  

Disclaimer
-----------
The Tool is still in Beta version. Please feel free to contact the author about any errors encountered in the software.

Coming soon
-----------
Validation tools

User documentation and examples

How to install
--------------
To get the latest release plase use [GitHub sources](https://github.com/yzontov/pls-da/). 
You can clone the git repository or download the source as a zip-file and install it in your Matlab environment.
To use the Tool you should set the Matlab current directory to the folder, which contains the Tool main classes ("PLSDAGUI.m", "PLSDAModel.m", "DataSet.m") as well as all auxiliary files, or add this folder to the Matlab Path.
One should load the analyzed data into the MATLAB workspace for working with GUI.