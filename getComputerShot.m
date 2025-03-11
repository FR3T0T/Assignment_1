function [row, col] = getComputerShot(shotGrid, playerGrid, difficulty)
    % Get computer's shot based on difficulty level
    % Enhanced with better AI strategies
    
    % Grid size
    [rows, cols] = size(shotGrid);
    
    % EASY MODE - random shots with occasional "misses" for player benefit
    if difficulty == 1
        validShot = false;
        
        while ~validShot
            % Random position
            row = randi(rows);
            col = randi(cols);
            
            % Check if already shot at this position
            if shotGrid(row, col) == 0
                validShot = true;
                
                % 10% chance to deliberately choose a sub-optimal shot
                % This makes easy mode even easier
                if rand < 0.1
                    % Try to find a new random position that doesn't have a ship
                    attempts = 0;
                    while attempts < 10 && playerGrid(row, col) > 0
                        row = randi(rows);
                        col = randi(cols);
                        attempts = attempts + 1;
                    end
                end
            end
        end
        
        return;
    end
    
    % MEDIUM MODE - hunt and target with ship orientation detection
    if difficulty == 2
        % First look for multiple hits in a line to detect orientation
        % Horizontal line detection
        for i = 1:rows
            for j = 1:cols-1
                if shotGrid(i, j) == 2 && shotGrid(i, j+1) == 2  % Two adjacent horizontal hits
                    % Try left
                    if j > 1 && shotGrid(i, j-1) == 0
                        row = i;
                        col = j-1;
                        return;
                    end
                    
                    % Try right
                    if j+2 <= cols && shotGrid(i, j+2) == 0
                        row = i;
                        col = j+2;
                        return;
                    end
                end
            end
        end
        
        % Vertical line detection
        for j = 1:cols
            for i = 1:rows-1
                if shotGrid(i, j) == 2 && shotGrid(i+1, j) == 2  % Two adjacent vertical hits
                    % Try up
                    if i > 1 && shotGrid(i-1, j) == 0
                        row = i-1;
                        col = j;
                        return;
                    end
                    
                    % Try down
                    if i+2 <= rows && shotGrid(i+2, j) == 0
                        row = i+2;
                        col = j;
                        return;
                    end
                end
            end
        end
        
        % If no line detected, look for single hits to target adjacent cells
        for i = 1:rows
            for j = 1:cols
                if shotGrid(i, j) == 2  % Found a hit
                    % Try adjacent cells (up, down, left, right)
                    directions = [[-1, 0]; [1, 0]; [0, -1]; [0, 1]];
                    
                    for d = 1:length(directions)
                        newRow = i + directions(d, 1);
                        newCol = j + directions(d, 2);
                        
                        % Check if valid and not already tried
                        if newRow >= 1 && newRow <= rows && newCol >= 1 && newCol <= cols && shotGrid(newRow, newCol) == 0
                            row = newRow;
                            col = newCol;
                            return;
                        end
                    end
                end
            end
        end
        
        % If no hits found, take random shot, but focus on center of board first
        % (statistically ships are more likely to be in center regions)
        validShot = false;
        attempts = 0;
        
        while ~validShot && attempts < 15
            attempts = attempts + 1;
            % Target center regions with higher probability
            row = round((rows/2) + randn(1)*(rows/4));
            col = round((cols/2) + randn(1)*(cols/4));
            
            % Ensure within grid bounds
            row = max(1, min(rows, row));
            col = max(1, min(cols, col));
            
            if shotGrid(row, col) == 0
                validShot = true;
            end
        end
        
        % If center targeting failed, fall back to any valid position
        if ~validShot
            while ~validShot
                row = randi(rows);
                col = randi(cols);
                
                if shotGrid(row, col) == 0
                    validShot = true;
                end
            end
        end
        
        return;
    end
    
    % HARD MODE - advanced targeting with probability density mapping
    if difficulty == 3
        % Use ship lengths for probability calculations - assume original game ship lengths
        shipLengths = [4, 3, 2];
        remainingShips = [];
        
        % Determine which ships are still in play
        % This is approximate since we don't know the exact hits per ship
        hitCount = sum(sum(shotGrid == 2));
        if hitCount < sum(shipLengths)
            % Count sequences of hits to estimate sunk ships
            horizontalRuns = findSequences(shotGrid == 2, 'horizontal');
            verticalRuns = findSequences(shotGrid == 2, 'vertical');
            
            % Combine all run lengths
            allRuns = [horizontalRuns; verticalRuns];
            
            % Determine which ships might still be in play
            for i = 1:length(shipLengths)
                % If we don't see a run matching this ship length, assume it's still in play
                if ~any(allRuns >= shipLengths(i))
                    remainingShips = [remainingShips, shipLengths(i)];
                else
                    % Remove one matching run (represents a sunk ship)
                    idx = find(allRuns >= shipLengths(i), 1);
                    allRuns(idx) = 0;
                end
            end
        end
        
        % If no remaining ships found, default to all ships
        if isempty(remainingShips)
            remainingShips = shipLengths;
        end
        
        % First, look for two or more adjacent hits to extend the line
        % Horizontal line detection
        for i = 1:rows
            for j = 1:cols-1
                if shotGrid(i, j) == 2 && shotGrid(i, j+1) == 2  % Two adjacent horizontal hits
                    % Find the extent of this horizontal run
                    startCol = j;
                    while startCol > 1 && shotGrid(i, startCol-1) == 2
                        startCol = startCol - 1;
                    end
                    
                    endCol = j + 1;
                    while endCol < cols && shotGrid(i, endCol+1) == 2
                        endCol = endCol + 1;
                    end
                    
                    % Try left
                    if startCol > 1 && shotGrid(i, startCol-1) == 0
                        row = i;
                        col = startCol-1;
                        return;
                    end
                    
                    % Try right
                    if endCol < cols && shotGrid(i, endCol+1) == 0
                        row = i;
                        col = endCol+1;
                        return;
                    end
                end
            end
        end
        
        % Vertical line detection
        for j = 1:cols
            for i = 1:rows-1
                if shotGrid(i, j) == 2 && shotGrid(i+1, j) == 2  % Two adjacent vertical hits
                    % Find the extent of this vertical run
                    startRow = i;
                    while startRow > 1 && shotGrid(startRow-1, j) == 2
                        startRow = startRow - 1;
                    end
                    
                    endRow = i + 1;
                    while endRow < rows && shotGrid(endRow+1, j) == 2
                        endRow = endRow + 1;
                    end
                    
                    % Try up
                    if startRow > 1 && shotGrid(startRow-1, j) == 0
                        row = startRow-1;
                        col = j;
                        return;
                    end
                    
                    % Try down
                    if endRow < rows && shotGrid(endRow+1, j) == 0
                        row = endRow+1;
                        col = j;
                        return;
                    end
                end
            end
        end
        
        % If no double hits found, look for single hits
        for i = 1:rows
            for j = 1:cols
                if shotGrid(i, j) == 2  % Found a hit
                    % Try adjacent cells
                    directions = [[-1, 0]; [1, 0]; [0, -1]; [0, 1]];
                    
                    for d = 1:length(directions)
                        newRow = i + directions(d, 1);
                        newCol = j + directions(d, 2);
                        
                        if newRow >= 1 && newRow <= rows && newCol >= 1 && newCol <= cols && shotGrid(newRow, newCol) == 0
                            row = newRow;
                            col = newCol;
                            return;
                        end
                    end
                end
            end
        end
        
        % If no hits to target, use probability mapping for remaining ships
        % Generate probability heatmap
        heatmap = zeros(rows, cols);
        
        % For each possible ship placement, increment probability
        for shipIdx = 1:length(remainingShips)
            shipLen = remainingShips(shipIdx);
            
            % Horizontal placements
            for i = 1:rows
                for j = 1:(cols-shipLen+1)
                    valid = true;
                    for k = 0:(shipLen-1)
                        % Check if this cell is either empty or a hit (miss means can't place ship here)
                        if shotGrid(i, j+k) == 1 % Miss
                            valid = false;
                            break;
                        end
                    end
                    
                    % If placement valid, increment all cells in this placement
                    if valid
                        for k = 0:(shipLen-1)
                            % Only add to probability if not already shot
                            if shotGrid(i, j+k) == 0
                                heatmap(i, j+k) = heatmap(i, j+k) + 1;
                            end
                        end
                    end
                end
            end
            
            % Vertical placements
            for j = 1:cols
                for i = 1:(rows-shipLen+1)
                    valid = true;
                    for k = 0:(shipLen-1)
                        if shotGrid(i+k, j) == 1 % Miss
                            valid = false;
                            break;
                        end
                    end
                    
                    % If placement valid, increment all cells in this placement
                    if valid
                        for k = 0:(shipLen-1)
                            % Only add to probability if not already shot
                            if shotGrid(i+k, j) == 0
                                heatmap(i+k, j) = heatmap(i+k, j) + 1;
                            end
                        end
                    end
                end
            end
        end
        
        % Find highest probability cell that hasn't been shot yet
        maxProb = 0;
        for i = 1:rows
            for j = 1:cols
                if shotGrid(i, j) == 0 && heatmap(i, j) > maxProb
                    maxProb = heatmap(i, j);
                    row = i;
                    col = j;
                end
            end
        end
        
        % If probability map found a target, return it
        if maxProb > 0
            return;
        end
        
        % Last resort: if probability mapping failed, take a random shot
        validShot = false;
        while ~validShot
            row = randi(rows);
            col = randi(cols);
            
            if shotGrid(row, col) == 0
                validShot = true;
            end
        end
        
        return;
    end
end

function sequences = findSequences(matrix, direction)
    % Helper function to find sequences of 1s in a matrix
    [rows, cols] = size(matrix);
    sequences = [];
    
    if strcmp(direction, 'horizontal')
        for i = 1:rows
            currentRun = 0;
            for j = 1:cols
                if matrix(i, j)
                    currentRun = currentRun + 1;
                else
                    if currentRun > 0
                        sequences = [sequences; currentRun];
                    end
                    currentRun = 0;
                end
            end
            % Check end of row
            if currentRun > 0
                sequences = [sequences; currentRun];
            end
        end
    else % vertical
        for j = 1:cols
            currentRun = 0;
            for i = 1:rows
                if matrix(i, j)
                    currentRun = currentRun + 1;
                else
                    if currentRun > 0
                        sequences = [sequences; currentRun];
                    end
                    currentRun = 0;
                end
            end
            % Check end of column
            if currentRun > 0
                sequences = [sequences; currentRun];
            end
        end
    end
end