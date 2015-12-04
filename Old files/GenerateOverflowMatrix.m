function overflowMatrix = GenerateOverflowMatrix(patchSize, sourceMatrix)
    sourceSize = size(sourceMatrix);
    overflowMatrix = zeros(patchSize(1)-1 + sourceSize(1), patchSize(2)-1+sourceSize(2));
    for i = 1:(patchSize(1)-1 + sourceSize(1))
        if i < (sourceSize(1) + 1)
           if(patchSize(1) == 1)
               overflowMatrix(i,:) = sourceMatrix(i,:);
           else
               overflowMatrix(i,:) = [sourceMatrix(i,:), sourceMatrix(i,1:patchSize(2) - 1)];
           end
        else
           overflowMatrix(i,:) = overflowMatrix(i-sourceSize(1),:);
        end
    end
end