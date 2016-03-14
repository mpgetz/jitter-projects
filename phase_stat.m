function [pref] = phase_stat(train)
    %input spike train, compute elementary statistic:
    pref = sum((-1).^train);
end
    