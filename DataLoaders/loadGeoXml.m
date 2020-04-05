function [width, leng, X1, Y1, xstep, ystep] = loadGeoXml(filename);

%For geocoded interferograms, need:
% coordinate1 (longitude)
%     startingvalue
%     delta
%     size (width)
%coordinate2 (latitude
%     startingvalue
%     delta
%     size (length)
xmlStruct = parseXML(filename);



step1 = xmlStruct.Children;
numChild1 = length(step1);

coordId= [];
for j = 1:numChild1
    if strmatch(step1(j).Name,'component')==1
        coordId = [coordId j];
    end
end

coord1 = step1(coordId(1));
coord2 = step1(coordId(2));

% Extract info for coordinate 1
xstep      = coord1.Children(8).Children(2).Children.Data;
width   = coord1.Children(16).Children(2).Children.Data;
X1      = coord1.Children(18).Children(2).Children.Data;

%Extract info for coordinate 2
ystep  = coord2.Children(8).Children(2).Children.Data;
leng   = coord2.Children(16).Children(2).Children.Data;
Y1      = coord2.Children(18).Children(2).Children.Data;