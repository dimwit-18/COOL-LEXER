(* This is a testfile involving a valid stack implementation program from my 
* previous assignment. This is a fairly large program and involves many valid 
* lexical components
*)


(* Stack Implementation for NON-ZERO integers. 0 here is used as a terminating character. Hence, it cannot be given as input for this program *)

(* class for managing empty stack operations. These operations are again redefined for non- empty stack in class Edit_Stack*)
class Stack {

    isempty() : Bool {       -- empty stack. returns true
        true
    };

    top() : Int {            -- top stack. returns 0 i.e empty stack
        0
    };

    tail() : Stack {          -- tail of the stack (stack exculding head). In this case tail stack is empty
        self
    };

    push(x : Int) : Stack {   -- pushes x into the stack by creating a new object of type Edit_stack and calling calling init dispatch
        (new Edit_Stack).init(self, x)
    };

    pop() : Stack {         -- nothing to pop
          self
    };

};

class Edit_Stack inherits Stack {

    stack_top : Int;       -- top of the stack
    tail_stack : Stack;    -- remaining stack other than top

    isempty() : Bool {     -- not empty
        false
    };

    top() : Int {          -- return top
        stack_top
    };

    tail() : Stack {       -- return tail
        tail_stack
    };

    init(stk : Stack, x : Int) : Stack{  -- updates top and tail of the stack after pushing x to stack stk
      {
        stack_top <- x;
        tail_stack <- stk;
        self;
      }
    };

    pop() : Stack{ -- updates top and tail of the stack after popping
      {
        stack_top <- tail().top();
        tail_stack <- tail().tail(); 
      }
    };

}; 

class Main inherits IO {

    stk : Stack;       -- stack
    empty : Bool;      -- variable to check if it's the first operation of the program.

    print_stack(s : Stack) : Object {   -- prints the stack recursively
        if s.isempty() then
                out_string("\n")
        else {
        	if(s.top() = 0) then
        		out_string("\n")
        	else {
		        out_int(s.top());
		        out_string(" ");
		        print_stack(s.tail());
            }
            fi;
        }
        fi
    };

    main() : Object {
        let x : Int, option : Int, flag : Bool <- true in { 
            empty <- true;
            while(flag) loop {
                out_string("Choose an operation to perform:\n1. push\n2. pop\n3. top\n4. print\n5. isempty?\n6. Exit\n");
                option <- in_int();
                if (option = 1) then {    -- push an integer into the stack
                    out_string("Enter an Integer to be pushed\n");
                    x <- in_int();
                    if(empty) then {
                        stk <- (new Stack).push(x);
                        empty <- false;
                    }
                    else 
                        stk <- stk.push(x)
                    fi;
                    out_string("Given integer is successfully pushed\n");
                }

                else {
                    if(option = 4) then {    -- Print Stack
                        if(empty = true) then
                            out_string("Empty Stack!!\n")
                        else {
                            if(not(stk.top() = 0)) then {
                                out_string("Your\
                                 Stack\
                                  is \n");
                                print_stack(stk);
                            }
                            else
                                out_string("The Stack is empty!!\n")
                            fi;
                        }
                        fi;
                    }
                    else {
                        if (option = 3) then {   -- top of the stack
                            if(empty = true) then
                                out_string("Empty Stack!!\n")
                            else {
                                if(stk.top() = 0) then 
                                    out_string("Empty Stack!!\n")
                                else {
                                    out_string("Top of your Stack is \n");
                                    out_int(stk.top());
                                    out_string("\n");
                                }
                                fi;
                            }
                            fi;
                        }
                        else {   
                            if(option = 2) then {    -- pop the stack
                                if(empty = true) then
                                    out_string("Empty Stack!!\n")
                                else {
                                    if(stk.top() = 0) then
                                        out_string("Empty Stack!!\n")
                                    else {
                                        stk.pop();
                                        out_string("Pop operation is successful!!\n");
                                    }
                                    fi;
                                }
                                fi;
                            }
                            else{         
                                if(option = 5) then {   -- isempty stack?
                                    if(empty) then
                                        out_string("The Stack is empty!!\n")
                                    else {
                                    	if(stk.top()=0) then
                                    		out_string("The Stack is empty!!\n")
                                    	else
                                        	out_string("The Stack is not empty!!\n")
                                        fi;
                                    }
                                    fi;
                                }
                                else {      -- exit program
                                    flag <- false;
                                    out_string("exiting\n");
                                }
                                fi;
                            }
                            fi;
                        }
                        fi;
                    }
                    fi;
                }
                fi;
            }
            pool;
        }
    };

};
