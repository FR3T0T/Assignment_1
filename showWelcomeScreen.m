function showWelcomeScreen(fig)
% SHOWWELCOMESCREEN - Shows welcome screen when the game starts
% Inputs:
%   fig - Handle to the main figure
    
    % Overlay panel for welcome
    welcomePanel = uipanel('Parent', fig, 'Position', [0.25, 0.25, 0.5, 0.5], ...
        'Title', 'Welcome to Battleship!', 'FontSize', 14, ...
        'BackgroundColor', [0.95 0.95 1]);
    
    % Add game description
    uicontrol('Parent', welcomePanel, 'Style', 'text', ...
        'Position', [20, 100, 460, 180], 'String', {...
        'HOW TO PLAY BATTLESHIP:', '', ...
        '1. Choose difficulty and click on "Start Game"', ...
        '2. Place your 3 ships by selecting orientation and clicking on your board', ...
        '3. Shoot at the computer''s ships by clicking on the opponent''s board', ...
        '4. The first to sink all of the opponent''s ships wins!', ...
        '', ...
        'Blue squares show your ships', ...
        'X marks a hit ship', ...
        'O marks a miss (water)'}, ...
        'FontSize', 11, 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 1]);
    
    % Start game button
    uicontrol('Parent', welcomePanel, 'Style', 'pushbutton', ...
        'Position', [180, 30, 120, 40], 'String', 'I''m ready!', ...
        'FontSize', 12, 'Callback', @(src,~) delete(welcomePanel));
end