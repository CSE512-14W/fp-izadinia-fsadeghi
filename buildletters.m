function letters = buildletters(fontsize, font)
% letters = buildletters(50, 'Arial')

% fontsize = 50;
% font = 'Arial';

tsize = [42,24];%32;
sz = fontsize+0;
letters = cell(1, 62);
ctr = 1;
for n = [-16:-7,1:26,33:58]
    c = char('A'+n-1);
    figure(1);
    clf;
    axis([-5,5,-5,5]);
    text(0,0,c,'FontUnit', 'Pixel', 'FontSize', fontsize, 'FontName', font, 'Color', 'black');
    set(gca, 'color', 'white');
    axis off;
    drawnow;
    pause(.002);
    
    img = frame2im(getframe(gca));
    drawnow;
    pause(.002);
    
    dimg = double(img);
    dimg = sqrt(dimg(:,:,1).^2+dimg(:,:,2).^2+dimg(:,:,3).^2)/sqrt(3);
    
    let = extractletter(dimg,0,sz);
    
    sr = find(sum(let,2)>0);
    sc = find(sum(let,1)>0);
    
    nlet = let(min(sr):max(sr),min(sc):max(sc));
    
    figure(2);imagesc(nlet);
    nletr = imresize(nlet, tsize);
    nletrt = nletr;
    nletrt(nletr>125) = 1;
    nletrt(nletr<=125) = 0;
    figure(3);imagesc(nletrt);
    
    letters{ctr} = nletrt;
    ctr=ctr+1;
end
templates = letters;
save(sprintf('letters_%s.mat', font), 'fontsize', 'templates');
