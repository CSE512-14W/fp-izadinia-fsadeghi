close all;
clear all;
clc;

im_name = 'd3_003.png';
% im_name = 'fun.png';


% extract connected components in image
connected_comp_patch(im_name);

% compute cost of edges between letters
get_rel_letters_func(im_name);
get_rel_letters_vert_func(im_name);

% compute words and their weights
[wsc, w, w_amean] = convert_image_to_chart(im_name);

[words, sizes] = read_gt(im_name(1:end-4));

w_amean = sqrt(w_amean);


ms = mean(sizes);
wm = mean(w_amean);

w_amean_sft = w_amean + (ms-wm);

matchw = {};
matchd = [];
matchdist = [];
for i = 1 : length(words)
    dists = [];
    for j = 1 : length(wsc)
        dd =  strdist(char(words{i}),char(wsc{j}),2,1);
        dists = [dists; dd];
    end
    [sval,sind] = sort(dists(:,1),'ascend');
    matchw = [matchw; wsc{sind(1)}];
    matchd = [matchd; w_amean_sft(sind(1))];
    matchdist = [matchdist; sval(1)];
end

topn = length(words);

close all;
figure(1);
barh(matchd(1:topn), 'facecolor', [31,119,180]/255);
set(gca, 'YTick',(1:topn));
set(gca, 'YTickLabel',matchw(1:topn));
ylim([0,topn+1]);
set(gca,'YDir','reverse');


figure(2);
barh(sizes(1:topn), 'facecolor', [31,119,180]/255);
set(gca, 'YTick',(1:topn));
set(gca, 'YTickLabel',words(1:topn));
ylim([0,topn+1]);
set(gca,'YDir','reverse');

err = sqrt(sum((matchd-sizes).^2)/topn);

figure(3);
barh(abs(sizes(1:topn)-matchd(1:topn)), 'facecolor', [31,119,180]/255);
set(gca, 'YTick',(1:topn));
set(gca, 'YTickLabel',words(1:topn));
ylim([0,topn+1]);
set(gca,'YDir','reverse');

fprintf('RMSE : %.4f\n', err);
