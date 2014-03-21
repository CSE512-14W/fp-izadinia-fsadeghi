close all;
clear all;
clc;

% im_name = 'd3_001.png';
im_name = 'fun.png';


% extract connected components in image
connected_comp_patch(im_name);

% compute cost of edges between letters
get_rel_letters_func(im_name);
get_rel_letters_vert_func(im_name);

% compute words and weights
convert_image_to_chart(im_name)

