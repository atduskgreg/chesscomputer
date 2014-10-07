/*
  Stockfish, a UCI chess playing engine derived from Glaurung 2.1
  Copyright (C) 2004-2008 Tord Romstad (Glaurung author)
  Copyright (C) 2008-2014 Marco Costalba, Joona Kiiski, Tord Romstad

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <string> 
#include <sstream> 

#include "bitboard.h"
#include "evaluate.h"
#include "position.h"
#include "search.h"
#include "thread.h"
#include "tt.h"
#include "ucioption.h"


using namespace std;

std::string escapeJsonString(const std::string& input) {
    std::ostringstream ss;
    // for (auto iter = input.cbegin(); iter != input.cend(); iter++) {
    //C++98/03:
    for (std::string::const_iterator iter = input.begin(); iter != input.end(); iter++) {
        switch (*iter) {
            case '\\': ss << "\\\\"; break;
            case '"': ss << "\\\""; break;
            case '/': ss << "\\/"; break;
            case '\b': ss << "\\b"; break;
            case '\f': ss << "\\f"; break;
            case '\n': ss << "\\n"; break;
            case '\r': ss << "\\r"; break;
            case '\t': ss << "\\t"; break;
            default: ss << *iter; break;
        }
    }
    return ss.str();
}

int main(int argc, char* argv[]) {
  // std::cout << engine_info() << std::endl;

  std::stringstream fen;
  std::stringstream go;

  bool processingFen = false;
  bool processingGo = false;
  bool fenReceived = false;
  bool goReceived = false; 

  std::string fenKey = "position";
  std::string goKey = "go";
  int indexOfGo = 0;

  for(int i = 1; i < argc; i++){
    
    if(fenKey.compare(argv[i]) == 0){
      processingFen = true;
      processingGo = false;
      fenReceived = true;
    }
    else if(goKey.compare(argv[i]) == 0){
      processingFen = false;
      processingGo = true;
      goReceived = true;
      indexOfGo = i;
    } else {

      if(processingFen){
        fen << argv[i] << " ";
      }

      if(processingGo){
        go << argv[i] << " ";
      }
    }

  }

  if(!(fenReceived && goReceived)){
    std::cout << "Must provide both 'position' and 'go' arguments. Usage:" << std::endl;
    std::cout << "\t./stockfish position <fen string> go depth <search depth>" << std::endl;
    exit(1);
  } 

  std::cout << "fen: " << fen.str() << std::endl;
  std::cout << "go: " << go.str() << std::endl;
 
  UCI::init(Options);
  Bitboards::init();
  Position::init();
  Bitbases::init_kpk();
  Search::init();
  Pawns::init();
  Eval::init();
  Threads.init();
  TT.resize(Options["Hash"]);

  Position pos;
  pos.set(fen.str(), Options["UCI_Chess960"], Threads.main());

  // send the depth as an istringstream
  std::istringstream goArgs(argv[indexOfGo + 2]);
  Search::LimitsType limits;
  goArgs >> limits.depth;

  Search::StateStackPtr SetupStates;
  Threads.start_thinking(pos, limits, SetupStates);

  Threads.exit();
  
}
