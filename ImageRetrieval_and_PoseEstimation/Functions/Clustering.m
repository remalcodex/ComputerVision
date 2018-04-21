function Clustering()
    d = uigetdir(pwd, 'Inputs/database/');
    files = dir(fullfile(d, '*.png'));
%     descriptors = [];
%     locs = [];
%     fnames = {'0_1.png';'0_2.png';'0_3.png';'0_4.png';'10_1.png';'10_2.png';'10_3.png';'10_4.png';'11_1.png';'11_2.png';'11_3.png';'11_4.png';'12_1.png';'12_2.png';'12_3.png';'12_4.png';'13_1.png';'13_2.png';'13_3.png';'13_4.png';'14_1.png';'14_2.png';'14_3.png';'14_4.png';'15_1.png';'15_2.png';'15_3.png';'15_4.png';'16_1.png';'16_2.png';'16_3.png';'16_4.png';'17_1.png';'17_2.png';'17_3.png';'17_4.png';'18_1.png';'18_2.png';'18_3.png';'18_4.png';'19_1.png';'19_2.png';'19_3.png';'19_4.png';'1_1.png';'1_2.png';'1_3.png';'1_4.png';'20_1.png';'20_2.png';'20_3.png';'20_4.png';'21_1.png';'21_2.png';'21_3.png';'21_4.png';'22_1.png';'22_2.png';'22_3.png';'22_4.png';'23_1.png';'23_2.png';'23_3.png';'23_4.png';'24_1.png';'24_2.png';'24_3.png';'24_4.png';'26_1.png';'26_2.png';'26_3.png';'26_4.png';'27_1.png';'27_2.png';'27_3.png';'27_4.png';'28_1.png';'28_2.png';'28_3.png';'28_4.png';'29_1.png';'29_2.png';'29_3.png';'29_4.png';'2_1.png';'2_2.png';'2_3.png';'2_4.png';'30_1.png';'30_2.png';'30_3.png';'30_4.png';'31_1.png';'31_2.png';'31_3.png';'31_4.png';'32_1.png';'32_2.png';'32_3.png';'32_4.png';'33_1.png';'33_2.png';'33_3.png';'33_4.png';'34_1.png';'34_2.png';'34_3.png';'34_4.png';'35_1.png';'35_2.png';'35_3.png';'35_4.png';'36_1.png';'36_2.png';'36_3.png';'36_4.png';'37_1.png';'37_2.png';'37_3.png';'37_4.png';'38_1.png';'38_2.png';'38_3.png';'38_4.png';'39_1.png';'39_2.png';'39_3.png';'39_4.png';'3_1.png';'3_2.png';'3_3.png';'3_4.png';'40_1.png';'40_2.png';'40_3.png';'40_4.png';'41_1.png';'41_2.png';'41_3.png';'41_4.png';'42_1.png';'42_2.png';'42_3.png';'42_4.png';'43_1.png';'43_2.png';'43_3.png';'43_4.png';'46_1.png';'46_2.png';'46_3.png';'46_4.png';'47_1.png';'47_2.png';'47_3.png';'47_4.png';'48_1.png';'48_2.png';'48_3.png';'48_4.png';'49_1.png';'49_2.png';'49_3.png';'49_4.png';'4_1.png';'4_2.png';'4_3.png';'4_4.png';'50_1.png';'50_2.png';'50_3.png';'50_4.png';'51_1.png';'51_2.png';'51_3.png';'51_4.png';'52_1.png';'52_2.png';'52_3.png';'52_4.png';'53_1.png';'53_2.png';'53_3.png';'53_4.png';'5_1.png';'5_2.png';'5_3.png';'5_4.png';'6_1.png';'6_2.png';'6_3.png';'6_4.png';'8_1.png';'8_2.png';'8_3.png';'8_4.png';'9_1.png';'9_2.png';'9_3.png';'9_4.png'};
%     for i = 1:size(fnames)
%         fname = fnames(i);
%         fname = fname{:};
%         [image, descriptor, loc] = sift(strcat('Inputs/database/', fname));
%         descriptors = [descriptors; descriptor];
%         locs = [locs; loc];
%     end
    load('Inputs/descriptors.mat');
    %Ran and saved the idx and C matrix. Uncomment if you wish to run it
    %again.
    %[idx, C] = kmeans(descriptors, 1000);
    load('Inputs/idx.mat');
    load('Inputs/C.mat');
    
    query_names = {'0.png';'1.png';'10.png';'11.png';'12.png';'13.png';'14.png';'15.png';'16.png';'17.png';'18.png';'19.png';'2.png';'20.png';'21.png';'22.png';'23.png';'24.png';'26.png';'27.png';'28.png';'29.png';'3.png';'30.png';'31.png';'32.png';'33.png';'34.png';'35.png';'36.png';'37.png';'38.png';'39.png';'4.png';'40.png';'41.png';'42.png';'43.png';'46.png';'47.png';'48.png';'49.png';'5.png';'50.png';'51.png';'52.png';'53.png';'6.png';'8.png';'9.png'};
    
    for i = 1:size(query_names)
        qname = query_names(i);
        qname = qname{:};
        
    end
end