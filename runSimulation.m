function runSimulation(src, ~)
% RUNSIMULATION - Kører automatiske simulationer for at teste computerens sværhedsgrad
% Inputs:
%   src - Source handle for callback

    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Få sværhedsgraden fra GUI
    difficulty = gameData.difficulty;
    difficultyNames = {'Let', 'Medium', 'Svær'};
    
    % Spørg om antal simulationer og hastighed
    answer = inputdlg({'Antal simulationer:', 'Vis grafisk? (1=ja, 0=nej)', 'Simulationshastighed (1-10, hvor 10 er hurtigst)'}, ...
                     'Simulationsindstillinger', 1, {'100', '0', '10'});
    if isempty(answer)
        return;
    end
    
    numSimulations = str2double(answer{1});
    showGraphics = str2double(answer{2}) == 1;
    simulationSpeed = str2double(answer{3});
    
    % Begræns hastigheden til mellem 1 og 10
    simulationSpeed = max(1, min(10, simulationSpeed));
    
    % Opret simulationspanel til at vise fremgang
    simPanel = uipanel('Parent', fig, 'Position', [0.3, 0.4, 0.4, 0.2], ...
        'Title', sprintf('Kører %d simulationer (%s sværhedsgrad, hastighed: %d/10)', 
                       numSimulations, difficultyNames{difficulty}, simulationSpeed), ...
        'FontSize', 12, 'BackgroundColor', [0.95 0.95 1]);
    
    statusText = uicontrol('Parent', simPanel, 'Style', 'text', ...
        'Position', [20, 30, 320, 30], 'String', 'Simulation i gang...', ...
        'FontSize', 12, 'BackgroundColor', [0.95 0.95 1]);
    
    progressBar = uicontrol('Parent', simPanel, 'Style', 'slider', ...
        'Position', [20, 10, 320, 20], 'Min', 0, 'Max', 1, 'Value', 0, ...
        'Enable', 'off');
    
    drawnow;
    
    % Forberedelse af datastrukturer til at gemme resultater
    results = struct();
    results.difficulty = difficulty;
    results.difficultyName = difficultyNames{difficulty};
    results.totalMoves = zeros(numSimulations, 1);
    results.totalHits = zeros(numSimulations, 1);
    results.totalMisses = zeros(numSimulations, 1);
    results.hitRatio = zeros(numSimulations, 1);
    results.gameWon = zeros(numSimulations, 1);
    
    % Mål for det totale antal hits der er nødvendige (baseret på skibsstørrelser)
    totalRequiredHits = sum([gameData.ships.length]);
    
    % Kør simulationer
    for sim = 1:numSimulations
        % Opdater status
        set(statusText, 'String', sprintf('Simulation %d af %d...', sim, numSimulations));
        set(progressBar, 'Value', (sim-1)/numSimulations);
        drawnow;
        
        % Nulstil spildata for denne simulation
        simData = gameData;
        simData.playerGrid = zeros(10, 10);
        simData.computerGrid = zeros(10, 10);
        simData.playerShots = zeros(10, 10);
        simData.computerShots = zeros(10, 10);
        simData.playerHits = [0, 0, 0];
        simData.computerHits = [0, 0, 0];
        
        % Placer skibe tilfældigt for computeren og "spilleren" (som computeren spiller mod)
        simData.playerGrid = placeComputerShips(simData.playerGrid, simData.ships);
        simData.computerGrid = placeComputerShips(simData.computerGrid, simData.ships);
        
        % Gem hits og misses for denne simulation
        hits = 0;
        misses = 0;
        moves = 0;
        gameWon = false;
        
        % Simuler spillet (computeren skyder mod den tilfældige spillerplade)
        while true
            moves = moves + 1;
            
            % Lad computeren skyde
            [row, col] = getComputerShot(simData.computerShots, simData.playerGrid, difficulty);
            
            % Registrer resultat
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
            
            % Opdater grafik hvis det er angivet, men uden pauser
            if showGraphics
                updateGridDisplay(handles.playerBoard, simData.playerGrid, simData.computerShots, true);
                % Kun opdater skærmen hver 10. træk for at øge hastigheden
                if mod(moves, 10) == 0
                    drawnow;
                end
            end
            
            % Check for victory
            if sum(simData.playerHits) >= totalRequiredHits
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
    end
    
    % Gendan normale visning
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Fjern simuleringspanel
    delete(simPanel);
    
    % Gem resultater og vis opsummering
    displaySimulationResults(fig, results);
end

function displaySimulationResults(fig, results)
    % Opret figurer med resultater
    resultsFig = figure('Name', sprintf('Battleship Simuleringsresultater - %s', results.difficultyName), ...
                      'Position', [200, 200, 800, 600]);
    
    % Beregn gennemsnitsværdier
    avgMoves = mean(results.totalMoves);
    avgHits = mean(results.totalHits);
    avgMisses = mean(results.totalMisses);
    avgHitRatio = mean(results.hitRatio);
    winRate = mean(results.gameWon) * 100;
    
    % Panel med opsummering
    summaryPanel = uipanel('Parent', resultsFig, 'Position', [0.05, 0.7, 0.9, 0.25], ...
           'Title', 'Opsummering', 'FontSize', 14, 'BackgroundColor', [0.95 0.95 1]);
    
    summaryText = sprintf(['Sværhedsgrad: %s\n' ...
                         'Gennemsnitligt antal træk: %.2f\n' ...
                         'Gennemsnitligt antal hits: %.2f\n' ...
                         'Gennemsnitligt antal misses: %.2f\n' ...
                         'Gennemsnitlig hit-ratio: %.2f%%\n' ...
                         'Vinder-rate: %.2f%%'], ...
                         results.difficultyName, avgMoves, avgHits, avgMisses, ...
                         avgHitRatio*100, winRate);
    
    uicontrol('Parent', summaryPanel, 'Style', 'text', ...
             'Position', [20, 10, 680, 120], 'String', summaryText, ...
             'FontSize', 14, 'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
             'BackgroundColor', [0.95 0.95 1]);
    
    % Generer plots
    % Plot 1: Histogram over antal træk
    subplot(2, 2, 3);
    histogram(results.totalMoves);
    title('Fordeling af antal træk');
    xlabel('Antal træk');
    ylabel('Frekvens');
    
    % Plot 2: Histogram over hit-ratio
    subplot(2, 2, 4);
    histogram(results.hitRatio * 100);
    title('Fordeling af hit-ratio');
    xlabel('Hit ratio (%)');
    ylabel('Frekvens');
    
    % Gem data i arbejdsområdet
    assignin('base', 'battleshipSimResults', results);
    
    % Opret tabel med data
    resultsTable = table(results.totalMoves, results.totalHits, results.totalMisses, ...
                        results.hitRatio*100, results.gameWon, ...
                        'VariableNames', {'AntalTræk', 'AntalHits', 'AntalMisses', ...
                                         'HitRatio_Procent', 'SpilVundet'});
    
    % Gem tabel i arbejdsområdet
    assignin('base', 'battleshipSimTable', resultsTable);
    
    % Vis besked til brugeren
    uicontrol('Parent', summaryPanel, 'Style', 'text', ...
             'Position', [20, 5, 680, 20], ...
             'String', ['Resultaterne er gemt i arbejdsområdet som ' ...
                      '"battleshipSimResults" (struct) og "battleshipSimTable" (tabel).'], ...
             'FontSize', 12, 'HorizontalAlignment', 'left', ...
             'BackgroundColor', [0.95 0.95 1]);
    
    % Eksporter data knap
    uicontrol('Parent', resultsFig, 'Style', 'pushbutton', ...
             'Position', [350, 360, 120, 30], 'String', 'Eksporter data', ...
             'Callback', @(src,~) exportSimulationData(resultsTable));
end

function exportSimulationData(resultsTable)
    % Eksporter data til en CSV-fil
    [fileName, filePath] = uiputfile('*.csv', 'Gem simulationsdata');
    
    if fileName ~= 0
        fullPath = fullfile(filePath, fileName);
        writetable(resultsTable, fullPath);
        msgbox(sprintf('Data eksporteret til %s', fullPath), 'Eksport fuldført');
    end
end