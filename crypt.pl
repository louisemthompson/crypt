% -*- mode: prolog -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FILE: crypt.pl
%
% NAME: Louise Thompson
%
% DATE: 2/5/2020
%
% DESCRIPTION: A prolog program to generate solutions to a
%              cryptarithmetic puzzle involving sums of digit lists.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% is_digit(+X)
is_digit(X) :-
    member(X, [0,1,2,3,4,5,6,7,8,9]).

% all_digits(+List)
all_digits([]).
all_digits([V|Rest]) :-
    is_digit(V), all_digits(Rest).

% unique(+List)
unique(List) :-
    list_to_ord_set(List, Set), length(List, L1), length(Set, L2),
    L1 = L2.

% dlist_to_num(+DList, ?Number)
% Convert a Dlist with all bound variables to an integer.
dlist_to_num([Digit], Digit) :- !.
dlist_to_num([Digit|Rest], ListInts) :-
    length(Rest, Power),
    Value is (10 ^ Power) * Digit,
    dlist_to_num(Rest, Almost),
    ListInts is Value + Almost.

% dlists_to_nums(+ListList, ?ListInts)
% Convert a list of Digit lists to a list of integers.
dlists_to_nums([],[]).
dlists_to_nums([Dlist|Rest], [Num|Others]) :-
    dlist_to_num(Dlist, Num),
    dlists_to_nums(Rest, Others).

% generate_set(+ListList, +Sum, ?Set)
% Generate the set of variables in the summation.
generate_set(ListList, Sum, Set) :-
    append(ListList, AlmostVarList),
    append(AlmostVarList, Sum, VarList),
    list_to_ord_set(VarList, Set), !.

% unlead_zero(+List)
% First digit is not a zero.
unlead_zero([First|_]) :- First =\= 0.

% list_unlead_zero(+ListList)
% All lists in list are unlead by a zero.
list_unlead_zero([]).
list_unlead_zero([List|Rest]) :-
    unlead_zero(List),
    list_unlead_zero(Rest).

% assign_nums(+ListList, +Sum)
% Assign integer values to variables in summation.
assign_nums(ListList, Sum) :-
    generate_set(ListList, Sum, Set),
    all_digits(Set),
    unique(Set),
    list_unlead_zero(ListList),
    unlead_zero(Sum).

% list_add(+List, ?Sum)
% Adds integers in a list.
list_add([], 0).
list_add([Int|Rest], Sum) :- list_add(Rest, Almost), Sum is Int + Almost.

% solve_sum(+ListList, +Sum)
solve_sum(ListList,Sum) :-
  assign_nums(ListList, Sum),
  dlists_to_nums(ListList, IntAddens),
  dlist_to_num(Sum, IntSum),
  list_add(IntAddens, IntSum).

% write_addends(+List)
% Writes integer addends.
write_addends([Int]) :- write(Int), put(32), !.
write_addends([Int|Rest]) :-
  write(Int), put(32), put(43), put(32),
  write_addends(Rest).

write_solution(ListList, Sum) :-
    % Writes a solved puzzle to the screen in an easily readable form:
    % e.g. write_solution([[2,8,1,7],[0,3,6,8]],[0,3,1,8,5])
    % produces: 2817 + 0368 = 03185  (followed by a newline)
    dlists_to_nums(ListList, IntList),
    dlist_to_num(Sum, IntSum),
    write_addends(IntList),
    put(61), put(32), write(IntSum), put(10).

solve_and_write(ListList,Sum) :-
    % Does just what it says.
    solve_sum(ListList,Sum),
    write_solution(ListList,Sum).


% Example usage:
% solve_and_write([[S,E,N,D],[M,O,R,E]],[M,O,N,E,Y])
