Implementation of the Hard and Soft PLS-DA for MATLAB (v.0.9.2)
===========================================

We present the software implementation of [Hard and Soft approaches to Partial Least Squares Discriminant Analysis (PLS-DA)](https://onlinelibrary.wiley.com/doi/abs/10.1002/cem.3030). 
The toolbox provides instruments for data pre-processing as well as for interpretation and visualization of classification models. 
The main class, PLSDAModel, is responsible for the logic and contains implementation of both methods as well as auxiliary algorithms. 
The instance of this class represents the actual model, and methods for data visualization and statistics. 
The PLSDAGUI class provides graphical user interface, where user can create and manipulate datasets, calibrate and explore models interactively.  

What is new
-----------

In the latest release (0.9.2):
* Minor GUI enhancements
* Bugs fixed
* Custom saveobj method implemented for DataSet class

A history of changes is available [here](NEWS.md)


How to install
--------------
The latest release is available as .mltbx installation package or zip-archive in the [Releases section](https://github.com/yzontov/pls-da/releases). 

To get the latest source code please use [GitHub sources](https://github.com/yzontov/pls-da/). 
You can clone the git repository or download the source as a zip-file and install it into Matlab environment.
To use the Tool you should set the Matlab current directory to the folder, which contains the Tool classes, or add this folder and sub-folders to the Matlab Path.
The package contains installation script which automates this process.

You should load the analyzed data into the MATLAB workspace for working with GUI.
