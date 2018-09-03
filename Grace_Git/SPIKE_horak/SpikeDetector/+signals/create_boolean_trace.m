function [spikes] = create_boolean_trace(length,matches)
% Create boolean trace of spikes in a singal channel

spikes = false(1,length);
for i = 1:size(matches,1);
    spikes(matches(i,1):matches(i,2)) = true;
end
end

