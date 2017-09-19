function x = coloncatfor(start, stop)
% COLONCAT Concatenate colon expressions
%    X = COLONCAT(START,STOP) returns a vector containing the values
%    [START(1):STOP(1) START(2):STOP(2) START(END):STOP(END)]. 
len = stop - start + 1;
     
% keep only sequences whose length is positive
pos = len > 0;
start = start(pos);
stop = stop(pos);
len = len(pos);
if isempty(len)
    x = [];
    return;
end

% find end and beginning indices for each chunk
partialLength = cumsum(len);
cumStart = [1 partialLength(1:end-1)+1];

% preallocate output
% then loop through start/stop pairs, in order, and fill
numtot = sum(len);
x = zeros(1,numtot);
for k = 1:length(start)
    x(cumStart(k):partialLength(k)) = start(k):stop(k);
end