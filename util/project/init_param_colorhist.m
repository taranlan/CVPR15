numColorHistBins = 22;
maxLValue = 100;

LBinSize = maxLValue / numColorHistBins;
abBinSize = 256 / numColorHistBins;
LBinEdges = [0:LBinSize:100];
abBinEdges = [-128:abBinSize:128];