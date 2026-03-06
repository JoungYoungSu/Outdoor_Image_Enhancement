% Depth model(depth = a0 + a1*L + a2*Δc)의 매개변수 측정하기
% 사용한 데이터세트: D-HAZY, NYU Depth dataset

clear; clc;

%데이터셋 경로 설정
dataset_root = 'D-HAZY';

depth_path  = fullfile(dataset_root,'NYU_depth');
L_path      = fullfile(dataset_root,'NYU_Hazy','L_new');
chroma_path = fullfile(dataset_root,'NYU_Hazy','chroma_new');

for fileIndex = 1:1449

    STR6 = num2str(fileIndex);

    % 파일 경로 생성
    D=strcat(STR1,'D-HAZY\NYU_depth',STR6,'.tiff');
    L=strcat(STR2,'D-HAZY\NYU_Hazy\L_new',STR6,'.tiff');
    color=strcat(STR2,'D-HAZY\NYU_Hazy\chroma_new',STR6,'.tiff');
    
    imD = imread(D); 
    imL = imread(L); 
    imcolor = imread(color); 
    
    [height, width] = size(imD);
    
    X = zeros(height*width,3);
    
    X(:,1) = ones(size(X,1),1); % 상수의 매개변수 a0 
    X(:,2) = double(imL(:))/255; % L의 배개변수 a1 
    X(:,3) = double(imcolor(:))/255; % chroma의 매개변수 a2
    Y(:,1) = double(imD(:))/255; % Y는 깊이맵 D
    
    X=[X(:,1) X(:,2) X(:,3)]; 
    [b,~,~,~,stats]=regress(Y,X); %Multiple linear regression (MATLAB 'regress')
    
    parameter(:,fileIndex)=b;
    error(:,fileIndex)=stats;

end

% 오직 R^2 > 0.9인 결과만 최종 parameters에 사용
parameter2=parameter(:,error(1,:)>0.9);
result=mean(parameter2,2);