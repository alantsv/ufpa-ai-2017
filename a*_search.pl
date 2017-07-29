% Distance function
road(arad, zerind, 75).
road(arad, sibiu, 140).
road(arad, timisoara, 118).
road(zerind, oradea, 71).
road(oradea, sibiu, 151).
road(sibiu, fagaras, 99).
road(fagaras, bucharest, 211).
road(bucharest, giurgiu, 90).
road(bucharest, urziceni, 85).
road(urziceni, hirsova, 98).
road(urziceni, vaslui, 142).
road(hirsova, eforie, 86).
road(vaslui, lasi, 92).
road(lasi, neamt, 87).
road(sibiu, rimnicu, 80).
road(rimnicu, pitesti, 97).
road(rimnicu, craiova, 146).
road(pitesti, craiova, 138).
road(pitesti, bucharest, 101).
road(timisoara, lugoj, 111).
road(lugoj, mehadia, 70).
road(mehadia, dobreta, 75).
road(dobreta, craiova, 120).

% Heuristic function
h(arad, 	366).
h(mehadia,  241).
h(bucharest,  0).
h(neamt, 	234).
h(craiova, 	160).
h(oradea ,	380).
h(drobeta, 	242).
h(pitesti, 	100).
h(eforie ,	161).
h(rimnicu,  193).
h(fagaras, 	176).
h(sibiu ,	253).
h(giurgiu, 	 77).
h(timisoara,329).
h(iasi, 	226).
h(vaslui, 	199).
h(lugoj, 	244).
h(zerind, 	374).
h(hirsova, 	151).
h(urziceni,  80).

% Next function
next(X,Y,C):-road(X,Y,C);road(Y,X,C).

% Final state
end(bucharest).

% A* search
search(X,VIS,OPEN,CAM):- end(X),reverse(CAM,CAMr),write(CAMr),nl,!.
search(X,VIS,OPEN,CAM):-
				CAM=[G-Gn|_],
                findall(Y-Cf,(next(X,Y,C), h(Y,Ch),Cf is Gn+C+Ch, \+member(Y,VIS)),L),
                sort(2,<,L,Lo),Lo=[Yo-Co|_],
				VIS1=[Yo|VIS],
				next(X,Yo,Cy), Gy is Gn+Cy, CAM1=[Yo-Gy|CAM],
				search(Yo,VIS1,OPEN,CAM1).

% ?- search(arad,[arad],_,[arad-0]).


