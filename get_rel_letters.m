clear all;
clc

global toler_degthresh;
toler_degthresh = 10;
ov_thresh = 0.3;

are_lowthresh = 0.2;
are_highthresh = 5;
clr_threshold = 0.1;

data_dir = './data/';
img_dir = './images/';
% input_imagename = 'final-wordle.jpg';
% input_imagename = 'test1.png';
% input_imagename = 'fun.png';
% input_imagename = 'google.jpg';
% input_imagename = 'relig.png';
% input_imagename = 'wordle1.jpg';
% input_imagename = 'play.png';
% input_imagename = 'like.png';
input_imagename = 'relig.png';
% input_imagename = 'dream.jpg';
% input_imagename = 'kids.png';

% input_imagename = 'trust.png';
% input_imagename = 'vegan.png';

[xx testname ext] = fileparts(input_imagename);

% testname = 'test1';
% testname = 'relig';
% testname = 'google';
% testname = 'fun';
% testname = 'final-wordle';
% file_name = 'wordle1.mat';

file_name = strcat(testname,'.mat');
load(fullfile(data_dir,file_name));

% sort nodes based on x1---------------------------------------------------
nnodes = length(nodes);
bboxes = {nodes(:).b}';
all_x1 = cell2mat(cellfun(@(x) x(1), bboxes,'UniformOutput',false));
[svals sinds] = sort(all_x1);
nodes = nodes(sinds);

all_y2 = cell2mat(cellfun(@(x) x(4), bboxes,'UniformOutput',false));
[svals sinds] = sort(all_y2,'descend');
nodes_ysort = nodes(sinds);

%--------------------------------------------------------------------------
colors = cell2mat({nodes(:).clr}');
clr_distmat = sqrt(sp_dist2(colors,colors));

mn = min(clr_distmat(:));
mx = max(clr_distmat(:));
clr_distmat_norm = (clr_distmat - mn)/(mx-mn);

% bbox horizdist ----------------------------------------------------------
bboxes = {nodes(:).b}';
all_x1 = cell2mat(cellfun(@(x) x(1), bboxes,'UniformOutput',false));
all_x2 = cell2mat(cellfun(@(x) x(3), bboxes,'UniformOutput',false));
all_w = all_x2 - all_x1;

% dx_distmat = sqrt(sp_dist2((all_x1+all_x2)/2,(all_x1+all_x2)/2));
dx_distmat = sqrt(sp_dist2(all_x1,all_x1));

all_y1 = cell2mat(cellfun(@(x) x(2), bboxes,'UniformOutput',false));
all_y2 = cell2mat(cellfun(@(x) x(4), bboxes,'UniformOutput',false));
all_h = all_y2 - all_y1;

all_area = all_w.*all_h;

area12_mat = repmat(all_area,1,nnodes)./repmat(all_area',nnodes,1);

% overlap matrix ----------------------------------------------------------
boxes = cell2mat({nodes(:).b}');
ov_mat = zeros(nnodes,nnodes);
ov1_mat = zeros(nnodes,nnodes);
ov2_mat = zeros(nnodes,nnodes);
for i = 1:nnodes
    this_n = nodes(i);
    this_box = this_n.b;
    [ov ov_n1 ov_n2] = calc_overlap(this_box, boxes);
    ov_mat(i,:) = ov';
    ov1_mat(i,:) = ov_n1;
    ov2_mat(i,:) = ov_n2;
end


%boundary2boundary dist----------------------------------------------------
%b2bdist is : x2-x1!
x1 = boxes(:,1);
x2 = boxes(:,3);
x2_mat1 = repmat(x2,1,nnodes);
x1_mat2 = repmat(x1',nnodes,1);
b2bdist = abs(x2_mat1 - x1_mat2);

%--------------------------------------------------------------------------

centers = cell2mat({nodes(:).cen}');
cntr_distmat = sqrt(sp_dist2(centers,centers));
mn = min(cntr_distmat(:));
mx = max(cntr_distmat(:));
cntr_distmat_norm = (cntr_distmat - mn)/(mx - mn);

%get inline ---------------------------------------------------------------
self_0deg = 0;
% self_90deg = 90;
inline0_relmat = zeros(nnodes,nnodes);
% inline90_relmat = zeros(nnodes,nnodes);

for i = 1:nnodes
    this_n = nodes(i);
    this_color = this_n.clr;
    this_cntr = this_n.cen;
    this_w = this_n.b(3) - this_n.b(1);
    this_box = this_n.b;
    %start getting its word!
    
    valid_inds = [1:nnodes]';
    valid_log = ones(nnodes,1);
    valid_log(i) = 0;
    here_valid_inds = valid_inds(logical(valid_log));
    
    centers_cell = centers(here_valid_inds,:);
    centers_cell = mat2cell(centers_cell,ones(size(centers_cell,1),1),[2]);
    inlin_letters = cell2mat(arrayfun(@(x) is_inLine(self_0deg,this_cntr,x),centers_cell,'UniformOutput',false));
    inlin_letters = here_valid_inds(inlin_letters);
    
    inlin_letters = [i,inlin_letters'];
    inlin_letters = sort(inlin_letters);
    for j = 1:length(inlin_letters)-1
        node2 = nodes(inlin_letters(j+1));
        w2 = node2.b(3) - node2.b(1);
        box2 = node2.b;
        [ov ov_n1 ov_n2] = calc_overlap(this_box, box2);
        inline0_relmat(inlin_letters(j),inlin_letters(j+1)) = 1;
    end
end

% dis/w DEG0---------------------------------------------------------------
% cntr_distmat
% clr_distmat
cntr_distmat_divw = zeros(size(cntr_distmat));
cntr_distmat_divh = zeros(size(cntr_distmat));
for i = 1:nnodes
    this_n = nodes(i);
    this_color = this_n.clr;
    this_cntr = this_n.cen;
    this_box = this_n.b;
    x1 = this_box(1);   y1 = this_box(2);
    x2 = this_box(3);   y2 = this_box(4);
    w = x2 - x1;
    h = y2 - y1;
    cntr_distmat_divw(i,:) = cntr_distmat(i,:)/w;
%     cntr_distmat_divh(i,:) = cntr_distmat/h;
end
cntr_distmat_divw_norm = cntr_distmat_divw/max(cntr_distmat_divw(:));
% cntr_distmat_divh_norm = cntr_distmat_divh/max(cntr_distmat_divh(:));

% bbox overlap ------------------------------------------------------------
ov_conct_mat = zeros(nnodes,nnodes);
ov_conctvals_mat = zeros(nnodes,nnodes);

for i = 1:nnodes
    node1 = nodes(i);
    node1_color = node1.clr;
    node1_cntr = node1.cen;
    node1_box = node1.b;
    n1_y1 = node1_box(2);
    n1_y2 = node1_box(4);
    w1 = node1_box(3) - node1_box(1);
    for j = 1:nnodes
        node2 = nodes(j);
        node2_color = node2.clr;
        node2_cntr = node2.cen;
        node2_box = node2.b;
        n2_y1 = node2_box(2);
        n2_y2 = node2_box(4);
        w2 = node2_box(3) - node2_box(1);
        
        min_y1 = min(n1_y1,n2_y1);
        max_y1 = max(n1_y1,n2_y1);
        min_y2 = min(n1_y2,n2_y2);
        max_y2 = max(n1_y2,n2_y2);
        
        union = max_y2 - min_y1;
        intersect  = min_y2 - max_y1;
        
        % is there any overlap?
        
        if(intersect>0)
            ov = intersect/union;
            ov_conctvals_mat(i,j) = ov;
            if(ov>=ov_thresh)
                ov_conct_mat(i,j) = 1;
            end
        end
        
%         if(intersect>0)
%             if(dx_distmat(i,j)<=(2.5*max(w1,w2)) && ov ==0) %/5)
% %             if(dx_distmat(i,j)<=(max(w1,w2)) && ov ==0) %/5)
%                 ov = intersect/union;
%                 ov_conctvals_mat(i,j) = ov;
%                 if(ov>=ov_thresh)
%                     ov_conct_mat(i,j) = 1;
%                 end
%             end
%         end
    end
end


w1_mat = repmat(all_w,1,nnodes);
w2_mat = repmat(all_w',nnodes,1);

avg_w1w2 = (w1_mat + w2_mat)/2;
max_w1w2 = max(cat(3,w1_mat,w2_mat),[],3);
sum_w1w2 = sum(cat(3,w1_mat,w2_mat),3);

% connectivity_and = (ov_conctvals_mat>=ov_thresh).*(inline0_relmat).*(dx_distmat<=2*avg_w1w2).*(ov_mat == 0).*(b2bdist<=avg_w1w2);
% connectivity_and = (ov_conctvals_mat>=ov_thresh).*(inline0_relmat).*(dx_distmat<=2*max_w1w2).*(ov_mat == 0).*(b2bdist<=avg_w1w2);
% connectivity_and = (ov_conctvals_mat>=ov_thresh).*(inline0_relmat).*(dx_distmat<=sum_w1w2).*(ov_mat == 0).*(b2bdist<=avg_w1w2);
% connectivity_and = (ov_conctvals_mat>=ov_thresh).*(dx_distmat<=sum_w1w2).*(ov_mat == 0).*(b2bdist<=avg_w1w2).*...
%                     (area12_mat>=are_lowthresh).*(area12_mat<=are_highthresh).*...
%                     (clr_distmat_norm<=clr_threshold);

% connectivity_and = (ov_conctvals_mat>=ov_thresh).*(inline0_relmat).*(dx_distmat<=sum_w1w2).*(ov_mat == 0).*(b2bdist<=avg_w1w2).*...
%                     (clr_distmat_norm<=clr_threshold);

connectivity_and = (ov_conctvals_mat>=ov_thresh ).*(0<=(2*max_w1w2 - dx_distmat)).*(ov_mat <=0.2).*(0<=(avg_w1w2 - b2bdist)).*...
                   (area12_mat>=are_lowthresh).*(area12_mat<=are_highthresh).*...
                   (0<=(clr_threshold - clr_distmat_norm));

% are_lowthresh = 0.2;
% are_highthresh = 5;

% % inline0_relmat
% % ov_mat
% % ov1_mat 
% % ov2_mat
% % dx_distmat
% % cntr_distmat_divw
% % cntr_distmat_norm
%connectivity based on color
% cntdist_threshold = 0.3;
% clr_threshold = 0.1;
% (clr_distmat_norm<clr_threshold)
% (cntr_distmat_norm<cntdist_threshold)

cost = 0.5*clr_distmat_norm + 0.5*cntr_distmat_norm;
% connectivity_or = (inline0_relmat | ov_conct_mat);
% connectivity_and = (inline0_relmat .* ov_conct_mat);

save(fullfile(data_dir,[testname '_cost_connectivity.mat']),'cost','connectivity_and','nodes',...
        'clr_distmat_norm','cntr_distmat_norm','all_w','ov_conctvals_mat','inline0_relmat',...
        'b2bdist','ov_mat','ov1_mat','ov2_mat',...
        'ov_thresh','toler_degthresh');

% 
% if(1)
%     save(fullfile(data_dir,[testname '_cost_connectivity.mat']),'cost','connectivity_or','connectivity_and','nodes');
% end

% visualize----------------------------------------------------------------
% im = imread(fullfile(img_dir,[testname '.png']));
% im = imread(fullfile(img_dir,[testname '.jpg']));
im = imread(fullfile(img_dir,input_imagename));
im = imresize(im,3);
figure(1);imshow(im);hold on;
% connectivity_rel = ov_conct_mat;
connectivity_rel = connectivity_and;
% connectivity_rel = inline0_relmat;
% connectivity_rel = connectivity_or;
% connectivity_rel = connectivity_and;
% connectivity_rel = connectivity_and;
cost_filt = cost.*connectivity_rel;
mx_cost = max(cost_filt(:));
mn_cost = min(cost_filt(:));

mx_lnweight = 15;
mn_lnweight = 5;

for i = 1:size(cost_filt,1)
    for j = 1:size(cost_filt,1)
        this_cost = cost_filt(i,j);
        if(this_cost>0)
            node1 = nodes(i);
            node2 = nodes(j);
            
            c1 = node1.cen;
            color = node1.clr/255;
            c2 = node2.cen;
            lnw = ((mn_lnweight - mx_lnweight)/(mx_cost - mn_cost))*(this_cost -mn_cost) + mx_lnweight;
            
            figure(1);plot([c1(1),c2(1)],[c1(2),c2(2)],'LineWidth',lnw,'Color',color);hold on;
            
        end
    end
end

hold off;
















