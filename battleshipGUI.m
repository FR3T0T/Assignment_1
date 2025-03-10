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
    
    % Opret hovedfigur med moderne styling
    fig = figure('Name', 'Battleship', 'Position', [100, 100, 1100, 650], ...
                 'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.95 0.95 0.98], ...
                 'CloseRequestFcn', @closeGame);
    
    % Gem gameData i figure
    setappdata(fig, 'gameData', gameData);
    
    % Opret kontrolpanel
    controlPanel = uipanel('Position', [0.02, 0.02, 0.2, 0.96], 'Title', 'Kontrolpanel', ...
                          'BackgroundColor', [0.95 0.95 0.98], ...
                          'FontWeight', 'bold', 'FontSize', 11);
    
    % Lav pænere sektioner i kontrolpanelet
    uipanel('Parent', controlPanel, 'Title', 'Indstillinger', ...
          'Position', [0.05, 0.7, 0.9, 0.25], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Opret sværhedsgrad-selector med mere beskrivende tekst
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 520, 120, 20], ...
              'String', 'Sværhedsgrad:', 'BackgroundColor', [0.95 0.95 0.98], ...
              'FontWeight', 'bold');
    
    difficultySelector = uicontrol('Parent', controlPanel, 'Style', 'popupmenu', ...
                                  'Position', [20, 490, 120, 25], ...
                                  'String', {'Let (tilfældige skud)', 'Medium (målrettet)', 'Svær (avanceret)'}, ...
                                  'Callback', @setDifficulty);
    
    % Start spil-knap med tydeligere design
    startButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                           'Position', [20, 440, 120, 40], ...
                           'String', 'Start Spil', 'FontWeight', 'bold', ...
                           'BackgroundColor', [0.3 0.6 0.3], 'ForegroundColor', 'white', ...
                           'Callback', @startGame);
    
    % Skibsplaceringssektion
    shipPanel = uipanel('Parent', controlPanel, 'Title', 'Skibsplacering', ...
          'Position', [0.05, 0.4, 0.9, 0.25], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Orientering-selector med forklarende ikon
    uicontrol('Parent', shipPanel, 'Style', 'text', 'Position', [10, 60, 120, 20], ...
              'String', 'Orientering:', 'BackgroundColor', [0.95 0.95 0.98], ...
              'FontWeight', 'bold');
    
    orientationSelector = uicontrol('Parent', shipPanel, 'Style', 'popupmenu', ...
                                   'Position', [10, 35, 120, 25], ...
                                   'String', {'Vandret →', 'Lodret ↓'});
    
    % Visuelt hjælpepanel til skibsplacering
    uicontrol('Parent', shipPanel, 'Style', 'text', 'Position', [10, 10, 150, 20], ...
             'String', 'Klik på dit bræt for at placere', ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Hjælpe-sektion
    uipanel('Parent', controlPanel, 'Title', 'Hjælp', ...
          'Position', [0.05, 0.2, 0.9, 0.15], 'FontSize', 10, ...
          'BackgroundColor', [0.95 0.95 0.98]);
    
    % Instruktioner-knap med bedre placering
    instructionsButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
                                 'Position', [20, 220, 120, 30], ...
                                 'String', 'Spilleregler', 'BackgroundColor', [0.4 0.5 0.8], ...
                                 'ForegroundColor', 'white', ...
                                 'Callback', @showInstructions);
    
    % Symbolforklaring
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 190, 120, 20], ...
             'String', 'Symbolforklaring:', 'FontWeight', 'bold', ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Symboler med farvekoder
    uicontrol('Parent', controlPanel, 'Style', 'text', 'Position', [20, 90, 130, 95], ...
             'String', {'■ Blå: Dit skib', ...
                       'X Rød: Ramt', ...
                       'O Sort: Forbi', ...
                       '~ Vand (ikke ramt)'}, ...
             'BackgroundColor', [0.95 0.95 0.98], ...
             'HorizontalAlignment', 'left');
    
    % Statusfelt med bedre styling - fjernet BorderType
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 10, 160, 70], ...
                         'String', 'Vælg sværhedsgrad og klik på "Start Spil"', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.95 0.95 0.98], ...
                         'FontWeight', 'bold');
    
    % Opret spillebrætter som axes med bedre titler - ÆNDRING: Tilføjet PickableParts property
    playerBoard = axes('Position', [0.25, 0.1, 0.35, 0.8], 'XColor', 'none', 'YColor', 'none', 'PickableParts', 'all');
    title('Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
    
    enemyBoard = axes('Position', [0.65, 0.1, 0.35, 0.8], 'XColor', 'none', 'YColor', 'none', 'PickableParts', 'all');
    title('Modstanderens bræt', 'FontWeight', 'bold', 'FontSize', 12);
    
    % Tilføj spillestatus-linje øverst
    gameStatusBar = uicontrol('Style', 'text', 'Position', [400, 620, 300, 25], ...
                             'String', 'Vælg indstillinger og start spillet', ...
                             'FontWeight', 'bold', 'FontSize', 11, ...
                             'BackgroundColor', [0.95 0.95 0.98]);
    
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
    handles.gameStatusBar = gameStatusBar;
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
    % Overlay panel til velkomst med mere attraktivt design
    welcomePanel = uipanel('Parent', fig, 'Position', [0.25, 0.25, 0.5, 0.5], ...
        'Title', 'Velkommen til Battleship!', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.9 0.95 1], 'HighlightColor', [0.2 0.4 0.8], ...
        'BorderWidth', 2);
    
    % Tilføj spilbeskrivelse med bedre formattering
    uicontrol('Parent', welcomePanel, 'Style', 'text', ...
        'Position', [20, 100, 460, 180], 'String', {...
        'SÅDAN SPILLER DU BATTLESHIP:', '', ...
        '1. Vælg sværhedsgrad og klik på "Start Spil"', ...
        '2. Placer dine 3 skibe ved at vælge orientering og klikke på dit bræt', ...
        '3. Skyd efter computerens skibe ved at klikke på modstanderens bræt', ...
        '4. Den første der sænker alle modstanderens skibe vinder!', ...
        '', ...
        'TIP: Når du placerer skibe, begynder du med det største skib først.'}, ...
        'FontSize', 11, 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.9 0.95 1]);
    
    % Start spil-knap med mere tydelig styling
    uicontrol('Parent', welcomePanel, 'Style', 'pushbutton', ...
        'Position', [180, 30, 120, 40], 'String', 'Jeg er klar!', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.3 0.6 0.3], ...
        'ForegroundColor', 'white', 'Callback', @(src,~) delete(welcomePanel));
end

function showGameResult(fig, isVictory)
    handles = getappdata(fig, 'handles');
    
    % Opret overlay panel med resultat - mere visuelt tiltalende
    resultPanel = uipanel('Parent', fig, 'Position', [0.3, 0.4, 0.4, 0.2], ...
        'BackgroundColor', [0.95 0.95 1], ...
        'HighlightColor', 'blue', 'BorderWidth', 2);
    
    if isVictory
        resultText = 'SEJR! Du sænkede alle modstanderens skibe!';
        textColor = [0 0.5 0];
        panelColor = [0.9 1 0.9];
    else
        resultText = 'NEDERLAG! Computeren sænkede alle dine skibe!';
        textColor = [0.8 0 0];
        panelColor = [1 0.9 0.9];
    end
    
    % Opdater baggrundsfarve baseret på resultat
    set(resultPanel, 'BackgroundColor', panelColor);
    
    % Tilføj tekst med bedre formattering
    uicontrol('Parent', resultPanel, 'Style', 'text', ...
        'Position', [20, 30, 320, 50], 'String', resultText, ...
        'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', textColor, ...
        'BackgroundColor', panelColor);
    
    % Tilføj knap til at starte nyt spil - tydeligere styling
    uicontrol('Parent', resultPanel, 'Style', 'pushbutton', ...
        'Position', [120, 10, 120, 30], 'String', 'Spil igen', 'FontWeight', 'bold', ...
        'BackgroundColor', [0.3 0.6 0.3], 'ForegroundColor', 'white', ...
        'Callback', @(~,~) restartGame(handles.startButton, resultPanel));
end

function restartGame(startButton, resultPanel)
    % Hjælpefunktion til at fjerne resultatpanelet og starte et nyt spil
    delete(resultPanel);
    startGame(startButton, []);
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
    % Forenklet version uden nested functions der løser problemet
    fig = ancestor(src, 'figure');
    
    % Opret simpel instruktionsfigur
    instructFig = figure('Name', 'Battleship Instruktioner', 'Position', [200, 200, 600, 450], ...
                       'MenuBar', 'none', 'NumberTitle', 'off', 'Color', [0.95 0.95 0.98]);
    
    % Opret tekstboksen først
    textBox = uicontrol('Parent', instructFig, 'Style', 'text', 'Position', [20, 20, 560, 380], ...
                     'String', '', 'BackgroundColor', [0.95 0.95 0.98], ...
                     'FontSize', 11, 'HorizontalAlignment', 'left');
    
    % Regler som standard
    set(textBox, 'String', {
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
    });
    
    % Brug direkte callbacks med reference til textBox
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [20, 410, 120, 30], ...
             'String', 'Spilleregler', 'Callback', @(~,~)showRulesContent(textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
             
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [150, 410, 120, 30], ...
             'String', 'Tips & Tricks', 'Callback', @(~,~)showTipsContent(textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
             
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [280, 410, 120, 30], ...
             'String', 'Skibe', 'Callback', @(~,~)showShipsContent(textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
end

function showRulesContent(textBox)
    set(textBox, 'String', {
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
    });
end

function showTipsContent(textBox)
    set(textBox, 'String', {
        'TIPS TIL AT VINDE I BATTLESHIP:', '', ...
        '1. SKIBSPLACERING:', ...
        '  - Spred dine skibe ud over brættet', ...
        '  - Undgå at placere skibe langs kanten', ...
        '  - Prøv at placere skibe i uventede mønstre', '', ...
        '2. SKYDETAKTIK:', ...
        '  - Start med at skyde spredt over brættet', ...
        '  - Når du rammer et skib, prøv at skyde i alle fire retninger', ...
        '  - Følg rækken af hits for at sænke skibet', ...
        '  - Husk på skibenes forskellige længder (4, 3, 2)', ... 
        '', ...
        '3. SVÆRHEDSGRADER:', ...
        '  - Let: Computeren skyder tilfældigt', ...
        '  - Medium: Computeren fokuserer på at finde dine skibe', ...
        '  - Svær: Computeren bruger avanceret strategi og skakbrætmønster'
    });
end

function showShipsContent(textBox)
    set(textBox, 'String', {
        'SKIBSOVERSIGT:', '', ...
        '1. BATTLESHIP (SLAGSKIB)', ...
        '   Længde: 4 felter', ...
        '   Dette er dit største skib', '', ...
        '2. CRUISER (KRYDSER)', ...
        '   Længde: 3 felter', ...
        '   Medium størrelse skib', '', ...
        '3. DESTROYER (DESTROYER)', ...
        '   Længde: 2 felter', ...
        '   Dit mindste og hurtigste skib', '', ...
        'PLACERINGSTIPS:', ...
        '  - Vælg orientering (vandret eller lodret) før du klikker', ...
        '  - Du placerer skibene ét ad gangen, fra størst til mindst', ...
        '  - Skibene må ikke røre hinanden eller gå ud over brættet'
    });
end

function startGame(src, ~)
    disp('startGame aktiveret');  % Debug log

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

    % REPLACE:
    % disp('Sætter placeShip funktion på brættet');
    % set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    % disp('ButtonDownFcn sat til @placeShip');

    % WITH:
    disp('Sætter placeShip funktion på brættet med anonymous function');
    set(handles.playerBoard, 'ButtonDownFcn', @(src,event) placeShipWrapper(src, event, fig));
    disp('ButtonDownFcn sat med wrapper');

    
    % Opdater status
    shipName = gameData.ships(1).name;
    shipLength = gameData.ships(1).length;
    set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', ...
                                           shipName, shipLength));
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', 'PLACER SKIBE: Vælg orientering og placer dine skibe');
    
    % Opdater brætterne
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Aktiver placeringsfunktion
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    
    % Fremhæv hvilket skib der skal placeres
    title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
    
    % Placer computerens skibe
    gameData.computerGrid = placeComputerShipsGUI(gameData.computerGrid, gameData.ships);
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function placeShip(src, ~)
    % Komplet skibsplaceringsfunktion
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Debug info
    disp('Klik registreret på brættet');
    disp(['GameState: ' gameData.gameState]);
    
    % Tjek om vi er i placeringsfasen
    if ~strcmp(gameData.gameState, 'placing')
        disp('Fejl: Spillet er ikke i placeringsfasen');
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    disp(['Klik koordinater: (' num2str(row) ',' num2str(col) ')']);
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        disp('Ugyldigt klik: Uden for brættet');
        return;
    end
    
    % Hent orientering og skibslængde
    orientation = get(handles.orientationSelector, 'Value');
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Tjek om placeringen er gyldig
    valid = validateShipPlacement(gameData.playerGrid, row, col, orientation, shipLength);
    
    if valid
        disp('Gyldig placering: Placerer skib');
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
        
        % Marker skibet som placeret og opdater visning
        gameData.ships(currentShip).placed = true;
        updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Fortsæt til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            disp(['Næste skib: ' gameData.ships(gameData.currentShip).name]);
        else
            disp('Alle skibe placeret. Starter spillet!');
            gameData.gameState = 'playing';
        end
    else
        disp('Ugyldig placering');
    end
    
    % Gem opdateret spilledata
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
        set(handles.statusText, 'String', 'Du har allerede skudt her!\nVælg et andet felt.');
        
        % Vis advarsel
        warningPanel = uipanel('Parent', fig, 'Position', [0.65, 0.45, 0.3, 0.1], ...
                              'BackgroundColor', [1 0.9 0.9], ...
                              'HighlightColor', [0.8 0 0], 'BorderWidth', 2);
        
        uicontrol('Parent', warningPanel, 'Style', 'text', ...
                 'Position', [10, 35, 280, 25], 'String', 'Du har allerede skudt her!', ...
                 'FontSize', 12, 'FontWeight', 'bold', 'ForegroundColor', [0.8 0 0], ...
                 'BackgroundColor', [1 0.9 0.9]);
        
        % Fjern advarsel efter 1.5 sekunder
        t = timer('ExecutionMode', 'singleShot', 'StartDelay', 1.5, ...
                 'TimerFcn', @(~,~) delete(warningPanel));
        start(t);
        return;
    end
    
    % Vis koordinater
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', sprintf('Du skyder på %s', coordStr));
    
    % Registrer spillerens skud med visuel feedback
    if gameData.computerGrid(row, col) > 0
        % Hit
        shipType = gameData.computerGrid(row, col);
        gameData.playerShots(row, col) = 2; % Mark as hit
        
        % Opdater status
        set(handles.statusText, 'String', sprintf('TRÆFFER!\nDu ramte et %s på %s!', gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.computerHits(shipType) = gameData.computerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.computerHits(shipType) == gameData.ships(shipType).length
            % Vis besked om sænket skib
            sunkPanel = uipanel('Parent', fig, 'Position', [0.65, 0.5, 0.3, 0.15], ...
                               'BackgroundColor', [0.9 0.95 1], ...
                               'HighlightColor', [0 0.5 0.8], 'BorderWidth', 2);
            
            uicontrol('Parent', sunkPanel, 'Style', 'text', ...
                     'Position', [10, 40, 280, 40], 'String', sprintf('Du sænkede modstanderens %s!', gameData.ships(shipType).name), ...
                     'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0 0.5 0.8], ...
                     'BackgroundColor', [0.9 0.95 1]);
            
            % Fjern besked efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                     'TimerFcn', @(~,~) delete(sunkPanel));
            start(t);
            
            set(handles.statusText, 'String', sprintf('SKIBET SÆNKET!\nDu sænkede modstanderens %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.playerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('FORBI!\nDit skud på %s ramte ingenting.', coordStr));
    end
    
    % Opdater visning med animation
    hitEffect = [];
    if gameData.playerShots(row, col) == 2
        % Effekt ved træffer
        axes(handles.enemyBoard);
        hitEffect = rectangle('Position', [col-1, row-1, 1, 1], 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'red', 'LineWidth', 2);
    else
        % Effekt ved forbi
        axes(handles.enemyBoard);
        hitEffect = plot(col-0.5, row-0.5, 'ko', 'MarkerSize', 25, 'LineWidth', 2, 'MarkerFaceColor', [0.8 0.8 0.8]);
    end
    
    % Opdater brætvisning efter kort forsinkelse
    pause(0.3);
    if ~isempty(hitEffect) && isvalid(hitEffect)
        delete(hitEffect);
    end
    updateGridDisplay(handles.enemyBoard, zeros(10,10), gameData.playerShots, false);
    
    % Check for win
    if sum(gameData.computerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'SEJR! Du sænkede alle modstanderens skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        set(handles.gameStatusBar, 'String', 'SPILLET ER SLUT: Du har vundet!', 'ForegroundColor', [0 0.6 0]);
        setappdata(fig, 'gameData', gameData);
        
        % Vis sejrbesked
        showGameResult(fig, true);
        return;
    end
    
    % Skift tur
    gameData.playerTurn = false;
    setappdata(fig, 'gameData', gameData);
    
    % Opdater UI før computerens tur
    set(handles.gameStatusBar, 'String', 'MODSTANDERENS TUR: Computeren skyder...', 'ForegroundColor', [0.8 0 0]);
    
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
    set(handles.gameStatusBar, 'String', sprintf('Computeren skyder på %s', coordStr));
    
    % Vis indikator for computerens skud
    axes(handles.playerBoard);
    targetMarker = plot(col-0.5, row-0.5, 'ro', 'MarkerSize', 15, 'LineWidth', 2);
    pause(0.5);
    delete(targetMarker);
    
    % Process shot
    if gameData.playerGrid(row, col) > 0
        % Hit
        shipType = gameData.playerGrid(row, col);
        gameData.computerShots(row, col) = 2; % Mark as hit
        
        % Visuelt fremhæv ramt felt
        axes(handles.playerBoard);
        hitEffect = rectangle('Position', [col-1, row-1, 1, 1], 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'red', 'LineWidth', 2);
        pause(0.3);
        delete(hitEffect);
        
        set(handles.statusText, 'String', sprintf('RAMT! Computeren ramte dit %s på %s!', ...
                                                gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.playerHits(shipType) = gameData.playerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.playerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('SKIBET SÆNKET! Computeren sænkede dit %s!', gameData.ships(shipType).name));
            
            % Vis besked om sænket skib
            sunkPanel = uipanel('Parent', fig, 'Position', [0.25, 0.5, 0.3, 0.15], ...
                              'BackgroundColor', [1 0.9 0.9], ...
                              'HighlightColor', [0.8 0 0], 'BorderWidth', 2);
            
            uicontrol('Parent', sunkPanel, 'Style', 'text', ...
                    'Position', [10, 40, 280, 40], 'String', sprintf('Computeren sænkede dit %s!', gameData.ships(shipType).name), ...
                    'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0.8 0 0], ...
                    'BackgroundColor', [1 0.9 0.9]);
            
            % Fjern besked efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                    'TimerFcn', @(~,~) delete(sunkPanel));
            start(t);
        end
    else
        % Miss
        gameData.computerShots(row, col) = 1; % Mark as miss
        
        % Visuelt fremhæv forbiskud
        axes(handles.playerBoard);
        missEffect = plot(col-0.5, row-0.5, 'ko', 'MarkerSize', 20, 'LineWidth', 2);
        pause(0.3);
        delete(missEffect);
        
        set(handles.statusText, 'String', sprintf('FORBI! Computerens skud på %s ramte ingenting.', coordStr));
    end
    
    % Update display
    updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Check for loss
    if sum(gameData.playerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'NEDERLAG! Computeren sænkede alle dine skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        set(handles.gameStatusBar, 'String', 'SPILLET ER SLUT: Computeren har vundet', 'ForegroundColor', [0.8 0 0]);
        setappdata(fig, 'gameData', gameData);
        
        % Vis nederlagsbesked
        showGameResult(fig, false);
        return;
    end
    
    % Switch turns back to player
    gameData.playerTurn = true;
    pause(0.5);
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde', 'ForegroundColor', [0 0 0]);
    
    % Prompt player for next move
    set(handles.statusText, 'String', sprintf('%s\nDin tur - klik på modstanderens bræt for at skyde.', ...
                                            get(handles.statusText, 'String')));
    
    setappdata(fig, 'gameData', gameData);
end

function drawGrid(ax)
    % Tegn et tomt 10x10 grid med forbedret stil
    cla(ax);
    hold(ax, 'on');
    
    % ÆNDRING: Tilføj en klikbar baggrund
    rectangle('Parent', ax, 'Position', [0 0 10 10], 'FaceColor', 'none', 'EdgeColor', 'none', 'PickableParts', 'all');
    
    % Sæt akseegenskaber
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Farvelæg baggrunden for bedre kontrast
    fill(ax, [0 10 10 0], [0 0 10 10], [0.96 0.98 1], 'EdgeColor', 'none');
    
    % Tegn gridlinjer med lidt skygge
    for i = 0:10
        line(ax, [i i], [0 10], 'Color', [0.7 0.7 0.8]);
        line(ax, [0 10], [i i], 'Color', [0.7 0.7 0.8]);
    end
    
    % Tilføj labels med bedre formattering
    for i = 1:10
        text(ax, i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(ax, -0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Fjern standard akseticks
    set(ax, 'XTick', [], 'YTick', []);
    
    hold(ax, 'off');
end

function updateGridDisplay(ax, shipGrid, shotGrid, showShips)
    % Opdater gridvisningen baseret på spillets tilstand
    cla(ax);
    hold(ax, 'on');
    
    % ÆNDRING: Tilføj en klikbar baggrund
    rectangle('Parent', ax, 'Position', [0 0 10 10], 'FaceColor', 'none', 'EdgeColor', 'none', 'PickableParts', 'all');
    
    % Tegn grundlæggende grid
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Farvelæg baggrunden for bedre kontrast
    fill([0 10 10 0], [0 0 10 10], [0.96 0.98 1], 'EdgeColor', 'none');
    
    % Tegn gridlinjer med lidt skygge
    for i = 0:10
        line([i i], [0 10], 'Color', [0.7 0.7 0.8]);
        line([0 10], [i i], 'Color', [0.7 0.7 0.8]);
    end
    
    % Tilføj labels med bedre formattering
    for i = 1:10
        text(i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(-0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Fjern standard akseticks
    set(ax, 'XTick', [], 'YTick', []);
    
    % Visualiser skibe, hits og misses med forbedret udseende
    for i = 1:10
        for j = 1:10
            if shotGrid(i, j) == 2
                % Hit
                rectangle('Position', [j-1, i-1, 1, 1], 'FaceColor', [0.9 0.3 0.3], 'EdgeColor', [0.7 0 0]);
                plot(j-0.5, i-0.5, 'kx', 'LineWidth', 2, 'MarkerSize', 15);
            elseif shotGrid(i, j) == 1
                % Miss
                plot(j-0.5, i-0.5, 'ko', 'MarkerSize', 10, 'LineWidth', 1.5, 'MarkerFaceColor', [0.5 0.5 0.5]);
            elseif showShips && shipGrid(i, j) > 0
                % Ship - mere visuelt attraktiv repræsentation
                shipType = shipGrid(i, j);
                shipColors = {[0.2 0.4 0.8], [0.3 0.5 0.8], [0.4 0.6 0.9]}; % Forskellige nuancer til forskellige skibe
                rectangle('Position', [j-1, i-1, 1, 1], 'FaceColor', shipColors{shipType}, ...
                         'EdgeColor', [0.1 0.2 0.5], 'LineWidth', 1);
            end
        end
    end
    
    hold(ax, 'off');
end

function valid = validateShipPlacement(grid, row, col, orientation, shipLength)
    % Valider om et skib kan placeres på det angivne sted
    
    % Tjek om skibet passer på brættet
    if orientation == 1 && col + shipLength - 1 > 10  % Vandret
        valid = false;
        return;
    elseif orientation == 2 && row + shipLength - 1 > 10  % Lodret
        valid = false;
        return;
    end
    
    % Tjek om felterne er ledige
    valid = true;
    if orientation == 1  % Vandret
        for i = 0:(shipLength-1)
            if grid(row, col+i) ~= 0
                valid = false;
                return;
            end
        end
    else  % Lodret
        for i = 0:(shipLength-1)
            if grid(row+i, col) ~= 0
                valid = false;
                return;
            end
        end
    end
end

function grid = placeComputerShipsGUI(grid, ships)
    % Automatisk placer computerens skibe på brættet
    % Genbruger logik fra den originale placeComputerShips.m
    
    % Ship lengths
    shipLengths = [ships.length];
    
    % Place each ship
    for i = 1:length(shipLengths)
        placedSuccessfully = false;
        
        while ~placedSuccessfully
            % Random position and orientation
            row = randi(10);
            col = randi(10);
            isHorizontal = randi(2) == 1;
            
            % Check if ship fits on grid
            if isHorizontal && col + shipLengths(i) - 1 > 10
                continue;
            elseif ~isHorizontal && row + shipLengths(i) - 1 > 10
                continue;
            end
            
            % Check if space is already occupied
            occupied = false;
            
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    if grid(row, col+j) ~= 0
                        occupied = true;
                        break;
                    end
                end
            else
                for j = 0:shipLengths(i)-1
                    if grid(row+j, col) ~= 0
                        occupied = true;
                        break;
                    end
                end
            end
            
            if occupied
                continue;
            end
            
            % Place the ship
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    grid(row, col+j) = i;
                end
            else
                for j = 0:shipLengths(i)-1
                    grid(row+j, col) = i;
                end
            end
            
            placedSuccessfully = true;
        end
    end
end

% Vi importerer getComputerShot funktionen fra den originale implementation
function [row, col] = getComputerShot(shotGrid, playerGrid, difficulty)
    % Get computer's shot based on difficulty level
    
    % Grid size
    [rows, cols] = size(shotGrid);
    
    % EASY MODE - random shots
    if difficulty == 1
        validShot = false;
        
        while ~validShot
            % Random position
            row = randi(rows);
            col = randi(cols);
            
            % Check if already shot at this position
            if shotGrid(row, col) == 0
                validShot = true;
            end
        end
        
        return;
    end
    
    % MEDIUM MODE - hunt and target
    if difficulty == 2
        % Look for hits to target adjacent cells
        for i = 1:rows
            for j = 1:cols
                if shotGrid(i, j) == 2  % Found a hit
                    % Try adjacent cells (up, down, left, right)
                    directions = [[-1, 0]; [1, 0]; [0, -1]; [0, 1]];
                    
                    for d = 1:length(directions)
                        newRow = i + directions(d, 1);
                        newCol = j + directions(d, 2);
                        
                        % Check if valid and not already tried
                        if newRow >= 1 && newRow <= rows && newCol >= 1 && newCol <= cols && shotGrid(newRow, newCol) == 0
                            row = newRow;
                            col = newCol;
                            return;
                        end
                    end
                end
            end
        end
        
        % If no hits found, take random shot
        validShot = false;
        while ~validShot
            row = randi(rows);
            col = randi(cols);
            
            if shotGrid(row, col) == 0
                validShot = true;
            end
        end
        
        return;
    end
    
    % HARD MODE - advanced targeting
    if difficulty == 3
        % First, look for two adjacent hits to extend the line
        for i = 1:rows
            for j = 1:cols-1
                if shotGrid(i, j) == 2 && shotGrid(i, j+1) == 2  % Horizontal hits
                    % Try left
                    if j > 1 && shotGrid(i, j-1) == 0
                        row = i;
                        col = j-1;
                        return;
                    end
                    
                    % Try right
                    if j+2 <= cols && shotGrid(i, j+2) == 0
                        row = i;
                        col = j+2;
                        return;
                    end
                end
            end
        end
        
        for j = 1:cols
            for i = 1:rows-1
                if shotGrid(i, j) == 2 && shotGrid(i+1, j) == 2  % Vertical hits
                    % Try up
                    if i > 1 && shotGrid(i-1, j) == 0
                        row = i-1;
                        col = j;
                        return;
                    end
                    
                    % Try down
                    if i+2 <= rows && shotGrid(i+2, j) == 0
                        row = i+2;
                        col = j;
                        return;
                    end
                end
            end
        end
        
        % If no adjacent hits, use medium difficulty strategy
        % Look for single hits
        for i = 1:rows
            for j = 1:cols
                if shotGrid(i, j) == 2  % Found a hit
                    % Try adjacent cells
                    directions = [[-1, 0]; [1, 0]; [0, -1]; [0, 1]];
                    
                    for d = 1:length(directions)
                        newRow = i + directions(d, 1);
                        newCol = j + directions(d, 2);
                        
                        if newRow >= 1 && newRow <= rows && newCol >= 1 && newCol <= cols && shotGrid(newRow, newCol) == 0
                            row = newRow;
                            col = newCol;
                            return;
                        end
                    end
                end
            end
        end
        
        % If no hits found, take random shot using checkerboard pattern
        validShot = false;
        attempts = 0;
        
        % Try checkerboard pattern first
        while ~validShot && attempts < 50
            attempts = attempts + 1;
            
            % Get random position adhering to checkerboard pattern
            r = randi(rows);
            c = randi(cols);
            
            % Only consider positions where r+c is even (checkerboard)
            if mod(r+c, 2) == 0 && shotGrid(r, c) == 0
                row = r;
                col = c;
                validShot = true;
            end
        end
        
        % If checkerboard failed, take any valid shot
        if ~validShot
            while ~validShot
                row = randi(rows);
                col = randi(cols);
                
                if shotGrid(row, col) == 0
                    validShot = true;
                end
            end
        end
        
        return;
    end
end

% Then ADD this new function at the end of the file:
function placeShipWrapper(src, event, fig)
    % This wrapper ensures the correct figure context is passed to placeShip
    disp('Wrapper aktiveret - kalder placeShip');
    placeShip(src, event);
end