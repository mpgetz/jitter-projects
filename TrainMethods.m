% collection of spike train analysis methods

classdef TrainMethods
    methods
        function [counts] = cch(self, n1, n2, bin, lag, maxlag);
        % creates CCH for spike trains n1, n2
        % lag, maxlag, expect integers
        % produces response with n1 reference, n2 target
            counts = zeros(1, (2*maxlag)/lag);
            lags = -maxlag:lag:maxlag;

            %n1 = round(n1, 3);
            %n2 = round(n2, 3);
            for l=1:length(lags)
                lag = lags(l);
                count = 0;
                lower = (lag-0.5)*bin;
                upper = (lag+0.5)*bin;

                for s=1:length(n1)
                    count = count + length(intersect(find((n2-lower)>=n1(s)), find(n1(s)>(n2-upper))));
                end
                counts(l) = count;

                display(l);
            end

            % plot counts
            bar(lags, counts);
            xlim([-maxlag-0.5, maxlag+0.5]);
        end

        %DO NOT CALL
        function [] = cch_series(self, trains)
        % creates set of cchs for all pairs in trains
        % trains is a cell containing spike data to be analyzed
        % 1msec bin window, 10msec analysis, input units in sec
            figure
            k = 1;
            for i=1:(length(trains)-1)
                for j=(i+1):length(trains)
                    subplot(2, 5, (k))
                    self.cch(trains{i}, trains{j}, .001, 1, 10);
                    k = k + 1;
                end
            end
        end

        function [] = raster(varargin)
        % generates raster plot of input spike trains
            args = varargin(:, [2:end]);
            l = length(args);

            figure
            hold on
            ylim([0 l]);
            for n=1:l
                arg = args{n};
                l_a = length(arg);

                % truncate to a(n arbitrarily) manageable size
                %if l_a > 500
                %    arg = arg(1:500);
                %    l_a = 500;
                %end

                for i=1:l_a
                    line([arg(i) arg(i)], [n-1, n]);
                end
            end
            hold off
        end

        function [synch, lag, pos] = find_synch(self, n1, n2, lbd, ubd)
        %picks out spikes with synch g/eq lbd and l/eq ubd
        %need a notion of direction (n1-->n2)
        %vectorize this?
            synch = zeros(1, length(n1));
            lag = zeros(1, length(n1));
            for i=1:length(n1)
                times = n2-n1(i);
                if ~isempty(find(lbd<=times & times<=ubd));
                    synch(i) = n1(i);
                    %report lag of closest spike, without direction preference
                    lag(i) = times(find(abs(times) == min(abs(times))));
                end
            end
            %remove nonsynch (i.e. 0) values
            pos = find(synch);
            synch = synch(pos); 
            lag = lag(find(lag));
        end
        
        function [array] = find_synch_array(self, times, labels)
            nRef = reshape([1:468], 12, 39);
            template = zeros(12*39, 12*39);
            for i=2:length(times)-1
                t = times(i);
                ref_times = [times(1:i-1), times(i+1, end)];
                synch = zeros(1, length(ref_times_));
            end
        end

       % Kamran dataset specific
        function [train, train_units] = get_spikes(self, times, cluster_set, label)
        % picks out assigned spikes from first dataset. 
        % first output in units=sessions; second output in units=sec
            train = find(cluster_set == label);
            train = times(train);
            train_units = train/32552;
        end

        %% UPDATED TO SPECIFY SHANK
        % assumes that s.shank and s.cluster uniquely specify neuron
        function [trains, trains_units] = get_spike_set(self, times, shanks, cluster_set, label)
        % here, times=spike.t, shanks=spike.shank, cluster_set=spike.cluster, label is the cluster label of interest
        % first output in units=sessions; second output in units=sec
            trains = {};
            trains_units = {};
            cluster = find(cluster_set == label);
            ind = unique(shanks(cluster));
            for i=1:length(ind)
                trains{i} = intersect(cluster, find(shanks==ind(i)));
                trains_units{i} = times(trains{i})/32552;
            end
        end

        function [cell] = get_trains(self, times, shanks, cluster_set, array)
        % collects all desired spike trains from input array of spike labels, in this case, spike var
            for i=1:length(array)
                [n, nt] = self.get_spike_set(times, shanks, cluster_set, array(i));
                cell{i} = nt;
            end
        end

        function [cell] = separate_clusters(self, clu)
        % separates clu array into sets of positions of cluster labels, useful for pulling out information based on cluster
            labels = unique(clu);
            for i=1:length(labels)
                cell{i} = find(clu == labels(i));
            end
        end

    end
end
