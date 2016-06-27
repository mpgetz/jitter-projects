classdef PlotTools
    properties
    end

    methods
        function [] = plot_wvs(self, wv_data, p, m, b, n)
            figure;
            %p is position of synchronous spikes (from fet file)
            %b is start value, n is end value; m is step size (wrt p)
            if nargin < 3
                p = 1;
                m = 1;
                b = 1;
                n = 1;
            end

            if nargin < 4
                m = 1;
                b = length(p);
                n = 1;
            end
            
            dim = size(wv_data);
            set = reshape(wv_data(:, :, p), dim(1), []);
            min_amp = min(min(set));
            max_amp = max(max(set));
            for y=b:n; 
                diff = n-b+1;
                %add optional array of timestamps here
                for i=1:8; 
                    subplot(8*m, diff, (((y-b)+1)+(diff*(i-1)))); 
                    plot(wv_data(i, :, p(y))); 
                    ylim([min_amp, max_amp]); 
                    xlim([0, 32]);
                    %xlim([0, 54]);
                    if i == 1
                        title(int2str(y));
                    end
                end 
            end
        end

        function [] = plot_interval_wvs(self, wv_data, channel, samples, synch)
            %plots intervals of given channel with width 'samples'
            %if samples does not divide 54, truncate lagging elements
            truncate = mod(54, samples);
            num_intervals = (54-truncate)/samples;

            figure;
            ref_wvs = randsample(1:max(size(wv_data)), length(synch));
            for i=1:num_intervals
                subplot(2, num_intervals, i)
                hold on
                for j=1:length(synch)
                    plot(wv_data(channel, ((i-1)*samples)+1:i*samples, synch(j)));
                end
                ylim([-1000, 1000]);
                if i == 1
                    title('synch waveforms');
                    ylabel(strcat('channel ', int2str(channel)));
                end
                hold off

                subplot(2, num_intervals, i+num_intervals)
                hold on
                for j=1:length(synch)
                    plot(wv_data(channel, ((i-1)*samples)+1:i*samples, ref_wvs(j)));
                end
                ylim([-1000, 1000]);
                if i == 1
                    title('random reference waveforms');
                    ylabel(strcat('channel ', int2str(channel)));
                end
                hold off
            end
        end

    end
end
