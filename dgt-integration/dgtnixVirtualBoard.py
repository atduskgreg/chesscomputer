#!/usr/bin/python

import os
import sys
import select
import binascii
import socket
import os, os.path
import types
import time
import threading
from curses import ascii
import string
import array
init="false"

_DGTNIX_SEND_CLK        =binascii.a2b_hex("41")
_DGTNIX_SEND_BRD        =binascii.a2b_hex("42")
_DGTNIX_SEND_UPDATE     =binascii.a2b_hex("43")
_DGTNIX_SEND_UPDATE_BRD =binascii.a2b_hex("44")
_DGTNIX_SEND_SERIALNR =binascii.a2b_hex("45")
_DGTNIX_SEND_BUSADDRESS =binascii.a2b_hex("46")
_DGTNIX_SEND_TRADEMARK  =binascii.a2b_hex("47")
_DGTNIX_SEND_VERSION  =binascii.a2b_hex("4d")
_DGTNIX_SEND_UPDATE_NICE =binascii.a2b_hex("4b")
_DGTNIX_SEND_EE_MOVES   =binascii.a2b_hex("49")
_DGTNIX_SEND_RESET      =binascii.a2b_hex("40")

_DGTNIX_NONE            =binascii.a2b_hex("00")
## ALL FOLLOWING MESSAGES ARE BINARY & TO 128 !!
_DGTNIX_BOARD_DUMP      =binascii.a2b_hex("86")
_DGTNIX_BWTIME          =binascii.a2b_hex("8d")
_DGTNIX_FIELD_UPDATE    =binascii.a2b_hex("8e")
_DGTNIX_EE_MOVES        =binascii.a2b_hex("8f")
_DGTNIX_BUSADDRESS        =binascii.a2b_hex("90")
_DGTNIX_SERIALNR        =binascii.a2b_hex("91")
_DGTNIX_TRADEMARK       =binascii.a2b_hex("92")
_DGTNIX_VERSION         =binascii.a2b_hex("93")

_DGTNIX_EMPTY       =binascii.a2b_hex("00")
_DGTNIX_WPAWN       =binascii.a2b_hex("01")
_DGTNIX_WROOK       =binascii.a2b_hex("02")
_DGTNIX_WKNIGHT     =binascii.a2b_hex("03")
_DGTNIX_WBISHOP     =binascii.a2b_hex("04")
_DGTNIX_WKING       =binascii.a2b_hex("05")
_DGTNIX_WQUEEN      =binascii.a2b_hex("06")
_DGTNIX_BPAWN       =binascii.a2b_hex("07")
_DGTNIX_BROOK       =binascii.a2b_hex("08")
_DGTNIX_BKNIGHT     =binascii.a2b_hex("09")
_DGTNIX_BBISHOP     =binascii.a2b_hex("0a")
_DGTNIX_BKING       =binascii.a2b_hex("0b")
_DGTNIX_BQUEEN      =binascii.a2b_hex("0c")


def initBoard():
    board=array.array("c")
    for i in range(64):
        board.append(_DGTNIX_EMPTY)
    return board

def setPiece(board, line, column, piece):
    board[(line-1)*8 + column - 1]=piece
    
def getPiece(board, line, column):
    return board[(line-1)*8 + column - 1]

def printBoard(board):
    pr="   A B C D E F G H\n"
    for i in range(64):
        if (i%8)==0 and i != 0:
            pr += "|\n"
        if i%8 == 0:
            pr+= str(8 - i/8)
            pr+= " "
        c,d=pieceToChar(board[i])
        pr += "|%c" % c
    pr += "|\n"
    sys.stdout.write(pr)


def waitForInitialisationMessages(client):
    while init=="false":
        try:
            data=client.recv(1)
            manageMessage(client, data)
        except socket.error:
            print "client closed"
            return
        

        
def manageMessage(client, data):
    message =""
    global init
    if data !="":
        if data==_DGTNIX_SEND_BRD:
            message= "received DGTNIX_SEND_BRD"
            client.send(_DGTNIX_BOARD_DUMP)
            client.send(_DGTNIX_NONE)
            client.send(binascii.a2b_hex("43"))
            # the board is initially set to be empty
            for x in range(64):
                client.send(_DGTNIX_EMPTY)
        elif data==_DGTNIX_SEND_UPDATE_BRD:
            message= "received DGTNIX_SEND_UPDATE_BRD"
            sys.exit()
        elif data==_DGTNIX_SEND_SERIALNR:
            message= "received DGTNIX_SEND_SERIALNR"
            client.send(_DGTNIX_SERIALNR)
            client.send(_DGTNIX_NONE)
            client.send(binascii.a2b_hex("06"))
            client.send('0')
            client.send('.')
            client.send('0')
        elif data==_DGTNIX_SEND_BUSADDRESS:
            message= "received DGTNIX_SEND_BUSADDRESS"
            client.send(_DGTNIX_BUSADDRESS)
            client.send(_DGTNIX_NONE)
            client.send(binascii.a2b_hex("05"))
            client.send(binascii.a2b_hex("00"))
            client.send(binascii.a2b_hex("00"))
        elif data==_DGTNIX_SEND_TRADEMARK:
            message= "received DGTNIX_SEND_TRADEMARK"
            client.send(_DGTNIX_TRADEMARK)
            client.send(_DGTNIX_NONE)
            trademark="dgtnix virtual board, http://dgtnix.sourceforge.net/"
            client.send(chr(len(trademark)+3))
            client.send(trademark)
        elif data==_DGTNIX_SEND_VERSION:
            message= "received DGTNIX_SEND_VERSION"
            client.send(_DGTNIX_VERSION)
            client.send(_DGTNIX_NONE)
            client.send(binascii.a2b_hex("05"))
            client.send(binascii.a2b_hex("00"))
            client.send(binascii.a2b_hex("00"))
        elif data==_DGTNIX_SEND_UPDATE_NICE:
            message= "received DGTNIX_SEND_UPDATE_NICE"
        elif data==_DGTNIX_SEND_RESET:
            message= "received DGTNIX_SEND_RESET"
        elif data==_DGTNIX_SEND_UPDATE:
            print "received DGTNIX_SEND_UPDATE"
            init="true"
        ####################This message are not handled by dgtnix !
        elif data==_DGTNIX_SEND_EE_MOVES:
            print "received DGTNIX_SEND_EE_MOVES"
            print "this message is not handled by dgtnix"
            sys.exit()
        elif data==_DGTNIX_SEND_CLK:
            print "received DGTNIX_SEND_CLK"
            print "this message is not handled by dgtnix"
            sys.exit()
        else:
            message= "unrecognized message from dgtnix:%c" % data
            sys.exit()
        print message


def pieceToChar(piece):
    if piece == _DGTNIX_WPAWN :
        return   'P', "white pawn"
    elif piece == _DGTNIX_WROOK :
        return   'R', "white rook"
    elif piece == _DGTNIX_WKNIGHT :
        return   'N', "white knight"
    elif piece == _DGTNIX_WBISHOP :
        return   'B', "white bishop"
    elif piece == _DGTNIX_WKING :
        return   'K', "white king"
    elif piece == _DGTNIX_WQUEEN :
        return   'Q', "white queen"
    elif piece == _DGTNIX_BPAWN :
        return   'p', "black pawn"
    elif piece == _DGTNIX_BROOK :
        return   'r', "black rook"
    elif piece == _DGTNIX_BKNIGHT :
        return   'n', "black knight"
    elif piece == _DGTNIX_BBISHOP :
        return   'b', "black bishop"
    elif piece == _DGTNIX_BKING :
        return   'k', "black king"
    elif piece == _DGTNIX_BQUEEN :
        return   'q', "black queen"
    elif piece == _DGTNIX_EMPTY :
        return ' ', "empty"
    else:
        return 0, "error"

def toColumnLine(c, l):
    if ascii.isalpha(c) == False:
        print "invalid column"
        return -1,-1
    if ascii.isupper(c):
        cColumn = string.lower(c)
    else:
        cColumn = c
    column = ord(cColumn) - ord('a') 
    if column < 0 or column > 7 :
        print "invalid column"
        return -1,-1
    if ascii.isdigit(l) == False:
        print "invalid line"
        return -1,-1
    line = int(l) - 1
    line = 7 - line
    if line < 0 or line > 7:
        print "invalid line"
        return -1,-1
    return column, line

def charToPiece(char):
    if char == 'P':
        return    _DGTNIX_WPAWN, "white pawn"
    elif char == 'R':
        return    _DGTNIX_WROOK, "white rook"
    elif char == 'N':
        return    _DGTNIX_WKNIGHT, "white knight"
    elif char == 'B':
        return    _DGTNIX_WBISHOP, "white bishop"
    elif char == 'K':
        return    _DGTNIX_WKING, "white king"
    elif char == 'Q':
        return   _DGTNIX_WQUEEN, "white queen"
    elif char == 'p':
        return   _DGTNIX_BPAWN, "black pawn"
    elif char == 'r':
        return   _DGTNIX_BROOK, "black rook"
    elif char == 'n':
        return   _DGTNIX_BKNIGHT, "black knight"
    elif char == 'b':
        return   _DGTNIX_BBISHOP, "black bishop"
    elif char == 'k':
        return   _DGTNIX_BKING, "black king"
    elif char == 'q':
        return   _DGTNIX_BQUEEN, "black queen"
    elif char == 'd' or char == 'D':
        return _DGTNIX_EMPTY, "nothing"
    else:
        return 0, "error"

def manageStandardMove(c, board):
   
    if len (c) != 4:
        print "invalid command :%s " % c 
        return 0
    column_i, line_i = toColumnLine(c[0], c[1])
    if column_i == -1:
        return 0
    column_f, line_f = toColumnLine(c[2], c[3])
    if column_f == -1:
        return 0
    if getPiece(board, line_i+1, column_i+1) == _DGTNIX_EMPTY:
        print "move piece from %c%c impossible, the square is empty" % ( c[0], c[1])
        return 0
    piece = getPiece(board, line_i+1, column_i+1)
    msgRemove = "t"+chr(ord('a')+column_i)+str(8-line_i)
    if manageRemovePiece(msgRemove,board) == 0:
        return 0

    if getPiece(board, line_f+1, column_f+1) != _DGTNIX_EMPTY:
        msgRemove = "t"+chr(ord('a')+column_f)+str(8-line_f)
        manageRemovePiece(msgRemove,board) 

    piece, s  = pieceToChar(piece)
    msgAdd = piece + chr(ord('a')+column_f)+str(8-line_f)
    manageAddPiece(msgAdd, board)
    return 1

def manageRemovePiece(c, board):
    if len(c) != 3:
        print "invalid command"
        return 0
    column, line = toColumnLine(c[1], c[2])
    if column == -1:
        return 0
    position = column + line * 8
    if getPiece(board, line+1, column+1) == _DGTNIX_EMPTY:
        print "cannot take piece from %c%c, the square is empty" %(c[1], c[2])
        return 1
    piece, sPiece = pieceToChar(getPiece(board, line+1, column+1))
    print "Removing %s from %c%c" %(sPiece, c[1], c[2])
    client.send(_DGTNIX_FIELD_UPDATE)
    client.send(_DGTNIX_NONE)
    client.send(chr(5))
    client.send(chr(position))
    client.send(_DGTNIX_EMPTY)
    setPiece(board, line+1, column+1, _DGTNIX_EMPTY)
    return 1

def manageAddPiece(c, board):
    if len(c) != 3:
        print "invalid command"
        return 0
    piece, sPiece = charToPiece(c[0])
    if(piece == 0):
        print "invalid piece"
        return 0
    column, line = toColumnLine(c[1], c[2])
    if column == -1:
        return 0
    
    position = column + line * 8
    if getPiece(board, line+1, column+1) != _DGTNIX_EMPTY:
        print "cannot add piece on %c%c, the square is not empty!" %(c[1], c[2])
        return 2, column, line
    print "Adding %s on %c%c" %(sPiece, c[1], c[2])
    client.send(_DGTNIX_FIELD_UPDATE)
    client.send(_DGTNIX_NONE)
    client.send(chr(5))
    client.send(chr(position))
    client.send(piece)
    setPiece(board, line+1, column+1, piece)
    return 1

filename=""
print "**************************"
print "* dgtnix virtual board   *"
print "**************************"
if len(sys.argv) == 1:
    filename="/tmp/dgtnixBoard"
    print "Using default filename for socket(%s)" % filename
    print "(you can change it by passing the filename as first argument)"
    print "Use this name as the port for the dgtnixInit(const char *port) function"
elif len(sys.argv) == 2:
    filename= sys.argv[1]
    print "using %s filename for socket" % sys.argv[1]
else:
    print "usage:%s <exchangeFile>" % sys.argv[0]
    sys.exit()
    
if os.path.exists(filename):
    os.remove(filename)
try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(filename)
except socket.error, (errno, strerror):
    print "open->I/O error(%s): %s" % (errno, strerror)
    if os.path.exists(filename):
        os.remove(filename)
    sys.exit()

sock.listen(1)
while 1:
    print "Waiting for a client to connect on %s (Ctrl-c to quit)" % filename
    (client, address)=sock.accept()
    print "*Connected*"
    board=initBoard()
    waitForInitialisationMessages(client)
    savedCommands=""
    print "command mode(h for help)"
    try:
        while 1:
            sys.stdout.write("command:")
            c=sys.stdin.readline()
            c=c.strip('\n')
            for command in c.split(','):
                command=command.strip()
                result=1
                if command == "":
                    continue
                if command == "quit" or command == "q":
                    print "bye"
                    client.close
                    sys.exit()
                elif command == "help" or command == "h" or command =="?":
                    print "Here is a list of the implemented commands :"
                    print "   -h or help or ? : display this help"
                    print "   -q or quit : quit"
                    print "   -d or display : display the board"
                    print "   -c or commands : display previous commands"
                    print "   -add piece simply by typing the piece and the square"
                    print "     white pieces :K,Q,R,B,N,P"
                    print "     black pieces :k,q,r,b,n,p"  
                    print "     the square notation (as for example a8) is case independant"
                    print "     example, Qa8 add a white queen on a8 (if the square is free)"
                    print "   -t : take/remove a piece followed square "
                    print "     ta4 remove piece from a4 if exists example"
                    print "   -e2e4 : you can append move in the standard form "
                    print "          a piece 'take' will be generated and  "
                    print "          a second if the destination square is not empty "
                    print "          and then a piece add"
                    print ""
                    print "You can combine multiple commands by separating them with comma"
                    print "For example you can generate an initial position by typing :"
                    sys.stdout.write("Rh1, Ng1, Bf1, Ke1, Qd1, Bc1, Nb1, Ra1,")
                    sys.stdout.write("Ph2, Pg2, Pf2, Pe2, Pd2, Pc2, Pb2, Pa2,")
                    sys.stdout.write("rh8, ng8, bf8, ke8, qd8, bc8, nb8, ra8,")
                    sys.stdout.write("ph7, pg7, pf7, pe7, pd7, pc7, pb7, pa7\n")
                    print "Note that at the connection, the virtual board is clear of any piece."
                elif command == "display" or command == "d":
                    printBoard(board)
                elif command == "commands" or  command == "c":
                    print savedCommands
                    continue
                elif len(command) == 4:
                     result=manageStandardMove(command, board)
                elif command[0] == 't':
                    result=manageRemovePiece(command, board)
                else:
                    result=manageAddPiece(command, board)
                if result == 1:
                    if savedCommands == "":
                        savedCommands = command
                    else:
                        savedCommands=savedCommands + "," + command
    except (KeyboardInterrupt, SystemExit):
        client.close()
        if os.path.exists(filename):
            os.remove(filename)
        sys.exit()
        
