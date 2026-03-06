% LAB 색공간에서의 선형적 깊이맵 식 추정
% CAP에서 사용된 방식과 동일하게 Guided Filter를 적용하여
% 투과율을 정제함

function J = estimate_lab_depth_model(im, L, a, b, atm, a1, a2, a3)

D = a1 + a2.*L + a3.*sqrt(a.^2+b.^2); 
refineD = fastguidedfilter_color(im, D, 7, 10^-3, 7/4); % 가이드 필터: d 안개 잡음 방지

t = exp(-1*refineD); % 계산한 d를 투과율 식에 입력

% t는 0.05~0.95 (0 or 1 부근의 잡음 발생 방지)
[x, y]=size(t);

for ti=1:x
    for tj=1:y
        if t(ti,tj)<0.05, t(ti,tj)=0.05; 
        elseif t(ti,tj)>1, t(ti,tj)=1;     
        end
    end
end

%--------------------------4. 디헤이징-------------------------------
J = zeros(x, y); 
J = L-atm(1);
J = J./t;
J = J+atm(1);

% imwrite(L,'D:\Outdoor_Image_Enhancement\Project_B_dehazing\L.png');
% imwrite(D,'D:\Outdoor_Image_Enhancement\Project_B_dehazing\D.png');
% imwrite(refineD,'D:\Outdoor_Image_Enhancement\Project_B_dehazing\Guide.png');
% imwrite(t,'D:\Outdoor_Image_Enhancement\Project_B_dehazing\t.png');
% imwrite(J,'D:\Outdoor_Image_Enhancement\Project_B_dehazing\J.png');

end