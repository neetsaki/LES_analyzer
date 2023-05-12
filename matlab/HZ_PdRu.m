// image filepath
im_Pd=imread('./View000 Pd L.bmp');
im_Ru=imread('./View000 Ru L.bmp');

Pd=im_Pd(1:512,12:523,1)+im_Pd(1:512,12:523,2)+im_Pd(1:512,12:523,3);
Ru=im_Ru(1:512,12:523,1)+im_Ru(1:512,12:523,2)+im_Ru(1:512,12:523,3);
// divide original EDS images 
div_num=16;
similarity=ones(div_num,div_num);
reduce_image_Pd=ones(div_num,div_num);
reduce_image_Ru=ones(div_num,div_num);

for i=1:1:div_num
    for j=1:1:div_num
        div=fix(512/div_num);
        Pd_pixel=Pd(i*div-div+1:i*div,j*div-div+1:j*div);
        ratio_Pd=mean(Pd_pixel(:));
        Ru_pixel=Ru(i*div-div+1:i*div,j*div-div+1:j*div);
        ratio_Ru=mean(Ru_pixel(:));
        if ratio_Pd < 128/div_num || ratio_Ru < 128/div_num
            reduce_image_Pd(i,j)=0;
            reduce_image_Ru(i,j)=0;
        else
            reduce_image_Pd(i,j)=ratio_Pd;
            reduce_image_Ru(i,j)=ratio_Ru;
        end
    end
end

reduce_image_Pd_norm=reduce_image_Pd/sum(reduce_image_Pd(:));
reduce_image_Ru_norm=reduce_image_Ru/sum(reduce_image_Ru(:));
ratio_average=mean(Pd)/mean(Ru);
blank=0;
for i=1:1:div_num
    for j=1:1:div_num
        div=fix(512/div_num);
        ratio_Pd=reduce_image_Pd_norm(i,j);
        ratio_Ru=reduce_image_Ru_norm(i,j);
%        Pd_pixel=Pd(i*div-div+1:i*div,j*div-div+1:j*div);
%        ratio_Pd=mean(Pd_pixel(:));
%        Ru_pixel=Ru(i*div-div+1:i*div,j*div-div+1:j*div);
%        ratio_Ru=mean(Ru_pixel(:));
        if ratio_Pd == 0 || ratio_Ru ==0
            ratio=0;
            blank = blank + 1;
        else
            ratio=log(ratio_Pd/ratio_Ru);
        end
        similarity(i,j)=ratio;
    end
end
blank_vs_total=blank/(512/div_num)/(512/div_num);
outlier_Pd4Ru=svd(similarity*similarity.'/(1-blank_vs_total)/(1-blank_vs_total));

x=1:1:div_num;
y=1:1:div_num;
[X,Y]=meshgrid(x,y);
axis([1 div_num 1 div_num]);
surf(X,Y,similarity)
