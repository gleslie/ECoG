% Run PARSER on logs to create CSV for import 
close all 
% clear all 

cd '/Applications/eeglab14_1_2b'
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EDF_FILEPATH = '/Users/robertjquon/Desktop/sound_study1/Downsampled/12B_1220_ds.edf';   % change this for each new subject
CSV_FILEPATH = '12B_parse.csv';                                                         % change this for each new subject
EEG = pop_biosig(EDF_FILEPATH);                    
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 


% % DO NOT NEED THIS FOR THIS METHOD
% % Calculate the absolute time for the first time stamp (convert relative timestamps to Natus timestamps)
% offset = EEG.etc.T0
% % Convert natus onset time to unix timestamp
% time0 = datetime(offset(1),offset(2), offset(3), offset(4), offset(5), offset(6));
% natus_time = datestr(time0);
% t1 = time0;
% t1.TimeZone = 'America/New_York'
% format longG
% natus_unixtime = posixtime(t1); % in ms
% EEG.t = join(string(EEG.times), natus_unixtime)
% %Add Unix time to vector of relative times (from EEG.times)
%     %new timestamps
% newEEG_times = EEG.times + natus_unixtime;
% %%%WE NOW HAVE ABS TIMESTAMPS FROM NATUS%%%


% Find peaks on DC channel (findpeaks.m) - output is relative
    %relative = start at arb point, absolute = start at unix timestamp
    %(experiment laptop)
        %(eeglab redraw --> edit --> channel locations) locate DC channel

% Match log with recorded DC channel time (CHANGE this step for each trial)
dc = EEG.data(257,:);
plot(dc) 
    
% FIND DC OUTPUT VALUES AND ASSIGN TO START/END TIMES:
thresh1 = 2*10^5;
thresh2 = 1*10^6;
dc(dc > thresh2) = thresh2;
dc(dc < thresh1) = 0;
dc_new = dc;
plot(dc_new)
ylim([-1e6 2e6])
hold on

[pks, locs] = findpeaks(dc_new);

% ID unique peaks for each stim
firstPoint = locs(1);        % First time point is the first element in locs
uniqueLocs = [locs(1)];      % First time point is a unique peak
timeThresh = 1000;           % Time distance threshold between peaks
for i = 2:length(locs)
    if (locs(i) - locs(i - 1) > timeThresh)
        firstPoint = locs(i);
        uniqueLocs = [uniqueLocs, locs(i)];
    end
end

% Correction to add last stimuli
penultimateIndex = length(uniqueLocs);
baselineTime = uniqueLocs(end);
lastRest = round(uniqueLocs(penultimateIndex - 1) + 16.38 * 512);
uniqueLocs(penultimateIndex) = lastRest;
uniqueLocs(penultimateIndex + 1) = baselineTime;

uniqueAmp = ones(1, length(uniqueLocs)) .* 1e6;
plot(uniqueLocs, uniqueAmp, '*')
hold off

% Find differences between uniquelocs to match with log differences
% (uniqueLocs(86) - uniqueLocs(85)) / 512
A = uniqueLocs;
diff = (A(2:end) - A(1:end-1)+1) / 512;
diff = [0, diff]; 
uniqueLocs2 = [uniqueLocs; diff];

% Define start and end times based on experiment parameters (ex: 60s =
% baseline, 15s stimuli)
% Write a loop to define time intervals based on predetermined times and
% label:
uniqueLocs3 = num2cell(uniqueLocs2);
for i = (1:length(uniqueLocs2(2,:)))
    val = uniqueLocs2(2, i);
    if (95 > val) && (val > 59)       % May have to adjust upper value for different subject 'Baselines'
        uniqueLocs3{3, i} = 'Baseline';
    elseif (17 > val) && (val > 14)
        uniqueLocs3{3, i} = 'Stimuli';
    else
        uniqueLocs3{3, i} = 'NA';
    end
end

% Remove multiple starting baselines if T 
for i = (1:10)                           
    val1 = uniqueLocs3{2,i};
    val2 = uniqueLocs3{2,i+1};
    if (val2 > 100)
        uniqueLocs3{3,i} = 'NA';
    end  
end

% Change last stimuli to baseline
uniqueLocs3{3, length(uniqueLocs3)} = 'Baseline';

% Correct times to reflect experiment times
uniqueLocs4 = {};
[~, subjectName, ~] = fileparts(EDF_FILEPATH);
j = 1;
for i = (1:length(uniqueLocs3))
    name = string(uniqueLocs3(3,i));
    if strcmp(name, 'Baseline')
        uniqueLocs4{j, 1} = subjectName;
        uniqueLocs4{j, 2} = name;
        uniqueLocs4{j, 3} = uniqueLocs3{1, i} - 512*60;
        uniqueLocs4{j, 4} = uniqueLocs3{1, i};
        j = j + 1;
    elseif strcmp(name, 'Stimuli')
        uniqueLocs4{j, 1} = subjectName;
        uniqueLocs4{j, 2} = name;
        uniqueLocs4{j, 3} = uniqueLocs3{1, i-1}; 
        uniqueLocs4{j, 4} = uniqueLocs3{1, i};
        j = j + 1;
    end
end

% load .csv file created from log
% Import log as csv to extract corresponding names 
cd '/Users/robertjquon/Desktop/sound_study1/ECoG/SPIKE_horak/SpikeDetector'
addpath('sound_logs')
logtimetable = importcsvfile(CSV_FILEPATH);                                               
logtimetable2 = transpose(logtimetable);
lognames = [logtimetable2{2,:}];


% replace 'stimuli' with names from log
newlognames = [];
for i = (1:length(lognames))
    name = lognames(i);
    if ~strcmp(name, 'N/A')
        newlognames = [newlognames lognames(i)];
    end 
end

if length(newlognames) == length(uniqueLocs4)
    for i = (1:length(uniqueLocs4))
        uniqueLocs4{i, 2} = newlognames(i);
    end
else
    error("Line 144 -- There is no 1-to-1 relationship between log and natus times")
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% finalLocs = {};     % RUN ONCE ONLY

finalLocs = [finalLocs; uniqueLocs4];   %RUN this after every new subject

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTES
% Obtain timestamps from plot (DC channel)

% Verify positions/spacings of DC with log to ID events

% Findpeaks for exact timepoint

% Input to table for start and stop times
%GOAL: find the natus absolute timestamp for each trial label in the
%experiment log
    %GOAL_INT: verify synchrony between experiment log timestamps and DC
    %peaks

% my_EEG = double(EEG.data);
% [my_detections,my_amplitudes] = detector(my_EEG,EEG.srate)











