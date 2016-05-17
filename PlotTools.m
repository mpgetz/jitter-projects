classdef PlotTools
    properties
    end

    methods
        function [] = plot_wvs(self, wv_data, p, test2, x, y)
            figure;
            %x a multiple of 8
            %if y > 4, newline
            for k=1:4; 
                for i=1:8; 
                    subplot(8*x, y, k+(y*(i-1))); 
                    plot(wv_data(i, :, p(k))); 
                    ylim([min(min(test2(:,:,p(k)))), max(max(test2(:,:,p(k))))]); 
                end 
            end
        end
    end
end
