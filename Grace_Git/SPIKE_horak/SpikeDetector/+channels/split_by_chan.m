function [detections,types] = split_by_chan(Nchan,EventChans,EventTS,clInd)
detections = cell(Nchan,1);
types = cell(Nchan,1);
for ch = 1:Nchan
    bChan = cellfun(@(x) any(x==ch),EventChans);
    evts = EventTS(bChan,:);
    [~,ord] = sort(evts(:,1));
    detections{ch} = evts(ord,:);
    if exist('clInd','var')
        cli = clInd(bChan);
        types{ch} = cli(ord)';
    end
end
end