Decoding the Text Encoding
===============
## Team Members

1. Hamid Izadinia izadinia@uw.edu
2. Fereshteh Sadeghi fsadeghi@uw.edu

![Overview](overview_final.png)

## Abstract
Word clouds and text visualization is one of the recent most popular and widely used types of visualizations. Despite the attractiveness and simplicity of producing word clouds, they do not provide a thorough visualization for the distribution of the underlying data. Therefore, it is important to redesign word clouds for improving the design choices and to be able to do further statistical analysis on data. In this paper we have proposed the development of a fully automatic redesigning algorithm for word cloud visualization. Our proposed method is able to decode an input word cloud visualization and provides the raw data in the form of a list of (word, value) pairs. We have tested our proposed method both qualitatively and quantitatively. The results of our experiments show that our algorithm is able to extract the words and their weights effectively with considerable low error rate.


[Poster](https://github.com/CSE512-14W/fp-izadinia-fsadeghi/raw/master/final/poster-izadinia-fsadeghi.pdf),
[Final Paper](https://github.com/CSE512-14W/fp-izadinia-fsadeghi/raw/master/final/paper-izadinia-fsadeghi.pdf) 

## Running Instructions
This project is implemented in Matlab and C++. For running the code you can run "run_script". In this script the following functions will run and the results will show in figure in every iteration of algorithm. The error of value estimation compared to ground truth prints as output.

The functions are:
1. Extracting the connected components in the image
     connected_comp_patch.m
2. Computing the edge weights for all connections in graph
     get_rel_letters_func.m
     get_rel_letters_vert_func.m
3. Iterative word extraction and their weight estimation
    convert_image_to_chart.m
4. Reading ground truth histograms from SVG file
    read_gt.m
