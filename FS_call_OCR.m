load templates;
global templates;
num_letras=size(templates,2);
img_r=imresize(inp_img,[42 24]);
letter=read_letter_perso(img_r,num_letras);