function SSD=SSDWithRandomEval(patch, source, x, y, length, width, patchDim, seed)
    rng(seed);
    dim = size(source);
    SSD = zeros(dim(1), dim(2));
    SSD = SSD + 255;
    numberOfSSDs = dim(1) * dim(2) * .1;
    current = 0;
    while(current < numberOfSSDs)
        r = int32(rand * (dim(1) - 1)) + 1;
        c = int32(rand * (dim(2) - 1)) + 1;
        if (x <= r && r <= x + length - 1 && y <= c && c <= y + width - 1) || (dim(1) - r + 1) < patchDim(1) || (dim(2) - c + 1) < patchDim(2)
            SSD(r,c) = 255;
        else
            SSD(r,c) = sumOfSquaresDifference(patch, source, r,c);
            current = current + 1;
        end
    end
end

function ssd = sumOfSquaresDifference(patch, source, r, c)
    dim1 = size(patch);
    dim2 = size(source);
    temp = zeros(dim1(1),dim1(2));
    for i = 1:dim1(1)
        x = r + i - 1;
        if x > dim2(1)
            x = x - dim2(1);
        end
        y = c + dim1(2) - 1;
        if y > dim2(2)
            y = y - dim2(2);
            temp(i, 1:(dim2(2) - c + 1)) = source(x, c:dim2(2));
            temp(i, (dim2(2) - c + 2):dim1(2)) = source(x, 1:y);
        else
            temp(i, 1:dim1(2)) = source(x, c:y);
        end
    end
    ssd = ((patch - temp).^2);
    ssd = sum(ssd(:));
    ssd = ssd/(255 * dim1(1) * dim1(2));
end