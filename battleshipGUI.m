function battleshipGUI()
% BATTLESHIPGUI - Grafisk brugergrænseflade til Battleship-spillet
% Dette er en GUI-version af battleship.m som bruger MATLAB's figure og
% uicontrol komponenter til at skabe en interaktiv spiloplevelse.
    
    % Initialiser spilledata
    gameData = struct();
    gameData.playerGrid = zeros(10, 10);
    gameData.computerGrid = zeros(10, 10);
    gameData.playerShots = zeros(10, 10);
    gameData.computerShots = zeros(10, 10);
    gameData.gameState = 'setup'; % setup, placing, playing, gameover
    gameData.difficulty = 1;
    gameData.currentShip = 1;
    gameData.ships = struct('name', {'Battleship', 'Cruiser', 'Destroyer'}, ...
                           'length', {4, 3, 2}, 'placed', {false, false, false});
    gameData.playerHits = [0, 0, 0];  % Hits on each player ship
    gameData.computerHits = [0, 0, 0]; % Hits on each computer ship
    gameData.playerTurn = true;
    
    % Opret hovedfigur
    fig = figure('Name', 'Battleship', 'Position', [100, 100, 1000, 600], ...
                 'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.9 0.9 0.95], ...
                 'CloseRequestFcn', @closeGame);
    
    % Gem gameData i figure
    setappdata(fig, 'gameData', gameData);
    
    % Opret kontrolpanel
    controlPanel = uipanel('Position', [0.02, 0.02, 0.2, 0.96], 'Title', 'Kontrolpanel', ...
                          'BackgroundColor', [0.9 0.9 0.95]);
    
    % Opret sværhedsgrad-selector
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 520, 120, 20], ...
              'String', 'Sværhedsgrad:', 'BackgroundColor', [0.9 0.9 0.95]);
    difficultySelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                  'Position', [20, 490, 120, 25], ...
                                  'String', {'Let', 'Medium', 'Svær'}, ...
                                  'Callback', @setDifficulty);
    
    % Start spil-knap
    startButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                           'Position', [20, 440, 120, 40], ...
                           'String', 'Start Spil', 'Callback', @startGame);
    
    % Orientering-selector (til skibsplacering)
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 390, 120, 20], ...
              'String', 'Orientering:', 'BackgroundColor', [0.9 0.9 0.95]);
    orientationSelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                   'Position', [20, 360, 120, 25], ...
                                   'String', {'Vandret', 'Lodret'});
    
    % Instruktioner-knap
    instructionsButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                                 'Position', [20, 310, 120, 30], ...
                                 'String', 'Instruktioner', 'Callback', @showInstructions);
    
    % Statusfelt
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 50, 160, 250], ...
                         'String', 'Vælg sværhedsgrad og klik på Start Spil', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.9 0.9 0.95]);
    
    % Opret spillebrætter som axes
    playerBoard = axes('Position', [0.25, 0.1, 0.35, 0.8]);
    title('Dit bræt');
    
    enemyBoard = axes('Position', [0.65, 0.1, 0.35, 0.8]);
    title('Modstanderens bræt');
    
    % Tegn grid for begge brætter
    drawGrid(playerBoard);
    drawGrid(enemyBoard);
    
    % Gem UI-referencer til senere brug
    handles = struct();
    handles.fig = fig;
    handles.controlPanel = controlPanel;
    handles.difficultySelector = difficultySelector;
    handles.orientationSelector = orientationSelector;
    handles.startButton = startButton;
    handles.statusText = statusText;
    handles.playerBoard = playerBoard;
    handles.enemyBoard = enemyBoard;
    setappdata(fig, 'handles', handles);
    
    % Deaktiver fjendebræt indtil spillet er startet
    set(enemyBoard, 'ButtonDownFcn', []);
    
    % Set playerBoard til at håndtere placeringen af skibe
    % Dette aktiveres efter spillet startes
    set(playerBoard, 'ButtonDownFcn', []);
    
    % Vis velkomstskærm
    showWelcomeScreen(fig);
end

function showWelcomeScreen(fig)
    % Overlay panel til velkomst
    welcomePanel = uipanel('Parent', fig, 'Position', [0.25, 0.25, 0.5, 0.5], ...
        'Title', 'Velkommen til Battleship!', 'FontSize', 14, ...
        'BackgroundColor', [0.95 0.95 1]);
    
    % Tilføj spilbeskrivelse
    uicontrol('Parent', welcomePanel, 'Style', 'text', ...
        'Position', [20, 100, 460, 180], 'String', {...
        'SÅDAN SPILLER DU BATTLESHIP:', '', ...
        '1. Vælg sværhedsgrad og klik på "Start Spil"', ...
        '2. Placer dine 3 skibe ved at vælge orientering og klikke på dit bræt', ...
        '3. Skyd efter computerens skibe ved at klikke på modstanderens bræt', ...
        '4. Den første der sænker alle modstanderens skibe vinder!', ...
        '', ...
        'Blå felter viser dine skibe', ...
        'X markerer ramt skib', ...
        'O markerer forbier (vand)'}, ...
        'FontSize', 11, 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 1]);
    
    % Start spil-knap
    uicontrol('Parent', welcomePanel, 'Style', 'pushbutton', ...
        'Position', [180, 30, 120, 40], 'String', 'Jeg er klar!', ...
        'FontSize', 12, 'Callback', @(src,~) delete(welcomePanel));
end

function showGameResult(fig, isVictory)
    handles = getappdata(fig, 'handles');
    
    % Opret overlay panel med resultat
    resultPanel = uipanel('Parent', fig, 'Position', [0.3, 0.4, 0.4, 0.2], ...
        'BackgroundColor', [0.9 0.9 1], 'BorderType', 'line', ...
        'HighlightColor', 'blue', 'BorderWidth', 2);
    
    if isVictory
        resultText = 'SEJR! Du sænkede alle modstanderens skibe!';
        textColor = [0 0.5 0];
    else
        resultText = 'NEDERLAG! Computeren sænkede alle dine skibe!';
        textColor = [0.8 0 0];
    end
    
    % Tilføj tekst
    uicontrol('Parent', resultPanel, 'Style', 'text', ...
        'Position', [20, 30, 320, 50], 'String', resultText, ...
        'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', textColor, ...
        'BackgroundColor', [0.9 0.9 1]);
    
    % FIX: Korriger callback til Spil igen-knappen
    % Denne linje er ændret for at både fjerne resultatpanelet og genstarte spillet
    uicontrol('Parent', resultPanel, 'Style', 'pushbutton', ...
        'Position', [120, 10, 120, 30], 'String', 'Spil igen', ...
        'Callback', @(~,~) restartGame(handles.startButton, resultPanel));
end

function closeGame(src, ~)
    % Bekræft afslutning af spil
    choice = questdlg('Er du sikker på, at du vil afslutte spillet?', ...
        'Afslut Battleship', 'Ja', 'Nej', 'Nej');
    
    if strcmp(choice, 'Ja')
        delete(src);
    end
end

function setDifficulty(src, ~)
    % Opdater sværhedsgrad
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    gameData.difficulty = get(src, 'Value');
    setappdata(fig, 'gameData', gameData);
end

function showInstructions(src, ~)
    % Vis spil-instruktioner
    fig = ancestor(src, 'figure');
    
    % Vis instruktioner i en ny figur
    instructFig = figure('Name', 'Battleship Instruktioner', 'Position', [200, 200, 500, 400], ...
                       'MenuBar', 'none', 'NumberTitle', 'off');
    
    uicontrol('Parent', instructFig, 'Style', 'text', 'Position', [20, 20, 460, 360], ...
             'String', {
                 'SÅDAN SPILLER DU BATTLESHIP:', '', ...
                 'FORMÅL:', ...
                 '  Sænk alle modstanderens skibe før dine bliver sænket!', '', ...
                 'GRIDKOORDINATER:', ...
                 '  - Rækker er mærket med bogstaver (A, B, C, ...)', ...
                 '  - Kolonner er mærket med tal (1, 2, 3, ...)', ...
                 '  - Vælg position ved at klikke på brættet', '', ...
                 'SPILLETS SYMBOLER:', ...
                 '  - Blå felt: Dit skib', ...
                 '  - Rødt felt med X: Træffer (ramt skib)', ...
                 '  - O: Forbier (du ramte vand)', '', ...
                 'GAMEPLAY:', ...
                 '  1. Placer dine skibe på dit grid', ...
                 '  2. Skift tur med computeren til at affyre skud', ...
                 '  3. Den første der sænker alle fjendens skibe vinder!'
             }, ...
             'HorizontalAlignment', 'left');
end

function restartGame(startButton, resultPanel)
    % Hjælpefunktion til at fjerne resultatpanelet og starte et nyt spil
    delete(resultPanel);
    startGame(startButton, []);
end

function startGame(src, ~)
    % Start et nyt spil
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Nulstil spildatastrukturen
    gameData.playerGrid = zeros(10, 10);
    gameData.computerGrid = zeros(10, 10);
    gameData.playerShots = zeros(10, 10);
    gameData.computerShots = zeros(10, 10);
    gameData.gameState = 'placing';
    gameData.currentShip = 1;
    gameData.playerTurn = true;
    gameData.playerHits = [0, 0, 0];
    gameData.computerHits = [0, 0, 0];
    for i = 1:length(gameData.ships)
        gameData.ships(i).placed = false;
    end
    
    % Opdater status
    set(handles.statusText, 'String', sprintf('Placer dit %s (%d felter)\nVælg orientering og klik på dit bræt.', ...
                                             gameData.ships(1).name, gameData.ships(1).length));
    
    % Opdater brætterne
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Aktiver placeringsfunktion
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    
    % Placer computerens skibe
    gameData.computerGrid = placeComputerShips(gameData.computerGrid, gameData.ships);
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function placeShip(src, ~)
    % Håndter klik på spillerens bræt for at placere skibe
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Tjek om vi er i placeringsfasen
    if ~strcmp(gameData.gameState, 'placing')
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Få orientering (1=vandret, 2=lodret)
    orientation = get(handles.orientationSelector, 'Value');
    
    % Tjek om skibet kan placeres
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Validering af placeringen
    valid = validateShipPlacement(gameData.playerGrid, row, col, orientation, shipLength);
    
    if valid
        % Placer skibet
        if orientation == 1  % Vandret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row, col+i) = currentShip;
            end
        else  % Lodret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row+i, col) = currentShip;
            end
        end
        
        % Opdater visning
        updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Marker skibet som placeret
        gameData.ships(currentShip).placed = true;
        
        % Gå til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            set(handles.statusText, 'String', sprintf('Placer dit %s (%d felter)\nVælg orientering og klik på dit bræt.', ...
                                                    gameData.ships(gameData.currentShip).name, ...
                                                    gameData.ships(gameData.currentShip).length));
        else
            % Alle skibe placeret - start spillet
            gameData.gameState = 'playing';
            
            % Vis "spil starter" besked
            gameStartPanel = uipanel('Parent', fig, 'Position', [0.35, 0.45, 0.3, 0.1], ...
                'BackgroundColor', [0.9 1 0.9]);
           
            uicontrol('Parent', gameStartPanel, 'Style', 'text', ...
                'Position', [10, 35, 280, 25], 'String', 'Alle skibe placeret! Spillet starter!', ...
                'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.9 1 0.9]);
           
            % Tilføj en timer til at fjerne panelet efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                'TimerFcn', @(~,~) delete(gameStartPanel));
            start(t);
            
            set(handles.statusText, 'String', 'Spillet er i gang! Klik på modstanderens bræt for at skyde.');
            set(handles.playerBoard, 'ButtonDownFcn', []);
            set(handles.enemyBoard, 'ButtonDownFcn', @fireShot);
        end
    else
        set(handles.statusText, 'String', 'Ugyldig placering! Prøv igen.');
    end
    
    setappdata(fig, 'gameData', gameData);
end

function fireShot(src, ~)
    % Håndter klik på fjendens bræt for at skyde
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Tjek om spillet er i gang
    if ~strcmp(gameData.gameState, 'playing') || ~gameData.playerTurn
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Tjek om feltet allerede er beskudt
    if gameData.playerShots(row, col) > 0
        set(handles.statusText, 'String', 'Du har allerede skudt her! Vælg et andet felt.');
        return;
    end
    
    % Vis koordinater
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Registrer spillerens skud
    if gameData.computerGrid(row, col) > 0
        % Hit
        shipType = gameData.computerGrid(row, col);
        gameData.playerShots(row, col) = 2; % Mark as hit
        set(handles.statusText, 'String', sprintf('HIT! Du ramte et %s på %s!', gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.computerHits(shipType) = gameData.computerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.computerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('Du sænkede modstanderens %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.playerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Dit skud på %s ramte ingenting.', coordStr));
    end
    
    % Opdater visning
    updateGridDisplay(handles.enemyBoard, zeros(10,10), gameData.playerShots, false);
    
    % Check for win
    if sum(gameData.computerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'SEJR! Du sænkede alle modstanderens skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Vis sejrbesked
        showGameResult(fig, true);
        return;
    end
    
    % Skift tur
    gameData.playerTurn = false;
    setappdata(fig, 'gameData', gameData);
    
    % Computerens tur - med lille forsinkelse så spilleren kan se hvad der sker
    pause(0.8);
    computerTurn(fig);
end

function computerTurn(fig)
    % Håndter computerens tur
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Check if game is still active
    if ~strcmp(gameData.gameState, 'playing')
        return;
    end
    
    % Get computer shot based on difficulty
    [row, col] = getComputerShot(gameData.computerShots, gameData.playerGrid, gameData.difficulty);
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Update status to show computer's move
    set(handles.statusText, 'String', sprintf('Computeren skyder på %s', coordStr));
    pause(0.5);
    
    % Process shot
    if gameData.playerGrid(row, col) > 0
        % Hit
        shipType = gameData.playerGrid(row, col);
        gameData.computerShots(row, col) = 2; % Mark as hit
        
        set(handles.statusText, 'String', sprintf('HIT! Computeren ramte dit %s på %s!', ...
                                                gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.playerHits(shipType) = gameData.playerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.playerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('Computeren sænkede dit %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.computerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Computerens skud på %s ramte ingenting.', coordStr));
    end
    
    % Update display
    updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Check for loss
    if sum(gameData.playerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'NEDERLAG! Computeren sænkede alle dine skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Vis nederlagsbesked
        showGameResult(fig, false);
        return;
    end
    
    % Switch turns back to player
    gameData.playerTurn = true;
    pause(0.5);
    
    % Prompt player for next move
    set(handles.statusText, 'String', sprintf('%s\nDin tur - klik på modstanderens bræt for at skyde.', ...
                                            get(handles.statusText, 'String')));
    
    setappdata(fig, 'gameData', gameData);
end