function [varargout] = load_xml(filename,varargin);

if(regexp(filename,'.xml'))
    xDoc = xmlread(filename);
else
    xDoc = xmlread([filename '.xml']);
end

for j=1:length(varargin)
    string          = varargin{j};
    tmpArg          = xDoc.getElementsByTagName(string);
    varargout{j}    = char(tmpArg.item(0).getFirstChild.getData);
end
