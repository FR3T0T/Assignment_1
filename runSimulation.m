function runSimulation(src, ~)
% RUNSIMULATION - Runs automatic simulations to test the computer's difficulty level
% Inputs:
%   src - Source handle for callback

    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Get difficulty level from GUI
    difficulty = gameData.difficulty;
    difficultyNames = {'Easy', 'Medium', 'Hard'};
    
    % Ask for number of simulations and speed
    answer = inputdlg({'Number of simulations:', 'Show graphics? (1=yes, 0=no)', 'Simulation speed (1-10, where 10 is fastest)'}, ...
                     'Simulation Settings', 1, {'100', '0', '10'});
    if isempty(answer)
        return;
    end
    
    numSimulations = str2double(answer{1});
    showGraphics = str2double(answer{2}) == 1;
    simulationSpeed = str2double(answer{3});
    
    % Limit speed between 1 and 10
    simulationSpeed = max(1, min(10, simulationSpeed));
    
    % Create simulation panel to show progress
    simPanel = uipanel('Parent', fig, 'Position', [0.3, 0.4, 0.4, 0.2], ...
        'Title', sprintf('Running %d simulations (%s difficulty, speed: %d/10)', ...
                       numSimulations, difficultyNames{difficulty}, simulationSpeed), ...
        'FontSize', 12, 'BackgroundColor', [0.95 0.95 1]);
    
    statusText = uicontrol('Parent', simPanel, 'Style', 'text', ...
        'Position', [20, 30, 320, 30], 'String', 'Simulation in progress...', ...
        'FontSize', 12, 'BackgroundColor', [0.95 0.95 1]);
    
    progressBar = uicontrol('Parent', simPanel, 'Style', 'slider', ...
        'Position', [20, 10, 320, 20], 'Min', 0, 'Max', 1, 'Value', 0, ...
        'Enable', 'off');
    
    drawnow;
    
    % Prepare data structures to store results
    results = struct();
    results.difficulty = difficulty;
    results.difficultyName = difficultyNames{difficulty};
    results.totalMoves = zeros(numSimulations, 1);
    results.totalHits = zeros(numSimulations, 1);
    results.totalMisses = zeros(numSimulations, 1);
    results.hitRatio = zeros(numSimulations, 1);
    results.gameWon = zeros(numSimulations, 1);
    
    % Target for total number of hits needed (based on ship sizes)
    totalRequiredHits = sum([gameData.ships.length]);
    
    % Add option for fast batch processing at high speed
    batchSize = 10; % Number of simulations to run in one batch without graphical updates
    
    if simulationSpeed >= 8 && numSimulations > 10
        batchProcessing = true;
        % Only update status for each batch
        updateFrequency = batchSize;
    else
        batchProcessing = false;
        updateFrequency = 1;
    end
    
    % Run simulations
    sim = 1;
    while sim <= numSimulations
        % Determine number of simulations in this batch
        currentBatchSize = min(batchSize, numSimulations-sim+1);
        batchEnd = sim + currentBatchSize - 1;
        
        % Update status
        if mod(sim-1, updateFrequency) == 0 || sim == 1
            set(statusText, 'String', sprintf('Simulation %d-%d of %d...', sim, batchEnd, numSimulations));
            set(progressBar, 'Value', (sim-1)/numSimulations);
            drawnow;
        end
        
        % Run simulations in the batch
        for batchSim = sim:batchEnd
            % Reset game data for this simulation
            simData = gameData;
            simData.playerGrid = zeros(10, 10);
            simData.computerGrid = zeros(10, 10);
            simData.playerShots = zeros(10, 10);
            simData.computerShots = zeros(10, 10);
            simData.playerHits = [0, 0, 0];
            simData.computerHits = [0, 0, 0];
            
            % Place ships randomly
            simData.playerGrid = placeComputerShips(simData.playerGrid, simData.ships);
            simData.computerGrid = placeComputerShips(simData.computerGrid, simData.ships);
            
            % Store hits and misses for this simulation
            hits = 0;
            misses = 0;
            moves = 0;
            gameWon = false;
            
            % Simulate the game (computer shoots at the random player board)
            while true
                moves = moves + 1;
                
                % Let computer shoot
                [row, col] = getComputerShot(simData.computerShots, simData.playerGrid, difficulty);
                
                % Register result
                if simData.playerGrid(row, col) > 0
                    % Hit
                    shipType = simData.playerGrid(row, col);
                    simData.computerShots(row, col) = 2;
                    hits = hits + 1;
                    
                    % Track ship damage
                    simData.playerHits(shipType) = simData.playerHits(shipType) + 1;
                else
                    % Miss
                    simData.computerShots(row, col) = 1;
                    misses = misses + 1;
                end
                
                % Update graphics if specified and not in batch mode
                if showGraphics && ~batchProcessing
                    % Only update with a frequency based on simulation speed
                    updateGraphicsInterval = 11 - simulationSpeed; % 1 to 10 speed gives 10 to 1 interval
                    if mod(moves, updateGraphicsInterval) == 0
                        updateGridDisplay(handles.playerBoard, simData.playerGrid, simData.computerShots, true);
                        drawnow;
                    end
                end
                
                % Check for victory
                if sum(simData.playerHits) >= totalRequiredHits
                    gameWon = true;
                    break;
                end
                
                % Safety check: Abort if too many moves (avoid infinite loops)
                if moves > 200
                    break;
                end
            end
            
            % Save results
            results.totalMoves(batchSim) = moves;
            results.totalHits(batchSim) = hits;
            results.totalMisses(batchSim) = misses;
            results.hitRatio(batchSim) = hits / moves;
            results.gameWon(batchSim) = gameWon;
        end
        
        % Update progress
        if batchProcessing
            set(progressBar, 'Value', batchEnd/numSimulations);
            drawnow;
        end
        
        % Go to next batch
        sim = batchEnd + 1;
    end
    
    % Restore normal view
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Remove simulation panel
    delete(simPanel);
    
    % Save results and display summary
    displaySimulationResults(fig, results);
end

function displaySimulationResults(fig, results)
    % Create figures with results
    resultsFig = figure('Name', sprintf('Battleship Simulation Results - %s', results.difficultyName), ...
                      'Position', [200, 200, 800, 600]);
    
    % Calculate average values
    avgMoves = mean(results.totalMoves);
    avgHits = mean(results.totalHits);
    avgMisses = mean(results.totalMisses);
    avgHitRatio = mean(results.hitRatio);
    winRate = mean(results.gameWon) * 100;
    
    % Panel with summary
    summaryPanel = uipanel('Parent', resultsFig, 'Position', [0.05, 0.7, 0.9, 0.25], ...
           'Title', 'Summary', 'FontSize', 14, 'BackgroundColor', [0.95 0.95 1]);
    
    summaryText = sprintf(['Difficulty: %s\n' ...
                         'Average number of moves: %.2f\n' ...
                         'Average number of hits: %.2f\n' ...
                         'Average number of misses: %.2f\n' ...
                         'Average hit ratio: %.2f%%\n' ...
                         'Win rate: %.2f%%'], ...
                         results.difficultyName, avgMoves, avgHits, avgMisses, ...
                         avgHitRatio*100, winRate);
    
    uicontrol('Parent', summaryPanel, 'Style', 'text', ...
             'Position', [20, 20, 680, 120], 'String', summaryText, ...
             'FontSize', 14, 'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
             'BackgroundColor', [0.95 0.95 1]);
    
    % Show message to the user about saved results
    uicontrol('Parent', summaryPanel, 'Style', 'text', ...
             'Position', [20, 5, 680, 20], ...
             'String', ['Results are saved in the workspace as ' ...
                      '"battleshipSimResults" (struct) and "battleshipSimTable" (table).'], ...
             'FontSize', 12, 'FontWeight', 'normal', 'HorizontalAlignment', 'left', ...
             'BackgroundColor', [0.95 0.95 1]);
    
    % Generate plots
    % Plot 1: Histogram of number of moves
    subplot(2, 2, 3);
    histogram(results.totalMoves);
    title('Distribution of moves');
    xlabel('Number of moves');
    ylabel('Frequency');
    
    % Plot 2: Histogram of hit ratio
    subplot(2, 2, 4);
    histogram(results.hitRatio * 100);
    title('Distribution of hit ratio');
    xlabel('Hit ratio (%)');
    ylabel('Frequency');
    
    % Save data in workspace
    assignin('base', 'battleshipSimResults', results);
    
    % Create table with data
    resultsTable = table(results.totalMoves, results.totalHits, results.totalMisses, ...
                        results.hitRatio*100, results.gameWon, ...
                        'VariableNames', {'NumberOfMoves', 'NumberOfHits', 'NumberOfMisses', ...
                                         'HitRatio_Percent', 'GameWon'});
    
    % Save table in workspace
    assignin('base', 'battleshipSimTable', resultsTable);
    
    % Export data button
    uicontrol('Parent', resultsFig, 'Style', 'pushbutton', ...
             'Position', [350, 360, 120, 30], 'String', 'Export data', ...
             'Callback', @(src,~) exportSimulationData(resultsTable));
end

function exportSimulationData(resultsTable)
    % Export data to a CSV file
    [fileName, filePath] = uiputfile('*.csv', 'Save simulation data');
    
    if fileName ~= 0
        fullPath = fullfile(filePath, fileName);
        writetable(resultsTable, fullPath);
        msgbox(sprintf('Data exported to %s', fullPath), 'Export completed');
    end
end