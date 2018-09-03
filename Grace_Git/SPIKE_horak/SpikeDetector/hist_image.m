function hist_image(var1,var2,types)

cond1 = types == 0;
cond2 = types >= 3;
cond3 = types == 1 | types == 2;

Nx = min(numel(unique(var1)),100);
Ny = min(numel(unique(var2)),100);
% Ny = Nx;

%% 2D histogram (var1 vs var2)
[n1,c] = hist3([var1(cond1),var2(cond1)],[Nx,Ny]);
[n2,~] = hist3([var1(cond2),var2(cond2)],c);
[n3,~] = hist3([var1(cond3),var2(cond3)],c);

% Red: FPs, Green: clear spikes, Blue: ambiguous spikes, Black: no data
n = cat(3,n1',n3',n2');
% n = (n./repmat(sum(n,3),1,1,3));
n = (n./repmat(sum(n,3),1,1,3)).*(repmat(sum(n,3),1,1,3)/max(reshape(sum(n,3),[],1))).^(1/6);
n(isnan(n)) = 0;
imagesc(n,'XData',c{1},'YData',c{2})
xlabel('var1')
ylabel('var2')

%% Scatter plot (var2 vs var1)
% plot(var1(cond1),var2(cond1),'r.',var1(cond2),var2(cond2),'b.',var1(cond3),var2(cond3),'g.')
% legend('FPs','Ambiguous','TPs')
% xlabel('var1')
% ylabel('var2')

%% Histograms of var1
% v = sort(var1);
% N = numel(v);
% c = linspace(v(fix(N*0.01)),v(fix(N*0.99)),100);
% 
% n1 = hist(var1(cond1),c);
% n2 = hist(var1(cond2),c);
% n3 = hist(var1(cond3),c);
% plot(c,n1/mean(n1),'r',c,n2/mean(n2),'b',c,n3/mean(n3),'g')
% legend('FPs','Ambiguous','TPs')
% xlabel('var1')
% ylabel('normalized frequency')

end
