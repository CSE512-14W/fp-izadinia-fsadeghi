function [ov ov_n1 ov_n2] = calc_overlap(box1, boxes2)

nboxes2 = size(boxes2,1);

xmin1 = box1(:,1);
ymin1 = box1(:,2);
xmax1 = box1(:,3);
ymax1 = box1(:,4);

w1 = xmax1 - xmin1 + 1;
h1 = ymax1 - ymin1 + 1;

xmin2 = boxes2(:,1);
ymin2 = boxes2(:,2);
xmax2 = boxes2(:,3);
ymax2 = boxes2(:,4);

w2 = abs(xmax2 - xmin2);
h2 = abs(ymax2 - ymin2);

area1 = w1.*h1; 
area2 = w2.*h2; 

xx1 = max(xmin1, xmin2);
yy1 = max(ymin1, ymin2);
xx2 = min(xmax1, xmax2);
yy2 = min(ymax1, ymax2);

w = xx2 - xx1 + 1;
h = yy2 - yy1 + 1;

inds  = find((w > 0) .* (h > 0));  %% real overlap
ov    = zeros(1, nboxes2);
ov_n1 = zeros(1, nboxes2);
ov_n2 = zeros(1, nboxes2);
inter = w(inds).*h(inds);         %% area of overlap

u = area1 + area2(inds) - w(inds).*h(inds);     %% area of union

ov(inds)    = inter ./ u;                       %% intersection / union
ov_n1(inds) = inter / area1;                    %% intersection / area in dres1
ov_n2(inds) = inter ./ area2(inds);             %% intersection / area in dres2

ov_n2(ov_n2>1) = 1;
ov_n1(ov_n1>1) = 1;
ov(ov>1) = 1;
% % u     = ca + ga(inds) - w(inds).*h(inds);     %% area of union
% % ov(inds)    = inter ./ u;                       %% intersection / union
% % ov_n1(inds) = inter / ca;                       %% intersection / area in dres1
% % ov_n2(inds) = inter ./ ga(inds);                  %% intersection / area in dres2