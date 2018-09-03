function [res] = evaluate_channels(est,ref)
res = cell(numel(est),1);
for i = 1:numel(est)
    res{i} = helper(est{i},ref{i});
end
res = [res{:}];
res = struct('TP',[res.TP],'FN',[res.FN],'FP',[res.FP]);
end

function res = helper(est,ref)
% Description: evaluate the accuracy of a spike detector based on how many
% of the detected spikes overlap with reference spike markers
%
% Input:
%   est - array of estimated spike starts/end indices [2 x N]
%   ref - array of reference spike start/end indices [2 x N]

% Find which pairs of labels overlap
R = zeros(size(ref,1),size(est,1));
for i = 1:size(ref,1)
    for j = 1:size(est,1)
        R(i,j) = (ref(i,1) <= est(j,2)) && (est(j,1) <= ref(i,2));
    end
end

% Results
TP = sum(sum(R,2) > 0); % true positives
FN = sum(sum(R,2) < 1); % false negatives
FP = sum(sum(R,1) < 1); % false positives

res = struct('TP',TP,'FN',FN,'FP',FP);
end