function [pref] = rphase_stat(train, freq)
    %similar to phase stat, but checks against sine wave up/down phase
    pref = sum(sin(freq*2*pi*train)>0);
end