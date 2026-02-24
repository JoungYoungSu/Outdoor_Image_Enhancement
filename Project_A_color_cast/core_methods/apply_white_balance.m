%2. 영상의 색조 분류 및 화이트 밸런스
function [a, b] = apply_white_balance(a, b, atm, npass)

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

end