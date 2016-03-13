% collection of spike train analysis methods

classdef TrainMethods
    methods
        function [] = cch(n1, n2);
        end

        function [] = raster(varargin)
        % generates raster plot of input spike trains
            args = varargin;

            figure
            hold on
            for n=1:length(args)
                arg = args(n);
                for i=1:length(arg)
                    line([arg(i) arg(i)], [n-1, n]);
                end
            end
            hold off
        end
    end
end
