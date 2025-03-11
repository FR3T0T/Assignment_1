function battleshipGUI()
% BATTLESHIPGUI - Grafisk brugergrænseflade til Battleship-spillet
% Dette er hovedfunktionen der starter spillet og opsætter GUI.
    
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
    
    % Statusfelt med bedre styling
    statusText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
                         'Position', [10, 10, 160, 70], ...
                         'String', 'Vælg sværhedsgrad og klik på "Start Spil"', ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.95 0.95 0.98], ...
                         'FontWeight', 'bold');
    
    % Opret spillebrætter som axes
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
    battleshipGrid('drawGrid', playerBoard);
    battleshipGrid('drawGrid', enemyBoard);
    
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
    battleshipUI('showWelcomeScreen', fig);
end

function setDifficulty(src, ~)
    % Opdater sværhedsgrad
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    gameData.difficulty = get(src, 'Value');
    setappdata(fig, 'gameData', gameData);
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

    % Opdater status
    shipName = gameData.ships(1).name;
    shipLength = gameData.ships(1).length;
    set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', ...
                                          shipName, shipLength));
    
    % Opdater spillestatus
    set(handles.gameStatusBar, 'String', 'PLACER SKIBE: Vælg orientering og placer dine skibe');
    
    % Opdater brætterne
    battleshipGrid('drawGrid', handles.playerBoard);
    battleshipGrid('drawGrid', handles.enemyBoard);
    
    % Fremhæv hvilket skib der skal placeres
    title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
    
    % Placer computerens skibe
    gameData.computerGrid = battleshipAI('placeComputerShips', gameData.computerGrid, gameData.ships);
    
    % Sæt placeShip funktion på brættet - VIGTIGT at dette gøres EFTER opdatering af brættet
    disp('Sætter placeShipOnBoard funktion på brættet');
    drawnow; % Force update før vi sætter callback
    set(handles.playerBoard, 'ButtonDownFcn', @placeShipOnBoard);
    disp('PlaceShipOnBoard funktion er sat på brættet');
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function placeShipOnBoard(src, ~)
    % Håndterer direkte skibsplacering på brættet
    disp('Klik modtaget på brættet!'); % Debug info
    
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    disp(['Klikket på position: (' num2str(row) ', ' num2str(col) ')']);
    
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
        disp('Gyldig placering - placerer skib');
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
        battleshipGrid('updateDisplay', handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Sæt ButtonDownFcn igen efter opdatering af grid
        set(handles.playerBoard, 'ButtonDownFcn', @placeShipOnBoard);
        
        % Fortsæt til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            shipName = gameData.ships(gameData.currentShip).name;
            shipLength = gameData.ships(gameData.currentShip).length;
            
            % Opdater instruktioner og titel
            set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', shipName, shipLength));
            title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
            
        else
            disp('Alle skibe placeret. Starter spillet!');
            gameData.gameState = 'playing';
            
            % Opdater UI for spillefasen
            set(handles.statusText, 'String', 'Alle skibe placeret!\nKlik på modstanderens bræt for at skyde.');
            set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde');
            title(handles.playerBoard, 'Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
            
            % Aktiver fjendebræt til at modtage skud
            set(handles.enemyBoard, 'ButtonDownFcn', @(src,event) battleshipLogic('fireShot', src, event));
            set(handles.playerBoard, 'ButtonDownFcn', []);
        end
    else
        disp('Ugyldig placering - prøv igen');
        % Vis fejlmeddelelse ved ugyldig placering
        title(handles.playerBoard, 'Ugyldig placering! Prøv igen.', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
        % Nulstil titlen efter kort tid
        t = timer('ExecutionMode', 'singleShot', 'StartDelay', 1.5, ...
                 'TimerFcn', @(~,~) title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', ...
                                                                     gameData.ships(currentShip).name, shipLength), ...
                                         'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]));
        start(t);
    end
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function placeShipOnBoard(src, ~)
    % Håndterer direkte skibsplacering på brættet
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Hent orientering og skibslængde
    orientation = get(handles.orientationSelector, 'Value');
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Tjek om placeringen er gyldig
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
        
        % Marker skibet som placeret og opdater visning
        gameData.ships(currentShip).placed = true;
        battleshipGrid('updateDisplay', handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Fortsæt til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            shipName = gameData.ships(gameData.currentShip).name;
            shipLength = gameData.ships(gameData.currentShip).length;
            
            % Opdater instruktioner og titel
            set(handles.statusText, 'String', sprintf('Placer dit %s\n(%d felter)\nVælg orientering og \nklik på dit bræt.', shipName, shipLength));
            title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', shipName, shipLength), 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]);
            
        else
            gameData.gameState = 'playing';
            
            % Opdater UI for spillefasen
            set(handles.statusText, 'String', 'Alle skibe placeret!\nKlik på modstanderens bræt for at skyde.');
            set(handles.gameStatusBar, 'String', 'DIN TUR: Klik på modstanderens bræt for at skyde');
            title(handles.playerBoard, 'Dit bræt', 'FontWeight', 'bold', 'FontSize', 12);
            
            % Aktiver fjendebræt til at modtage skud
            set(handles.enemyBoard, 'ButtonDownFcn', @(src,event) battleshipLogic('fireShot', src, event));
            set(handles.playerBoard, 'ButtonDownFcn', []);
        end
    else
        % Vis fejlmeddelelse ved ugyldig placering
        title(handles.playerBoard, 'Ugyldig placering! Prøv igen.', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
        % Nulstil titlen efter kort tid
        t = timer('ExecutionMode', 'singleShot', 'StartDelay', 1.5, ...
                 'TimerFcn', @(~,~) title(handles.playerBoard, sprintf('Dit bræt - Placer %s (%d felter)', ...
                                                                     gameData.ships(currentShip).name, shipLength), ...
                                         'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.2 0.4 0.8]));
        start(t);
    end
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end

function valid = validateShipPlacement(grid, row, col, orientation, shipLength)
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
    battleshipUI('showRulesContent', textBox);
    
    % Brug direkte callbacks med reference til textBox
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [20, 410, 120, 30], ...
             'String', 'Spilleregler', 'Callback', @(~,~)battleshipUI('showRulesContent', textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
             
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [150, 410, 120, 30], ...
             'String', 'Tips & Tricks', 'Callback', @(~,~)battleshipUI('showTipsContent', textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
             
    uicontrol('Parent', instructFig, 'Style', 'pushbutton', 'Position', [280, 410, 120, 30], ...
             'String', 'Skibe', 'Callback', @(~,~)battleshipUI('showShipsContent', textBox), ...
             'BackgroundColor', [0.4 0.5 0.8], 'ForegroundColor', 'white');
end

function closeGame(src, ~)
    % Bekræft afslutning af spil
    choice = questdlg('Er du sikker på, at du vil afslutte spillet?', ...
        'Afslut Battleship', 'Ja', 'Nej', 'Nej');
    
    if strcmp(choice, 'Ja')
        delete(src);
    end
end

function test_click_handler()
% Tilføj denne funktion til enden af battleshipGUI.m fil
% Kald den fra kommandovinduet efter at have startet spillet ved at skrive:
% test_click_handler
%
% Denne funktion vil direkte sætte en klik-handler på spillebrættet
% for at teste om der er problemer med klik-detektion

    % Find figur og håndtere
    fig = findobj('Type', 'figure', 'Name', 'Battleship');
    if isempty(fig)
        disp('Ingen Battleship spil fundet! Start battleshipGUI først.');
        return;
    end
    
    handles = getappdata(fig, 'gameData');
    if isempty(handles)
        disp('Kunne ikke finde gameData. Prøver at finde brættet direkte...');
        
        % Find axerne direkte
        ax = findobj(fig, 'Type', 'axes');
        if length(ax) >= 2
            playerBoard = ax(1);
        else
            disp('Kunne ikke finde spillebrættet!');
            return;
        end
    else
        handles = getappdata(fig, 'handles');
        playerBoard = handles.playerBoard;
    end
    
    % Slet alt indhold og tegn en ny baggrund for at forbedre klikbarhed
    cla(playerBoard);
    set(playerBoard, 'ButtonDownFcn', @test_click, 'PickableParts', 'all', 'HitTest', 'on');
    
    % Tegn en baggrund der er sikker på at fange klik
    hold(playerBoard, 'on');
    h = patch([0 10 10 0], [0 0 10 10], [0.8 0.9 1], 'Parent', playerBoard);
    set(h, 'FaceAlpha', 0.5, 'EdgeColor', 'blue', 'LineWidth', 2, 'ButtonDownFcn', @test_click);
    
    % Tilføj forklarende tekst
    text(5, 5, 'Klik hvor som helst på dette bræt', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Parent', playerBoard);
    
    hold(playerBoard, 'off');
    
    % Debug info
    disp('Direkte klik-handler er nu sat på venstre bræt.');
    disp('Prøv at klikke på det blå felt for at teste om klik detekteres.');
end

function test_click(src, ~)
    % Få koordinater
    ax = gca;
    point = get(ax, 'CurrentPoint');
    x = point(1,1);
    y = point(1,2);
    
    % Vis klik-position
    disp('----------------------');
    disp('KLIK DETEKTERET!');
    disp(['Position: (' num2str(x) ', ' num2str(y) ')']);
    disp('----------------------');
    
    % Tilføj markør ved klik-position
    hold(ax, 'on');
    plot(x, y, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'red');
    text(x, y+0.5, 'Klik!', 'Color', 'red', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    hold(ax, 'off');
end