function restartGame(startButton, resultPanel)
% RESTARTGAME - Helper function to remove the result panel and start a new game
% Inputs:
% startButton - Handle to the start button
% resultPanel - Handle to the result panel
    
    delete(resultPanel);
    startGame(startButton, []);
end