function [row, col] = getPlayerShot(shotGrid)
    % Get and validate player's shot coordinates
    
    validShot = false;
    
    while ~validShot
        % Get input
        posStr = input('Enter target coordinates (e.g., A1): ', 's');
        [row, col] = parsePosition(posStr);
        
        % Check if position is valid
        if row < 1 || row > 10 || col < 1 || col > 10
            fprintf('Invalid position! Must be between A1 and J10.\n');
            continue;
        end
        
        % Check if already shot at this position
        if shotGrid(row, col) > 0
            fprintf('You already fired at that location!\n');
            continue;
        end
        
        validShot = true;
    end
end