%File to create scrollable plots of PCs

function pca_ui(pcset1, pcset2, candidate)
    %ideal to change this to varargin in the future

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
        sc = scatter(xc, yc, 'markertype', '*');
    end
    hold off

    %vertical slider
    vsld = uicontrol('Style', 'slider', 'Min', 1, 'Max', 24, 'Value', 1);
    vsld.Position = [20, 20, 400, 20];
    vsld.SliderStep = [1/23, 1/23];
    vsld.Callback = @setpc1

    %horizontal slider
    hsld = uicontrol('Style', 'slider', 'Min', 1, 'Max', 24, 'Value', 2);
    hsld.Position = [440, 20, 400, 20];
    hsld.SliderStep = [1/23, 1/23];
    hsld.Callback = @setpc2

    f.Visible = 'on';

    function setpc1(source, callbackdata)
        x1 = pcset1(source.Value, :);
        x2 = pcset2(source.Value, :);
        s1.XData = x1;
        s2.XData = x2;
    end

    function setpc2(source, callbackdata)
        y1 = pcset1(source.Value, :);
        y2 = pcset2(source.Value, :);
        s1.YData = y1;
        s2.YData = y2;
    end
end
