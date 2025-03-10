function varargout = battleshipAI(command, varargin)
% BATTLESHIPAI - AI og computer-relaterede funktioner til Battleship-spillet
%
% Kommandoer:
%   'placeComputerShips' - Placerer computerens skibe automatisk
%   'getComputerShot'    - Bestemmer computerens næste skud
%
% Se hver specifik funktion for flere detaljer om input parametre.

    switch command
        case 'placeComputerShips'
            varargout{1} = placeComputerShips(varargin{:});
        case 'getComputerShot'
            [row, col] = getComputerShot(varargin{:});
            varargout{1} = row;
            varargout{2} = col;
        otherwise
            error('Ugyldig kommando: %s', command);
    end
end

function grid = placeComputerShips(grid, ships)
    % Automatisk placer computerens skibe på brættet
    
    % Ship lengths
    shipLengths = [ships.length];
    
    % Place each ship
    for i = 1:length(shipLengths)
        placedSuccessfully = false;
        
        while ~placedSuccessfully
            % Random position and orientation
            row = randi(10);
            col = randi(10);
            isHorizontal = randi(2) == 1;
            
            % Check if ship fits on grid
            if isHorizontal && col + shipLengths(i) - 1 > 10
                continue;
            elseif ~isHorizontal && row + shipLengths(i) - 1 > 10
                continue;
            end
            
            % Check if space is already occupied
            occupied = false;
            
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    if grid(row, col+j) ~= 0
                        occupied = true;
                        break;
                    end
                end
            else
                for j = 0:shipLengths(i)-1
                    if grid(row+j, col) ~= 0
                        occupied = true;
                        break;
                    end
                end
            end
            
            if occupied
                continue;
            end
            
            % Place the ship
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    grid(row, col+j) = i;
                end
            else
                for j = 0:shipLengths(i)-1
                    grid(row+j, col) = i;
                end
            end
            
            placedSuccessfully = true;
        end
    end
end

function [row, col] = getComputerShot(shotGrid, playerGrid, difficulty)
    % Get computer's shot based on difficulty level
    
    % Grid size
    [rows, cols] = size(shotGrid);
    
    % EASY MODE - random shots
    if difficulty == 1
        validShot = false;
        
        while ~validShot
            % Random position
            row = randi(rows);
            col = randi(cols);
            
            % Check if already shot at this position
            if shotGrid(row, col) == 0
                validShot = true;
            end
        end
        
        return;
    end
    
    % MEDIUM MODE - hunt and target
    if difficulty == 2
        % Look for hits to target adjacent cells
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
        
        % If no hits found, take random shot
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
    
    % HARD MODE - advanced targeting
    if difficulty == 3
        % First, look for two adjacent hits to extend the line
        for i = 1:rows
            for j = 1:cols-1
                if shotGrid(i, j) == 2 && shotGrid(i, j+1) == 2  % Horizontal hits
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
        
        for j = 1:cols
            for i = 1:rows-1
                if shotGrid(i, j) == 2 && shotGrid(i+1, j) == 2  % Vertical hits
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
        
        % If no adjacent hits, use medium difficulty strategy
        % Look for single hits
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
        
        % If no hits found, take random shot using checkerboard pattern
        validShot = false;
        attempts = 0;
        
        % Try checkerboard pattern first
        while ~validShot && attempts < 50
            attempts = attempts + 1;
            
            % Get random position adhering to checkerboard pattern
            r = randi(rows);
            c = randi(cols);
            
            % Only consider positions where r+c is even (checkerboard)
            if mod(r+c, 2) == 0 && shotGrid(r, c) == 0
                row = r;
                col = c;
                validShot = true;
            end
        end
        
        % If checkerboard failed, take any valid shot
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
end