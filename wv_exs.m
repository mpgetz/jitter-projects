%Exploratory code for finding overlapping wave synch in spk data

i = 1;
samples = 54;
vec = reshape(wvs{1}e(i, :, :), samples, [])';
[c, s, l, t, e, m] = pca(vec);
