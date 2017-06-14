%% :- module(minimax, [minimax/3]).

% minimax(+Pos, -Pos1, -Val)
% Best move from Pos leads to position BestNextPos.
minimax(Pos, BestNextPos, Val) :-                  % Pos has successors
    bagof(NextPos, move(Pos, NextPos), List),
    best(List, BestNextPos, Val), !.
minimax(Pos, Pos, Val) :-                          % Pos has no successors
    utility(Pos, Val).	
minimax2(Pos, Pos-Val):-minimax(Pos, _,Val).       %  return the same position
%%
best(L, Pos, Val) :- maplist(minimax2,L,Lx),getBest(Lx, Pos-Val),!.
getBest(L,PV):-L=[Pos-_|_], 
               (is_min(Pos)-> sort(2,<,L,Lo),Lo=[PV|_],!;
			    is_max(Pos)-> sort(2,>,L,Lo),Lo=[PV|_],!).
is_min([o, _, _]).
is_max([x, _, _]).
%%  sort(1,<,[2-a,5-b,1-c,4-d,11-e],L).
tl([[o,play,[x,o,x,x,b,o,o,x,b]],
    [o,play,[b,o,x,b,b,o,o,x,b]],
	[o,play,[b,o,x,o,o,x,o,o,b]]]).	
%% tl(X),maplist(minimax2,X,L).	
%% tl([X,Y,Z]),minimax2(X,X1).

%%%:- module(tictactoe, [move/2,min_to_move/1,max_to_move/1,utility/2,winPos/2,drawPos/2]).

utility([o, win, _],  -1).      
utility([x, win, _],   1).     
utility([_, draw, _],  0).

%% Tab=[o,o,x, x,x,o ,o,o,x] 
%% Tab=[b,b,b,b,b,b,b,b,b,b] vazio 
 emlinha3([1,2,3]). %% horiz em linha
 emlinha3([4,5,6]).
 emlinha3([7,8,9]).
 emlinha3([1,4,7]). %% vert
 emlinha3([2,5,8]).
 emlinha3([3,6,9]).
 emlinha3([1,5,9]). %% diag
 emlinha3([3,5,7]).
 %%
 argN(1,[X|Xs],X):-!.
 argN(N,[X|Xs],Xo):-N>0,!,N1 is N-1,argN(N1,Xs,Xo).
 %% Tab=[b,b,b,b],member(X,[1,2,3,4]),moveC(X,Tab/Tab1,x).
 %%
 moveC(N,Tab/Tab1,X):- N1 is N-1, length(A,N1),!, append(A,[B|Bs],Tab),append(A,[X|Bs],Tab1).
  cruz(N,Tab) :- argN(N,Tab,x).
  bola(N,Tab) :- argN(N,Tab,o).
 vazia(N,Tab) :- argN(N,Tab,b).
 cheia(N,Tab) :- \+ vazia(N,Tab).
 %%
 gameOver(T,V) :- vence(T,V).
 gameOver(T,empate) :- empate(T).
 vence(T,x):- emlinha3([A,B,C]), cruz(A,T),cruz(B,T),cruz(C,T),!.
 vence(T,o):- emlinha3([A,B,C]), bola(A,T),bola(B,T),bola(C,T),!.
 preenche(XO,T/T2):- member(X,[1,2,3,4,5,6,7,8,9]),
                  vazia(X,T),moveC(X,T/T1,XO),!,preenche(XO,T1/T2).
 preenche(XO,T/T).
%%
 empate(T):- preenche(o,T/T1),\+ vence(T1,_),!,
             preenche(x,T/T2),\+ vence(T2,_).
 %% ?- T=[o,b,x, b,b,b, b,b,b], empate(T).
 %% ?- T=[o,o,x, x,x,o ,o,o,x], empate(T).
 
% na primeira livre, backtrack todas 
move_aux(XO,T/T1):- member(X,[1,2,3,4,5,6,7,8,9]),
				    vazia(X,T),moveC(X,T/T1,XO).
%  T=[b,b,o,x,o,b],move_aux(o,T/T1). 
%
%% ?- move([o, play,[b,o,x, b,b,b, b,b,b] ],X). 
%% ?- move([o, play,[x,x,x,x,b,o,o,x,x]],X).
/**
?-move([o, play,[b,o,x, b,b,b, b,b,b] ],X). 
X = [x, play, [o, o, x, b, b, b|...]] ;
X = [x, play, [b, o, x, o, b, b|...]] ;
X = [x, play, [b, o, x, b, o, b|...]] ;
X = [x, play, [b, o, x, b, b, o|...]] ;
...
**/
%%
move([X1, play, Board], [X2, win, NextBoard]) :-
    nextPlayer(X1, X2),
    move_aux(X1, Board/NextBoard), 
    winPos(X1, NextBoard), !.
% empata 
move([X1, play, Board], [X2, draw, NextBoard]) :-
    nextPlayer(X1, X2), 
    move_aux(X1, Board/NextBoard),
    drawPos(X1,NextBoard), !.
% joga 
move([X1, play, Board], [X2, play, NextBoard]) :-
    nextPlayer(X1, X2),
    move_aux(X1, Board/NextBoard).
%%
winPos(P,T):-vence(T,P). 
drawPos(_,Board) :- empate(Board).
%%
%% =====================================================
%% :- use_module(minimax).

play :-nl,write('= Prolog TicTacToe ='), nl,
	      write('= x starts the game ='), nl,
	  playAskColor.
	
playAskColor :-
	  nl, write('human player ? (x or o)'), nl,
	  read(HumPlayer), nl,
	  ( 
	    HumPlayer \= o, HumPlayer \= x, !,     
	    write('Error:   !'), nl,
	    playAskColor                    
	    ; EmptyBoard=[b,b,b, b,b,b, b,b,b],  
	    show(EmptyBoard), nl,
	    play([x, play, EmptyBoard], HumPlayer)
	  ).

% play(+Position, +HumanPlayer)
play([Player, play, Board], HumPlayer) :- Player=HumPlayer,!,
    nl, write('Next move ?'), nl,
    read(Pos), nl,                                  
    ( vazia(Pos,Board),
      nextPlayer(Player, Player1),
	  moveC(Pos,Board/Board1,Player), 
      nextState(Player,Board1,State),
	  show(Board1),
       (  endState(State, HumPlayer),!
        ; play([Player1, play, Board1], HumPlayer) 
	    ) 
      ;
      write('-> Bad Move !'), nl,                
      play([Player, play, Board], HumPlayer)        
    ).

% Compute the best move for computer with minimax or alpha-beta.
play([Player, play, Board], HumPlayer) :-
    nl, write('Computer play : '), nl, nl,
    Pos=[Player, play, Board], 
	minimax(Pos, Pos1,_), % joga minimax
	Pos1=[Player1, State, Board1],
	nextState(Player,Board1,State),
    show(Board1),
    (  endState(State, Player),!
      ; play([Player1, play, Board1], HumPlayer)).
%%
endState(win, Player):-                                 
      nl, write('End of game : '),
      write(Player), write(' win !'), nl, nl.
endState(draw, Player):-                                   
      nl, write('End of game : '), 
	  write(' draw !'), nl, nl.
%%      	
nextPlayer(o, x).
nextPlayer(x, o).
nextState(Player,Board,State):-
       winPos(Player,Board) -> State = win ;
      drawPos(Player,Board) -> State = draw ;
                               State = play.
%%							   							
show(T) :-desenha(T). 
   %% desenha o tabuleiro
wrtLinha(X,Y,Z,T):-
	argN(X,T,V1), wVal(V1),write('|'),
	argN(Y,T,V2), wVal(V2),write('|'),
	argN(Z,T,V3), wVal(V3),nl.
wVal(X):- X=b ->write(' ');write(X).
desenha(T) :- 
nl, tab(7),wrtLinha(1,2,3,T), tab(7),write('------'),nl,
	tab(7),wrtLinha(4,5,6,T), tab(7),write('------'),nl,
	tab(7),wrtLinha(7,8,9,T).
/*
EXERCICIOS PRÁTICOS 
1) qual a diferença de sort(1,<,X,Y), para sort(2,>,X,Y), mostre
consultando por ex. sort(1,<,[2-a,5-b,1-c,4-d,11-e],L).

O sort/4 tem como primeiro parametro o indice pelo qual será ordenado a lista
e o segundo determida a ordenação acesdente ou descendente. Sendo assim, 
o sort(1,<,X,Y), ordena a lista X pelo primeiro indice do menor para 
o maior (ascendente),enquanto, sort(2,>,X,Y) ordena pelo segundo indice de 
forma descendente.
?- sort(1,<,X,Y).
L = [1-c, 2-a, 4-d, 5-b, 11-e]
?- sort(2,>,X,Y).
L = [11-e, 4-d, 1-c, 5-b, 2-a]

2) mostre T onde vence(T,o) é true

?- vence([o,o,o],o).
true

3) faça uma consulta mostrando como testar uma
configuração do Tab onde bola vence
?- Tab = [o,o,o, x,x,b, b,b,b], vence(Tab, o).
Tab = [o, o, o, x, x, b, b, b, b]

4) faça uma consulta mostrando como testar uma
configuração do Tab onde ocorreu empate
?- Tab = [o,x,o, x,x,o, b,o,x], empate(Tab).
Tab = [o, x, o, x, x, o, b, o, x]

5) faça uma consulta checando se a pos 3 do tabuleiro 
é vazia
?- Tab = [o,o,b, x,x,b, b,b,b], vazia(3, Tab).
Tab = [o, o, b, x, x, b, b, b, b]

6) mostre todos os movimentos para cruz no Tab=[b,o,x, b,b,b, b,b,b]?
?- Tab=[b,o,x, b,b,b, b,b,b], move([x, play,Tab],X). 
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [x, o, x, b, b, b, b, b, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, x, b, b, b, b, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, b, x, b, b, b, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, b, b, x, b, b, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, b, b, b, x, b, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, b, b, b, b, x, b]]
Tab = [b, o, x, b, b, b, b, b, b],
X = [o, play, [b, o, x, b, b, b, b, b, x]]


7) dado o Tab=[b,o,x, b,b,b, b,b,b], nextState retorna oque?
?- Tab=[b,o,x, b,b,b, b,b,b], nextState(P,Tab,S).
S = play,
Tab = [b, o, x, b, b, b, b, b, b]

8) o que faz o predicado Tab=[b,o,x, b,b,b, b,b,b],
move_aux(o,T/T1)?
T = [b|_1306],
T1 = [o|_1306],
Tab = [b, o, x, b, b, b, b, b, b]

9) como fazer o computador escolher jogada aletória?
10) (dificil) como mudar heuristica, 5=>3 canto=>2, =>1....
	
*/
