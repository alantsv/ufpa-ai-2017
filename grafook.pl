%% Busca Heuristica Russel x Norvig 
%% elf - 2017 
road(arad,zerind,75).
road(arad,sibiu,140).
road(arad,timisoara,118).
road(zerind,oradea,71).
road(oradea,sibiu,151).
road(sibiu,fagaras,99).
road(fagaras,bucharest,211).
road(bucharest,giurgiu,90).
road(bucharest,urziceni,85).
road(urziceni,hirsova,98).
road(urziceni,vaslui,142).
road(hirsova,eforie,86).
road(vaslui,lasi,92).
road(lasi,neamt,87).
road(sibiu,rimnicu,80).
road(rimnicu,pitesti,97).
road(rimnicu,craiova,146).
road(pitesti,craiova,138).
road(pitesti,bucharest,101).
road(timisoara,lugoj,111).
road(lugoj,mehadia,70).
road(mehadia,dobreta,75).
road(dobreta,craiova,120).
%%
h(arad,     366).	
h(mehadia, 	241).
h(bucharest,  0).	
h(neamt, 	  234). 
h(craiova, 	160).	
h(oradea ,	380). 
h(drobeta, 	242).	
h(pitesti, 	100). 
h(eforie ,	161). 	
h(rimnicu,  193).
h(fagaras, 	176).
h(sibiu,  	253).
h(giurgiu, 	 77). 	
h(timisoara,329). 
h(iasi, 	  226).	
h(vaslui, 	199). 
h(lugoj, 	  244). 	
h(zerind, 	374). 
h(hirsova, 	151).	
h(urziceni,  80).

%% ?- findall(X,h(_,X),L),sum_list(L,S).

prox(X,Y,C):-road(X,Y,C);road(Y,X,C).

% ?- busca(arad,[],[],Cam).
fim(bucharest).
%% Busca gulosa com heuristica fraca.
							% verificar se o X é o final e retorna o reverso do caminhho feito.
busca(X,VIS,OPEN,CAM, Res):- fim(X),reverse(CAM,Res),!.
							% Verifica todos as todas a partir do X e retorno-os na list L junto com o custo C.
busca(X,VIS,OPEN,CAM,Res):- findall(Y-C,(prox(X,Y,C), \+member(Y,VIS)),L),
                        % Ordena a lista L pelo custo C e retira o primeiro elemento, ou seja, o de menor custo.
    					sort(2,<,L,Lo),Lo=[Yo-Co|_], 
    					% Adiciona a cidade de menor custo na lista dos vistiados e no caminho.
						VIS1=[Yo|VIS], CAM1=[Yo|CAM],
    					% Recursivamente avalia as próxixas rotas.
						busca(Yo,VIS1,OPEN,CAM1,Res). 
% ?- busca(arad,[arad],_,[arad], Res).

%% busca gulosa 
							% verificar se o X é o final e retorna o reverso do caminhho feito.
busca1(X,VIS,OPEN,CAM, Res):- fim(X),reverse(CAM,Res),!.
							% Verifica todos as todas a partir do X e retorno-os na list L junto com a heuristica.
busca1(X,VIS,OPEN,CAM, Res):- findall(Y-C,(prox(X,Y,_), h(Y,C),\+member(Y,VIS)),L),
                         % Ordena a lista L pelo custo C e retira o primeiro elemento, ou seja, a de menor heuristica.
    					 sort(2,<,L,Lo),Lo=[Yo-Co|_], 
    					 % Adiciona a cidade de menor heuristaca na lista dos vistiados e no caminho.
						 VIS1=[Yo|VIS], CAM1=[Yo|CAM],
    					 % Recursivamente avalia as próxixas rotas.
						 busca1(Yo,VIS1,OPEN,CAM1, Res). 
% ?- busca1(arad,[arad],_,[arad], Res).


%% A* 
							% verificar se o X é o final e retorna o reverso do caminhho feito.
busca2(X,VIS,OPEN,CAM, Res):- fim(X),reverse(CAM,Res),!.
busca2(X,VIS,OPEN,CAM, Res):- 
				CAM=[G-Gn|_], % pega o custo passado g(n)
    			% Verifica todos as todas a partir do X e retorno-os na list L junto com a soma da heuristica
    			% e o custo.
                findall(Y-Cf,(prox(X,Y,C), h(Y,Ch),Cf is Gn+C+Ch, \+member(Y,VIS)),L),
    			% Ordena a lista L pelo custo C e retira o primeiro elemento, ou seja, a soma da heutistica e o custo.
                sort(2,<,L,Lo),Lo=[Yo-Co|_], 
    			% Adiciona a cidade de menor heuristaca na lista dos vistiados
				VIS1=[Yo|VIS], 
    			% Adiciona a cidade visitada caminho com a soma de custo da anterior e a da que foi selecionado
				prox(X,Yo,Cy), Gy is Gn+Cy, CAM1=[Yo-Gy|CAM],
                % Recursivamente avalia as próxixas rotas.
				busca2(Yo,VIS1,OPEN,CAM1, Res). 
% ?- busca2(arad,[arad],_,[arad-0], Res).

%%%
/**
EX: 

a) Modifique as versões busca/busca1 para retornar a distancia desde da
cidade inicial ate cada uma delas como abaixo.

b) comente os busca, escrevendo acima de cada linha o 
que a linha seguinte esta fazendo, começando com os parametros 
o que entra e sai   

busca(arad,[],[],Cam).
[zerind,oradea,sibiu,rimnicu,pitesti,bucharest]
Cam = [].

?- busca2(arad,[arad],_,[arad-0]).
[arad-0,sibiu-140,rimnicu-220,pitesti-317,bucharest-418]
true ;
false.

?- busca1(arad,[arad],_,[arad-0]).
[arad-0,sibiu-140,fagaras-239,bucharest-450]
**/
		
