function connected_comp_patch(im_name)
% connected_comp_patch('test1.png')
% connected_comp_patch('final-wordle.jpg')
% connected_comp_patch('wordle1.jpg')
% connected_comp_patch('fun.png')
% connected_comp_patch('google.jpg')
% connected_comp_patch('relig.png')
% connected_comp_patch('adwords_wordle.png')
% connected_comp_patch('play.png')
% connected_comp_patch('Tony.jpg')
% connected_comp_patch('vegan.png')
% connected_comp_patch('like.png')
% connected_comp_patch('love.jpg')
% connected_comp_patch('read.jpg')
% connected_comp_patch('dream.jpg')
% connected_comp_patch('kids.png')
% connected_comp_patch('trust.png')
% connected_comp_patch('work.png')
% connected_comp_patch('d3_001.png')


close all;

imagesset = './images/';
data = './data/';
vis_p = './vis/';


% im_name = 'test1.png';
% im_name = 'final-wordle';
% im_name = 'wordle1.jpg';
im = imread(sprintf('%s%s', imagesset, im_name));
im = imresize(im,3);

res_path = sprintf('%s%s.mat', data, im_name(1:end-4));

figure(1);
imshow(im);

img = rgb2gray(im);

immed = median(img(:));
if(immed < 125)
    img = 255-img;
end


% img = double(img);


% threshold = graythresh(img);
threshold = .82; %.75
imbw =~im2bw(img,threshold);


figure(2);
imshow(imbw);
vis_file = sprintf('%s%s_binary.jpg', vis_p, im_name(1:end-4));
imwrite(imbw,vis_file);


% imbwhr = imbw;
% for i = 1 : 10
%     imbwhr = bwmorph(imbwhr,'hbreak');
% end
% figure(5);
% imshow(imbwhr);



[Ilabel num] = bwlabel(imbw);
disp(num);
Iprops = regionprops(Ilabel);
Ibox = [Iprops.BoundingBox];
Ibox = reshape(Ibox,[4 num]);

clrs = rand(length(Iprops)+1,3);



figure(10);
colormap(clrs);
imagesc(Ilabel);

[ih,iw,ik] = size(im);

chs = round(iw/100);
ch = repmat(1-0.2*xor((mod(repmat(0:size(im,2)-1,size(im,1),1),chs*2)>(chs-1)),(mod(repmat((0:size(im,1)-1)',1,size(im,2)),chs*2)>(chs-1))),[1 1 3]);

mask = cat(3,Ilabel,Ilabel,Ilabel);
lbl_im = reshape(clrs(Ilabel+1,:),[ih,iw,ik]);
final_im = (mask==0).*ch + (mask~=0).*lbl_im;
fig11 = figure(11);
set(fig11,'Position',[50,50, 1200,700]);
imagesc(final_im);
vis_file = sprintf('%s%s_chekerb_color.jpg', vis_p, im_name(1:end-4));
imwrite(final_im,vis_file);


load('letters_Arial.mat');

% load templates;

templates = templates(11:end); % only letters
global templates;
num_letras=size(templates,2);


% n = ceil(sqrt(num));
% figure(11);
% ha = tight_subplot(n,n,[.03 .03],[.03 .03],[.03 .03])
for ii = 1:num 
%     axes(ha(ii)); 
    b = round(Iprops(ii).BoundingBox);
    b = [b(1), b(2), b(1)+b(3), b(2)+b(4)];
    ipatch = imbw(b(2):b(4),b(1):b(3));
    ipatchc = im(b(2):b(4),b(1):b(3),:);
%     colormap('winter');
%     imagesc(ipatch);
    img_r=imresize(ipatch,[42 24]);
    [letter, comp, tops] = read_letter_perso(img_r,num_letras);
    title(sprintf('%s,%s,%s,%s', tops{1}, tops{2}, tops{3}, tops{4}));
    axis off;
    
    [ih,iw,ik]= size(ipatchc);
    
    nodes(ii).lbl = ii;
    nodes(ii).letter = letter;
    nodes(ii).comp = comp;
    nodes(ii).tops = tops;
    nodes(ii).b = b;
    nodes(ii).cen = Iprops(ii).Centroid;
    nodes(ii).area = Iprops(ii).Area;
    R = reshape(ipatchc(:,:,1),[ih,iw]);
    G = reshape(ipatchc(:,:,2),[ih,iw]);
    B = reshape(ipatchc(:,:,3),[ih,iw]);
    nodes(ii).clr(1) = mean(R(ipatch));
    nodes(ii).clr(2) = mean(G(ipatch));
    nodes(ii).clr(3) = mean(B(ipatch));
    nodes(ii).ipatch = ipatch;
end

bboxes = {nodes(:).b}';
all_x1 = cell2mat(cellfun(@(x) x(1), bboxes,'UniformOutput',false));
[svals sinds] = sort(all_x1);
nodes = nodes(sinds);

fig11 = figure(11);
set(fig11,'Position',[50,50, 1200,700]);
title('');
hold on;
for i = 1 : length(nodes)
    b = nodes(i).b;
    plot(b([1,1,3,3,1]),b([2,4,4,2,2]),'linewidth',2);
end
hold off;
f = getframe(gca);
vis_file = sprintf('%s%s_chekerb_color_box.jpg', vis_p, im_name(1:end-4));
imwrite(f.cdata,vis_file);


save(res_path, 'nodes', 'Ilabel');





% Remove all object containing fewer than 30 pixels
% imagen = bwareaopen(imbw,30);
% figure(4);
% imshow(ima);


% imbwhr = bwmorph(imbw,'hbreak');
% figure(5);
% imshow(imbwhr);
% 
% 
% se = strel('disk',3);
% imbwer = imerode(imbw,se);
% figure(3);
% imshow(imbwer);
% 
% se = strel('disk',3);
% imbwdt = imdilate(imbwer,se);
% figure(4);
% imshow(imbwdt);



