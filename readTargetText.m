% Func: read the record information in a general format

% INPUT:
% e.g.1
% recordFolder = 'E:\Study\Doctor\科研\MAS\PEER\Baker PEER Transportation\Oak 2 50 gms July 14';
% recordName = 'Oak_2_50_1_FN.acc';
% headerLines = 7;   % read the targeted first line of the file as text
% informLine = 7;  % the target line in the file
% informFmt = '%f %f NPTS, DT';   % the information text pattern

% % e.g.2
% recordFolder = 'D:\Wen\Research\MAS\Duration\Pan Database\Pan_2019_ES\Short\PEERNGARecords_Unscaled Imperial Valley-06 El Centro Array';
% recordName = 'RSN172_IMPVALL.H_H-E01-UP.AT2';
% headerLines = 4;   % read the targeted first line of the file as text
% informLine = 3;  % the target line in the file
% informFmt = '%s TIME SERIES IN UNITS OF %s';   % the information text pattern
% 
% 
% filepath = [recordFolder '\' recordName];   % file path
% 
% informTarget = readTargetText(filepath, ...
%     headerLines, informLine, informFmt);

function informTarget = readTargetText(filepath, ...
    headerLines, informLine, informFmt)


% Read the header as cell
fid = fopen(filepath,'r');  % open file

i = 0;   % row counter
content = cell(headerLines,1);   % initialization
while i < headerLines % loop from the beginning to the end of the .txt
    tline = fgetl(fid); % read each line
    i = i+1;
    content{i} = tline;  % store each line to the content
end

fclose(fid);  % close file

% Read the record information
informTarget = sscanf(content{informLine}, informFmt);

end