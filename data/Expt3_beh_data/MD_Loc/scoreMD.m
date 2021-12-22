function [MdBeh, MdBehSubjAvg] = scoreMD( )
    %scoreMD
    
    dataDir = pwd;
    dataFiles = dir(fullfile(dataDir, '*.csv'));
    dataFiles = {dataFiles.name}';
    nDataFiles = length(dataFiles);
    
    MdBeh = table();
    MdBeh.DataFile = dataFiles;
    MdBeh.NumNoResponse = nan(nDataFiles,1);
    MdBeh.EasyAcc = nan(nDataFiles,1);
    MdBeh.HardAcc = nan(nDataFiles,1);
    MdBeh.EasyRT = nan(nDataFiles,1);
    MdBeh.HardRT = nan(nDataFiles,1);
    
    trialsPerRun = 48;
    
    for iDataFile = 1:nDataFiles
        dataFile = MdBeh.DataFile{iDataFile};
        RunData = readtable(fullfile(dataDir, dataFile));
        
        assert(height(RunData) == trialsPerRun, ...
               'Wrong number of trials in file %s\n', dataFile);
        
        noResponseTrials = isnan(RunData.Response);
        MdBeh.NumNoResponse(iDataFile) = sum(noResponseTrials);
        
        easyTrials = strcmp(RunData.Condition, 'Easy');
        MdBeh.EasyAcc(iDataFile) = mean(RunData.Accuracy(easyTrials));
        MdBeh.EasyRT(iDataFile) = nanmean(RunData.RT(easyTrials));
        
        
        hardTrials = strcmp(RunData.Condition, 'Hard');
        MdBeh.HardAcc(iDataFile) = mean(RunData.Accuracy(hardTrials));
        MdBeh.HardRT(iDataFile) = nanmean(RunData.RT(hardTrials));
    end
    
    subjIds = regexp(MdBeh.DataFile, '(.+)_[1-2]_data.csv', 'tokens');
    subjIds = cellfun(@(x) x{:}, subjIds);
    [~,~,subjNums] = unique(subjIds);
    
    MdBeh.SubjNum = subjNums;
    MdBeh.SubjId = subjIds;
    
    varOrder = {'SubjNum';
                'SubjId';
                'DataFile';
                'NumNoResponse';
                'EasyAcc';
                'HardAcc';
                'EasyRT';
                'HardRT'};
            
	MdBeh = MdBeh(:, varOrder);
    
    MdBehSubjAvg = table();
    MdBehSubjAvg.SubjNum = unique(MdBeh.SubjNum);
    MdBehSubjAvg.EasyAcc = accumarray(MdBeh.SubjNum, MdBeh.EasyAcc, [], @mean);
    MdBehSubjAvg.HardAcc = accumarray(MdBeh.SubjNum, MdBeh.HardAcc, [], @mean);
    MdBehSubjAvg.EasyRT = accumarray(MdBeh.SubjNum,  MdBeh.EasyRT, [], @mean);
    MdBehSubjAvg.HardRT = accumarray(MdBeh.SubjNum,  MdBeh.HardRT, [], @mean);
    
    
    %% stats
    %Mean and std
    %Easy
    meanEasyAcc = mean(MdBehSubjAvg.EasyAcc) * 100;
    stdEasyAcc = std(MdBehSubjAvg.EasyAcc) * 100;
    
    meanEasyRT = mean(MdBehSubjAvg.EasyRT);
    stdEasyRT = std(MdBehSubjAvg.EasyRT);
    
    fprintf('\nEasy Trials\n');
    fprintf('\tAcc: %0.2f%% +- %0.2f%%\n', meanEasyAcc, stdEasyAcc);
    fprintf('\tRT: %0.2fs +- %0.2fs\n', meanEasyRT, stdEasyRT);
    
    %Hard
    meanHardAcc = mean(MdBehSubjAvg.HardAcc) * 100;
    stdHardAcc = std(MdBehSubjAvg.HardAcc) * 100;
    
    meanHardRT = mean(MdBehSubjAvg.HardRT);
    stdHardRT = std(MdBehSubjAvg.HardRT);
    
    fprintf('\nHardTrials\n');
    fprintf('\tAcc: %0.2f%% +- %0.2f%%\n', meanHardAcc, stdHardAcc);
    fprintf('\tRT: %0.2fs +- %0.2fs\n', meanHardRT, stdHardRT);
    
    
    
    %more accurate on easy trials than hard trials
    nSubjs = height(MdBehSubjAvg);
    [~,p,~,stats] = ttest(MdBehSubjAvg.EasyAcc, MdBehSubjAvg.HardAcc);
    tstat = stats.tstat;
    df = stats.df;
    
    pooledSD = sqrt(((nSubjs-1)*(stdEasyAcc^2 + stdHardAcc^2)) / (2*nSubjs-2));
    meanDiff = meanEasyAcc - meanHardAcc;
    cohensD = meanDiff / pooledSD;
    fprintf('\nMore Accurate on Easy then Hard\n');
    fprintf('\tt(%d): %0.5f\n', df, tstat);
    fprintf('\tp: %d\n', p);
    fprintf('\td: %0.5f\n', cohensD);
    
    
    
	%faster on easy trials than hard trials
    [~,p,~,stats] = ttest(MdBehSubjAvg.HardRT, MdBehSubjAvg.EasyRT);
    tstat = stats.tstat;
    df = stats.df;
    
    pooledSD = sqrt(((nSubjs-1)*(stdEasyRT^2 + stdHardRT^2)) / (2*nSubjs-2));
    meanDiff = meanHardRT - meanEasyRT;
    cohensD = meanDiff / pooledSD;
    fprintf('\nFaster on Easy then Hard\n');
    fprintf('\tt(%d): %0.5f\n', df, tstat);
    fprintf('\tp: %d\n', p);
    fprintf('\td: %0.5f\n', cohensD);
end

