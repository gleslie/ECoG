function [c,spike_chans] = field_extent(eeg,evt_chans)
% Input:
%   eeg - ECoG data [channels x samples]
%   evt_chans - channels recruited in the IED
%
% Output:
%   c - correlation of IED principal component with each channel
%
% Notes:
%   MSE does not work as well as correlation. zscoring appears to have a
%   positive impact in some cases and little or none in others.

x = zscore(eeg')';

[~,components] = pca(x(evt_chans,:)');
% [coeffs (Nchan x Ncomp), components (Nsamp x Ncomp),~,~,exlained (Ncomp x 1)] = pca[eeg (Nsamp x Nchan)]

c = abs(corr(components(:,1),x'));

%% NEED TO WORK ON THIS
% TODO: use corr coeff? penalty for distant electrodes? ...

spike_chans = find(c>=0.8);
x = eeg(spike_chans,:);

N = size(x,1);
mse = NaN(N,N);
for i = 1:N
    for j = i:N
        mse(i,j) = mean((x(i,:)-x(j,:)).^2);
    end
end

[~,k] = nanmax(mse(:));
[i,j] = ind2sub(size(mse),k);
spike_chans = spike_chans([i,j]);

% Sort by sign of correlation with PC [lower, higher]
[~,ord] = sort(c(spike_chans));
spike_chans = spike_chans(ord);
end
