function [waveforms] = segment_detections(recordings,detections)
waveforms = cell(size(detections));
for i = 1:numel(waveforms)
    waveforms{i} = arrayfun(@(x,y) recordings(i,x:y),detections{i}(:,1),detections{i}(:,2),'uni',false);
end
end
