using ImageMagick
using Images
using LinearAlgebra
using DelimitedFiles
using Plots

function save_data(data,name)
    a=open(string(name,".txt"),"w")
    writedlm(a,data,"\t")
    close(a)
    return true
end

function draw_matrix(matrix,im_num)
    heatmap(matrix;colormap=:coolwarm,clim=(-2,2))
    heatmap!(size=(1150,1000))
    savefig(string("./","$im_num",".png"))
    return true
end

imread(fname)=channelview(Gray.(load(fname)))*255f0
im_Pd=imread("./View000 Pd L.bmp")
im_Ru=imread("./View000 Ru L.bmp")
Pd=im_Pd[1:512,12:523]
Ru=im_Ru[1:512,12:523]

div_num=32
similarity=ones(div_num,div_num)
reduce_image_Pd=ones(div_num,div_num)
reduce_image_Ru=ones(div_num,div_num)
div=Int(512/div_num)

a=ones(div,div)
b=ones(div_num,div_num)

for i in 1:div_num
    for j in 1:div_num
        Pd_pixel=Pd[i*div-div+1:i*div,j*div-div+1:j*div]
        ratio_Pd=dot(Pd_pixel,a)/div/div
        Ru_pixel=Ru[i*div-div+1:i*div,j*div-div+1:j*div]
        ratio_Ru=dot(Ru_pixel,a)/div/div
        if ratio_Pd < 128/div_num || ratio_Ru < 128/div_num
            reduce_image_Pd[i,j]=0
            reduce_image_Ru[i,j]=0
        else
            reduce_image_Pd[i,j]=ratio_Pd;
            reduce_image_Ru[i,j]=ratio_Ru;
        end
    end
end


reduce_image_Pd_norm=reduce_image_Pd/dot(reduce_image_Pd,b)
reduce_image_Ru_norm=reduce_image_Ru/dot(reduce_image_Ru,b)

ratio_average=dot(Pd,ones(512,512))/dot(Ru,ones(512,512))
num_blank=0

for i in 1:div_num
    for j in 1:div_num
        ratio_Pd=reduce_image_Pd_norm[i,j]
        ratio_Ru=reduce_image_Ru_norm[i,j]
        if ratio_Pd == 0 || ratio_Ru ==0
            ratio=0
            num_blank = num_blank + 1
        else
            ratio=log(ratio_Pd/ratio_Ru);
        end
        similarity[i,j]=ratio
    end
end

blank_vs_total=num_blank/div/div
outlier_PdRu=eigvals(similarity*similarity'/(1-blank_vs_total)/(1-blank_vs_total))
save_data(outlier_PdRu,"./Outlier_Matrix_Eigenvalues.txt")

similarity_T=ones(div_num,div_num)
for x in 1:div_num
    for y in 1:div_num
        similarity_T[Int(x),y]=similarity[Int(div_num-x+1),y]
    end
end
draw_matrix(similarity_T,"PdRu4")