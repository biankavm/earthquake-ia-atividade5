%  Reasoning in Bayesian Networks

:- op(900, fy, not).			% prefix operator not

prob([X|Xs],Cond,P):- !,
	prob(X, Cond, Px),
	prob(Xs, [X|Cond],PRest),
	P is Px*PRest.
prob([], _, 1):- !.
prob(X, Cond, 1):-
	member(X,Cond), !.
prob(X, Cond, 0):-
	member(not X, Cond), !.
prob(not X,Cond, P):-
	prob(X, Cond, P0),
	P is 1 - P0.

% Use Bayes rule if condition involves a descendant of X

prob(X, Cond0, P):-
	deleteM(Y, Cond0, Cond),
	predecessor(X,Y), !, 		% Y is a descendant of X
	prob(X, Cond, Px),
	prob(Y,[X|Cond],PyGivenX),
	prob(Y, Cond, Py),
	P is Px*PyGivenX / Py.		% Assuming Py > 0

% Cases when condition does not involve a descendant

prob(X, _, P):-
	p(X, P), !.					% X is a root case - its probability is given 
prob(X, Cond, P):- !,
	findall((CONDi,Pi),p(X,CONDi,Pi),CPlist), % Conditions on parents
	sum_probs(CPlist, Cond, P).

% sum_probs

sum_probs([], _, 0).
sum_probs([(COND1,P1) | CondsProbs], COND, P):-
	prob(COND1,COND,PC1),
	sum_probs(CondsProbs,COND,PRest),
	P is P1*PC1 + PRest.

% predecessor

predecessor(X, not Y):- !,
	predecessor(X, Y).
predecessor(X,Y):-
	parent(X,Y).
predecessor(X,Z):-
	parent(X,Y),
	predecessor(Y,Z).

% utility predicates


deleteM(X,[X|L],L).
deleteM(X,[Y|L1],[Y|L2]):-
	deleteM(X,L1,L2).
