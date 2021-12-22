This directory contains the outputs of the spm_ss toolbox analyses.

***File names***

Individual file naming follows the following format: 
parcels_localizerexperiment_criticalexperiment.csv

Localizer experiment is used to select the most responsive voxels within a parcel; once we select these voxels, we can estimate their response to the critical experiment conditions. 

***Contrasts for langloc***

    S - sentence reading
    N - nonword reading

***Contrasts for MDloc***

    H - hard working memory task
    E - easy working memory task
    H-E

***Contrasts for Categorization***

    LD - easy working memory task
    HD - hard working memory task
    LD-HD

***Column names***

ROI - functional region of interest
Subject - participant ID
Effect - a contrast of interest from the critical experiment
LocalizerSize - fROI size (in voxels)
EffectSize - effect size for each contrast from the critical experiment