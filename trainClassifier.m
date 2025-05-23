function [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% Returns a trained classifier and its accuracy. The following code recreates the classification model trained in Classification Learner. You can use
% this generated code to automatically train the same model on new data, or to learn how to train the model programmatically.
%
%  Input:
%      trainingData: A table containing the predictor and response columns imported into the App.
%
%
%  Output:
%      trainedClassifier: A struct containing the trained classifier. This struct has various fields with information about the trained classifier.
%
%      trainedClassifier.predictFcn: A function to make predictions on new data.
%
%      validationAccuracy: A double value representing the validation accuracy in percentage. In the App, the "Models" pane displays the validation accuracy for each model.
%
% Use this code to train the model on new data. To retrain the classifier, call this function from the command line with the original data or new data as the input argument trainingData.
%
% For example, to retrain a classifier trained on the original dataset T, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T)
%
% To make predictions on new data T2 using the returned "trainedClassifier", use:
%   [yfit,scores] = trainedClassifier.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as those used during training. For details, enter:
%   trainedClassifier.HowToPredict

% Auto-generated by MATLAB on 2025-05-19 16:46:23


% Extract predictors and response
% This code processes the data into the appropriate shape for training the model.
%
inputTable = trainingData;
predictorNames = {'RR_Prev', 'RR_Post', 'R_Amplitude', 'P_Amplitude', 'Q_Amplitude', 'S_Amplitude', 'T_Amplitude', 'PR_Interval', 'QRS_Duration', 'ST_Segment', 'QT_Interval', 'P_Duration', 'T_Duration', 'P_Area', 'QRS_Area', 'T_Area'};
predictors = inputTable(:, predictorNames);
response = inputTable.BeatType;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
classNames = categorical({'1'; '5'; '8'});

% Train the classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 141854, ...
    'NumVariablesToSample', 'all');
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template, ...
    'ClassNames', classNames);

% Create the result struct with the predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

% Add fields to the result struct
trainedClassifier.RequiredVariables = {'RR_Prev', 'RR_Post', 'R_Amplitude', 'P_Amplitude', 'Q_Amplitude', 'S_Amplitude', 'T_Amplitude', 'PR_Interval', 'QRS_Duration', 'ST_Segment', 'QT_Interval', 'P_Duration', 'T_Duration', 'P_Area', 'QRS_Area', 'T_Area'};
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2024b.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table T, use: \n [yfit,scores] = c.predictFcn(T) \nReplace ''c'' with the variable name of this struct, e.g., ''trainedModel''.\n \nThe table T must contain the variables returned by this property: \n c.RequiredVariables \nThe variable formats (e.g., matrix/vector, data type) must match the original training data.\nOther variables are ignored.\n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the appropriate shape for training the model.
%
inputTable = trainingData;
predictorNames = {'RR_Prev', 'RR_Post', 'R_Amplitude', 'P_Amplitude', 'Q_Amplitude', 'S_Amplitude', 'T_Amplitude', 'PR_Interval', 'QRS_Duration', 'ST_Segment', 'QT_Interval', 'P_Duration', 'T_Duration', 'P_Area', 'QRS_Area', 'T_Area'};
predictors = inputTable(:, predictorNames);
response = inputTable.BeatType;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
classNames = categorical({'1'; '5'; '8'});

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationEnsemble, 'KFold', 10);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
