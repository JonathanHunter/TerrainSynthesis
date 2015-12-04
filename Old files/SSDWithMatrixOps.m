function SSDWithMatrixOps()
    image(generateImage());
end

function image = generateImage()
    image1 = double(rgb2gray(imread('C:\Users\Jonathan\Desktop\FaceSmall', 'png')));
    image2 = double(rgb2gray(imread('C:\Users\Jonathan\Desktop\FaceSmall1', 'png')));
    
    dim = size(image2);
    image = zeros(dim(1), dim(2));
    for r = 1:dim(1)
        for c = 1:dim(2)
            image(r,c) = sumOfSquaresDifference(image1, image2, r,c);
        end
    end
    image
end

function ssd = sumOfSquaresDifference(image1, image2, r, c)
    dim1 = size(image1);
    dim2 = size(image2);
    temp = zeros(dim1(1),dim1(2));
    for i = 1:dim1(1)
        x = r + i - 1;
        if x > dim2(1)
            x = x - dim2(1);
        end
        y = c + dim1(2) - 1;
        if y > dim2(2)
            y = y - dim2(2);
            temp(i, 1:(dim2(2) - c + 1)) = image2(x, c:dim2(2));
            temp(i, (dim2(2) - c + 2):dim1(2)) = image2(x, 1:y);
        else
            temp(i, 1:dim1(2)) = image2(x, c:y);
        end
    end
    ssd = ((image1 - temp).^2);
    ssd = sum(ssd(:));
    ssd = ssd/(255 * dim1(1) * dim1(2));
end