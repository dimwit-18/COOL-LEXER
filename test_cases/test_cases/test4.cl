(**
* testfile for comments and whitespaces
* in Cool programming language
*)

class Main {
	main():IO {
		new IO.out_string("Hello world!\n")
	 -- hello this is a small program to test for comments and whitespaces. 

   -- This is a single line comment and is not tokenized

    (* this is a  
           (*
      (* nested comment 
         *)     and is a valid comment but not tokenized
                                    *)
                                       *)

    (* 
        this one shows unmatched 
                multi_line_comment terminator *)
                 *) 
                 
     (* (* 
        This is an example of EOF in comment *)

	};
};