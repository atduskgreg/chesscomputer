from glob import glob
import re

with open("chess-moves-data.csv", "wb") as outfile:
    outfile.write("AllMoves\tBlack\tBlackElo\tDate\tECO\tEvent\tEventDate\tPlyCount\tResult\tRound\tSite\tWhite\tWhiteElo\n")
    for filename in sorted(glob("*.PGN")):
        record = {}
        with open(filename, "rb") as infile:
            game_string = ""
            for i, line in enumerate(infile):
                if "." in line and ("[" not in line and "]" not in line):
                    game_string += line.replace("\n", " ")
                    
                if "[Event " in line:
                    if record != {}:
                        if "FEN" in record.keys():
                            del record["FEN"]
                        if "SetUp" in record.keys():
                            del record["SetUp"]
                        if "Remark" in record.keys():
                            del record["Remark"]
                        if "MovePly" in record.keys():
                            del record["MovePly"]
                        if "Annotator" in record.keys():
                            del record["Annotator"]
                        if "Source" in record.keys():
                            del record["Source"]
                        if "PresId" in record.keys():
                            del record["PresId"]
                        if "open]" in record.keys():
                            del record["open]"]
                        
                        if sorted(record.keys()) != ['Black', 'BlackElo', 'Date', 'ECO',
                                                     'Event', 'EventDate', 'PlyCount',
                                                     'Result', 'Round', 'Site',
                                                     'White', 'WhiteElo']:
                            print "key error (", len(record.keys()), "keys)", sorted(record.keys())
                            continue
                        
                        all_moves = []
                        for move_list in [x.split() for x in re.sub("\{[^)]*\}", "", game_string).split(".")][1:]:
                            all_moves.append(move_list[:2])
                        
                        record["AllMoves"] = "|".join([item for sublist in all_moves for item in sublist])
                        
                        out_str = ""
                        for column in sorted(record.keys()):
                            out_str += "%s\t" % (record[column])
                        outfile.write(out_str[:-1] + "\n")
                    
                        record = {}
                        game_string = ""

                if "[" in line and " \"" in line:
                    sline = line.split(" \"")
                    try:
                        record[sline[0].strip("[")] = sline[1].strip().strip("]").strip("\"").replace("\t", " ")
                    except:
                        print "error with:", sline


