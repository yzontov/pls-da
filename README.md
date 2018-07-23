Implementation of the Hard and Soft PLS-DA for MATLAB (Release Candidate 1)
===========================================

We present the software implementation of hard and soft approaches to Partial Least Squares Discriminant Analysis (PLS-DA). 
The toolbox provides instruments for data pre-processing as well as for interpretation and visualization of classification models. 
The main class, PLSDAModel, is responsible for the logic and contains implementation of both methods as well as auxiliary algorithms. 
The instance of this class represents the actual model, and methods for data visualization and statistics. 
The PLSDAGUI class provides graphical user interface, where user can create and manipulate datasets, calibrate and explore models interactively.  

How to install
--------------
To get the latest release please use [GitHub sources](https://github.com/yzontov/pls-da/). 
You can clone the git repository or download the source as a zip-file and install it into Matlab environment.
To use the Tool you should set the Matlab current directory to the folder, which contains the Tool classes, or add this folder to the Matlab Path.
You should load the analyzed data into the MATLAB workspace for working with GUI.