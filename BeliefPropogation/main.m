clc;
%clear all;
close all;
imtool close all;
addpath(genpath('Functions/'));

%Step 1.
BeliefPropogation_Hamming();

%Step 2.
BP_Stereo();

close all;