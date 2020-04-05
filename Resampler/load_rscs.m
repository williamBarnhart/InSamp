function [varargout]=load_rscs(filename,varargin)

if(regexp(filename,'.rsc'))
    [a,b]=textread(filename,'%s%s');
else
    [a,b]=textread([filename '.rsc'],'%s%s');
end

for j=1:length(varargin)
  string=varargin{j};
  string=upper(string);  
  found=0;
  for i=1:length(a)
    if(strcmp(a(i),string))
     if(str2num(char(b(i))))
        varargout{j} = eval(char(b(i)));
    else
        varargout{j} = char(b(i));
     end
    found=1;
    end
  end
  if(~found)
      varargout{j}='Variable not found';
  end
end

