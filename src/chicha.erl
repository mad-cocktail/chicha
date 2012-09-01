-module(chicha).
-export([parse_transform/2]).


parse_transform(Forms, _Options) ->
    F  = fun search_operator/1,                                
    X = [postorder(F, Tree) || Tree <- Forms],                    
    io:format(user, "Before:\t~p\n\nAfter:\t~p\n", [Forms, X]),   
    X.                                                            
                                                              

left(X) ->
    erl_syntax:infix_expr_left(X).

right(X) ->
    erl_syntax:infix_expr_right(X).


-spec op_name(Tree) -> Op when
    Tree :: erl_syntax:syntaxTree(),
    Op :: string().
op_name(Tree) ->
    case node_type(Tree) of
        prefix_expr ->
            op_name(erl_syntax:prefix_expr_operator(Tree));
        infix_expr ->
            op_name(erl_syntax:infix_expr_operator(Tree));
        operator ->
            erl_syntax:operator_literal(Tree)
    end.

node_type(X) ->
    erl_syntax:type(X).


search_operator(Tree) ->
    Skip = Tree,
    case node_type(Tree) of
        infix_expr ->
            case is_fun_name_delim_operator(Tree) of
                true  -> replace_operator(Tree);
                false -> Skip
            end;
        _Type -> Skip
    end.

is_fun_name_delim_operator(Tree) ->
    Op = op_name(Tree),
    LT = node_type(left(Tree)),
    RT = node_type(right(Tree)),
    IsValidLT = LT =:= module_qualifier orelse LT =:= atom,
    {IsValidLT, Op, RT} =:= {true, "/", integer}.


replace_operator(Tree) ->
    Name  = left(Tree),
    Arity = right(Tree),
    copy_pos(Tree, erl_syntax:implicit_fun(Name, Arity)).


copy_pos(From, To) ->
    Pos = erl_syntax:get_pos(From),
    erl_syntax:set_pos(To, Pos).


postorder(F, Form) ->                                           
    NewTree =                                                   
        case erl_syntax:subtrees(Form) of                       
        [] ->                                                   
            Form;                                               
        List ->                                                 
            Groups = [handle_group(F, Group) || Group <- List], 
            Tree2 = erl_syntax:update_tree(Form, Groups),       
            Form2 = erl_syntax:revert(Tree2),                   
            Form2                                               
        end,                                                    
    F(NewTree).                                                 
                                                                
handle_group(F, Group) ->                       
    [postorder(F, Subtree) || Subtree <- Group].

