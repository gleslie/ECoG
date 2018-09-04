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

%%% Compute Means
all_subjects = unique(tablesound11(:,1));
all_conditions = unique((tablesound11(:,2)));