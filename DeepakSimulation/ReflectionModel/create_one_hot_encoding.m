%clear
%load dataset_multipath_profiles.mat
% This script will convert the dataset into one hot encoding
labels_discrete = ceil(labels./2);
n_xlabels = length(unique(labels_discrete(:,1)));
n_ylabels =length(unique(labels_discrete(:,2)));
labels_idx=sub2ind([n_xlabels,n_ylabels],labels_discrete(:,1),labels_discrete(:,2));
labels_one_hot = zeros(size(labels,1),n_xlabels*n_ylabels);
for i=1:size(labels_one_hot,1)
    labels_one_hot(i,labels_idx(i))=1;
end
    