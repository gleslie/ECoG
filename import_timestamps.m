%%% Import and Preprocess of ECoG Data using Matlab
%%% v1 Grace Leslie 7 August 2018
close all

%%% For you to update according to your local directory structure:
%%% Global File and Directory Names
eeglab_dir = '/Users/grace/Documents/eeglab14_1_1b'
data_dir = '/Users/grace/Desktop/ECoG-Sound-Study'
end_data_dir = '/Users/grace/Desktop/ECoG-Sound-Study/processed'
timestamps_filename = '/Users/grace/Desktop/ECoG-Sound-Study/table_sound1.xlsx';
ImportDataSetNumber = 1; %% Change this to the dataset in the list you want to import.
%%% End of variables to update

%%% Load EEGLAB
cd(eeglab_dir)
eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
eeglab('redraw');

%%% List all EDF files in directory
cd(data_dir);
s = dir('*.edf'); % s is structure array with fields name, 
                   % date, bytes, isdir
EEGfiles = {s.name}';

%%% Import data from spreadsheet
% please note cell ranges
[~, ~, tablesound11] = xlsread(timestamps_filename,'Sheet1');
tablesound11 = tablesound11(2:263,:);
tablesound11(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tablesound11)) = {''};

%%% Import variable names from first row
[~, ~, tablenames] = xlsread(timestamps_filename,'Sheet1');
tablenames = tablenames(1,:);
tablenames(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tablenames)) = {''};

%%% Import one dataset (This is written to convert to a looped script
%%% later)

cd(data_dir)
for it = 1:length(EEGfiles)
EEG = pop_biosig(EEGfiles{it});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, it,'setname',EEGfiles{it},'gui','off'); 
end
eeglab redraw

eeglab('redraw');
EEG = eeg_checkset( EEG );

%%% Quick Preprocess of ECoG data

% % Resample to 256 Hz
% EEG = pop_resample( EEG, 256);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

% HPF at .1 Hz
EEG = pop_eegfiltnew(EEG, [],0.1,8448,1,[],1);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

% LPF at 64 Hz
EEG = pop_eegfiltnew(EEG, [],64,54,0,[],1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','1A.edf resampled filtered','gui','off');
EEG = eeg_checkset( EEG );

% Compute Average Reference
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','1A.edf resampled filtered rereferenced','gui','off'); 


%%% Create new data structure with trial data

%%% Allocate space for data structure (using number of trials in imported
%%% spreadsheet)

trial_data = cell(length(tablesound11),1);

% Find all rows with this subject's data
[filepath,subject_name,ext] = fileparts(EEGfiles{it})
index = find(strcmp(tablesound11(:,1),subject_name));

for it = 1:length(index)
    idx1 = cell2mat(tablesound11(index(it),3));
    idx2 = cell2mat(tablesound11(index(it),4));
    trial_data{index(it)} = EEG.data(:,idx1:idx2);
end

save([end_data_dir '/trial_data'], 'trial_data')
clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY data_dir EEG EEGfiles eeglab_dir ...
    eeglabUpdater end_data_dir ext filepath idx1 idx2 ImportDataSetNumber index ...
    it LASTCOM PLUGINLIST s STUDY subject_name tablenames tablesound11 timestamps_filename