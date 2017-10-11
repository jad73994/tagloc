%clear
%load('ReflectionModel\dataset_delta_simple.mat')
err = zeros(size(labels));
for i=1:size(features,1)
    ground_truth=labels(i,:);
    p=zeros(size(features,3),size(features,4));
    for j=1:size(features,2)
        p = p+squeeze(features(i,j,:,:));
        
    end
    [~,idx]=max(p(:));
    [a,b]=ind2sub(size(p),idx);
    prediction = [(b-1)*0.5,(a-1)*0.5];
    err(i,:) = prediction-ground_truth;
end