classdef PlotTools
    properties
        samples = 54;
    end

    methods
        function self = PlotTools(data_ref)
            %init method
            if data_ref == 'y'
                self.samples = 32;
            end
        end

        function [] = plot_wvs(self, wv_data, x0, xN, pos, step)
            figure;
            %pos is position of synchronous spikes (from fet file)
            %x0 is start value, xN is end value; m is step size (wrt pos)
            if nargin < 3
                %assumes only one spike is being plotted
                for i=1:8; 
                    subplot(8, 1, i); 
                    plot(wv_data(i, :)); 
                    ylim([min(min(wv_data)), max(max(wv_data))]); 
                    xlim([0, self.samples]);
                end 
                return
            end
                
            if nargin < 5
                %assumes that x0 is positive
                pos = [1:1:xN];
                step = 1;
            end

            if nargin < 6 
                step = 1;
            end
            
            dim = size(wv_data);
            set = reshape(wv_data(:, :, pos), dim(1), []);
            min_amp = min(min(set));
            max_amp = max(max(set));
            for y=x0:xN; 
                diff = xN-x0+1;
                %add optional array of timestamps here
                for i=1:8; 
                    subplot(8*step, diff, (((y-x0)+1)+(diff*(i-1)))); 
                    plot(wv_data(i, :, pos(y))); 
                    ylim([min_amp, max_amp]); 
                    xlim([0, self.samples]);
                    if i == 1
                        title(int2str(y));
                    end
                end 
            end
        end

        function [] = plot_wv_overlays(self, wvs, clus, clu_set, num)
            %Plots overlayed series of random waveforms from a given cluster
            %Input: clu_set takes an array of integers
            %   wvs, clus, expect array (i.e. index into the cell)

            dim = size(wvs);
            for i=1:length(clu_set)
                c = clu_set(i);
                pos = randsample(find(clus==c), num);
                set = reshape(wvs(:, :, pos), dim(1), []);
                min_amp = min(min(set));
                max_amp = max(max(set));

                x0 = 1;
                xN = length(clu_set);
                for y=x0:xN; 
                    diff = xN-x0+1;
                    %add optional array of timestamps here
                    for j=1:8; 
                        subplot(8, diff, (((y-x0)+1)+(diff*(j-1)))); 
                        hold on;

                        for k=1:num
                            plot(wvs(j, :, pos(k))); 
                            ylim([min_amp, max_amp]); 
                            xlim([0, self.samples]);
                        end
                        hold off;

                        if j == 1
                            title(int2str(y));
                        end
                    end 
                end            
            end
        end

        %DON'T USE WITHOUT MODIFICATIONS
        %{
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
        %}

    end
end
