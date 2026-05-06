sublist(Sublist, List) :-
    append(_, Rest, List),
    append(Sublist, _, Rest).
