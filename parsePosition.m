function [row, col] = parsePosition(posStr)
    % Parse position string like "A1" into row and column numbers
    
    % Default invalid values
    row = -1;
    col = -1;
    
    % Check if input is valid
    if length(posStr) < 2
        return;
    end
    
    % Extract row letter (first character)
    rowChar = upper(posStr(1));
    if rowChar >= 'A' && rowChar <= 'J'
        row = rowChar - 'A' + 1;
    end
    
    % Extract column number (remaining characters)
    colStr = posStr(2:end);
    col = str2double(colStr);
    
    % Check if conversion was successful
    if isnan(col)
        col = -1;
    end
end