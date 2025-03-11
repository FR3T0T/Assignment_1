function results = simulateGames(numSimulations, difficulty, simulationSpeed)
% SIMULATEGAMES - Kører simulationer af Battleship-spil uden GUI
% Inputs:
%   numSimulations - Antal spil der skal simuleres
%   difficulty - Sværhedsgrad (1=Let, 2=Medium, 3=Svær)
%   simulationSpeed - Hastighed af simuleringen (1-10, hvor 10 er hurtigst)
% Outputs:
%   results - Struct med simuleringsresultater
    
    % Håndter valgfri parameter
    if nargin < 3
        simulationSpeed = 10; % Standard: Maksimal hastighed
    end

    % Definer skibe (samme som i battleshipGUI.m)
    ships = struct('name', {'Battleship', 'Cruiser', 'Destroyer'}, ...
                  'length', {4, 3, 2}, 'placed', {true, true, true});
    
    % Mål for det totale antal hits der er nødvendige
    totalRequiredHits = sum([ships.length]);
    
    % Forberedelse af datastrukturer til at gemme resultater
    results = struct();
    results.difficulty = difficulty;
    results.difficultyNames = {'Let', 'Medium', 'Svær'};
    results.difficultyName = results.difficultyNames{difficulty};
    results.totalMoves = zeros(numSimulations, 1);
    results.totalHits = zeros(numSimulations, 1);
    results.totalMisses = zeros(numSimulations, 1);
    results.hitRatio = zeros(numSimulations, 1);
    results.gameWon = zeros(numSimulations, 1);
    results.numShots = cell(numSimulations, 1);  % For at gemme antal skud for hvert skib
    
    % Vis konsol fremgangsbar
    fprintf('Simulerer %d spil med %s sværhedsgrad (hastighed: %d/10):\n', 
           numSimulations, results.difficultyName, simulationSpeed);
    progress = 0;
    fprintf('[%s]', repmat(' ', 1, 50));
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    
    % Opsæt batch-størrelse baseret på hastighed
    batchSize = simulationSpeed^2; % Højere hastighed giver større batches
    
    % Kør simulationer i batches for at øge hastigheden
    sim = 1;
    while sim <= numSimulations
        % Bestem batch-størrelse
        currentBatchSize = min(batchSize, numSimulations - sim + 1);
        batchEnd = sim + currentBatchSize - 1;
        
        % Opdater fremgangsbar
        if floor(sim/numSimulations*50) > progress
            progress = floor(sim/numSimulations*50);
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
            fprintf('[%s%s]', repmat('=', 1, progress), repmat(' ', 1, 50-progress));
        end
        
        % Nulstil spildata for denne simulation
        playerGrid = zeros(10, 10);
        computerShots = zeros(10, 10);
        playerHits = [0, 0, 0];
        
        % Placer skibe tilfældigt for "spilleren" (som computeren spiller mod)
        playerGrid = placeComputerShips(playerGrid, ships);
        
        % Gem hits og misses for denne simulation
        hits = 0;
        misses = 0;
        moves = 0;
        gameWon = false;
        
        % Hold styr på antal skud for hvert skib
        shotsByShipType = zeros(1, length(ships));
        
        % Simuler spillet (computeren skyder mod den tilfældige spillerplade)
        while true
            moves = moves + 1;
            
            % Lad computeren skyde
            [row, col] = getComputerShot(computerShots, playerGrid, difficulty);
            
            % Registrer resultat
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
            
            % Sikkerhedscheck: Afbryd hvis for mange træk (undgå uendelige løkker)
            if moves > 200
                break;
            end
        end
        
        % Gem resultater
        results.totalMoves(sim) = moves;
        results.totalHits(sim) = hits;
        results.totalMisses(sim) = misses;
        results.hitRatio(sim) = hits / moves;
        results.gameWon(sim) = gameWon;
        results.numShots{sim} = shotsByShipType;
    end
    
    fprintf('\nSimulering gennemført!\n');
    
    % Beregn aggregate statistikker
    results.avgMoves = mean(results.totalMoves);
    results.avgHits = mean(results.totalHits);
    results.avgMisses = mean(results.totalMisses);
    results.avgHitRatio = mean(results.hitRatio);
    results.winRate = mean(results.gameWon) * 100;
    
    % Beregn gennemsnitligt antal skud per skibstype
    shipTypeShots = zeros(length(ships), 1);
    for i = 1:numSimulations
        for j = 1:length(ships)
            shipTypeShots(j) = shipTypeShots(j) + results.numShots{i}(j);
        end
    end
    results.avgShotsByShipType = shipTypeShots / numSimulations;
    
    % Vis opsummering
    fprintf('\nOpsummering for %s sværhedsgrad:\n', results.difficultyName);
    fprintf('Gennemsnitligt antal træk: %.2f\n', results.avgMoves);
    fprintf('Gennemsnitligt antal hits: %.2f\n', results.avgHits);
    fprintf('Gennemsnitligt antal misses: %.2f\n', results.avgMisses);
    fprintf('Gennemsnitlig hit-ratio: %.2f%%\n', results.avgHitRatio*100);
    fprintf('Vinder-rate: %.2f%%\n', results.winRate);
    
    % Konverter til tabel for nem adgang
    results.table = table(results.totalMoves, results.totalHits, results.totalMisses, ...
                         results.hitRatio*100, results.gameWon, ...
                         'VariableNames', {'AntalTræk', 'AntalHits', 'AntalMisses', ...
                                          'HitRatio_Procent', 'SpilVundet'});
end