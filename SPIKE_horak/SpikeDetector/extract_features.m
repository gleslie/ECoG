function [features] = extract_features(eeg,detections,Fs)

% Input:
%   eeg - ECoG data sampled at 200 Hz [channels x samples]
%   detections - IED detections from detect_spikes.m
%   Fs - the sample rate (should be 200 Hz)
%
% Output: {channels x 1}[detections x templates]
%   features - various features

swin = round(0.02*Fs);
twin = 9; % NEEDS TO MATCH CORRESPONDING VARIABLE IN THE DETECTOR %

features = cell(size(detections));
for kChan = 1:size(features,1)
    dets = detections{kChan};
    wins = cat(2,max(dets(:,1) + twin -round(0.1*Fs),1),min(dets(:,1) + twin + round(0.2*Fs),size(eeg,2)));

%     wfs_seg = arrayfun(@(x,y) eeg(kChan,x:y),dets(:,1),dets(:,2),'uni',false);
    dur = arrayfun(@(x,y) y-x+1,dets(:,1),dets(:,2));
    
    waveforms = arrayfun(@(x,y) eeg(kChan,x:y),wins(:,1),wins(:,2),'uni',false);
    avg_slope = cellfun(@(x) mean(abs(diff(x))),waveforms);
    max_slope = cellfun(@(x) max(abs(diff(x))),waveforms);
    amp = cellfun(@(x) max(abs(x)),waveforms);
    
    % Smooth waveforms for next step
    waveforms = cellfun(@(x) smooth(x,swin),waveforms,'uni',false);
    [dur1,dur2,rising,falling,curvature,area,skew] = deal(NaN(numel(waveforms),1));
    for kDet = 1:numel(waveforms)
        wf = waveforms{kDet};
        [max_amp,kMax] = max(wf(1+swin:end-swin)); kMax = kMax + swin;
        [min_amps,kMins] = findpeaks(-wf); min_amps = -min_amps;
        kMin1 = kMins(find(kMins < kMax & min_amps < mean(wf(1:kMax)),1,'last'));%(max_amp+mean(wf))/2,1,'last'));
        kMin2 = kMins(find(kMins > kMax & min_amps < mean(wf(kMax:end)),1,'first'));%(max_amp+mean(wf))/2,1,'first'));
        if isempty(kMin1), kMin1 = 1; end
        if isempty(kMin2), kMin2 = numel(wf); end
        min_amp1 = wf(kMin1);
        min_amp2 = wf(kMin2);

        dur1(kDet) = (kMax-kMin1)/Fs;
        dur2(kDet) = (kMin2-kMax)/Fs;
        rising(kDet) = (max_amp-min_amp1)/dur1(kDet);
        falling(kDet)= (min_amp2-max_amp)/dur2(kDet);
        curvature(kDet) = (falling(kDet)-rising(kDet))*Fs*2/(kMin2-kMin1);
        area(kDet) = sum(abs(wf(kMin1:kMin2)));
        skew(kDet) = sum(abs(wf(kMin1:kMax)))-sum(abs(wf(kMax:kMin2)));

%         timeaxis = 0:1/Fs:(length(wf)-1)/Fs;
%         plot(timeaxis,wf,timeaxis([kMin1,kMax,kMin2]),wf([kMin1,kMax,kMin2]),'.')
    end

    features{kChan} = cat(2,avg_slope,max_slope,rising,falling,...
        dur1,dur2,dur,amp,curvature,area,skew);
end

end