function [detections,amplitudes] = detector(eeg,srate,thresh,min_spacing)
% Description: Detects sharp, high-amplitude signals in intracranial EEG
% recordings as a proxy for interictal epileptiform activity. See the
% following conference proceedings for a description of the detection
% algorithm and performance results.
%   "Implementation and evaluation of an interictal spike detector." Horak
%   et al. Proc SPIE 9600 (2015). doi:10.1117/12.2189248
%
% Input:
%   eeg - iEEG data [channels x samples]
%   srate - Sample frequency of data (should be >= 200 Hz)
%   (thresh) - Detection threshold (standard deviations from background activity)
%   (min_spacing) - Combines detections occuring within this interval of one another (default: 1s)
%
% Output:
%   detections - Cell array of detections by channel. The detections are
%       represented as pairs of start and end samples {channels x 1}[detections x 2]
%   amplitudes - Processed amplitudes corresponding to each detection. This
%       is the measure used to determine detections {channels x 1}[detections x 1]
%
% Last Updated: 2015-09-23
% Author: Peter Horak

    % Default input parameters
    narginchk(2,5)
    if ~exist('thresh','var')
        thresh = 8; % detection threshold (s.d.)
    end
    if ~exist('min_spacing','var')
        min_spacing = 1; % criteria for combining spikes in a train (sec)
    end
    
    SF = 512; % sample frequency to use with the detector
    
    % Basic input checking
    Nchan = size(eeg,1);
    Nsamp = size(eeg,2);
    assert(abs(round(srate))==srate && srate~=0,'Sample frequency must be a positive integer.')
    assert(srate >= SF,'Sample freuqency must be at least %.0f Hz.',SF)
    assert(Nsamp >= srate,'Recording must contain at least 1 second of data.')
    
    % Put preprocessing of signal into template
    template = triang(round(SF*0.06))';
    preproc = [2,1,-1,-2]/8;
    template = conv(preproc,conv(template,preproc,'valid'),'full');
    tlen = length(template); % assumed minimum inter-spike interval
    
    % Downsample the iEEG data for the detector
    eeg = resample(eeg',SF,srate)';
    Nsamp = ceil(Nsamp*SF/srate);
    % Demean each channel
    eeg = eeg - repmat(mean(eeg,2),[1,Nsamp]);
    
    % Detect spikes in each channel individually
    [detections,amplitudes] = deal(cell(Nchan,1));
    for kChan = 1:Nchan
        peaks = [];

        % Calculate the cross-correlation with the preprocessed template
        xc = conv(eeg(kChan,:),template,'valid');
        
        % Catch empty channels
        xc_std = medstd(xc,SF);
        if xc_std > 0
            % Normalize the cross-correlation
            xc_norm = (xc - mean(xc))/xc_std;
            xc_norm(1) = 0; xc_norm(end) = 0;
            
            % Find regions with high cross-correlation
            if any(abs(xc_norm) > thresh)
                [amps,peaks] = findpeaks(abs(xc_norm),'MinPeakDistance',tlen,'MinPeakHeight',thresh);
                peaks = peaks + ceil(tlen/2); % center detection on template
                
                % Discard detections too close to the start or end of the recording
                bKeep = tlen < peaks & peaks <= Nsamp-tlen;
                amps = amps(bKeep);
                peaks = peaks(bKeep);
            end
        end

        if ~isempty(peaks)
            % Combine spikes in close temporal proximity
            dpeaks = diff(peaks) > min_spacing*SF;
            amps = amps([true dpeaks])';
            dets = [peaks([true dpeaks])'-tlen,peaks([dpeaks true])'+tlen];
        else
            % No detections
            amps = NaN(0,1);
            dets = NaN(0,2);
        end
        % Store detections, converting to the original sample frequency
        amplitudes{kChan} = amps;
        detections{kChan} = round(dets*srate/SF);
    end
end

function sd = medstd(x,n)
% Description: Estimates the baseline standard deviation of a signal by
% taking the median from the distribution of standard deviations calculated
% with a sliding window. Originally based on movingvar by Aslak Grinsted:
% http://www.mathworks.com/matlabcentral/fileexchange/8252-moving-variance
%
% Input:
%   x - signal (e.g. iEEG recording or some derivative signal)
%   n - length of the sliding window in samples
%
% Output:
%   sd - estimate of the baseline standard deviation

win = zeros(1,n)+1/n;
sd = sqrt(median(conv(x.^2,win,'valid')-conv(x,win,'valid').^2));
% sd = median(std(reshape(x(1:n*floor(size(x,2)/n)),n,[]),[],1));
end
