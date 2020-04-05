function [varargout] = loadISCEinfo(filename,varargin);

fid     = fopen(filename,'r');
iscelog = textscan(fid,'%s','Delimiter','');
iscelog = iscelog{:};

for j=1:length(varargin);
    string = varargin{j};
    lia    = ~cellfun(@isempty,strfind(iscelog,string));
    id = find(lia);
    output = iscelog{id(end)};
    splits = strsplit(output,'=');
    if length(splits)==1
        splits = strsplit(output,':');
    end
    
    varargout{j} = splits{end};
end
fclose(fid);

    
