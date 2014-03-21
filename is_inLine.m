function  isyes = is_inLine(deg,loc1,loc2)
loc2 = loc2{1};
if(length(loc2)~=2)
    disp('error in inline');
    keyboard
end
global toler_degthresh;
x1 = loc1(1);
y1 = loc1(2);
x2 = loc2(1);
y2 = loc2(2);

% this_deg = (180*atan(abs((y2 - y1)/(x2-x1))))/pi;
this_deg = abs((180*atan(((y2 - y1)/(x2-x1))))/pi);

if(isnan(this_deg) || isinf(this_deg))
    disp('error in inline');
    keyboard;
end

if(abs(this_deg - deg)<=toler_degthresh)
    isyes = true;
else
    isyes = false;
end

if(isyes)
    fprintf('this deg %d\n',this_deg);
end
