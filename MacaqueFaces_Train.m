function [accuracy, CM, ids] = MacaqueFaces_Train(image_dir,output_fname,cval)

%% Train a classification model to identify faces
% Aimed at videos of rhesus macaque monkeys.
% Produces .mat file containing classification model and associated info.
%
% To get started all training images need to be sorted by identity into
% sub-directories (see model_set.zip for an example of this). Assumes
% training images of size 100x100 pixels. Returns accuracy calculated from
% k-fold cross-validation, confusion matrix (CM) and the order of the ids
% in the confusion matrix (ids)
%
% image_dir: fle path to directory containing the training images
%
% output_fname: filepath and filename to save model output to (will be
% saved as a .mat file)
%
% cval: by default ten-fold cross-validation will be used, set cval to use
% different number of k-folds.
%
% if there are not equal numbers of images for each individual then the
% minimum number of images will be used for training

if nargin<3
    cval=10;
end

%% Get Identities and Image Names

imgSet = imageSet(image_dir,'recursive');

ids={imgSet.Description};
imgcount=[imgSet.Count];

minimg=min(imgcount);
warning('off','vision:imageSet:atLeastOneOutputEmpty');
if sum(imgcount>minimg)>0
    [imgSet,~]=partition(imgSet,minimg,'method','randomized');
end


%% read in images and extract local binary pattern features
no=0;
allvecs=zeros(length(ids)*minimg,1475);
allids=cell(1,length(ids)*minimg);


for M=1:length(ids)
    for N=1:minimg
        I=imread(imgSet(M).ImageLocation{N});
        if ndims(I)==3
            I=rgb2gray(I); % if image is RGB then convert to grayscale
        end
        no=no+1;
        allvecs(no,:)=extractLBPFeatures(I,'Radius',1,'NumNeighbors',8,'CellSize',[20,20]);
        allids{no}=ids{M};
    end
end

%% run PCA and extract prinicple components explaining 95% of variance
[pca_coeffs,allscores,~,~,expl]=pca(allvecs);
i=find(cumsum(expl)<=95);
pca_coeffs=pca_coeffs(:,i);
allscores=allscores(:,i);
pca_mean=mean(allvecs);

%% train LDA classification model and run k-fold cross-validation

obj=fitcdiscr(allscores,allids,'discrimType','diagLinear');

part_Model=crossval(obj,'KFold',cval);
accuracy=(1-kfoldLoss(part_Model,'LossFun','ClassifError'))*100;
[valid_pred,~]=kfoldPredict(part_Model);
CM=confusionmat(allids,valid_pred,'order',ids);

save(output_fname,'obj','accuracy','pca_coeffs','pca_mean','CM','ids');
