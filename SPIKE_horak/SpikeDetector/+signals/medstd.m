function sd = medstd(x,n)
% Description: estimates the baseline standard deviation of a signal by
% taking the median from the distribution of standard deviations calculated
% with a sliding window. Based on movingvar by Aslak Grinsted (2005):
% http://www.mathworks.com/matlabcentral/fileexchange/8252-moving-variance
%
% Input:
%   x - signal (e.g. ECoG recording or some derivative signal)
%   n - length of the sliding window
%
% Output:
%   sd - the estimate of the standard deviation

win = zeros(1,n)+1/n;
sd = sqrt(median(conv(x.^2,win,'valid')-conv(x,win,'valid').^2));
% sd = median(std(reshape(x(1:n*floor(size(x,2)/n)),n,[]),[],1));

return
