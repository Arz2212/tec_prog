% Тесты для задачи 4Б: проверка вхождения списка в список
:- consult('task4b.pl').

test_sublist :-
    format('=== Проверка вхождения (должны быть true) ===~n'),
    TrueCases = [
        ([1,2,3], [0,1,2,3,4,5]),
        ([1,2,3], [a,b,c,1,2,3,d]),
        ([1,2,3], [1,2,3]),
        ([], [1,2,3]),
        ([a], [a]),
        ([2,3], [1,2,3,4])
    ],
    forall(member((Sub, List), TrueCases),
        (   (sublist(Sub, List) -> Status = '✓ true ' ; Status = '✗ false')
        ,   format('  ~s: sublist(~w, ~w)~n', [Status, Sub, List])
        )),

    format('~n=== Проверка НЕвхождения (должны быть false) ===~n'),
    FalseCases = [
        ([1,2,3], [1,2]),
        ([1,2,3], [1,2,a,3]),
        ([1,2,3], [1,2,a,b,4,3]),
        ([1,2,3], [3,2,1]),
        ([a,b], [a])
    ],
    forall(member((Sub, List), FalseCases),
        (   (sublist(Sub, List) -> Status = '✗ true ' ; Status = '✓ false')
        ,   format('  ~s: sublist(~w, ~w)~n', [Status, Sub, List])
        )).

:- test_sublist.
