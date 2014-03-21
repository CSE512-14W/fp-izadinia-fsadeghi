function meanq = google(varargin)
%GOOGLE searches varargin at google
%  google.m is a shell interface to initiate Google search and display 
%  first few results in Matlab Command Window. The function treats varargin
%  as the query word(s) and uses regular expression to analyze the text 
%  returned by Google. One of the fun parts is you can type typos, since 
%  Google usually knows what is right from wrong.
%
%  google.m keeps cache so to prevent bugging Google from same query. it
%  displays Cache when it is. Users are allowed to clear the cache.
%
%  Examples:
%  google mathworks
%  google matlab file xechange 
%  google matlab chaowei chen
%
%  Chao-Wei Chen. 3/30/2013

q=google_query(varargin);
if isempty(q),return;end

url=q2url(q);

txt=google_urlread(url,q); % read from google or cached

meanq = google_did_you_mean(txt);
%urls=regexp(txt,'<a href=".*?(http://.*?)&amp.*?>(.*?)</a>','tokens')';
urls=regexp(txt,'<a href=".*?q=(http://.*?)&amp.*?>(.*?)</a>.*?<cite>(.*?)</cite>.*?<span class="st">(.*?)</span>','tokens')';

displaylink(urls);

end
function url=q2url(q)
config=load_google_config;
if isempty(config.key),
    url=['https://www.google.com/search?q=' q ];    
else
    url=['https://www.google.com/search?q=' q '&key="' config.key '"'];    
end

end
function q = google_did_you_mean(txt)
q=regexp(txt,'<a class="spell" href=".*?q=(.*?)&amp','tokens');
if ~isempty(q)
    q=q{1};q=q{1};   url=q2url(q);
    dsp=['Showing results for <a href="matlab:google(''' q ''')">' q '</a>'];
%     disp(dsp);
end
end

function txt=google_urlread(url,q)
cache=['googlecache_q=' q '.html'];
loc=which(cache);
path=fileparts(which('google.m'));
if isempty(loc)    
    loc=fullfile(path,cache);
    urlwrite(url,loc);    % save cache
else
    loc_rm=fullfile(path,'googlecache*.html');
%     disp(['---Cache <a href="matlab:delete(''' loc_rm ''')">(clear?)</a>---']);
    
end

loc=['file:///' strrep(loc,'\','/')]; % Windows style
txt=urlread(loc);
end

function displaylink(urls)

num=0;
for k=1:numel(urls)
    url=urls{k};
    % has problem in k=1
    link=url{1};string=url{2};cite=url{3};description=url{4};
    num=num+1;

    string=regexprep(string,'</?br?>','');
    cite=regexprep(cite,'</?br?>','');
    description=regexprep(description,'</?br?>','');
    dsp=[num2str(num) ':  <a href="matlab:web(''' link ''',''-browser'')">' string '</a>'];

    disp(dsp);

    if ~isempty(which('cprintf.m')) % for stylish output
        pause(0.02);
        cprintf('comment',['\t' cite '\n']);pause(0.01);
        cprintf('text',['\t' description '\n']);pause(0.01);        
        disp(' ');
    end
    
end
end

function q=google_query(v)
q=[];
qn=numel(v);
switch(qn)
    case 0, fprintf('no query key word\n');
    case 1, q=v{1};
    otherwise,        
        while(numel(v)>=1)
            q=[q v{1} '+'];
            v=v(2:end);
        end                
        q=strrep(q,' ','');
        q=q(1:end-1);
end

end

function config=load_google_config

path=fileparts(which('google.m'));
matname=fullfile(path,'google.config.mat');

if exist(matname,'file'),
    load(matname,'config');    
else
  
    uicontrol('style','text','fontsize',14,...
    'units','normalized','position',[0 0.6 1 0.3],'string',{'config google.m for the first time.','(delete google.config.mat to reappear this message)'});    
    uicontrol('style','pushbutton','fontsize',14,...
    'units','normalized','position',[0 0.3 1 0.3],'string','get Google API key, but none is fine currently',...
    'callback',@callback_get_google_API_key);
    uicontrol('style','pushbutton','fontsize',14,...
    'units','normalized','position',[0 0 1 0.3],'string','download cprintf.m for stylish output',...
    'callback',@callback_download_cprintf);
    
    config.key='';
    save(matname,'config');
end

%%
    function callback_get_google_API_key(obj,event)
        web('https://developers.google.com/custom-search/v1/getting_started#auth','-browser');        
        config.key=cell2mat(inputdlg('Google API access key:','Enter your key',1,{'AIzaSyCj1-7uMW-KOD_xTWAm_u_4X561gnRMMMg'}));            
        save(matname,'config');
    end
    function callback_download_cprintf(obj,event)
        web('http://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window','-browser');        
    end
end