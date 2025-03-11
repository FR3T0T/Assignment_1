function results = simulateGames(numSimulations, difficulty, simulationSpeed)
% SIMULATEGAMES - Runs simulations of Battleship games without GUI
% Inputs:
%   numSimulations - Number of games to simulate
%   difficulty - Difficulty level (1=Easy, 2=Medium, 3=Hard)
%   simulationSpeed - Speed of the simulation (1-10, where 10 is fastest)
% Outputs:
%   results - Struct with simulation results
    
    % Handle optional parameter
    if nargin < 3
        simulationSpeed = 10; % Default: Maximum speed
    end

    % Define ships (same as in battleshipGUI.m)
    ships = struct('name', {'Battleship', 'Cruiser', 'Destroyer'}, ...
                  'length', {4, 3, 2}, 'placed', {true, true, true});
    
    % Target for the total number of hits needed
    totalRequiredHits = sum([ships.length]);
    
    % Prepare data structures to store results
    results = struct();
    results.difficulty = difficulty;
    results.difficultyNames = {'Easy', 'Medium', 'Hard'};
    results.difficultyName = results.difficultyNames{difficulty};
    results.totalMoves = zeros(numSimulations, 1);
    results.totalHits = zeros(numSimulations, 1);
    results.totalMisses = zeros(numSimulations, 1);
    results.hitRatio = zeros(numSimulations, 1);
    results.gameWon = zeros(numSimulations, 1);
    results.numShots = cell(numSimulations, 1);  % To store number of shots for each ship
    
    % Show console progress bar
    fprintf('Simulating %d games with %s difficulty (speed: %d/10):\n', ...
       numSimulations, results.difficultyName, simulationSpeed);
    progress = 0;
    fprintf('[%s]', repmat(' ', 1, 50));
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    
    % Set up batch size based on speed
    batchSize = simulationSpeed^2; % Higher speed gives larger batches
    
    % Run simulations in batches to increase speed
    sim = 1;
    while sim <= numSimulations
        % Determine batch size
        currentBatchSize = min(batchSize, numSimulations - sim + 1);
        batchEnd = sim + currentBatchSize - 1;
        
        % Update progress bar
        if floor(sim/numSimulations*50) > progress
            progress = floor(sim/numSimulations*50);
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
            fprintf('[%s%s]', repmat('=', 1, progress), repmat(' ', 1, 50-progress));
        end
        
        % Reset game data for this simulation
        playerGrid = zeros(10, 10);
        computerShots = zeros(10, 10);
        playerHits = [0, 0, 0];
        
        % Place ships randomly for the "player" (which the computer plays against)
        playerGrid = placeComputerShips(playerGrid, ships);
        
        % Store hits and misses for this simulation
        hits = 0;
        misses = 0;
        moves = 0;
        gameWon = false;
        
        % Keep track of number of shots for each ship
        shotsByShipType = zeros(1, length(ships));
        
        % Simulate the game (computer shoots at the random player board)
        while true
            moves = moves + 1;
            
            % Let the computer shoot
            [row, col] = getComputerShot(computerShots, playerGrid, difficulty);
            
            % Register result
            if playerGrid(row, col) > 0
                % Hit
                shipType = playerGrid(row, col);
                computerShots(row, col) = 2;
                hits = hits + 1;
                
                % Track ship damage
                playerHits(shipType) = playerHits(shipType) + 1;
                shotsByShipType(shipType) = shotsByShipType(shipType) + 1;
            else
                % Miss
                computerShots(row, col) = 1;
                misses = misses + 1;
            end
            
            % Check for victory
            if sum(playerHits) >= totalRequiredHits
                gameWon = true;
                break;
            end
            
            % Safety check: Abort if too many moves (avoid infinite loops)
            if moves > 200
                break;
            end
        end
        
        % Save results
        results.totalMoves(sim) = moves;
        results.totalHits(sim) = hits;
        results.totalMisses(sim) = misses;
        results.hitRatio(sim) = hits / moves;
        results.gameWon(sim) = gameWon;
        results.numShots{sim} = shotsByShipType;
    end
    
    fprintf('\nSimulation completed!\n');
    
    % Calculate aggregate statistics
    results.avgMoves = mean(results.totalMoves);
    results.avgHits = mean(results.totalHits);
    results.avgMisses = mean(results.totalMisses);
    results.avgHitRatio = mean(results.hitRatio);
    results.winRate = mean(results.gameWon) * 100;
    
    % Calculate average number of shots per ship type
    shipTypeShots = zeros(length(ships), 1);
    for i = 1:numSimulations
        for j = 1:length(ships)
            shipTypeShots(j) = shipTypeShots(j) + results.numShots{i}(j);
        end
    end
    results.avgShotsByShipType = shipTypeShots / numSimulations;
    
    % Show summary
    fprintf('\nSummary for %s difficulty:\n', results.difficultyName);
    fprintf('Average number of moves: %.2f\n', results.avgMoves);
    fprintf('Average number of hits: %.2f\n', results.avgHits);
    fprintf('Average number of misses: %.2f\n', results.avgMisses);
    fprintf('Average hit ratio: %.2f%%\n', results.avgHitRatio*100);
    fprintf('Win rate: %.2f%%\n', results.winRate);
    
    % Convert to table for easy access
    results.table = table(results.totalMoves, results.totalHits, results.totalMisses, ...
                         results.hitRatio*100, results.gameWon, ...
                         'VariableNames', {'NumberOfMoves', 'NumberOfHits', 'NumberOfMisses', ...
                                          'HitRatio_Percent', 'GameWon'});
end