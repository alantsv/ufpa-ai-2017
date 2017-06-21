%%
% parameterização

geracoes(30). %% 100 
populacao(20).
populacaoCruza(18). %% para versão elitista
prob_cruza(0.7).
prob_mutacao(0.30). 
num_bits(38).  %% comossomo 
gene_bits(19). %% num_bits/2
%
f8(X,Y):-format(atom(Y),'~3f|', X). % ponto futuante 
fx(X,Y):-format(atom(Y),'~16R', X). % hexadecimal 
f2(X,Y):-format(atom(Y),'~2R', X). % hexadecimal 
%%

%% f(x) = x* sen(30.141516*x)+1, x={0..25}
%% f(x,y)=0.5 - ([sin(sqrt(x^2+y^2))]^2-0.5)/([1+0,001(x^2+y^2)]^2)
%% f(X,Y,Z):- Z is 0.5 - ((sin(sqrt(X^2+Y^2)))^2-0.5)/((1+0.001*(X^2+Y^2))^2).
%% ?- f(3,4,Z).
f(X,Y,Z):- Z is X*X*Y.
%% f(X,Y,Z):- Z is X*sin(X*10*3.141516)+1.
%%
%% ?- X is (2^19-1)/1000,X=Y, f(X,Y,Z).
%% ?- X is 2^19-1, f2(X,Y). 
%% ?- X is 2^19-1, f2(X,Y).
%% X = 524287, Y = '1111111111111111111'. 
%%
geraHum(C):- num_bits(N),lista_rand(C,2,N).
lista_rand( [],V,N):-N<1,!.
lista_rand([R|L],V,N):-N1 is N-1, R is random(V), lista_rand(L,V,N1).
random(X,N):- X is random(N)+1.
rand(N,R):- R is random(65000)/64999*N.
%%	

%% Algoritmo genetico
wPop(X):-var(X),!.
wPop([X|Xs]):-!,wInd(X),wPop(Xs). 
wPop([]):-nl,!.
wInd(V-X):-!,f8(V,V8),write(V8),write(' '),wInd(X). 
wInd(X):-get2dec(X,A,B), wcromo(A,B),nl.		 
wInd(X):-write(X),nl. 	
wcromo(X,Y) :- f8(X,X1),f8(Y,Y1),write(X1:Y1).
%%wcromo(X,Y) :- fx(X,X1),fx(Y,Y1),write(X1:Y1).		 
%%
%%
gera:- 
    populacao(NP),
    findall(C,(between(1,NP,_),geraHum(C)),Pop),
	wPop(Pop), 
	avalia_roleta(Pop,PopAv),
	geracoes(NG),
	gera_geracao(0/NG,PopAv/PopAv1),!.
		
avalia_roleta(Pop,PopOut):-
    aval_pop(Pop,PopAv),
	zipper(V1,P,PopAv),
	sumlist(V1,Sum),
	maplist(div(Sum),V1,V1s), % média ponderada 
	zipper(V1s,P,PopAv1), 	
	%%write(popav),wPop(PopAv1),nl,
	sort(1,>=,PopAv1,PopOrd), % ordena pop 
	write(popord),nl,wPop(PopOrd),nl,get0(CC),
	PopOrd=[_-X1,_-X2,_-X3,_-X4|_], 
	%%write('4 melhores, 2 prim = eletite:'),nl,
	aval_pop([X1,X2,X3,X4],[X1v,X2v,X3v,X4v]),%% nao roleta
	wInd(X1v),wInd(X2v),nl,
	%%wInd(X3v),wInd(X4v),nl, 
	PopOrd=PopOut.
avalia_roleta(_,_):- write(falhou:avalia),nl. 	
%		
gera_geracao(N/M,Pop/Pop1):-N>M,!,
	write('Geracao final'), write(N), write(':'), nl,
	wPop(Pop1), nl.
	
/*  
%%===========================================
%% sem elitismo 
gera_geracao(G/M,Pop/NOutx):-
	write('Geracao '), write(G), write('%%:'), nl,
	cruza(Pop,NPop1),     %% write(cruzou),nl, 
	mutacao(NPop1,NPop),  %% write(mutou),nl, 
	avalia_roleta(NPop,NOut), 
	G1 is G+1,
	gera_geracao(G1/M,NOut/NOutx).
*/	
%%==========================================
%% elitista salva 2 melhores 
%%  i) podemos reproduzir todos ou  
%%  ii) reproduzir todos menos elite  
%%      ver comentários 
%%==========================================
gera_geracao(G/M,Pop/NOutx):-
	write('Geracao '), write(G), write('%%:'), nl,
	[V1-X1,V2-X2|Xs]=Pop,   %% tira dois ind 
	zipper(Vss,Xss,Xs),     %% nao reproduz elite 
	%%zipper(Vss,Xss,Pop),    %% reproduzir todos  
	write('melhores ind sem elite'),nl,
	avalia_roleta(Xss,Xso), %% avalia novamente Soma=1
	%% write('##'),nl,wPop(Xs),get0(C),
	cruza(Xso,NPop1),       %% write(cruzou),nl, 
	mutacao(NPop1,NPop),    %% write(mutou),nl, 
	%%
	write('melhores ind com elite'),nl,
	avalia_roleta([X1,X2|NPop],NOut), 
	G1 is G+1,
	gera_geracao(G1/M,NOut/NOutx).
%%
%% Avaliacao dos Cromossomas
aval_pop(P,VP):- maplist(avalCromo,P,VP).
binDec(I,D) :- length(I,L),binDec(L,I,0/D).
binDec(E,[I|Is],D/Do) :- E1 is E-1, D1 is D+I*2^E1,binDec(E1,Is,D1/Do).	
binDec(_,[],Do/Do). 
avalCromo(X,V-X):-get2dec(X,A1,B1), f(A1,B1,V).
get2dec(Seq,A1,B1):- length(Seq,N), N1 is N // 2, length(A,N1),append(A,B,Seq),
		binDec(A,AD), binDec(B,BD),
%%		A1 is AD, B1 is BD. 
		A1 is AD/1000, B1 is BD/1000.       

%% ?- binDec([1,1,0,0,0,0,0,0],X).
%% ?- binDec([0,0,0,0,1,1,1,1],X).	
%% ?- avalCromo([1,0,1,1,0, 1,1,1,1,0,  1,1,1,1,1, 0,0,0,0],V).
%% ?- avalCromo([0,1,1,1,0, 1,1,1,1,0,  0,0,0,0,0, 0,0,0,0],V).
%% ?- get2dec([1,0,1,1,0, 1,1,1,1,0,  1,1,1,1,1, 0,0,0,0],V,V1).
%% ?- get2dec([0,1,1,1,0, 1,1,1,1,0,  0,0,0,0,0, 0,0,0,0],V,V1).
%

zipper([X|Xs],[Y|Ys],[X-Y|XYs]):- !,zipper(Xs,Ys,XYs).
zipper([],[],[]).
div(X,Y,YX):-YX is Y/X.
%% ?- maplist(div(2),[1,2,3],X). 
limpa(L,Lp):- zipper(_,Lp,L).
%% ?- limpa([1-a,2-b,3-c],L).
		
%% Operador de crossover 
cruza(P,Po):- populacaoCruza(N), Max is N, cruza1(Max,P,[]/Po). 
cruza1(N,_,Po/Po):-length(Po,N1), N1 >= N,!.
cruza1(N,P,Acc/Po):-
        roda_roleta(P,I1),roda_roleta(P,I2),
	    pontos_cruza(P1,P2),
	    prob_cruza(Pcruz), rand(1,Pc),
	   ((Pc =< Pcruz -> cruzar(I1,I2,P1,P2,NI1),
	                    cruzar(I2,I1,P1,P2,NI2))
		;(NI1=I1,NI2=I2)),
	    addList(NI1,Acc/Acc1),addList(NI2,Acc1/Acc2),
	    cruza1(N,P,Acc2/Po),!.
addList(X,L/Lo):- member(X,L),!,Lo=L;Lo=[X|L].	
%%    
%% ROLETA: usa soma cumulativa  		   
roda_roleta(Pop,I):- rand(1,X), getPop(X,Pop,I).
getPop(X,[V-I|VIs],I):- X=<V,!.
getPop(X,[V-I|VIs],Io):- Xi is X-V, getPop(Xi,VIs,Io).
getPop(X,[],_):-write(roleta_falhou). 
%% ?- roda_roleta([0.2-a,0.5-b,1-c],I).     
%			
cruzar(I1,I2,P1,P2,NInd):-
   length(I1,LN),
   sublist(I1,1,P1,A),  P21 is P2+1, 
   sublist(I1,P21,LN,C), P11 is P1+1, 
   sublist(I2,P11,P2,B),  
   append([A,B,C],NInd),!.
cruzar(X,Y,_,_,X):-write(cruzar_falhou). 	   
%
sublist(L,I,F,S):-sublist1(L,1,I/F,S).	  
sublist1(     _,N,I/F,[]     ):- N>F,!.
sublist1([X|Xs],N,I/F,    Xs1):- I>N,!,N1 is N+1,sublist1(Xs,N1,I/F,Xs1).
sublist1([X|Xs],N,I/F,[X|Xs1]):-     !,N1 is N+1,sublist1(Xs,N1,I/F,Xs1).
%%%%
/*
?- sublist([a,b,c,d,e,f],1,5,X).  X = [a, b, c, d, e].
?- sublist([a,b,c,d,e,f],5,5,X).  X = [e].
?- sublist([a,b,c,d,e,f],6,5,X).  X = [].
*/
% ?- cruzar([1,2,3,4,5,6,7],[a,b,c,d,e,f,g],2,5,X).
% ?- cruzar([a,b,c,d,e,f,g],[1,2,3,4,5,6,7],2,5,X).
% ?- cruzar([1, 0, 0, 1, 1, 1, 1, 0], [a,b,c,d,e,f,g], 2,4,X).
% ?- cruzar([1, 0, 1, 1, 0, 1, 1, 0], [a,b,c,d,e,f,g],3,6,X)	
%
%============================================================	
%% operador de mutacao 
%
mutacao([],[]):-!.
mutacao([Ind|Resto],[NInd|Resto1]):-
	prob_mutacao(Pmut), rand(1,Pm),
	((Pm < Pmut -> mutacao1(Ind,NInd));NInd=Ind),
	mutacao(Resto,Resto1),!.
mutacao(X,X):-write(mutacao:falhou:X),nl.

mutacao1(Ind,NInd):-
	pontos_cruza(P1,P2), %%  2 genes para serem trocados
	muta(Ind,P1,Ind1),
	muta(Ind1,P2,NInd).
muta(I1,P,NInd):-
   P0 is P-1, 
   length(I1,LN),!,
   sublist(I1,1,P0,A), !, P1 is P+1,  
   sublist(I1,P1,LN,C),!, 
   sublist(I1,P,P,[B]),!, 
   ((B=1,!,B1=0;B1=1)),
   append([A,[B1],C],NInd),!.
muta(X,_,X):-write(muta_falhou),nl.
%% ?-  muta([1,0,0,0,0,1],3,B).		

pontos_cruza(R1,R2):-
     num_bits(N),P1 is random(N)+1, P2 is random(N)+1, 
     ((P1<P2,!, R1=P1, R2=P2; 
      (P1>P2,!, R1=P2, R2=P1; 
       P1=P2,!, pontos_cruza(R1,R2)))). 
              
%% ?-  pontos_cruza(X,Y). 
