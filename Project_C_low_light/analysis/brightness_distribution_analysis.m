% 영상의 밝기 평균 분포 분석
% 사용 데이터셋: LOL dataset (real subset 약 90장)

clear; clc;

% dataset path (user should modify this)
dataset_path = 'your_dataset_path_here';

LOW_DATA = zeros(90,1);

for fileIndex = 1:90

input_path=strcat(dataset_path,num2str(fileIndex),'.tiff'); %잡음 B 
img = imread(input_path);

img = double(img)/255; % 스케일링

% Project A (color correction)
StageA = color_cast_correction(img); 

% depth model parameters
a1 = -0.0391; 
a2 = 0.9180; 
a3 = -1.8072; 

% Dehazing
J = estimate_lab_depth_model(img, ...
 StageA.L, StageA.a_corr, StageA.b_corr, StageA.atm, ...
 a1, a2, a3);

% Average brightness
J_ave=sum(sum(J))/numel(J);

LOW_DATA(fileIndex,1) = J_ave; 

end

% plot
figure, plot(1:numel(LOW_DATA), LOW_DATA(1:numel(LOW_DATA),1),'.r'),hold on
xlim([1 numel(LOW_DATA)]); ylim([0 0.8]);
plot(1:numel(LOW_DATA), 0.6.*ones(1,numel(LOW_DATA)),'--k'), hold on
plot(1:numel(LOW_DATA), 0.35.*ones(1,numel(LOW_DATA)),'--k'), hold off

title('Average brightness of low-light dataset');
xlabel('Dataset');
ylabel('Average brightness');