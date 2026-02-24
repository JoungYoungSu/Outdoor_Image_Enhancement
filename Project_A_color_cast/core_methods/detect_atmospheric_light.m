% 1. 쿼드 트리 영역 분할 방식을 이용한 영상 대기광 영역 검출

function [Area, npass, index, LAB, a, b, atm] = detect_atmospheric_light(i)

Area=i; n=1; %초기화

% 최대 반복 횟수까지 반복
while(n<=9)&&(nnz(Area)/3>100) 

    % step 1. 입력 영상 X의 영역 분할 
    c1 = split_into_quadrants(Area);

    % step 2. 쿼드 트리 영역 점수(score) 설정
    score = zeros(1,4);
    for k = 1:4
        temp = reshape(c1{k}, [], 3);
        hl = temp(:);
        score(k) = abs(mean(hl,'omitnan') - std(hl,'omitnan'));
    end

    % step 3. 최적 대기광 영역 선별
    % 가장 큰 score 점수 가진 Area 선별
    [~, idx] = max(score);      % 중복 점수 방지 max 방식
    Area = c1{idx};
    index(n,1) = idx;           % 최댓값 위치 저장(find랑 동일 역할)
    
    n=n+1; 

    % 반복 회차별 선별된 Area 확인 및 출력
    %figure;imshow(Area); 
    %saveName = ['debug_iter_', num2str(n), '.tiff'];
    %imwrite(Area,saveName);

end

% 최종 선별된 Area의 표준편차 계산 
stand1(1,n)=std(Area(:),'omitnan');
npass=stand1(1,3); %3번째 영역: 안개 베일

% step 4. LAB 색공간 변환 및 대기광 영역 출력
% RGB -> CIELAB 변환 코드: 채널 1, 2, 3에 각각 L, a, b 채널
cform=makecform('srgb2lab'); %Image Processing Toolbox 필요

% 입력 영상 X를 CIELAB으로
LAB=applycform(uint8(i.*255), cform); % 전체 영상
LAB = double(LAB)/255;
a = LAB(:,:,2)-0.5; 
b = LAB(:,:,3)-0.5;

% 대기광 영역 Area를 CIELAB으로
ALAB=applycform(uint8(Area.*255), cform); 
ALAB = double(ALAB)/255;
ALAB(:,:,2) =ALAB(:,:,2)-0.5; 
ALAB(:,:,3) =ALAB(:,:,3)-0.5;

% 전역 배경 대기광 atm 계산
[Ah, Aw, ~]=size(Area);
atm=reshape(ALAB,Ah* Aw,3); %Area의 대기광 L, A, B 모두 출력
atm=sum(atm)/(Ah* Aw); % atm: 대기광 영역의 각 색 채널 평균 LA, aA, bA

end