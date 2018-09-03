function [res] = evaluate_simple(est_ts,est_ch,ref_ts,ref_ch)
% Description: evaluate the accuracy of a spike detector based on how many
% of the detected spikes overlap with reference spike markers
%
% Input:
%   est - array of estimated spike starts/end indices [2 x N]
%   ref - array of reference spike start/end indices [2 x N]

% Find which pairs of labels overlap
R = false(size(ref_ts,1),size(est_ts,1));
for i = 1:size(R,1)
    for j = 1:size(R,2)
        R(i,j) = (ref_ts(i,1) <= est_ts(j,2)) && (est_ts(j,1) <= ref_ts(i,2)) && ...
            (numel(intersect(ref_ch{i},est_ch{j})) > 0);
    end
end

% Results
TP = sum(sum(R,2) > 0); % true positives
FN = sum(sum(R,2) == 0); % false negatives
FP = sum(sum(R,1) == 0); % false positives

res = struct('TP',TP,'FN',FN,'FP',FP);

end