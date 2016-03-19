% collection of spike train analysis methods

classdef TrainMethods
    methods
        function [counts] = cch(self, n1, n2, disc, maxlag);
        % creates CCH for spike trains n1, n2
            counts = zeros(1, (2*maxlag)/disc);
            lags = -maxlag:disc:maxlag;

            %n1 = round(n1, 3);
            %n2 = round(n2, 3);
            for l=1:length(lags)
                lag = lags(l);
                count = 0;
                for s=1:length(n2)
                    count = count + sum((n1+lag)==n2(s));
                end
                counts(l) = count;
            end

            % plot counts
            bar([-maxlag:disc:maxlag], counts);
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
                    arg = arg(0:500);
                end

                for i=1:l_a
                    line([arg(i) arg(i)], [n-1, n]);
                end
            end
            hold off
        end

        % Kamran dataset specific
        function [train] = get_spikes(self, times, cluster_set, label)
            train = find(cluster_set == label);
            train = times(train);
        end
    end
end
