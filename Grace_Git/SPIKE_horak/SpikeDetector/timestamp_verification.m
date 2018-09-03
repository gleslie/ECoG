close all 
clear all

cd '/Applications/eeglab14_1_2b'
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_biosig('/Users/robertjquon/Desktop/SPIKE_DETECTORS/Downsampled/1A.edf');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 

%Calculate the absolute time for the first time stamp (convert relative timestamps to Natus timestamps)
offset = EEG.etc.T0
    %convert natus onset time to unix timestamp
time0 = datetime(offset(1),offset(2), offset(3), offset(4), offset(5), offset(6));
natus_time = datestr(time0);
t1 = time0;
t1.TimeZone = 'America/New_York'
format longG
natus_unixtime = posixtime(t1); % in ms

%Add Unix time to vector of relative times (from EEG.times)
    %new timestamps
newEEG_times = EEG.times + natus_unixtime;


%%%WE NOW HAVE ABS TIMESTAMPS FROM NATUS%%%


%Find peaks on DC channel (findpeaks.m) - output is relative
    %relative = start at arb point, absolute = start at unix timestamp
    %(experiment laptop)
        %(eeglab redraw --> edit --> channel locations) locate DC channel

 
%Match log with recorded DC channel time (CHANGE this step for each trial)
dc = EEG.data(257,:);
plot(dc, '+') 
     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% TRIAL STRUCTURE start 


% find peaks based on threshold height
threshold = 5*10^6; 
[pks, locs] = findpeaks(dc);
lindx = find(pks>threshold);
peaksover = pks(lindx);
peaktimes = locs(lindx); 
peaksovertimes = (peaktimes); 


% OR

[peaks,locs] = findpeaks(dc, 'MinPeakHeight', 5*10^6);
result = [locs*10^5];







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OUTLINE STEP 2
% Obtain timestamps from plot (DC channel)

% Verify positions/spacings of DC with log to ID events

% Findpeaks for exact timepoint

% Input to table for start and stop times












%GOAL: find the natus absolute timestamp for each trial label in the
%experiment log
    %GOAL_INT: verify synchrony between experiment log timestamps and DC
    %peaks
my_EEG = double(EEG.data);
[my_detections,my_amplitudes] = detector(my_EEG,EEG.srate)













