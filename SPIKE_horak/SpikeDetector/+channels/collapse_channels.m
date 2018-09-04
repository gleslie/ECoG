function [EventTS,EventChans] = collapse_channels(detections,traces,thresh)
% if exist('thresh','var')
%     EventTS = signals.segment_boolean_trace(sum(traces,1)>0,1);
%     % For each detection, create a boolean array indicating recruited channels
%     EventCH = arrayfun(@(x,y) sum(traces(:,x:y),2) > 0,EventTS(:,1),EventTS(:,2),'uni',false);
%     EventCH = cat(2,EventCH{:}); % [channels x detections]
%     d = pdist(double(EventCH),'hamming');
%     l = linkage(d);
%     groups = cluster(l,'CutOff',thresh,'Criterion','distance');
if exist('thresh','var')
    nSpikes = cellfun(@(x) size(x,1),detections);

    relations = cluster.relate_channels(traces);

    % groups: array of group labels corresponding to each channel
    groups = zeros(size(traces,1),1);
    groups(nSpikes==0) = NaN;
    currGroup = 1;
    while any(groups==0)
        ungrouped = find(groups==0);
        kCurr = ungrouped(find(nSpikes(ungrouped) == max(nSpikes(ungrouped)),1,'first'));
        groups(kCurr) = currGroup;

        ungrouped = find(groups==0);
        for j = 1:numel(ungrouped)
            agreement = relations(kCurr,ungrouped(j));
            if (agreement >= thresh) % 0.6
                groups(ungrouped(j)) = currGroup;
            end
        end
        currGroup = currGroup + 1;
    end
else
    groups = ones(size(traces,1),1);
end

% grps: cell array with channels in each group
[EventTS,EventChans] = deal(cell(nanmax(groups),1));
for kGroup = 1:numel(EventTS)
    grps = find(groups==kGroup);
    grp_tr = traces(grps,:);
    
    EventTS{kGroup} = signals.segment_boolean_trace(sum(grp_tr,1)>0,1);
    EventChans{kGroup} = arrayfun(@(x,y) grps(sum(grp_tr(:,x:y),2) > 0)',EventTS{kGroup}(:,1),EventTS{kGroup}(:,2),'uni',false);
end
% if exist('thresh','var')
%     EventTS = EventTS(cellfun(@(x) size(x,1)*(200/size(traces,2))*6>=thresh,EventTS));
% end
EventTS = cat(1,EventTS{:});
EventChans = cat(1,EventChans{:});

end