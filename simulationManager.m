function simulationManager()
% SIMULATIONMANAGER - GUI for at håndtere Battleship simulationer
    
    % Create figure
    fig = figure('Name', 'Battleship Simulationsmanager', 'Position', [300, 300, 500, 400], ...
                'MenuBar', 'none', 'NumberTitle', 'off');
    
    % Main panel
    mainPanel = uipanel('Parent', fig, 'Position', [0.05, 0.05, 0.9, 0.9], ...
                      'Title', 'Simulationskonfiguration', 'FontSize', 12);
    
    % Simulation options
    uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [20, 300, 200, 20], ...
             'String', 'Antal simulationer per sværhedsgrad:', 'HorizontalAlignment', 'left');
    
    numSimsEdit = uicontrol('Parent', mainPanel, 'Style', 'edit', 'Position', [230, 300, 100, 25], ...
                          'String', '100');
                          
    % Simulation speed
    uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [20, 270, 200, 20], ...
             'String', 'Simulationshastighed (1-10):', 'HorizontalAlignment', 'left');
             
    speedSlider = uicontrol('Parent', mainPanel, 'Style', 'slider', 'Position', [230, 270, 100, 25], ...
                           'Min', 1, 'Max', 10, 'Value', 10, 'SliderStep', [0.1 0.1]);
                           
    speedText = uicontrol('Parent', mainPanel, 'Style', 'text', 'Position', [340, 270, 30, 20], ...
                         'String', '10');
                         
    % Update speed text when slider changes
    addlistener(speedSlider, 'Value', 'PostSet', @(src,evt) set(speedText, 'String', ...
               num2str(round(get(speedSlider, 'Value')))));
    
    % Difficulty level checkboxes
    diffPanel = uipanel('Parent', mainPanel, 'Position', [0.05, 0.6, 0.9, 0.25], ...
                      'Title', 'Sværhedsgrader at simulere:', 'FontSize', 10);
    
    easyCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 60, 100, 20], ...
                        'String', 'Let', 'Value', 1);
    
    mediumCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 35, 100, 20], ...
                          'String', 'Medium', 'Value', 1);
    
    hardCheck = uicontrol('Parent', diffPanel, 'Style', 'checkbox', 'Position', [20, 10, 100, 20], ...
                        'String', 'Svær', 'Value', 1);
    
    % Output options
    outputPanel = uipanel('Parent', mainPanel, 'Position', [0.05, 0.3, 0.9, 0.25], ...
                        'Title', 'Output indstillinger:', 'FontSize', 10);
    
    plotCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 60, 220, 20], ...
                        'String', 'Vis plots under simulering', 'Value', 0);
    
    summaryCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 35, 220, 20], ...
                           'String', 'Vis opsummerende plots', 'Value', 1);
    
    saveCheck = uicontrol('Parent', outputPanel, 'Style', 'checkbox', 'Position', [20, 10, 220, 20], ...
                        'String', 'Gem resultater til workspace', 'Value', 1);
    
    % Buttons
    runButton = uicontrol('Parent', mainPanel, 'Style', 'pushbutton', 'Position', [150, 40, 200, 40], ...
                        'String', 'Kør simulationer', 'FontSize', 12, ...
                        'Callback', @runSimulations);
    
    % Tilføj hjælpe-knap
    uicontrol('Parent', mainPanel, 'Style', 'pushbutton', 'Position', [380, 10, 60, 30], ...
             'String', 'Hjælp', 'Callback', @showHelp);
    
    function runSimulations(~, ~)
        % Få simuleringskonfiguration
        numSims = str2double(get(numSimsEdit, 'String'));
        runEasy = get(easyCheck, 'Value');
        runMedium = get(mediumCheck, 'Value');
        runHard = get(hardCheck, 'Value');
        showPlots = get(plotCheck, 'Value');
        showSummary = get(summaryCheck, 'Value');
        saveToWorkspace = get(saveCheck, 'Value');
        simulationSpeed = round(get(speedSlider, 'Value'));
        
        % Valider antal simulationer
        if isnan(numSims) || numSims <= 0 || numSims > 10000
            errordlg('Antal simulationer skal være et positivt tal (maks 10000)', 'Ugyldig input');
            return;
        end
        
        % Vis venteskærm
        waitPanel = uipanel('Parent', fig, 'Position', [0.2, 0.4, 0.6, 0.2], ...
                          'Title', 'Simulering i gang', 'FontSize', 12);
        
        statusText = uicontrol('Parent', waitPanel, 'Style', 'text', ...
                             'Position', [20, 30, 260, 20], 'String', 'Forbereder simulering...');
        
        % Forbered resultater
        allResults = {};
        difficultyLabels = {};
        
        % Kør simulationerne
        try
            if runEasy
                set(statusText, 'String', sprintf('Simulerer LET sværhedsgrad (hastighed: %d/10)...', simulationSpeed));
                drawnow;
                easyResults = simulateGames(numSims, 1, simulationSpeed);
                allResults{end+1} = easyResults;
                difficultyLabels{end+1} = 'Let';
                
                if saveToWorkspace
                    assignin('base', 'battleshipEasyResults', easyResults);
                end
            end
            
            if runMedium
                set(statusText, 'String', sprintf('Simulerer MEDIUM sværhedsgrad (hastighed: %d/10)...', simulationSpeed));
                drawnow;
                mediumResults = simulateGames(numSims, 2, simulationSpeed);
                allResults{end+1} = mediumResults;
                difficultyLabels{end+1} = 'Medium';
                
                if saveToWorkspace
                    assignin('base', 'battleshipMediumResults', mediumResults);
                end
            end
            
            if runHard
                set(statusText, 'String', sprintf('Simulerer SVÆR sværhedsgrad (hastighed: %d/10)...', simulationSpeed));
                drawnow;
                hardResults = simulateGames(numSims, 3, simulationSpeed);
                allResults{end+1} = hardResults;
                difficultyLabels{end+1} = 'Svær';
                
                if saveToWorkspace
                    assignin('base', 'battleshipHardResults', hardResults);
                end
            end
            
            % Fjern ventepanel
            delete(waitPanel);
            
            % Vis opsummerende plots hvis valgt
            if showSummary && length(allResults) > 0
                createSummaryPlots(allResults, difficultyLabels);
            end
            
            % Opret sammenligningstabel
            if length(allResults) > 0
                comparisonTable = createComparisonTable(allResults, difficultyLabels);
                
                if saveToWorkspace
                    assignin('base', 'battleshipComparisonTable', comparisonTable);
                end
                
                % Vis resultatbesked
                msgbox('Simulationerne er gennemført!', 'Færdig');
            else
                msgbox('Ingen simulationer valgt!', 'Advarsel');
            end
            
        catch e
            % Håndter fejl
            delete(waitPanel);
            errordlg(['Der opstod en fejl under simuleringen: ' e.message], 'Fejl');
        end
    end

    function createSummaryPlots(results, labels)
        % Sammenlign resultater med plots
        figure('Name', 'Sammenligning af sværhedsgrader', 'Position', [100, 100, 1200, 800]);
        
        % Sammensæt data
        allMoves = [];
        allHitRatios = [];
        groupLabels = {};
        
        for i = 1:length(results)
            allMoves = [allMoves; results{i}.totalMoves];
            allHitRatios = [allHitRatios; results{i}.hitRatio];
            groupLabels = [groupLabels; repmat(labels(i), length(results{i}.totalMoves), 1)];
        end
        
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
        avgMoves = cellfun(@(x) x.avgMoves, results);
        avgHitRatios = cellfun(@(x) x.avgHitRatio*100, results);
        
        avgData = [avgMoves; avgHitRatios];
        bar(avgData');
        title('Gennemsnitlige værdier');
        set(gca, 'XTickLabel', labels);
        legend({'Antal træk', 'Hit ratio (%)'}, 'Location', 'northwest');
        
        % Plot 4: Win rates
        subplot(2, 2, 4);
        winRates = cellfun(@(x) x.winRate, results);
        bar(winRates);
        title('Vinder-procent');
        set(gca, 'XTickLabel', labels);
        ylabel('Procent (%)');
        ylim([0, 100]);
    end

    function table = createComparisonTable(results, labels)
        % Opret sammenligningstabel
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
        
        % Konverter til tabel
        table = array2table([avgMoves, avgHits, avgMisses, avgHitRatio, winRates], ...
                           'VariableNames', {'Gns_Træk', 'Gns_Hits', 'Gns_Misses', ...
                                          'Gns_HitRatio', 'Vinder_Procent'});
        
        % Tilføj sværhedsgrad som første kolonne
        table = addvars(table, labels', 'Before', 'Gns_Træk', 'NewVariableNames', {'Sværhedsgrad'});
        
        % Vis tabel
        figure('Name', 'Sammenligningstabel', 'Position', [400, 400, 700, 200]);
        uitable('Data', table{:,:}, 'ColumnName', table.Properties.VariableNames, ...
               'RowName', {}, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
    end

    function showHelp(~, ~)
        helpFig = figure('Name', 'Simuleringshjælp', 'Position', [400, 300, 500, 400], ...
                       'MenuBar', 'none', 'NumberTitle', 'off');
        
        helpText = {...
            'BATTLESHIP SIMULATIONSMANAGER', '', ...
            'Denne værktøj lader dig simulere Battleship-spil med forskellige sværhedsgrader.', '', ...
            'SÅDAN BRUGES VÆRKTØJET:', '', ...
            '1. Angiv antal simulationer for hver sværhedsgrad (f.eks. 100)', ...
            '2. Vælg hvilke sværhedsgrader der skal testes', ...
            '3. Vælg output-indstillinger:', ...
            '   - "Vis plots under simulering" viser spilplader under simulering (langsomt)', ...
            '   - "Vis opsummerende plots" viser statistiske plots efter simulering', ...
            '   - "Gem resultater til workspace" gemmer data til videre analyse', ...
            '4. Klik på "Kør simulationer" for at starte', '', ...
            'RESULTATER:', '', ...
            'Resultaterne omfatter:', ...
            '- Gennemsnitligt antal træk for at vinde', ...
            '- Hit/miss ratio', ...
            '- Vinder-procent', ...
            '- Sammenligning mellem forskellige sværhedsgrader'};
        
        uicontrol('Parent', helpFig, 'Style', 'text', 'Position', [20, 20, 460, 350], ...
                 'String', helpText, 'HorizontalAlignment', 'left');
    end
end