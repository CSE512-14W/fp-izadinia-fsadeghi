function [let, avex, avey] = extractletter(img, num, sz)

[rows, columns] = find(img==num);

avex = floor(sum(rows)/length(rows));
avey = floor(sum(columns)/length(columns));

let = zeros(sz, sz);

for m = 1 : length(rows)
    r = max(1, min(sz, rows(m)    + sz/2 - avex));
    c = max(1, min(sz, columns(m) + sz/2 - avey));
    let(r,c) = 255;
end

% for layer = 1 : 1
%     newlet = let;
%     for i = 1 : sz
%         for j = 1 : sz
%             rows = max(1, min(sz,i-1:i+1));
%             cols = max(1, min(sz,i-1:i+1));
%             if(max(max(let(rows,cols)))>let(i,j))
%                 newlet(i,j) = max(max(let(rows,cols)));
%             end
%         end
%     end
%     let = newlet;
% end


