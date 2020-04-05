function [varargout] = load_xml(filename,varargin);

if(regexp(filename,'.xml'))
    xDoc = xmlread(filename);
else
    xDoc = xmlread([filename '.xml']);
end

for j=1:length(varargin)
    string          = varargin{j};
    tmpArg          = xDoc.getElementsByTagName(string);
    c               = tmpArg.getLength-1;
    varargout{j}    = char(tmpArg.item(c).getFirstChild.getData);
end
