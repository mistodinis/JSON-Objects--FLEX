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

semn [ -]?
cifra [0-9]
numar {semn}+{cifra}+\.?{cifra}?
sir "\""+[a-zA-Z0-9 ,*%#/:.;-]*"\""+
boolean "true"|"false"
obiect "\""+[a-zA-Z0-9]*"\""+":"+" "+
startList "["
endList "]"
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
    // printf("%s \n", yytext);
    strcpy(current_object,yytext);
    // printf(" %s  === curObj  ==== COL obj\n" ,current_object);
    
   
}
<COLLECTION>","+" "*"\n"*"\t"*{startCollection}+ {
    // printf("here\n");
}

<COLLECTION>{startCollection} {
    insertValueInMap(objectMap,objectList.back(),OBIECT);
    numarDeObiecteImbricate++;
    // cout << "Object pushed.. " << current_object << " == COL startColection\n"; 
     objectList.push_back(current_object);
}

<COLLECTION>{startList} {
    numarDeListe++;
    // printf("nr liste = %d === COL -startList \n"  , numarDeListe);
    nrOfElements[numarDeListe] = 0;
    insertValueInMap(objectMap,objectList.back(),LISTA);
    strcpy(headOfList, current_object);
    list.push_back(current_object);
    // printf("headOfList = %s == Col - startList" , headOfList);
    BEGIN(LIST);
}


<COLLECTION>{sir} {
    // printf("%s \n ", yytext);
    insertValueInMap(objectMap,objectList.back(),SIR);
    }

<COLLECTION>{numar} {
    // printf("%s sirLAW\n ", yytext);
     insertValueInMap(objectMap,objectList.back(),NUMAR);

}
<COLLECTION>{nullValue} {
    // printf("%s sirLAW\n ", yytext);
     insertValueInMap(objectMap,objectList.back(),NULLVALUE);

}
<COLLECTION>{boolean} {
    //  printf("%s sirLAW\n ", yytext);
     insertValueInMap(objectMap,objectList.back(),BOOLEAN);

}

<COLLECTION>{endCollection} {
   
   
    // map<string, set<string>>::iterator it;
    string s2;
    
    s2 = objectList.back();
    
    // cout << "==================\n";
   

    // cout << s2 << endl;
    auto setString = objectMap.find(s2);
    set<string> ssset = setString->second;
    int j = 0 , sizeOfObjectList = objectList.size() - 1;
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
    // printf("Deleting.. %s  === COL endColection " , objectList.back());
    // cout << "Deleting.. " << objectList.back() << " === COL endColections\n";
    objectList.pop_back();
    // printf("%d \n" , objectMap.size());
    if(!s2.empty()   && !list.empty()){
        if(s2.find(list.back()) < s2.size()){
        nrOfElements[numarDeListe]++;
        printf(" numarul din lista actuala este = %d \n" , nrOfElements[numarDeListe]);
        // currentListMember = strcat(headOfList, "[");
        // currentListMember = strcat(currentListMember , itoa(nrOfElements[numarDeListe] - 1));
        // currentListMember = strcat(currentListMember, "]");
        // cout << list.back() << " LIST - startCol \n";
    // cout  << "Object pushed.. " << list.back() << " COL - endColection\n"; 
         string numarDeElemente = to_string(nrOfElements[numarDeListe]);
         string aux = list.back() + "[" + numarDeElemente + "]";
        objectList.push_back(aux);
        }
    }
 
   
    // BEGIN(INITIAL);
    
}

<COLLECTION>{endList} {
    //  printf("%d \n" , nrOfElements[numarDeListe]);
     numarDeListe--;
    // printf("nr liste = %d === COL - endList\n"  , numarDeListe);

     objectList.pop_back();
     list.pop_back();
    //  BEGIN(INITIAL);
}

<LIST>{startCollection} {
    // nrOfElements[numarDeListe]++;
    // printf("%d \n" ,nrOfElements[numarDeListe]);
    isActive[numarDeListe] = 1;
    // currentListMember = strcat(headOfList, "[");
    // currentListMember = strcat(currentListMember , itoa(nrOfElements[numarDeListe] - 1));
    // currentListMember = strcat(currentListMember, "]");
        // cout << "Object adding.. "<<list.back() << " LIST - startCol \n";
        string numarDeElemente = to_string(nrOfElements[numarDeListe]);
         string aux = list.back() + "[" + numarDeElemente + "]";
    objectList.push_back(aux);

    BEGIN(COLLECTION);
}

<LIST>{numar}" "*","? {
        nrOfElements[numarDeListe]++;
        // printf("numar " );
        
}
<LIST>{sir}" "*"," {
    //  printf("%s \n sirLaw" , yytext);
}
<LIST>{nullValue}" "*"," {
    //  printf("%s \n " , yytext);
}
<LIST>{obiect} {
    //  printf("obiect \n");
 }

<LIST>{endList} {
    //  printf("%d \n" , nrOfElements[numarDeListe]);
     numarDeListe--;
    // printf("nr liste = %d ===List_ endList\n"  , numarDeListe);
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