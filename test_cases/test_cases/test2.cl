(**
* Test file for Reserved words and Identifiers
* in Cool programming language
*)

class Main inherits IO {

    i : Int <- 10;

    function(parameter : Int, flag : Bool) : Int{
        let temp : Int <- 5 in {
            if  (not flag) then
                parameter <- parameter + 1
            else
                parameter
            fi;

            if (isvoid temp) then  temp else temp - 1 fi;
        }
    };

    main() : SELF_TYPE {
        {
           (new IO).out_string("hello!!\n");
            whIle (i <= 10) loop i <- i + 1 pool;
            Case i of 
                id1 : Int => i;
                id2 : Bool => i <- i + 1;
                id3 : String => i <- i + 2;
            esac
            these are object ids
            These Are Type Ids
            self; -- object id
        }
    };
};