function LoadGridFloat(pathFlt, pathHDR)
    hdr = fopen(pathHDR);
    dim = fscanf(hdr, '%*s%d');
    fclose(hdr);
    ftl = fopen(pathFlt);
    a = fread(ftl, dim(1)*dim(2), 'float32', 'ieee-le');
    fclose(ftl);
    i = reshape(a, [dim(1), dim(2)]);
    clear a;
    minimum = min(i(:))
    maxim = max(i(:))
    i = i - minimum;
    i = i.*(50/(maxim-minimum));
    i = transpose(i);
    image(i);
end