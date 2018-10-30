Identify subsets of compound keys that have duplicates                                                                     
                                                                                                                           
Great question - thanks (this question demonstrates powerfull SAS(only?) functionality?)                                   
                                                                                                                           
  Two Solutions                                                                                                            
                                                                                                                           
     1. proc sort and view                                                                                                 
     2. Two pass moe efficient hash by                                                                                     
          Paul Dorfman                                                                                                     
          sashole@bellsouth.net (onend)                                                                                    
                                                                                                                           
github                                                                                                                     
https://tinyurl.com/yaad3vox                                                                                               
https://github.com/rogerjdeangelis/utl-identify-subsets-of-compound-keys-that-have-duplicates                              
                                                                                                                           
SAS Forum                                                                                                                  
https://tinyurl.com/y8uya89p                                                                                               
https://communities.sas.com/t5/SAS-Procedures/How-to-separate-and-store-unique-and-duplicate-records-in-two/td-p/172408    
                                                                                                                           
Identify subsets of compound keys that have duplicates                                                                     
                                                                                                                           
Given three keys id1, id2 and id3 identify where                                                                           
                                                                                                                           
id1 and id2 repeat                                                                                                         
id1 and id3 repeat                                                                                                         
id2 and id3 repeat                                                                                                         
id1, id2 and id3 unique                                                                                                    
                                                                                                                           
Do processing in the order above.                                                                                          
                                                                                                                           
INPUT                                                                                                                      
=====                                                                                                                      
                                                                                                                           
 WORK.HAVE total obs=7  |                                                                                                  
                        |                                                                                                  
  ID1    ID2    ID3     |  RULES                                                                                           
                        |                                                                                                  
   A      1      U      |  id1 and id2 repeat                                                                              
   A      1      V      |                                                                                                  
                                                                                                                           
   B      W      I      |  id1 and id3 repeat                                                                              
   B      X      I      |                                                                                                  
                                                                                                                           
   Y      6      Z      |  id2 and id3 repeat                                                                              
   Z      6      Z      |                                                                                                  
                                                                                                                           
   I      J      K      |  id1, id2 and id3 unique                                                                         
                                                                                                                           
OUTPUT                                                                                                                     
-----                                                                                                                      
                                                                                                                           
 WORK.WANT_VUE total obs=7                                                                                                 
                                                                                                                           
  ID1    ID2    ID3              GRP                                                                                       
                                                                                                                           
   A      1      U     id1 and id2 repeat                                                                                  
   A      1      V     id1 and id2 repeat                                                                                  
   B      W      I     id1 and id3 repeat                                                                                  
   B      X      I     id1 and id3 repeat                                                                                  
   Y      6      Z     id2 and id3 repeat                                                                                  
   Z      6      Z     id2 and id3 repeat                                                                                  
   I      J      K     id1, id2 and id3 unique                                                                             
                                                                                                                           
PROCESS                                                                                                                    
=======                                                                                                                    
                                                                                                                           
* split into dups and nondups on pairs of keys. Output of sort is input to next sort;                                      
                                                                                                                           
proc sort data=have  out=dups12 uniqueout= unq12 nouniquekey;by id1 id2;run;quit;                                          
proc sort data=unq12 out=dups13 uniqueout= unq13 nouniquekey;by id1 id3;run;quit;                                          
proc sort data=unq13 out=dups23 uniqueout= unq   nouniquekey;by id2 id3;run;quit;                                          
                                                                                                                           
* use a view it may be faster than a physical dataset;                                                                     
data want_vue / view=want_vue;                                                                                             
                                                                                                                           
set                                                                                                                        
   dups12(in=D12)                                                                                                          
   dups13(in=D13)                                                                                                          
   dups23(in=D23)                                                                                                          
   unq   (in=Unq)                                                                                                          
 ;                                                                                                                         
                                                                                                                           
select;                                                                                                                    
   when (D12)  grp='id1 and id2 repeat     ';                                                                              
   when (D13)  grp='id1 and id3 repeat     ';                                                                              
   when (D23)  grp='id2 and id3 repeat     ';                                                                              
   when (Unq)  grp='id1, id2 and id3 unique';                                                                              
end;                                                                                                                       
                                                                                                                           
run;quit;                                                                                                                  
                                                                                                                           
*                _              _       _                                                                                  
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _                                                                           
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |                                                                          
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |                                                                          
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|                                                                          
                                                                                                                           
;                                                                                                                          
                                                                                                                           
data have;                                                                                                                 
input (id1 id2 id3) (:$20.);                                                                                               
cards4;                                                                                                                    
A 1 U                                                                                                                      
A 1 V                                                                                                                      
B W I                                                                                                                      
B X I                                                                                                                      
Y 6 Z                                                                                                                      
Z 6 Z                                                                                                                      
I J K                                                                                                                      
;;;;                                                                                                                       
run;quit;                                                                                                                  
                                                                                                                           
*____             _                                                                                                        
|  _ \ __ _ _   _| |                                                                                                       
| |_) / _` | | | | |                                                                                                       
|  __/ (_| | |_| | |                                                                                                       
|_|   \__,_|\__,_|_|                                                                                                       
                                                                                                                           
;                                                                                                                          
                                                                                                                           
Using hashes, though, it can be done in just 2 passes against a completely disordered input file.                          
Note that below, the output is restructured to include the variables REP*                                                  
indicating which composite keys have got dupes and which have not:                                                         
                                                                                                                           
data have ;                                                                                                                
  input (ID1 ID2 ID3) (:$1.) ;                                                                                             
  cards ;                                                                                                                  
A 1 U                                                                                                                      
A 1 V                                                                                                                      
B W I                                                                                                                      
B X I                                                                                                                      
Y 6 Z                                                                                                                      
Z 6 Z                                                                                                                      
I J K                                                                                                                      
;                                                                                                                          
run ;                                                                                                                      
                                                                                                                           
%let grp = id1 id2, id1 id3, id2 id3, id1 id2 id3 ;                                                                        
%let rep = REP12 REP13 REP23 REP123 ;                                                                                      
                                                                                                                           
data want (drop = _:) ;                                                                                                    
  if _n_ = 1 then do ;                                                                                                     
    if 0 then set have ; * just var order: ID before REP ;                                                                 
    array rep &rep ;                                                                                                       
    dcl hash x () ;                                                                                                        
    x.definekey ("_i_") ;                                                                                                  
    x.definedata ("h") ;                                                                                                   
    x.definedone () ;                                                                                                      
    _g = "&grp" ; * set g-length ;                                                                                         
    do over rep ;                                                                                                          
      dcl hash h () ;                                                                                                      
      _g = scan ("&grp", _i_, ",") ;                                                                                       
      do _j = 1 to countw (_g) ;                                                                                           
        h.definekey (scan (_g, _j)) ;                                                                                      
      end ;                                                                                                                
      h.definedata ("_q") ;                                                                                                
      h.definedone () ;                                                                                                    
      x.add() ;                                                                                                            
    end ;                                                                                                                  
    do until (z) ;                                                                                                         
      set have end = z ;                                                                                                   
      do over rep ;                                                                                                        
        x.find() ;                                                                                                         
        if h.find() ne 0 then _q = 1 ;                                                                                     
        else                  _q + 1 ;                                                                                     
        h.replace() ;                                                                                                      
      end ;                                                                                                                
    end ;                                                                                                                  
  end ;                                                                                                                    
  set have ;                                                                                                               
  do over rep ;                                                                                                            
    x.find() ;                                                                                                             
    h.find() ;                                                                                                             
    rep = ifn (_q > 1, 1, 0) ;                                                                                             
  end ;                                                                                                                    
run ;                                                                                                                      
                                                                                                                           
The output would look like so:                                                                                             
                                                                                                                           
ID1 ID2 ID3 REP12 REP13 REP23 REP123                                                                                       
------------------------------------                                                                                       
A   1   U       1     0     0      0                                                                                       
A   1   V       1     0     0      0                                                                                       
B   W   I       0     1     0      0                                                                                       
B   X   I       0     1     0      0                                                                                       
Y   6   Z       0     0     1      0                                                                                       
Z   6   Z       0     0     1      0                                                                                       
I   J   K       0     0     0      0                                                                                       
                                                                                                                           
In fact, the code above is a bit slothful since the whole feat can be pulled by using two parms like:                      
                                                                                                                           
%let parm = 12 13 23 123 ;                                                                                                 
%let repv = REP ;                                                                                                          
                                                                                                                           
Best regards                                                                                                               
                                                                                                                           
