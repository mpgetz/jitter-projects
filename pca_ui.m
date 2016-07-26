%File to create scrollable plots of PCs

function pca_ui(pcset1, pcset2, candidate)
    %ideal to change this to varargin in the future
    %plot in blue is first cluster; plot in red is second
    %asterisk in yellow is candidate point

    if nargin < 3
        candidate = [];
    end

    f = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
    hold on
    x1 = pcset1(1, :);
    y1 = pcset1(2, :);
    s1 = scatter(x1, y1);

    x2 = pcset2(1, :);
    y2 = pcset2(2, :);
    s2 = scatter(x2, y2);

    if ~isempty(candidate)
        xc = candidate(1, :);
        yc = candidate(2, :);
        sc = scatter(xc, yc, '*');
    end
    hold off

    m = size(pcset1, 1)
    %horizontal slider
    hsld = uicontrol('Style', 'slider', 'Min', 1, 'Max', m, 'Value', 1);
    hsld.Position = [440, 10, 400, 20];
    hsld.SliderStep = [1/(m-1), 1/(m-1)];
    hsld.Callback = @setpc1

    %vertical slider
    vsld = uicontrol('Style', 'slider', 'Min', 1, 'Max', m, 'Value', 2);
    vsld.Position = [20, 10, 400, 20];
    vsld.SliderStep = [1/(m-1), 1/(m-1)];
    vsld.Callback = @setpc2

    xlabel(strcat('PC ', int2str(hsld.Value)));
    ylabel(strcat('PC ', int2str(vsld.Value)));
    f.Visible = 'on';

    function setpc1(source, callbackdata)
        x1 = pcset1(source.Value, :);
        x2 = pcset2(source.Value, :);
        s1.XData = x1;
        s2.XData = x2;
        if ~isempty(candidate)
            xc = candidate(source.Value, :);
            sc.XData = xc;
        end
        xlabel(strcat('PC ', int2str(hsld.Value)));
    end

    function setpc2(source, callbackdata)
        y1 = pcset1(source.Value, :);
        y2 = pcset2(source.Value, :);
        s1.YData = y1;
        s2.YData = y2;
        if ~isempty(candidate)
            yc = candidate(source.Value, :);
            sc.YData = yc;
        end
        ylabel(strcat('PC ', int2str(vsld.Value)));
    end
end
