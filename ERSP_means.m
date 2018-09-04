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
my_cond1 = [1 2 3]; % 40 Hz signals
my_cond2 = 10; % Baseline

%%% find indices corresponding to conditions
cond1 = [];
for it = 1:length(my_cond1)
    cond1 = [cond1; find(strcmp(tablesound11(:,2),all_conditions(my_cond1(it))))];
end

cond2 = [];
for it = 1:length(my_cond2)
    cond2 = [cond2; find(strcmp(tablesound11(:,2),all_conditions(my_cond2(it))))];
end


for it = 1:length
    
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef({trial_data{1} trial_data{2}},1,[-1000 2000],250);


