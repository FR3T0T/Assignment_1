function simulationManager()
% SIMULATIONMANAGER - GUI for managing Battleship simulations
    
    % Create figure
    fig = figure('Name', 'Battleship Simulation Manager', 'Position', [300, 300, 500, 400], ...
                'MenuBar', 'none', 'NumberTitle', 'off');
    
    % Main panel
    mainPanel = uipanel('Parent', fig, 'Position', [0.05, 0.05, 0.9, 0.9], ...
                      'Title', 'Simulation Configuration', 'FontSize', 12);
    
    % Simulation options
    uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [20, 300, 200, 20], ...
             'String', 'Number of simulations per difficulty:', 'HorizontalAlignment', 'left');
    
    numSimsEdit = uicontrol('Parent', mainPanel, 'Style', 'edit', 'Position', [230, 300, 100, 25], ...
                          'String', '100');
                          
    % Simulation speed
    uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [20, 270, 200, 20], ...
             'String', 'Simulation speed (1-10):', 'HorizontalAlignment', 'left');
             
    speedSlider = uicontrol('Parent', mainPanel, 'Style', 'slider', 'Position', [230, 270, 100, 25], ...
                           'Min', 1, 'Max', 10, 'Value', 10, 'SliderStep', [0.1 0.1]);
                           
    speedText = uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [340, 270, 30, 20], ...
                         'String', '10');
                         
    % Update speed text when slider changes
    addlistener(speedSlider, 'Value', 'PostSet', @(src,evt) set(speedText, 'String', ...
               num2str(round(get(speedSlider, 'Value')))));
    
    % Difficulty level checkboxes
    diffPanel = uipanel('Parent', mainPanel, 'Position', [0.05, 0.6, 0.9, 0.25], ...
                      'Title', 'Difficulty levels to simulate:', 'FontSize', 10);
    
    easyCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 60, 100, 20], ...
                        'String', 'Easy', 'Value', 1);
    
    mediumCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 35, 100, 20], ...
                          'String', 'Medium', 'Value', 1);
    
    hardCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 10, 100, 20], ...
                        'String', 'Hard', 'Value', 1);
    
    % Output options
    outputPanel = uipanel('Parent', mainPanel, 'Position', [0.05, 0.3, 0.9, 0.25], ...
                        'Title', 'Output options:', 'FontSize', 10);
    
    plotCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 60, 220, 20], ...
                        'String', 'Show plots during simulation', 'Value', 0);
    
    summaryCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 35, 220, 20], ...
                           'String', 'Show summary plots', 'Value', 1);
    
    saveCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 10, 220, 20], ...
                        'String', 'Save results to workspace', 'Value', 1);
    
    % Buttons
    runButton = uicontrol('Parent', mainPanel, 'Style', 'pushbutton', 'Position', [150, 40, 200, 40], ...
                        'String', 'Run simulations', 'FontSize', 12, ...
                        'Callback', @runSimulations);
    
    % Add help button
    uicontrol('Parent', mainPanel, 'Style', 'pushbutton', 'Position', [380, 10, 60, 30], ...
             'String', 'Help', 'Callback', @showHelp);
    
    function runSimulations(~, ~)
        % Get simulation configuration
        numSims = str2double(get(numSimsEdit, 'String'));
        runEasy = get(easyCheck, 'Value');
        runMedium = get(mediumCheck, 'Value');
        runHard = get(hardCheck, 'Value');
        showPlots = get(plotCheck, 'Value');
        showSummary = get(summaryCheck, 'Value');
        saveToWorkspace = get(saveCheck, 'Value');
        simulationSpeed = round(get(speedSlider, 'Value'));
        
        % Validate number of simulations
        if isnan(numSims) || numSims <= 0 || numSims > 10000
            errordlg('Number of simulations must be a positive number (max 10000)', 'Invalid input');
            return;
        end
        
        % Show wait screen
        waitPanel = uipanel('Parent', fig, 'Position', [0.2, 0.4, 0.6, 0.2], ...
                          'Title', 'Simulation in progress', 'FontSize', 12);
        
        statusText = uicontrol('Parent', waitPanel, 'Style', 'text', ...
                             'Position', [20, 30, 260, 20], 'String', 'Preparing simulation...');
        
        % Prepare results
        allResults = {};
        difficultyLabels = {};
        
        % Run simulations
        try
            if runEasy
                set(statusText, 'String', sprintf('Simulating EASY difficulty (speed: %d/10)...', simulationSpeed));
                drawnow;
                easyResults = simulateGames(numSims, 1, simulationSpeed);
                allResults{end+1} = easyResults;
                difficultyLabels{end+1} = 'Easy';
                
                if saveToWorkspace
                    assignin('base', 'battleshipEasyResults', easyResults);
                end
            end
            
            if runMedium
                set(statusText, 'String', sprintf('Simulating MEDIUM difficulty (speed: %d/10)...', simulationSpeed));
                drawnow;
                mediumResults = simulateGames(numSims, 2, simulationSpeed);
                allResults{end+1} = mediumResults;
                difficultyLabels{end+1} = 'Medium';
                
                if saveToWorkspace
                    assignin('base', 'battleshipMediumResults', mediumResults);
                end
            end
            
            if runHard
                set(statusText, 'String', sprintf('Simulating HARD difficulty (speed: %d/10)...', simulationSpeed));
                drawnow;
                hardResults = simulateGames(numSims, 3, simulationSpeed);
                allResults{end+1} = hardResults;
                difficultyLabels{end+1} = 'Hard';
                
                if saveToWorkspace
                    assignin('base', 'battleshipHardResults', hardResults);
                end
            end
            
            % Remove wait panel
            delete(waitPanel);
            
            % Show summary plots if selected
            if showSummary && length(allResults) > 0
                createSummaryPlots(allResults, difficultyLabels);
            end
            
            % Create comparison table
            if length(allResults) > 0
                comparisonTable = createComparisonTable(allResults, difficultyLabels);
                
                if saveToWorkspace
                    assignin('base', 'battleshipComparisonTable', comparisonTable);
                end
                
                % Show result message
                msgbox('Simulations completed!', 'Done');
            else
                msgbox('No simulations selected!', 'Warning');
            end
            
        catch e
            % Handle errors
            delete(waitPanel);
            errordlg(['An error occurred during simulation: ' e.message], 'Error');
        end
    end

    function createSummaryPlots(results, labels)
        % Compare results with plots
        figure('Name', 'Comparison of difficulty levels', 'Position', [100, 100, 1200, 800]);
        
        % Compile data
        allMoves = [];
        allHitRatios = [];
        groupLabels = {};
        
        for i = 1:length(results)
            allMoves = [allMoves; results{i}.totalMoves];
            allHitRatios = [allHitRatios; results{i}.hitRatio];
            groupLabels = [groupLabels; repmat(labels(i), length(results{i}.totalMoves), 1)];
        end
        
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
        avgMoves = cellfun(@(x) x.avgMoves, results);
        avgHitRatios = cellfun(@(x) x.avgHitRatio*100, results);
        
        avgData = [avgMoves; avgHitRatios];
        bar(avgData');
        title('Average values');
        set(gca, 'XTickLabel', labels);
        legend({'Number of moves', 'Hit ratio (%)'}, 'Location', 'northwest');
        
        % Plot 4: Win rates
        subplot(2, 2, 4);
        winRates = cellfun(@(x) x.winRate, results);
        bar(winRates);
        title('Win percentage');
        set(gca, 'XTickLabel', labels);
        ylabel('Percentage (%)');
        ylim([0, 100]);
    end

    function table = createComparisonTable(results, labels)
        % Create comparison table
        numDifficulties = length(results);
        
        avgMoves = zeros(numDifficulties, 1);
        avgHits = zeros(numDifficulties, 1);
        avgMisses = zeros(numDifficulties, 1);
        avgHitRatio = zeros(numDifficulties, 1);
        winRates = zeros(numDifficulties, 1);
        
        for i = 1:numDifficulties
            avgMoves(i) = results{i}.avgMoves;
            avgHits(i) = results{i}.avgHits;
            avgMisses(i) = results{i}.avgMisses;
            avgHitRatio(i) = results{i}.avgHitRatio*100;
            winRates(i) = results{i}.winRate;
        end
        
        % Convert to table
        table = array2table([avgMoves, avgHits, avgMisses, avgHitRatio, winRates], ...
                           'VariableNames', {'Avg_Moves', 'Avg_Hits', 'Avg_Misses', ...
                                          'Avg_HitRatio', 'Win_Percentage'});
        
        % Add difficulty level as first column
        table = addvars(table, labels', 'Before', 'Avg_Moves', 'NewVariableNames', {'Difficulty'});
        
        % Show table
        figure('Name', 'Comparison Table', 'Position', [400, 400, 700, 200]);
        uitable('Data', table{:,:}, 'ColumnName', table.Properties.VariableNames, ...
               'RowName', {}, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
    end

    function showHelp(~, ~)
        helpFig = figure('Name', 'Simulation Help', 'Position', [400, 300, 500, 400], ...
                       'MenuBar', 'none', 'NumberTitle', 'off');
        
        helpText = {...
            'BATTLESHIP SIMULATION MANAGER', '', ...
            'This tool allows you to simulate Battleship games with different difficulty levels.', '', ...
            'HOW TO USE THE TOOL:', '', ...
            '1. Specify number of simulations for each difficulty level (e.g. 100)', ...
            '2. Choose which difficulty levels to test', ...
            '3. Select output options:', ...
            '   - "Show plots during simulation" shows game boards during simulation (slow)', ...
            '   - "Show summary plots" shows statistical plots after simulation', ...
            '   - "Save results to workspace" saves data for further analysis', ...
            '4. Click on "Run simulations" to start', '', ...
            'RESULTS:', '', ...
            'The results include:', ...
            '- Average number of moves to win', ...
            '- Hit/miss ratio', ...
            '- Win percentage', ...
            '- Comparison between different difficulty levels'};
        
        uicontrol('Parent', helpFig, 'Style', 'text', 'Position', [20, 20, 460, 350], ...
                 'String', helpText, 'HorizontalAlignment', 'left');
    end
end