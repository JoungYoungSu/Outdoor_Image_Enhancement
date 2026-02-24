% 1. 색조 기반 화이트 밸런스 
clear all;

% 사진 입력을 위한 경로 설정
STR1='D:\합친파일\대학원\대학원\안개영상\원본\'; %입력 경로
STR2='도시전광'; 
STR3='122'; 
STR5='D:\Outdoor_Image_Enhancement\Project_A_color_cast\results\'; %출력 경로
input_path=strcat(STR1,STR2,'\',STR3,'.tiff'); 

% 입력
i = imread(input_path);
im = double(i)/255;
[x,y,z]=size(im);
if z==1, im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);end

%-------------1-1. 쿼드 트리 영역 분할 방식을 이용한 영상 대기광 검출----------
Area=im; n=1;

% 최대 반복 횟수까지 반복
while(n<=9)&&(nnz(Area)/3>100) 
    [Ah, Aw, ~]=size(Area);
    
    % step 1. 입력 영상 X의 영역 분할 
    % 홀수인 경우 사이즈 증가
    if rem(Ah,2)==1, Area(Ah+1,:,:)=NaN;[Ah, Aw, ~]=size(Area);end
    if rem(Aw,2)==1, Area(:,Aw+1,:)=NaN;[Ah, Aw, ~]=size(Area);end
    
    % 쿼드 트리 영역(Area) 분할
    A1=Area(1:Ah/2,1:Aw/2,:);
    A2=Area(1:Ah/2,Aw/2+1:end,:);
    A3=Area(Ah/2+1:end,1:Aw/2,:);
    A4=Area(Ah/2+1:end,Aw/2+1:end,:);
    
    % 1번 쿼드 트리했을 때의 Area 출력 확인 
    if n==1
       saveName=strcat(STR5,'A1'); 
       imwrite(A1,sprintf('%s.tiff',saveName));
       saveName=strcat(STR5,'A2'); 
       imwrite(A2,sprintf('%s.tiff',saveName));
       saveName=strcat(STR5,'A3'); 
       imwrite(A3,sprintf('%s.tiff',saveName));
       saveName=strcat(STR5,'A4'); 
       imwrite(A4,sprintf('%s.tiff',saveName));
    end
    
    % step 2. 쿼드 트리 영역 점수(score) 설정
    % 계산을 위해 각 AREA R,G,B로 한줄 정렬
    A=zeros((Ah/2)*(Aw/2),3); 
    A(:,:,1)=reshape(A1, (Ah/2)*(Aw/2), 3);
    A(:,:,2)=reshape(A2, (Ah/2)*(Aw/2), 3);
    A(:,:,3)=reshape(A3, (Ah/2)*(Aw/2), 3);
    A(:,:,4)=reshape(A4, (Ah/2)*(Aw/2), 3);
    
    % 각 영역의 score식: 평균은 크고, 분산은 작아야함
    for int=1:4
        h=A(:,:,int);hl=h(:);
        score(int,:)=abs(mean(hl,'omitnan')-std(hl,'omitnan')); 
    end
    
    % step 3. 최적 대기광 영역 선별
    c1{1}=A1;c1{2}=A2;c1{3}=A3;c1{4}=A4;

    % 가장 큰 score 점수 가진 Area 선별
    Area=c1{score==max(score)};
    index(n,1)=find(score==max(score),1); %위치 저장 인덱스(잡음 판단 과정에 사용)
    
    % 반복 회차별 선별된 Area 확인 및 출력
    %figure;imshow(Area); 
    saveName=strcat(STR5,int2str(n)); %출력할 경로 및 이름
    imwrite(Area,sprintf('%s.tiff',saveName));
    
    n=n+1; 

end
% 최종 선별된 Area의 표준편차 계산 
[Ah, Aw, ~]=size(Area);
stand1(1,n)=std(Area(:),'omitnan');
npass=stand1(1,3);

% step 4. lAB 색공간 변환 및 대기광 영역 출력
% RGB -> CIELAB 변환 코드: 채널 1, 2, 3에 각각 L, a, b 채널
cform=makecform('srgb2lab'); %Image Processing Toolbox 필요

% 입력 영상 X를 CIELAB으로
LAB=applycform(i, cform); % 전체 영상
LAB = double(LAB)/255;
a = LAB(:,:,2)-0.5; 
b = LAB(:,:,3)-0.5;

% 대기광 영역 Area를 CIELAB으로
ALAB=applycform(uint8(Area.*255), cform); 
ALAB = double(ALAB)/255;
ALAB(:,:,2) =ALAB(:,:,2)-0.5; 
ALAB(:,:,3) =ALAB(:,:,3)-0.5;

% 전역 배경 대기광 atm 계산
atm=reshape(ALAB,Ah* Aw,3); %Area의 대기광 L, A, B 모두 출력
atm=sum(atm)/(Ah* Aw); % atm: 대기광 영역의 각 색 채널 평균 LA, aA, bA

%----------------1-2. 영상의 색조 분류 및 화이트 밸런스------------------------
% 대기광의 색조 계산
E_atm=sqrt(atm(:,2).^2+atm(:,3).^2);%채도 측정방법:E
if (E_atm<0.04)&&(npass>=0.09), E_atm=0;end %분산 높은 것 제외

% 대기광 색조(E_atm) 기반 화이트 밸런스 가중치(level: 0~1) 설정
if E_atm>0.1, level=1; % case 1. 매우 진한 컬러캐스트 
elseif (E_atm>=0.04)&&(E_atm<0.1),level=0.8; % case 2. 안개베일과 유사한 색 포함
elseif (E_atm>=0.02)&&(E_atm<0.04),level=0.6; % case 3. 일반적인 영상 포함
else level=0; % case 4. 대부분 비캐스트 영상
end

% 화이트 밸런스: 회색세계 가설 식(화소-평균)에 가중치 적용 
a = a-level*atm(:,2);
b = b-level*atm(:,3);

%---------------------------
% 각 채널에 코드 결과 입력하기
result = zeros(x,y,z);
result(:,:,1) = LAB(:,:,1);
result(:,:,2) = a+0.5; 
result(:,:,3) = b+0.5;
result=uint8(result.*255);

% RGB로 변환
cform_lab2srgb = makecform('lab2srgb'); 
R_whitebalace = applycform(result, cform_lab2srgb);

% 화이트 밸런스한 a, b 값 입력해 출력영상 확인
%R_whitebalace = lab_to_rgb(im, LAB(:,:,1), a, b);

imshow(R_whitebalace);
imwrite(R_whitebalace,sprintf('%s.tiff', strcat(STR5, 'white_result')));