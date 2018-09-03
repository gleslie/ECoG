%%% Import and Preprocess of ECoG Data using Matlab
%%% v1 Grace Leslie 7 August 2018
close all
clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY data_dir EEG EEGfiles eeglab_dir ...
    eeglabUpdater end_data_dir ext filepath idx1 idx2 ImportDataSetNumber index ...
    it LASTCOM PLUGINLIST s STUDY subject_name tablenames tablesound11 timestamps_filename

%%% For you to update according to your local directory structure:
%%% Global File and Directory Names
eeglab_dir = '/Users/robertjquon/Desktop/sound_study1/eeglab14_1_2b'
data_dir = '/Users/robertjquon/Desktop/sound_study1/Downsampled'
end_data_dir = '/Users/robertjquon/Desktop/sound_study1/processed'
timestamps_filename = '/Users/robertjquon/Desktop/sound_study1/table_sound1.xlsx';
ImportDataSetNumber = 4; %% Change this to the dataset in the list you want to import.      %%%%%%%%%%
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
for it = ImportDataSetNumber % 1:length(EEGfiles)
EEG = pop_biosig(EEGfiles{it});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, it,'setname',EEGfiles{it},'gui','off'); 
end
eeglab redraw

% EEG = ALLEEG(1, ImportDataSetNumber)
EEG = eeg_checkset( EEG );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Quick Preprocess of ECoG data
% removing non ECoG channel data  %%%%%%%%%% DO THIS MANUALLY WITH EEGLAB
% (edit->sel data)
pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','kurt'); % use this to see what chan to reject, then manual rej with edit->seldata
% EEG = eeg_checkset( EEG );
% EEG = pop_select( EEG,'nochannel',{EEG.nbchan-106 : EEG.nbchan});
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 

% cleanline 
EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan] ,'computepower',1,'linefreqs',[60 120] ,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);

% HPF at .1 Hz % consider setting lower to 0.01
EEG = pop_eegfiltnew(EEG, [],0.1,8448,1,[],1);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

% LPF at 64 Hz
EEG = pop_eegfiltnew(EEG, [],64,54,0,[],1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[EEGfiles{it} ' resampled filtered'],'gui','off'); 
EEG = eeg_checkset( EEG );

% channel rejection 
EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','kurt');

% % Resample to 256 Hz
% EEG = pop_resample( EEG, 256);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

% Compute Average Reference
EEG = pop_reref(EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[EEGfiles{it} ' resampled filtered rereferenced'],'gui','off'); 


%%% Create new data structure with trial data

%%% Allocate space for data structure (using number of trials in imported
%%% spreadsheet)



%%%% ONLY RUN THIS THE FIRST TIME!!!
% trial_data = cell(length(tablesound11),1);



% Find all rows with this subject's data
[filepath,subject_name,ext] = fileparts(EEGfiles{ImportDataSetNumber})
index = find(strcmp(tablesound11(:,1),subject_name));

for it = 1:length(index)
    idx1 = cell2mat(tablesound11(index(it),3));
    idx2 = cell2mat(tablesound11(index(it),4));
    trial_data{index(it)} = EEG.data(:,idx1:idx2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


save([end_data_dir '/trial_data'], 'trial_data', '-v7.3')
% save([end_data_dir '/2A'], 'EEG', '-v7.3')

