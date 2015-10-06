function SSDWithAutoCorrelationAndSAT()
    image(generateImage());
end

function image = generateImage()
    tic;
    image1 = double(rgb2gray(imread('C:\Users\Jonathan\Desktop\FaceSmall', 'png')));
    image2 = double(rgb2gray(imread('C:\Users\Jonathan\Desktop\FaceSmall1', 'png')));
    time2 = toc;
    sprintf('load images %f', time2)
    time1 = time2;
    sumI1 = sum(image1(:).^2);
    sat2 = SummedAreaTables(image2.^2);
    time2 = toc;
    sprintf('sum and sat %f', time2-time1)
    time1 = time2;
    mat2 = GenerateOverflowMatrix(size(image1), image2);
    time2 = toc;
    sprintf('Generate overflow matrix %f', time2-time1)
    time1 = time2;
    corr = xcorr2(image1,mat2);
    time2 = toc;
    sprintf('xcorr %f', time2-time1)
    time1 = time2;
    dim = size(image2);
    image = zeros(dim(1), dim(2));
    for r = 1:dim(1)
        for c = 1:dim(2)
            image(r,c) = sumOfSquaresDifference(image1, image2, r,c, sumI1, sat2, corr);
        end
    end
    time2 = toc;
    sprintf('fill matrix %f', time2-time1) 
    image
end

function ssd = sumOfSquaresDifference(image1, image2, r, c, sumI1, sat2, corr)
    dim1 = size(image1);
    dim2 = size(image2);
    sumI2 = LookUpvalue(sat2, r, c, dim1, dim2);
    ssd = sumI1 + sumI2 - 2 * (corr(dim2(1) + dim1(1) - 1 - (r - 1), dim2(1) + dim1(2) - 1 - (c - 1)));
    ssd = ssd/(255 * dim1(1) * dim1(2));
end