% D-Hazy 데이터 세트의 L, a,b 채널 출력
im = imread(NYU_Hazy); % D-HAZY의 NYU_Hazy 데이터세트 입력

cform = makecform('srgb2lab');
LAB = applycform(im, cform);
LAB =double(LAB)/255;

L = LAB(:,:,1);
LAB(:,:,2) = LAB(:,:,2)-0.5; %a, b기본 값으로 d구하기 위함
LAB(:,:,3) = LAB(:,:,3)-0.5;
a = LAB(:,:,2);
b = LAB(:,:,3);

chroma= sqrt(a.^2+b.^2); % Chroma(채도) 수식

imwrite(L,Lname);% L(밝기) 이미지 추출
imwrite(chroma,colorname);% Chroma(채도) 사진 추출
