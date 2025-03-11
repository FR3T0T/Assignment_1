function showGameResult(fig, isVictory)
% SHOWGAMERESULT - Viser slutresultat når spillet er færdigt
% Inputs:
%   fig - Handle til hovedfiguren
%   isVictory - Boolean, true hvis spilleren vandt, false hvis computeren vandt
    
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
    
    % Spil igen-knap
    uicontrol('Parent', resultPanel, 'Style', 'pushbutton', ...
        'Position', [120, 10, 120, 30], 'String', 'Spil igen', ...
        'Callback', @(~,~) restartGame(handles.startButton, resultPanel));
end