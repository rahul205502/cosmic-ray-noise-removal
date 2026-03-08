
I2 = im2double(imread('cosmic_corrupted_img_2012.png'));
I1 = im2double(imread('cosmic_corrupted_img_2010.png'));

if size(I1,3)==3
    I1 = rgb2gray(I1);
end

if size(I2,3)==3
    I2 = rgb2gray(I2);
end

[optimizer, metric] = imregconfig('monomodal');
I2_reg = imregister(I2,I1,'translation',optimizer,metric);

I = I2_reg;
Ref = I1;

[m,n] = size(I);

% Temporal difference
F1 = abs(I - Ref).^1.5;
% Gradient magnitude
[Gx,Gy] = imgradientxy(I);
F2 = sqrt(Gx.^2 + Gy.^2);
% Laplacian spike detection
Hlap = fspecial('laplacian',0.2);
F3 = abs(imfilter(I,Hlap,'replicate'));
% Local variance
F4 = stdfilt(I,ones(3));

F1 = mat2gray(F1);
F2 = mat2gray(F2);
F3 = mat2gray(F3);
F4 = mat2gray(F4);

fis = mamfis('Name','CosmicRayDetector');

fis = addInput(fis,[0 1],'Name','Diff');
fis = addInput(fis,[0 1],'Name','Grad');
fis = addInput(fis,[0 1],'Name','Lap');
fis = addInput(fis,[0 1],'Name','Var');

for i = 1:4
    fis = addMF(fis,fis.Inputs(i).Name,'trapmf',[0 0 0.2 0.4],'Name','low');
    fis = addMF(fis,fis.Inputs(i).Name,'trimf',[0.2 0.5 0.8],'Name','medium');
    fis = addMF(fis,fis.Inputs(i).Name,'trapmf',[0.6 0.8 1 1],'Name','high');
end
fis = addOutput(fis,[0 1],'Name','CR_Prob');

fis = addMF(fis,'CR_Prob','trapmf',[0 0 0.2 0.4],'Name','low');
fis = addMF(fis,'CR_Prob','trimf',[0.3 0.6 0.9],'Name','medium');
fis = addMF(fis,'CR_Prob','trapmf',[0.7 0.85 1 1],'Name','high');

ruleList = [
3 0 0 0 3 1 1;
3 0 3 0 3 1 1;
3 0 2 0 3 1 1;
3 0 0 3 3 1 1;

2 0 3 0 2 1 1;
2 2 2 2 2 1 1;

1 0 0 0 1 1 1;
];

fis = addRule(fis,ruleList);

featureMatrix = [F1(:) F2(:) F3(:) F4(:)];
CR_prob = evalfis(fis,featureMatrix);
CR_prob = reshape(CR_prob,m,n);

CR_mask = CR_prob > 0.55;
CR_mask = bwareaopen(CR_mask,2);
CR_mask = imdilate(CR_mask,strel('disk',1));

I_nlms = I;
padI = padarray(I,[1 1],'symmetric');
mu0 = 0.7;
epsi = 1e-6;

w = ones(9,1)/9;

for i = 2:m+1
    for j = 2:n+1
        if CR_mask(i-1,j-1)
            x = reshape(padI(i-1:i+1,j-1:j+1),[],1);
            d = padI(i,j);

            y = w'*x;
            e = d - y;
            mu = mu0 * CR_prob(i-1,j-1);
            w = w + mu*e*x/(norm(x)^2 + epsi);
            I_nlms(i-1,j-1) = w'*x;
        end
    end
end

lambda = 0.99;
delta = 0.01;

I_rls = I_nlms;
padI = padarray(I_nlms,[1 1],'symmetric');

for i = 2:m+1
    for j = 2:n+1
        if CR_prob(i-1,j-1) > 0.75
            x = reshape(padI(i-1:i+1,j-1:j+1),[],1);
            d = padI(i,j);
            w = zeros(9,1);
            P = (1/delta)*eye(9);
            k = (P*x)/(lambda + x'*P*x);

            e = d - w'*x;
            w = w + k*e;
            P = (P - k*x'*P)/lambda;
            I_rls(i-1,j-1) = w'*x;
        end
    end
end

I_final = imgaussfilt(I_rls,0.6);

figure;
sgtitle('Input Cosmic ray corrupted Images')
subplot(1,2,1)
imshow(I1)
title('year = 2010')

subplot(1,2,2)
imshow(I2)
title('year = 2012')

figure;
subplot(1,2,1)
imshow(CR_prob,[])
colorbar
title('CR Probability Map')

subplot(1,2,2)
imshow(CR_mask)
title('Detected Cosmic Rays')

figure;
imshow(I_final)
title('Final Output')

clean_pixels = ~CR_mask;
PSNR = psnr(I_final(clean_pixels), I(clean_pixels));
MSE = immse(I_final(clean_pixels), I(clean_pixels));

fprintf('PSNR: %.4f dB\n',PSNR);
fprintf('MSE: %.6f\n',MSE);