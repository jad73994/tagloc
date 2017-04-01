function [ bits_data ] = getBitsData( rngInput )
%GETBITSDATA Summary of this function goes here
%   Detailed explanation goes here
    load Parameters.mat   

    numBits=num_syms_data*num_bins_data;
    rng(rngInput);
    bits_data=randi(2,1,numBits)-1;

end

