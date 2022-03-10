%{

#include <stdio.h>


#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <set>
#include <iterator>

using namespace std;

int i , 
numarDeListe = 0,
numarDeObiecteImbricate = 0;

string OBIECT = "obiect";
string NUMAR = "numar";
string SIR = "sir";
string NULLVALUE = "null";
string BOOLEAN = "boolean";
string LISTA = "lista";
string RADACINA = "radacina";

int nrOfElements[100];
int isActive[100];
char current_object[100];
char headOfList[100];
char currentListMember[100];

vector <string> list;
map<string,set<string>> objectMap;
vector <string> objectList;

void insertValueInMap(map<string,set<string>> &myMap , string  &key , string & value){
        
    map<string,set<string>>::iterator it = myMap.find(key);

    if(it != myMap.end()){
        it->second.insert(value);
    }else{
        set<string> temp;
        temp.insert(value);
        myMap.insert(std::make_pair(key,temp));
    }
}

%}


%option noyywrap

startCollection "{"+
endCollection "}"
startList "["
endList "]"

semn [ -]?
cifra [0-9]
numar {semn}+{cifra}+\.?{cifra}?
sir "\""+[a-zA-Z0-9 ,*%#/:.;-]*"\""+
boolean "true"|"false"
obiect "\""+[a-zA-Z0-9]*"\""+":"+" "+
nullValue "null"


%x OBJECT VALUE LIST COLLECTION QUOTE

%%
<INITIAL>{startCollection}  {
    
    if(numarDeObiecteImbricate == 0){
        
        numarDeObiecteImbricate++;
        objectList.push_back(RADACINA);
    }
    BEGIN(COLLECTION);
}

<INITIAL>"["  {BEGIN(LIST); }

<INITIAL>{endCollection} { BEGIN(COLLECTION);}

<COLLECTION>{obiect} {
   
    strcpy(current_object,yytext);
}

<COLLECTION>","+" "*"\n"*"\t"*{startCollection}+ {
}

<COLLECTION>{startCollection} {
    
    insertValueInMap(objectMap,objectList.back(),OBIECT);
    
    numarDeObiecteImbricate++;
    
    objectList.push_back(current_object);
}

<COLLECTION>{startList} {
   
    numarDeListe++;
    nrOfElements[numarDeListe] = 0;
    insertValueInMap(objectMap,objectList.back(),LISTA);
    strcpy(headOfList, current_object);
    list.push_back(current_object);
    
    BEGIN(LIST);
}

<COLLECTION>{sir} {
   
    insertValueInMap(objectMap,objectList.back(),SIR);
}

<COLLECTION>{numar} {
   
     insertValueInMap(objectMap,objectList.back(),NUMAR);
}

<COLLECTION>{nullValue} {
    
     insertValueInMap(objectMap,objectList.back(),NULLVALUE);
}

<COLLECTION>{boolean} {
   
     insertValueInMap(objectMap,objectList.back(),BOOLEAN);
}

<COLLECTION>{endCollection} {
   
    string s2;
    s2 = objectList.back();
   
    auto setString = objectMap.find(s2);
    set<string> ssset = setString->second;
    int j = 0 ,
        sizeOfObjectList = objectList.size() - 1;
    
    for(auto s1 = objectList.begin(); s1 != objectList.end(); s1++){
        if(j == sizeOfObjectList){
        
            cout << *s1 << " contine: ";
            break;
        }
        cout << *s1 << "-> " ; 
        j++;
    }
    
    for(auto stringContor = ssset.begin(); stringContor != ssset.end(); ++stringContor){
        cout << *stringContor << " ,";
    }
    cout << endl;
    numarDeObiecteImbricate--;
   
    objectMap.erase(objectList.back());
    objectList.pop_back();
   
    if(!s2.empty()   && !list.empty()){
        if(s2.find(list.back()) < s2.size()){
             
            nrOfElements[numarDeListe]++;
            printf(" numarul din lista actuala este = %d \n" , nrOfElements[numarDeListe]);
            
            string numarDeElemente = to_string(nrOfElements[numarDeListe]);
            string aux = list.back() + "[" + numarDeElemente + "]";
            
            objectList.push_back(aux);
        }
    }
}

<COLLECTION>{endList} {
   
     numarDeListe--;
   
     objectList.pop_back();
     list.pop_back();
}

<LIST>{startCollection} {
   
    isActive[numarDeListe] = 1;
  
    string numarDeElemente = to_string(nrOfElements[numarDeListe]);
    string aux = list.back() + "[" + numarDeElemente + "]";
    objectList.push_back(aux);

    BEGIN(COLLECTION);
}

<LIST>{numar}" "*","? {
       
        nrOfElements[numarDeListe]++;   
}


<LIST>{endList} {
   
    numarDeListe--;
    list.pop_back();
    
    BEGIN(COLLECTION);
 }

<LIST>.|\n ;
<COLLECTION>.|\n ;

.|\n ;
%%


int main(int argc , char **argv){
   
   yyin = fopen(argv[1], "r");
   if(!yyin){
       printf("eroare");
   }

    yylex();

   return 0;
}