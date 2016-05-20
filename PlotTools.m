classdef PlotTools
    properties
    end

    methods
        function [] = plot_wvs(self, wv_data, p, m, b, n)
            figure;
            %p is position of synchronous spikes (from fet file)
            %if y > 4, newline
            for y=b:n; 
                diff = n-b+1;
                %add optional array of timestamps here
                for i=1:8; 
                    subplot(8*m, diff, (((y-b)+1)+(diff*(i-1)))); 
                    plot(wv_data(i, :, p(y))); 
                    ylim([min(min(wv_data(:,:,p(y)))), max(max(wv_data(:,:,p(y))))]); 
                    xlim([0, 54]);
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
