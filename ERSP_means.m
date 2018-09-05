cd('dependencies/eeglab14_1_2b')
eeglab

load trial_data(1).mat
timestamps_filename = 'table_sound1_strings.xlsx'

%%% Import data from spreadsheet
% please note cell ranges
[~, ~, tablesound11] = xlsread(timestamps_filename,'Sheet1');
tablesound11 = tablesound11(2:263,:);
tablesound11(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tablesound11)) = {''};

%%% Import variable names from first row
[~, ~, tablenames] = xlsread(timestamps_filename,'Sheet1');
tablenames = tablenames(1,:);
tablenames(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tablenames)) = {''};

%%% List of all subjects / conditions
all_subjects = unique(tablesound11(:,1));
all_conditions = unique((tablesound11(:,2)));

%%% Select which conditions you wish to compare
my_cond1 = [7 5]; % 40 Hz signals
my_cond2 = [4 6]; % Baseline

%%% find indices corresponding to conditions
cond1 = [];
for it = 1:length(my_cond1)
    cond1 = [cond1; find(strcmp(tablesound11(:,2),all_conditions(my_cond1(it))))];
end

cond2 = [];
for it = 1:length(my_cond2)
    cond2 = [cond2; find(strcmp(tablesound11(:,2),all_conditions(my_cond2(it))))];
end

%%% Calculate mean trial data across each condition
cond1_mean = []
for it = 1:length(cond1)
    if length(trial_data{it})>length(cond1_mean)
        
        padsize = length(trial_data{it})-length(cond1_mean);
        new = zeros(size(trial_data{it}));
        new(1:size(cond1_mean,1),1:size(cond1_mean,2)) = cond1_mean;
        cond1_mean = new + trial_data{it};
    elseif length(trial_data{it})<length(cond1_mean)
        
        padsize = length(cond1_mean)-length(trial_data{it});
        new = zeros(size(cond1_mean));
        new(1:size(trial_data{it},1),1:size(trial_data{it},2)) = trial_data{it};        
        cond1_mean = new + cond1_mean;     
    end
    
end

cond1_mean = cond1_mean ./ it;

%%% Again for condition 2...
cond2_mean = []
for it = 1:length(cond2)
    if length(trial_data{it})>length(cond2_mean)
        
        padsize = length(trial_data{it})-length(cond2_mean);
        new = zeros(size(trial_data{it}));
        new(1:size(cond2_mean,1),1:size(cond2_mean,2)) = cond2_mean;
        cond2_mean = new + trial_data{it};
    elseif length(trial_data{it})<length(cond2_mean)
        
        padsize = length(cond2_mean)-length(trial_data{it});
        new = zeros(size(cond2_mean));
        new(1:size(trial_data{it},1),1:size(trial_data{it},2)) = trial_data{it};        
        cond2_mean = new + cond2_mean;     
    end
    
end

cond2_mean = cond2_mean ./ it;
cond2_mean = cond2_mean(1:size(cond1_mean,1),1:size(cond1_mean,2));
    
    
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef({cond1_mean cond2_mean},1,[-1000 2000],250);


