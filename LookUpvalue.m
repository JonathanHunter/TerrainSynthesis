function sum = LookUpvalue(SummedAreaTable, r, c, patchDim, sourceDim)
    r = sourceDim(1) - r + 1;
    c = sourceDim(2) - c + 1;
    %SummedAreaTable = SummedAreaTables([13,9,5,1;14,10,6,2;15,11,7,3;16,12,8,4]);
    %r = 1;
    %c = 1;
    %dim1 = [4,4];
    %dim2 = [4,4];
    sum = 0;
    A = r + patchDim(1) - 1;
    if A > sourceDim(1) % 1
        C = A - sourceDim(1);
        A = sourceDim(1);
        sum = SummedAreaTable(A,c) + SummedAreaTable(C,c); % +A + C
        if r - 1 > 0 % -B
            sum = sum - SummedAreaTable(r - 1, c);
        end
        E =  c - patchDim(2);
        if E < 0 % 1 - 1
            E = sourceDim(2) + E;    
            sum = sum + SummedAreaTable(A,sourceDim(2)) - SummedAreaTable(A,E); % +D - E
            if r - 1 > 0 % -F + G
               sum = sum - SummedAreaTable(r-1,sourceDim(2)) + SummedAreaTable(r-1,E); 
               sum = sum + SummedAreaTable(C,sourceDim(2)) - SummedAreaTable(C, E); % +H - I
            end
        elseif E > 0 % 1 - 2
            sum = sum - SummedAreaTable(A,E) + SummedAreaTable(r-1,E) - SummedAreaTable(C,E); % -D + E - F
        end
    else % 2
        sum = SummedAreaTable(A,c); % +A
        if r - 1 > 0 % -B
            sum = sum - SummedAreaTable(r - 1, c);
        end
        E =  c - patchDim(2);
        if E < 0 % 2 - 1
            E = sourceDim(2) + E;    
            sum = sum + SummedAreaTable(A,sourceDim(2)) - SummedAreaTable(A,E); % +D - E
            if r - 1 > 0 % -F + G
               sum = sum - SummedAreaTable(r-1,sourceDim(2)) + SummedAreaTable(r-1,E); 
            end
        elseif E > 0 % 2 - 2
            sum = sum - SummedAreaTable(A,E); % -C
            if r - 1 > 0 % +D
               sum = sum + SummedAreaTable(r-1,E); 
            end
        end
    end
end