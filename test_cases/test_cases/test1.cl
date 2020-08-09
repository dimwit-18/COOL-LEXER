(**
* Test file for Valid operators, braces, paranthesis and invalid characters(tokens)
* in Cool programming language
*)

class Main inherits IO {

    i : Int <- 10;

    function(parameter : Int, flag : Bool) : Int{
            if  (flag = true) then
                parameter <- parameter + 1
            else
                parameter
            fi
    };

    main() : SELF_TYPE {
        {
            i <- i + i - 5 * 2 / 4;
            (new IO).out_string("hello!!\n");
            if (i < 10) then hello@IITH else hello => ~IITH fi;
            if (i <= 10) then out_string("This is relational operator!!\n") else self fi;
            if (i > 10 && i >= 11 || i % 2) then out_string("These are invalid operators!!|n") else self fi;
            #$^!`'>\  -- are invalid;
            		​ -- invalid. zero width space
            self;
        }
    };
};
