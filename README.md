# b3d_tools

The goal of this project is to provide tools to read, write, and visualize three-dimensional electric field data in the B3D format, in both Matlab and Python.

In the current version, a particular implementation of the latest version 4 is supported, Location and time data must be given as variable points. The data must have at least two float channels (ex and ey). Time offset is not supported. Optionally, the second meta string represents a length-two vector that describes the location points as a grid.

[Data format description](https://electricgrids.engr.tamu.edu/wp-content/uploads/sites/129/2022/01/B3D-format-description-v4_Jan11_2022.pdf)
