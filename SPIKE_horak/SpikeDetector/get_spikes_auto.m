close all
clear all
%% 
% load trial_data
% Call get_spikes on all trials for each subject
%% Run Once at Beginning
lengthExcel = 262; %number of rows in excel sheet
spikeCell = cell(lengthExcel, 3); 

%% Change for each subject 
%% 1A = 1:32, 2A = 33:40, 3A = 41:114, 4A = 115:188, 6A = 189:262
startIndex = 189;
endIndex = 262;
subjectID = "6A";


for i = startIndex:endIndex
    [detections, fa] = get_spikes(trial_data{i,1}, 512, '/Users/robertjquon/Desktop/sound_study1/processed');
    spikeCell{i, 1} = subjectID;
    spikeCell{i, 2} = detections;
    spikeCell{i, 3} = fa;
    sprintf("%d Trials Left", endIndex - i)
    sprintf("%d Trials Complete", i - startIndex + 1)
end

%% Save spikes
processed_data_dir = "/Users/robertjquon/Desktop/sound_study1/processed/sound_spikes";
save(processed_data_dir, 'spikeCell', '-v7.3')
