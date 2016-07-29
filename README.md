# jitter-projects

## TrainMethods 
This class collects methods useful for manipulating spike train data, though highly specific to the organization of certain datasets. Includes an inefficient CCH generator and rastor plot generator, and lazy methods for searching for spike synchrony. 

## IO_data
For input/output of filetypes related to Klusters, e.g. fet, clu and spk files. At present, class is instantiated with dataset-specific properties. These should be edited or generalized in the future. 
* clu_in imports a .clu file as an array.
* spk_in imports a .spk file as an array.
* fet_in imports a .fet file as an array with the following:
    [timestamp, shank, cluster#, features]

## WaveformMethods
Methods centered around a waveform resolution function, aimed at separating spatiotemporally overlapping waves.
* build_example creates an example of spatiotemporal overlap from randomly selected waves in the data.
* get_fets re-performs PCA and returns a matrix of coefficients and an array of mean and standard deviation for each cluster's principle components.
* get_pcs computes principle components for each wave in a pair of clusters, as well as for a candidate waveform (to be sorted)
* get_template_wvs computes the mean waveform for a cluster from all waveforms in the trial.
* resolve_synch attempts to resolve spatiotemporal overlap of waveforms by subtraction and returns a guess of: clusters involved, lag between them and a resultant wavefrom

## PlotTools
Helpful plotting tools specific to electrophys datasets. 
