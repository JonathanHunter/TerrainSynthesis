function SSD=SSDWithAreaExclusion(patch, source, x, y, length, width, patchDim)
    patchSum = sum(patch(:).^2);
    SAT = SummedAreaTables(source.^2);
    overflowMatrix = GenerateOverflowMatrix(size(patch), source);
    crossCorrelation = xcorr2(patch,overflowMatrix);
    dim = size(source);
    SSD = zeros(dim(1), dim(2));
    for r = 1:dim(1)
        for c = 1:dim(2)
            if (x <= r && r <= x + length - 1 && y <= c && c <= y + width - 1) || (dim(1) - r + 1) < patchDim(1) || (dim(2) - c + 1) < patchDim(2)
                SSD(r,c) = 255;
            else
                SSD(r,c) = sumOfSquaresDifference(patch, source, r,c, patchSum, SAT, crossCorrelation);
            end
        end
    end
end

function ssd = sumOfSquaresDifference(patch, source, r, c, patchSum, SAT, crossCorrelation)
    patchDim = size(patch);
    sourceDim = size(source);    
    sourceSum = LookUpvalue(SAT, r, c, patchDim, sourceDim);
    ssd = patchSum + sourceSum - 2 * (crossCorrelation(sourceDim(1) + patchDim(1) - 1 - (r - 1), sourceDim(2) + patchDim(2) - 1 - (c - 1)));
    ssd = ssd/(255 * patchDim(1) * patchDim(2));
    ssd = ssd + (rand * 200);
end