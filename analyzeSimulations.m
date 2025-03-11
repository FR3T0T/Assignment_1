function analyzeSimulations(numSimulations, simulationSpeed)
% ANALYZESIMULATIONS - Runs and compares simulations for all difficulty levels
% Inputs:
%   numSimulations - Number of simulations to run per difficulty level
%   simulationSpeed - Speed of the simulation (1-10, where 10 is fastest)

    if nargin < 1
        numSimulations = 100;
    end
    
    if nargin < 2
        simulationSpeed = 10; % Default: Maximum speed
    end
    
    fprintf('Analyzing Battleship AI with %d simulations for each difficulty level (speed: %d)...\n', 
           numSimulations, simulationSpeed);
    
    % Run simulations for each difficulty level
    easyResults = simulateGames(numSimulations, 1, simulationSpeed);
    mediumResults = simulateGames(numSimulations, 2, simulationSpeed);
    hardResults = simulateGames(numSimulations, 3, simulationSpeed);
    
    % Compare results with box plots
    figure('Name', 'Comparison of difficulty levels', 'Position', [100, 100, 1200, 800]);
    
    % Combine data from all difficulty levels
    allMoves = [easyResults.totalMoves; mediumResults.totalMoves; hardResults.totalMoves];
    allHitRatios = [easyResults.hitRatio; mediumResults.hitRatio; hardResults.hitRatio];
    groupLabels = [repmat({'Easy'}, numSimulations, 1); ...
                  repmat({'Medium'}, numSimulations, 1); ...
                  repmat({'Hard'}, numSimulations, 1)];
    
    % Plot 1: Number of moves
    subplot(2, 2, 1);
    boxplot(allMoves, groupLabels);
    title('Comparison of number of moves');
    ylabel('Number of moves');
    
    % Plot 2: Hit ratio
    subplot(2, 2, 2);
    boxplot(allHitRatios, groupLabels);
    title('Comparison of hit ratio');
    ylabel('Hit ratio');
    
    % Plot 3: Average values
    subplot(2, 2, 3);
    avgData = [easyResults.avgMoves, mediumResults.avgMoves, hardResults.avgMoves; ...
              easyResults.avgHitRatio*100, mediumResults.avgHitRatio*100, hardResults.avgHitRatio*100];
    bar(avgData);
    title('Average values');
    set(gca, 'XTickLabel', {'Number of moves', 'Hit ratio (%)'});
    legend({'Easy', 'Medium', 'Hard'}, 'Location', 'northwest');
    
    % Plot 4: Average number of moves to win
    subplot(2, 2, 4);
    winningMovesEasy = easyResults.totalMoves(easyResults.gameWon == 1);
    winningMovesMedium = mediumResults.totalMoves(mediumResults.gameWon == 1);
    winningMovesHard = hardResults.totalMoves(hardResults.gameWon == 1);
    
    avgWinningMoves = [mean(winningMovesEasy), mean(winningMovesMedium), mean(winningMovesHard)];
    bar(avgWinningMoves);
    title('Average number of moves to win');
    set(gca, 'XTickLabel', {'Easy', 'Medium', 'Hard'});
    ylabel('Number of moves');
    
    % Create table with comparative statistics
    comparisonTable = table(...
        {'Easy'; 'Medium'; 'Hard'}, ...
        [easyResults.avgMoves; mediumResults.avgMoves; hardResults.avgMoves], ...
        [easyResults.avgHits; mediumResults.avgHits; hardResults.avgHits], ...
        [easyResults.avgMisses; mediumResults.avgMisses; hardResults.avgMisses], ...
        [easyResults.avgHitRatio*100; mediumResults.avgHitRatio*100; hardResults.avgHitRatio*100], ...
        [easyResults.winRate; mediumResults.winRate; hardResults.winRate], ...
        'VariableNames', {'Difficulty', 'Avg_Moves', 'Avg_Hits', 'Avg_Misses', 'Avg_HitRatio', 'Win_Percent'});
    
    % Display table
    fprintf('\nComparison of difficulty levels:\n');
    disp(comparisonTable);
    
    % Save data to workspace
    assignin('base', 'battleshipEasyResults', easyResults);
    assignin('base', 'battleshipMediumResults', mediumResults);
    assignin('base', 'battleshipHardResults', hardResults);
    assignin('base', 'battleshipComparisonTable', comparisonTable);
    
    fprintf('\nAll results have been saved to the workspace.\n');
    fprintf('Use the variables: battleshipEasyResults, battleshipMediumResults, battleshipHardResults, and battleshipComparisonTable.\n');
end