function [detections,fa] = get_spikes(EEG,SF,file)
% Input:
%   EEG - The [channels x timestamps] matrix for a specific trial
%   SF - Sampling Rate
%   file - Path to where EEG data is stored

% Output:
%   res - performance metrics [session x channel].[1 x detection]

N = size(EEG,1);
twin = 31; % NEEDS TO MATCH CORRESPONDING VARIABLE IN THE DETECTOR %

% Get marks and detections
[detections,trace] = detector(EEG,SF,8,1); % removed additional SF argument 8,60

trace = false(size(EEG));
for i = 1:numel(detections)
    for j = 1:size(detections{i},1)
        trace(i,detections{i}(j,1):detections{i}(j,2)) = true;
    end
end


% Demean entire matrix
EEG = EEG - repmat(mean(EEG,2),[1,size(EEG,2)]);
% Notch filter EEG (detector does internally)
[b,a] = iirnotch(120/SF,(120/SF)/35,3);
EEG = double(EEG); % converted to double 
EEG = filtfilt(b,a,EEG')';

% Low-pass filter EEG (irrelevant for detector which uses derivative)
[b,a] = butter(3,2/SF,'high');
EEG = filtfilt(b,a,EEG')';

[features] = extract_features(EEG,detections,SF);

fa = cell(N,1);
for j = 1:N
    dets = detections{j};
    
    % Extract multi-channel features
    nChRecruited = arrayfun(@(x,y) sum(sum(trace(:,x:x+2*twin),2) > 0),dets(:,1),dets(:,2),'uni',false);

    wins = cat(2,max(dets(:,1) + twin -round(0.1*SF),1),min(dets(:,1) + twin + round(0.2*SF),size(EEG,2)));
    [extent,source] = arrayfun(@(x,y) channels.field_extent(EEG(:,x:y),sum(trace(:,x:y),2)>0),wins(:,1),wins(:,2),'uni',false);

    fa{j} = struct('file',file,'channel',j,...
        'kur',kurtosis(EEG(j,:)),...
        'sd',std(EEG(j,:)),'msd',signals.medstd(EEG(j,:),SF),...
        'nChan',nChRecruited,'extent',extent,'source',source,...
        'features',num2cell(features{j},2));
end

end