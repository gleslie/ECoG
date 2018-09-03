function test()
% Description: Test the spike detector for basic functionality.
%
% Last Updated: 2015-09-23
% Author: Peter Horak

rng('default');

Fx = 500;
Fy = 200;
T = 8; % length of test recording (sec)
tx = 0:1/Fx:T-1/Fx;
% ty = 0:1/Fy:T-1/Fy;

% Synthetic signal (continuous random walk with decay)
x = normrnd(0,1,2,T*Fx);
for i = 2:size(x,2)
    x(:,i) = x(:,i)+0.9*x(:,i-1);
end
x = bsxfun(@times,x,1./std(x,[],2)); % normalized standard deviation to 1

% Create artificial spikes and insert into the data at known times
spike = -gausswin(round(0.06*Fx))';%0.6*sin(linspace(0,pi,round(0.1*Fx)))
spike = repmat(spike,2,1);
l = size(spike,2);
stimes = [1,1.5,3,5.2,5.4,5.55,7]; % spike times (sec)
samps = [5,5,5,4,4,4,3].^2; % spike amplitudes
for i = 1:numel(stimes)
    k = round(Fx*stimes(i));
    x(:,k:k+l-1) = x(:,k:k+l-1) + samps(i)*spike;
end

% Add 60Hz noise to second channel
x(2,:) = x(2,:) + 4^2*sin(60*2*pi*tx);

% Resample to detector sampe rate
y = resample(x',Fy,Fx)';

fprintf('Testing thresholds (Fs = 500Hz)\n');
[dets,~] = detector(x,Fx,2);
check(dets,stimes*Fx,[1,1,2,3,3,3,4])
[dets,~] = detector(x,Fx,3);
check(dets,stimes*Fx,[1,1,2,3,3,3,0])
[dets,~] = detector(x,Fx,6);
check(dets,stimes*Fx,[1,1,2,0,0,0,0])
[dets,~] = detector(x,Fx,8);
check(dets,stimes*Fx,[0,0,0,0,0,0,0])

fprintf('Testing thresholds (Fs = 500Hz)\n');
[dets,~] = detector(y,Fy,2);
check(dets,stimes*Fy,[1,1,2,3,3,3,4])
[dets,~] = detector(y,Fy,3);
check(dets,stimes*Fy,[1,1,2,3,3,3,0])
[dets,~] = detector(y,Fy,6);
check(dets,stimes*Fy,[1,1,2,0,0,0,0])
[dets,~] = detector(y,Fy,8);
check(dets,stimes*Fy,[0,0,0,0,0,0,0])

fprintf('Testing mininum spacings (Fs = 500Hz)\n');
[dets,~] = detector(x,Fx,2,0);
check(dets,stimes*Fx,[1,2,3,4,5,6,7])
[dets,~] = detector(x,Fx,2,1);
check(dets,stimes*Fx,[1,1,2,3,3,3,4])
[dets,~] = detector(x,Fx,2,2);
check(dets,stimes*Fx,[1,1,1,2,2,2,2])

fprintf('Testing amplitudes (Fs = 500Hz)\n');
[~,amps] = detector(x,Fx,2);
amps = round(amps{1});
err1 = myassert(all(amps(1:3) >= amps(4)),'incorrect ranking of amplitudes');
err2 = myassert(all(amps(1:2) >= amps(3)),'incorrect ranking of amplitudes');
if err1 || err2
    disp(amps')
end

end

% Check that the correct detections overlap (or don't overlap) with the
% artificial spikes
function check(dets,samps,correct)
k1 = arrayfun(@(x) find(dets{1}(:,1) < x & x < dets{1}(:,2)),samps,'uni',false);
k1(cellfun(@(x) isempty(x),k1)) = {0}; % no overlapping detections
k1 = [k1{:}];
k2 = arrayfun(@(x) find(dets{2}(:,1) < x & x < dets{2}(:,2)),samps,'uni',false);
k2(cellfun(@(x) isempty(x),k2)) = {0}; % no overlapping detections
k2 = [k2{:}];
err1 = myassert(all(k1==k2),'detections inconsistent between channels');
err2 = myassert(all(k1==correct & k2==correct),'incorrect detections');
if err1 || err2
    disp(k1)
    disp(k2)
end
end

% Test an expression. If it fails print an error message but continue
% execution of the unit tests
function err = myassert(expression,msg)
try
    assert(expression)
    err = false;
catch me
    fprintf(2,'Failed test on line %d (%s)\n',me.stack(end).line,msg);
    err = true;
end
end
