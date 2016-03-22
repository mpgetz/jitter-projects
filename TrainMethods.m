% collection of spike train analysis methods

classdef TrainMethods
    methods
        function [counts] = cch(self, n1, n2, bin, lag, maxlag);
        % creates CCH for spike trains n1, n2
        % lag, maxlag, expect integers
        % produces response of n2 wrt n1
            counts = zeros(1, (2*maxlag)/lag);
            lags = -maxlag:lag:maxlag;

            %n1 = round(n1, 3);
            %n2 = round(n2, 3);
            for l=1:length(lags)
                lag = lags(l);
                count = 0;
                lower = (lag-0.5)*bin;
                upper = (lag+0.5)*bin;

                for s=1:length(n2)
                    count = count + length(intersect(find((n1+lower)<=n2(s)), find((n2(s)<(n1+upper)))));
                end
                counts(l) = count;

                display(l);
            end

            % plot counts
            bar(lags, counts);
            xlim([-maxlag-0.5, maxlag+0.5]);
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
                if l_a > 500
                    arg = arg(1:500);
                    l_a = 500;
                end

                for i=1:l_a
                    line([arg(i) arg(i)], [n-1, n]);
                end
            end
            hold off
        end

        % Kamran dataset specific
        function [train, train_units] = get_spikes(self, times, cluster_set, label)
        % picks out assigned spikes from first dataset. 
        % first output in units=sessions; second output in units=sec
            train = find(cluster_set == label);
            train = times(train);
            train_units = train/32552;
        end
    end
end
