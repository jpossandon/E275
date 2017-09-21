%%%%%%
% difference between first fixation in modification and refixations, all
% modifications together, including and excluding amplitude covariate
% define better baselines
% clear p
if fmodel==1
    stim_ICAem_rrefyes_keepyes
elseif fmodel==2
    sac_ICAem_rrefyes_keepyes
elseif fmodel==3
    stim_leftmir_ICAem_rrefyes_keepyes
elseif fmodel==4
    stim_ICAem_rrefyes_keepyes_covbias
elseif fmodel==11
    stimTFR_wave_ICAem_rref_keep
elseif fmodel==12
    comparisonTFR_wave_ICAem_rref_keep
elseif fmodel==13
    stimTFR_hanning_ICAem_rref_keep
end