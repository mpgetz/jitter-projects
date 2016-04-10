% Assorted exploratory methods which do not yet serve a more general purpose
% Largely used as a record of command-line work
%tm = TrainMethods;

% extract msec synch spikes from refcell wrt tcell
refcell = cell1{2};
tcell = cell2{3};
synch = zeros(1, length(refcell));
n = zeros(1, length(refcell));

for i=1:length(refcell)
    if ~isempty(find(refcell(i)+.00015>=tcell & tcell>=refcell(i)))
        synch(i) = refcell(i);
        n(i) = 1;
    end
end

% remove hanging zeros
synchp = find(synch);
synch = synch(synchp);
n = find(n);

% plot group of msec cchs given by column pairs in var objs
%objs = [1, 2; 1, 3; 2, 3];
%for j=1:3
%    subplot(1, 3, (j))
%    tm.cch(cell1{objs(j, 1)}, cell2{objs(j, 2)}, .00003, 1, 20);
%    title(strcat('n8 shank', int2str(ns1(objs(j, 1))), '-->', 'n11 shank', int2str(ns2(objs(j, 2)))));
%    xlabel('.03ms bin');
%end

%% plot group of cchs
%figure
%k = 1;
%for i=1:4
%%for i=1:(length(cell)-1)
%    for j=1:4
%    %for j=(i+1):length(cell)
%        subplot(4, 4, (k))
%        tm.cch(cell1{i}, cell2{j}, .001, 1, 10);
%        title(strcat('n8 shank', int2str(ns1(i)), '-->', 'n11 shank', int2str(ns2(j))));
%        k = k+1;
%        i,j
%    end
%end

% compute direction of movement wrt x-axis
%angles8 = zeros(1, length(c8p));
%for elem=1:length(c8p)
%    s = c8p(elem);
%    x8 = spike.x(s+1)-spike.x(s-1);
%    y8 = spike.y(s+1)-spike.y(s-1);
%    [theta, rho] = cart2pol(x8, y8);
%    angles8(elem) = theta;
%end

% the code below plots the spikes assigned to n on a map of the position
x = spike.x(n);

figure
plot(spike.x, spike.y);
line([x, x], [.2, .25], 'Color', 'r');
