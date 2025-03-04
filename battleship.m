function battleship()
    % BATTLESHIP - Simple Battleship game with fixed settings
    % Game has a 10x10 grid and 3 ships (lengths 4, 3, and 2)
    
    % Clear screen and display welcome
    clc;
    fprintf('\n==========================================\n');
    fprintf('         WELCOME TO BATTLESHIP            \n');
    fprintf('==========================================\n\n');
    
    % Show basic instructions
    fprintf('INSTRUCTIONS:\n');
    fprintf('1. Place your 3 ships on the 10x10 grid\n');
    fprintf('2. Take turns firing at the computer''s ships\n');
    fprintf('3. First to sink all enemy ships wins!\n\n');
    fprintf('Press any key to begin...\n');
    pause;
    
    % Set fixed game parameters
    gridSize = 10;
    ships = struct('name', {'Battleship', 'Cruiser', 'Destroyer'}, ...
                  'length', {4, 3, 2});
                
    % Choose difficulty
    fprintf('\nSelect difficulty level:\n');
    fprintf('1. Easy (Random shots)\n');
    fprintf('2. Medium (Basic targeting)\n');
    fprintf('3. Hard (Advanced targeting)\n');
    difficulty = input('Enter your choice (1-3): ');
    
    % Initialize grids
    playerGrid = zeros(gridSize);       % Player's ships
    computerGrid = zeros(gridSize);     % Computer's ships
    playerShots = zeros(gridSize);      % Player's shots
    computerShots = zeros(gridSize);    % Computer's shots
    
    % Place ships
    playerGrid = placePlayerShips(playerGrid, ships);
    computerGrid = placeComputerShips(computerGrid);
    
    % Initialize ship hit counters
    playerHits = [0, 0, 0];  % Hits on each player ship
    computerHits = [0, 0, 0]; % Hits on each computer ship
    
    % Game loop
    playerTurn = true;
    gameOver = false;
    turn = 1;
    
    while ~gameOver
        % Display game state
        clc;
        fprintf('\n===== TURN #%d =====\n\n', turn);
        
        % Show player's grid and shot history
        fprintf('----- YOUR SHIPS -----\n');
        displayGrid(playerGrid, computerShots);
        
        fprintf('\n----- YOUR SHOTS -----\n');
        displayTargetGrid(playerShots);
        
        if playerTurn
            % Player's turn
            fprintf('\n>>> YOUR TURN <<<\n');
            [row, col] = getPlayerShot(playerShots);
            
            % Process shot
            if computerGrid(row, col) > 0
                % Hit
                shipType = computerGrid(row, col);
                playerShots(row, col) = 2; % Mark as hit
                
                fprintf('HIT! You hit a %s!\n', ships(shipType).name);
                
                % Track ship damage
                computerHits(shipType) = computerHits(shipType) + 1;
                
                % Check if ship sunk
                if computerHits(shipType) == ships(shipType).length
                    fprintf('You sank the computer''s %s!\n', ships(shipType).name);
                end
            else
                % Miss
                playerShots(row, col) = 1; % Mark as miss
                fprintf('MISS!\n');
            end
            
            % Check for win
            if sum(computerHits) == sum([ships.length])
                gameOver = true;
                fprintf('\n*** VICTORY! ***\n');
                fprintf('You sank all the computer''s ships!\n');
            end
        else
            % Computer's turn
            fprintf('\n>>> COMPUTER''S TURN <<<\n');
            pause(1);
            
            % Get computer shot based on difficulty
            [row, col] = getComputerShot(computerShots, playerGrid, difficulty);
            coordStr = sprintf('%c%d', 'A' + row - 1, col);
            fprintf('Computer fires at %s\n', coordStr);
            
            % Process shot
            if playerGrid(row, col) > 0
                % Hit
                shipType = playerGrid(row, col);
                computerShots(row, col) = 2; % Mark as hit
                
                fprintf('HIT! Computer hit your %s!\n', ships(shipType).name);
                
                % Track ship damage
                playerHits(shipType) = playerHits(shipType) + 1;
                
                % Check if ship sunk
                if playerHits(shipType) == ships(shipType).length
                    fprintf('Computer sank your %s!\n', ships(shipType).name);
                end
            else
                % Miss
                computerShots(row, col) = 1; % Mark as miss
                fprintf('MISS!\n');
            end
            
            % Check for loss
            if sum(playerHits) == sum([ships.length])
                gameOver = true;
                fprintf('\n*** DEFEAT! ***\n');
                fprintf('The computer sank all your ships!\n');
            end
        end
        
        % Switch turns
        playerTurn = ~playerTurn;
        
        % Increment turn counter when player's turn comes back around
        if playerTurn && ~gameOver
            turn = turn + 1;
            fprintf('\nPress any key to continue to next turn...\n');
            pause;
        end
    end
    
    % Game over - show final state
    fprintf('\n==== GAME OVER ====\n');
    
    % Play again prompt
    playAgain = input('\nPlay again? (y/n): ', 's');
    if lower(playAgain) == 'y'
        battleship(); % Restart game
    else
        fprintf('Thanks for playing!\n');
    end
end