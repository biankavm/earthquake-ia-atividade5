% Operador para negação lógica
:- op(900, fy, not).

% Definição de ancestrais na rede
parent(burglary, alarm).
parent(earthquake, alarm).
parent(alarm, johnCalls).
parent(alarm, maryCalls).

% Probabilidades a priori
p(burglary, 0.001).
p(earthquake, 0.002).

% Probabilidades condicionais de Alarm dado Burglary e Earthquake
p(alarm, [burglary, earthquake], 0.70).
p(alarm, [burglary, not earthquake], 0.01).
p(alarm, [not burglary, earthquake], 0.70).
p(alarm, [not burglary, not earthquake], 0.01).

% Probabilidades condicionais de JohnCalls dado Alarm
p(johnCalls, [alarm], 0.90).
p(johnCalls, [not alarm], 0.05).

% Probabilidades condicionais de MaryCalls dado Alarm
p(maryCalls, [alarm], 0.70).
p(maryCalls, [not alarm], 0.01).

% Probabilidade de conjunção
prob([X | Xs], Cond, P) :- !,
    prob(X, Cond, Px),
    prob(Xs, [X | Cond], PRest),
    P is Px * PRest.
prob([], _, 1) :- !.

% Probabilidade de um evento conhecido na condição
prob(X, Cond, 1) :- member(X, Cond), !.
prob(X, Cond, 0) :- member(not X, Cond), !.

% Probabilidade de uma negação
prob(not X, Cond, P) :- !,
    prob(X, Cond, PX),
    P is 1 - PX.

% Probabilidade condicional quando há descendente
prob(X, Cond0, P) :-
    delete(Y, Cond0, Cond),
    predecessor(X, Y), !,
    prob(X, Cond, PX),
    prob(Y, [X | Cond], PY_given_X),
    prob(Y, Cond, PY),
    P is PX * PY_given_X / PY.

% Probabilidade sem descendente envolvido
prob(X, _, P) :- p(X, P), !.
prob(X, Cond, P) :-
    findall((CondX, PX), p(X, CondX, PX), CPList),
    sum_probs(CPList, Cond, P).

% Soma ponderada de probabilidades condicionais
sum_probs([], _, 0).
sum_probs([(Cond1, P1) | Rest], Cond, P) :-
    prob(Cond1, Cond, PC1),
    sum_probs(Rest, Cond, PRest),
    P is P1 * PC1 + PRest.

% Ancestralidade na rede
predecessor(X, not Y) :- !, predecessor(X, Y).
predecessor(X, Y) :- parent(X, Y).
predecessor(X, Z) :-
    parent(X, Y),
    predecessor(Y, Z).

% Utilitários de lista
member(X, [X | _]).
member(X, [_ | T]) :- member(X, T).

delete(X, [X | T], T).
delete(X, [Y | T], [Y | R]) :- delete(X, T, R).


/** <examples>
1.Qual a probabilidade de John ligar, dado que houve um roubo?
?- prob(johnCalls, [burglary], P).
P = 0.059673000000000004
    
2.Qual a probabilidade de John ligar, dado que houve um terremoto?
?- prob(johnCalls, [earthquake], P).
P = 0.645

3.Qual a probabilidade de que o alarme dispare, dado que houve roubo e terremoto?
?- prob(alarm, [burglary, earthquake], P).
P = 0.7

4.Qual a probabilidade de que o alarme dispare, dado que não houve roubo nem terremoto?
?- prob(alarm, [not burglary, not earthquake], P).
P = 0.01

5.Qual a probabilidade de que John e Mary liguem, dado que o alarme disparou?
?- prob([johnCalls, maryCalls], [alarm], P).
P = 0.63

6.Qual a probabilidade de que houve um roubo, dado que John ligou? (inferência reversa via Bayes)
?- prob(burglary, [johnCalls], P).
P = 0.001
**/
