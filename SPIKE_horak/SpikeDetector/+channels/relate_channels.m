% use thresh=10
function [relations] = relate_channels(traces)
% Input:
%   traces - boolean traces of detections [channels x samples]
%
% Output:
%   relations - for a given channel (column), each row indicates the
%   fraction of detections shared with the corresponding channel

% Collapse all detections across all channels
EventTS = signals.segment_boolean_trace(sum(traces,1)>0,1);
% For each detection, create a boolean array indicating recruited channels
EventCH = arrayfun(@(x,y) sum(traces(:,x:y),2) > 0,EventTS(:,1),EventTS(:,2),'uni',false);
EventCH = cat(2,EventCH{:}); % [channels x detections]

relations = NaN(size(traces,1));
for kChan = 1:size(relations,1)
    % Find all detections containing the current channel and calculate the
    % fraction of these detections in which which a channel is recruited
    % (for every channel)
    relations(:,kChan) = mean(EventCH(:,EventCH(kChan,:)),2);
end

end
