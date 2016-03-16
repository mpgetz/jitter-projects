% collection of spike train analysis methods

classdef TrainMethods
    methods
        function [counts] = cch(self, n1, n2, disc, maxlag);
        % creates CCH for spike trains n1, n2
            counts = zeros(1, (2*maxlag)/disc);
            lags = -maxlag:disc:maxlag;

            for lag=1:length(lags)
                for s=1:length(n2)
                    counts(lag) = sum((n1+lag)==n2(s));
                end
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
                for i=1:length(arg)
                    line([arg(i) arg(i)], [n-1, n]);
                end
            end
            hold off
        end
    end
end
