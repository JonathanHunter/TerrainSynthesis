#This is a graphics research project for Georgia Tech and was done in collaboration with Professor Greg Turk.  
The application reads in a height map from the [U.S. Geological Survey](http://viewer.nationalmap.gov/basic/?basemap=b1&category=ned,nedsrc&title=3DEP%20View) specifically [this](ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/NED/1/GridFloat/n39w080.zip).  
For the purposes of speeading the application runtime up the height map data is shrunk to 1/15th its original size. It then creates a normal map of the smaller suface.  
Next using the patch placement technique from [�Image Quilting for Texture Synthesis and Transfer�](http://www.eecs.berkeley.edu/Research/Projects/CS/vision/papers/efros-siggraph01.pdf) 
by Efros and Freeman, it generates a new normal map three times the size of the smaller texture.  
Finally it creates a color version of the generated terrain by using a full color surface reflection image from the [Google Earth Engine](https://explorer.earthengine.google.com/#workspace).