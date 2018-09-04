function [] = spikes_plot(trials_data_row, spike_ints)
%SPIKES_PLOT Summary of this function goes here
%   plots all spikes detected for each trial
% plot spikes

figure(1)
mMax = size(spike_ints);
for s = 1:mMax(1,1)
    subplot(mMax(1,1),1,s);
    plot(trials_data_row(spike_ints{s, 3}, spike_ints{s, 1}:spike_ints{s, 2}))
end
end


