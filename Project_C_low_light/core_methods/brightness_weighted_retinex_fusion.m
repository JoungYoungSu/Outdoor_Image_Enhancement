% 밝기 가중치 기반 Retinex와 디헤이징 혼합 
function R = brightness_weighted_retinex_fusion(J)

% J의 평균 밝기 계산
J_ave=sum(sum(J))/numel(J); 

% 밝기 기반 case 분류
if J_ave>0.6, R = double(J);

else
    L = double(J*255+ 1) ; %8bit 변환 후 log 계산을 위해 1을 더함.
    
    % SSR 함수 적용
    SSR = ssr_retinex(L); 
    
        if J_ave<0.35
            R = 0.2.*double(J) + 0.8.*SSR; % Case 3. 레티넥스 가중치 0.8
        else 
            R = 0.4.*double(J) + 0.6.*SSR; % Case 2. 레티넥스 가중치 0.6
        end

end

