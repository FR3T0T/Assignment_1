function analyzeSimulations(numSimulations, simulationSpeed)
% ANALYZESIMULATIONS - Kører og sammenligner simulationer for alle sværhedsgrader
% Inputs:
%   numSimulations - Antal simulationer der skal køres per sværhedsgrad
%   simulationSpeed - Hastighed af simuleringen (1-10, hvor 10 er hurtigst)

    if nargin < 1
        numSimulations = 100;
    end
    
    if nargin < 2
        simulationSpeed = 10; % Standard: Maksimal hastighed
    end
    
    fprintf('Analyserer Battleship AI med %d simulationer for hver sværhedsgrad (hastighed: %d)...\n', 
           numSimulations, simulationSpeed);
    
    % Kør simulationer for hver sværhedsgrad
    easyResults = simulateGames(numSimulations, 1, simulationSpeed);
    mediumResults = simulateGames(numSimulations, 2, simulationSpeed);
    hardResults = simulateGames(numSimulations, 3, simulationSpeed);
    
    % Sammenlign resultater med box plots
    figure('Name', 'Sammenligning af sværhedsgrader', 'Position', [100, 100, 1200, 800]);
    
    % Sammensæt data fra alle sværhedsgrader
    allMoves = [easyResults.totalMoves; mediumResults.totalMoves; hardResults.totalMoves];
    allHitRatios = [easyResults.hitRatio; mediumResults.hitRatio; hardResults.hitRatio];
    groupLabels = [repmat({'Let'}, numSimulations, 1); ...
                  repmat({'Medium'}, numSimulations, 1); ...
                  repmat({'Svær'}, numSimulations, 1)];
    
    % Plot 1: Antal træk
    subplot(2, 2, 1);
    boxplot(allMoves, groupLabels);
    title('Sammenligning af antal træk');
    ylabel('Antal træk');
    
    % Plot 2: Hit ratio
    subplot(2, 2, 2);
    boxplot(allHitRatios, groupLabels);
    title('Sammenligning af hit ratio');
    ylabel('Hit ratio');
    
    % Plot 3: Gennemsnitlige værdier
    subplot(2, 2, 3);
    avgData = [easyResults.avgMoves, mediumResults.avgMoves, hardResults.avgMoves; ...
              easyResults.avgHitRatio*100, mediumResults.avgHitRatio*100, hardResults.avgHitRatio*100];
    bar(avgData);
    title('Gennemsnitlige værdier');
    set(gca, 'XTickLabel', {'Antal træk', 'Hit ratio (%)'});
    legend({'Let', 'Medium', 'Svær'}, 'Location', 'northwest');
    
    % Plot 4: Gennemsnitligt antal træk for at vinde
    subplot(2, 2, 4);
    winningMovesEasy = easyResults.totalMoves(easyResults.gameWon == 1);
    winningMovesMedium = mediumResults.totalMoves(mediumResults.gameWon == 1);
    winningMovesHard = hardResults.totalMoves(hardResults.gameWon == 1);
    
    avgWinningMoves = [mean(winningMovesEasy), mean(winningMovesMedium), mean(winningMovesHard)];
    bar(avgWinningMoves);
    title('Gennemsnitligt antal træk for at vinde');
    set(gca, 'XTickLabel', {'Let', 'Medium', 'Svær'});
    ylabel('Antal træk');
    
    % Opret tabel med sammenlignende statistik
    comparisonTable = table(...
        {'Let'; 'Medium'; 'Svær'}, ...
        [easyResults.avgMoves; mediumResults.avgMoves; hardResults.avgMoves], ...
        [easyResults.avgHits; mediumResults.avgHits; hardResults.avgHits], ...
        [easyResults.avgMisses; mediumResults.avgMisses; hardResults.avgMisses], ...
        [easyResults.avgHitRatio*100; mediumResults.avgHitRatio*100; hardResults.avgHitRatio*100], ...
        [easyResults.winRate; mediumResults.winRate; hardResults.winRate], ...
        'VariableNames', {'Sværhedsgrad', 'Gns_Træk', 'Gns_Hits', 'Gns_Misses', 'Gns_HitRatio', 'Vinder_Procent'});
    
    % Vis tabel
    fprintf('\nSammenligning af sværhedsgrader:\n');
    disp(comparisonTable);
    
    % Gem data i workspace
    assignin('base', 'battleshipEasyResults', easyResults);
    assignin('base', 'battleshipMediumResults', mediumResults);
    assignin('base', 'battleshipHardResults', hardResults);
    assignin('base', 'battleshipComparisonTable', comparisonTable);
    
    fprintf('\nAlle resultater er gemt i arbejdsområdet.\n');
    fprintf('Brug variablerne: battleshipEasyResults, battleshipMediumResults, battleshipHardResults, og battleshipComparisonTable.\n');
end