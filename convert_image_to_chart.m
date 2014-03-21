function convert_image_to_chart(im_name)
close all;

imagesset = './images/';

data = './data/';

% video_p = './video/';  
video_p = '/media/HHDD2/vis_course_final_project_video/';
% video_p = '/home/fsadeghi/Documents/uw/Courses/winter14_visualization/FinalProjectVideos/';
% video_p = '/home/izadinia/Documents/UW/FinalProjectVideos/'

% im_name = 'like.png';
% im_name = 'trust.png';
% im_name = 'fun.png';
% im_name = 'relig.png';
% im_name = 'test1.png';
% im_name = 'final-wordle.jpg';
% im_name = 'google.jpg';
% im_name = 'wordle1.jpg';
im = imread(sprintf('%s%s', imagesset, im_name));
im = imresize(im,3);

make_video = 0;

res_path = sprintf('%s%s_cost_connectivity.mat', data, im_name(1:end-4));
load(res_path);
res_path = sprintf('%s%s.mat', data, im_name(1:end-4));
load(res_path, 'nodes','Ilabel');

if(make_video)
    % video_path = sprintf('%s%s.avi', video_p, im_name(1:end-4));
    % aviobj = avifile(video_path,'compression','None','fps',2);
    video_im_path = sprintf('%s%s/', video_p, im_name(1:end-4));
    mkdir(video_im_path);
end

[ih,iw,ik] = size(im);

figure(1);
imshow(im);
hold on;

node_num = length(nodes);

costf = cost;
costf(~connectivity_and) = inf;


bs = zeros(node_num,4);
for i = 1 : node_num
    b = nodes(i).b;
    bs(i,:) = b;
    plot(b([1,1,3,3,1]),b([2,4,4,2,2]));
end

slc = zeros(node_num,1);
w_ends = [];
w = {};
w_area = {};
w_bbs = {};
w_clrs = {};
w_lbls = {};
w_amean = [];
w_chnum = [];
w_updt = [];
w_ipatch = {};
counter = 1;

fig2 = figure(2);
set(fig2,'Position',[700,50, 500,500]);
clf;

for i = 1 : 5: iw

    fig1 = figure(1);
    set(fig1,'Position',[50,50, 650,500]);
    
    
    h2 = plot([i, i], [1, ih], 'r', 'linewidth', 3);
    
    
    inds = find(bs(:,1)<=i & slc==0);
    if(~isempty(inds))
        for j = 1 : length(inds)
            b = bs(inds(j),:);
            plot(b([1,1,3,3,1]),b([2,4,4,2,2]),'r','linewidth',2);
        end
        slc(inds)=1;
        
        if(isempty(w_ends))
            for j = 1 : length(inds)
                w_ends = [w_ends; inds(j)];
                w = [w; nodes(inds(j)).letter];
                w_area = [w_area; nodes(inds(j)).area];
                w_bbs = [w_bbs; nodes(inds(j)).b];
                w_clrs = [w_clrs; nodes(inds(j)).clr];
                w_lbls = [w_lbls; nodes(inds(j)).lbl];
                w_amean = [w_amean; nodes(inds(j)).area];
                w_chnum = [w_chnum; 1];
                w_updt = [w_updt; 1];
            end
        else
            costc = costf(w_ends,inds);
            
            %solve assignment problem
            [assignment, mincost] = assignmentoptimal(costc');
            
            for j = 1 : size(assignment,1)
                if assignment(j)==0
                    w_ends = [w_ends; inds(j)];
                    w = [w; nodes(inds(j)).letter];
                    w_area = [w_area; nodes(inds(j)).area];
                    w_bbs = [w_bbs; nodes(inds(j)).b];
                    w_clrs = [w_clrs; nodes(inds(j)).clr];
                    w_lbls = [w_lbls; nodes(inds(j)).lbl];
                    w_amean = [w_amean; nodes(inds(j)).area];
                    w_chnum = [w_chnum; 1];
                    w_updt = [w_updt; 1];
                else
                    try
                        w_ends(assignment(j)) = inds(j);
                        w{assignment(j)} = [w{assignment(j)} nodes(inds(j)).letter];
                        w_area{assignment(j)}  = [w_area{assignment(j)}, nodes(inds(j)).area];
                        w_bbs{assignment(j)} = [w_bbs{assignment(j)}; nodes(inds(j)).b];
                        w_clrs{assignment(j)} = [w_clrs{assignment(j)}; nodes(inds(j)).clr];
                        w_lbls{assignment(j)} = [w_lbls{assignment(j)}; nodes(inds(j)).lbl];
                        w_amean(assignment(j)) = mean(w_area{assignment(j)});
                        w_chnum(assignment(j)) = length(w_area{assignment(j)});
                        w_updt(assignment(j)) = 1;
                    catch
                        keyboard;
                    end
                end
            end
        end
        
        fig2 = figure(2);
        set(fig2,'Position',[700,50, 500,500]);
        clf;

        val = find(w_chnum>2);
        if(isempty(val))
            drawnow;
            delete(h2);
            continue;
        end
        top_show = 20;
        topn = min(top_show, length(val));
        [sval, sind] = sort(w_amean(val),'descend');
        sind = val(sind);
%         if(length(sval)>20)
%             hamid = 100;
%         end
        barh(sqrt(sval(1:topn)), 'facecolor', [31,119,180]/255);
        set(gca, 'YTick',(1:topn));
        set(gca, 'YTickLabel',w(sind(1:topn)));
%         yt = get(gca, 'YTick');
        ylim([0,top_show+1]);
        hold on
        for j = 1 : length(val)
            if(w_updt(sind(j)))
                mask = zeros(ih,iw);
                for k =1 : length(w_lbls{sind(j)})
                    mask = mask | Ilabel==w_lbls{sind(j)}(k);
                end
                mask = cat(3,mask,mask,mask);

                immask = ~mask .* 255.*ones(size(im)) + mask .* double(im);
                bb = w_bbs{sind(j)};
                b = [min(bb(:,1)), min(bb(:,2)), max(bb(:,3)), max(bb(:,4))];
                w_ipatch{sind(j)} = immask(b(2):b(4),b(1):b(3),:);
                w_updt(sind(j)) = 0;
            end
            
            [ph,pw,pk] = size(w_ipatch{sind(j)});
            ratio = pw/ph;
            iim2 = image(uint8(w_ipatch{sind(j)}),'XData',.09*sqrt(sval(1))*[-(.1+ratio) -.1],'YData',j+[-.4 +.4]);
        end
        hold off;
        set(gca,'YDir','reverse');
    end
    
    if(mod(counter,10)==0)
        F1 = getframe(fig1);
        F1.cdata = imresize(F1.cdata, [floor(size(F1.cdata,1)/8)*8,floor(size(F1.cdata,2)/8)*8]);
        F2 = getframe(fig2);
        F2.cdata = imresize(F2.cdata, [floor(size(F2.cdata,1)/8)*8,floor(size(F2.cdata,2)/8)*8]);
        F.cdata = cat(2,F1.cdata,F2.cdata);
        F.colormap = [];
%         aviobj = addframe(aviobj,F);
        
        if(make_video)
                imwrite(F.cdata, sprintf('%s%06d.jpg', video_im_path, counter));
        end
    end
    drawnow;
    delete(h2);
    counter=counter+1;
end
% aviobj = close(aviobj);

wsc = w;
for i = 1 : length(w)
    if(w_chnum(i)>2)
        corc = google(w{i});
        if(~isempty(corc))
            wsc{i} = corc;
        end
    end
end


system('rm googlecache_q*.html');



%% show them again
top_show = 20;
topn = min(top_show, length(val));
fig3 = figure(3);
set(fig3,'Position',[1250,50, 400,500]);

clf;
[sval, sind] = sort(w_amean(val),'descend');
sind = val(sind);
barh(sqrt(sval(1:topn)), 'facecolor', [31,119,180]/255);
set(gca, 'YTick',(1:topn));
set(gca, 'YTickLabel',w(sind(1:topn)));
ylim([0,top_show+1]);
hold on
for j = 1 : length(val)
    if(w_updt(sind(j)))
        mask = zeros(ih,iw);
        for k =1 : length(w_lbls{sind(j)})
            mask = mask | Ilabel==w_lbls{sind(j)}(k);
        end
        mask = cat(3,mask,mask,mask);
        
        immask = ~mask .* 255.*ones(size(im)) + mask .* double(im);
        bb = w_bbs{sind(j)};
        b = [min(bb(:,1)), min(bb(:,2)), max(bb(:,3)), max(bb(:,4))];
        w_ipatch{sind(j)} = immask(b(2):b(4),b(1):b(3),:);
        w_updt(sind(j)) = 0;
    end
    
    [ph,pw,pk] = size(w_ipatch{sind(j)});
    ratio = pw/ph;
    iim2 = image(uint8(w_ipatch{sind(j)}),'XData',.09*sqrt(sval(1))*[-(.1+ratio) -.1],'YData',j+[-.4 +.4]);
end
hold off;
set(gca,'YDir','reverse');






