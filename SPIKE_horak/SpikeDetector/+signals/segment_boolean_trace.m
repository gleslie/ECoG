function segments = segment_boolean_trace(trace, win)
%Finds segments of a boolean 1D array where the where the value is True.
    
segments = NaN(0,2);
ind = find(trace);
if isempty(ind), return, end

% Find the starts and ends of sample trains (events) exceeding the threshold
starts = zeros(size(ind));
ends = zeros(size(ind));
i = 1;
starts(i) = ind(i);
for j = 2:length(ind)
    if (ind(j)-ind(j-1)) > win
        ends(i) = ind(j-1)+win;
        i = i+1;
        starts(i) = ind(j);
    end
end
ends(i) = ind(end);

% Start and end times for each interictal event
segments = [starts(1:i)',ends(1:i)'];

end