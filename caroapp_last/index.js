const express = require("express");
const bodyParser = require("body-parser");
const session = require("express-session");
const Passport = require("passport");
const LocalStrategy = require("passport-local").Strategy;
const jwt = require("jsonwebtoken");
const app = express();

const USER = require("./db");
const { hash, getToken, verifyToken } = require("./lib/crypto");

app.use("/assets", express.static(__dirname + "/public"));
app.use(express.static(__dirname + "/views/dist"));
app.set("view engine", "ejs");

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
    secret: "mysecret",
    cookie: {
        maxAge: 1000*60*30
    }
}))
app.use(Passport.initialize());
app.use(Passport.session());

// Cuong
const {USER_ROUTE} = require('./routers/User');
app.use('/user', USER_ROUTE);


const http = require("http").createServer(app);
const io = require("socket.io")(http);


app.get('/swagger', (req, res) => {
  res.render('dist/index');
})

app.get("/private", (req, res) => {
    if (req.isAuthenticated()) {
        res.send("Welcome to private page");
    }
    else res.send("Please Login!");
})

app.get("/", (req, res) => {
    if (req.isAuthenticated()) res.render("index");
    else res.redirect("login");
});

app.get("/login", (req, res) => res.render("login"));

app.route("/api/login")
.get((req, res) => {
    res.status(200).json({status: false})
})
.post((req, res, next) => {
    Passport.authenticate('local', (err, user, info) => {
        if (err) return next(err);
        if (!user) return res.status(200).json({status: false, msg: "The username or password is incorrect!"})
        req.logIn(user, (err) => {
            if (err) return next(err);
            return res.status(200).json({
                status: true,
                msg: "Login Successfully",
                data: {
                    username: user.username,
                    fullname: user.fullname,
                    score: user.score,
                    access_token: getToken(user.username)
                }
            })
        })
    })(req, res, next);
});

app.get("/api/ranking", (req, res) => {
    try {
        USER.findAll({raw: true})
        .then((arrusers) => {
            let arr = [];
            // keysSorted = arrusers.sort((a, b) => a.score < b.score);
            keysSorted = arrusers.sort((a, b) => (a.score < b.score) ? 1 : -1);
            keysSorted.forEach((user) => {
                arr.push({
                    username: user.username,
                    fullname: user.fullname,
                    email: user.email,
                    score: user.score
                })
            })
            res.status(200).json({
                status: true,
                data: arr
            })
        });
    } catch (error) {
        res.status(200).json({
            status: false,
            msg: "Server is overloaded, please come back later!"
        })
    }
});


Passport.use(new LocalStrategy(
    (username, password, done) => {
        USER.findOne({
            raw: true,
            where: {
                username: username,
                password: hash(password)
            }
        }).then(user => {
            if (user) {
                return done(null, user);
            }
            return done(null, false);
        });
    }
))

Passport.serializeUser((user, done) => {
    done(null, user.username);
})

Passport.deserializeUser((name, done) => {
    USER.findOne({
        raw: true,
        where: {
            username: name 
        }
    }).then(user => {
        let userRecord = user;
        if (userRecord) return done(null, userRecord);
        return done(null, false);
    });
})





let arrUsers = [];
let arrRooms = [];
let boardSize = 10;
let dataRoom = {};



Array.matrix = (n, x) => {
    let Matrix = [];
    for (let i = 0; i < n; i++) {
        a = [];
        for (let j = 0; j < n; j++) {
            a[j] = x;
        }
        Matrix[i] = a;
    }
    return Matrix;
}
// socket.io

io.on("connection", function(socket){
    let userName;
    let totalTurns = 0;
    let chessBoard;
    let myroom = "";
    boardSize = 10;

    socket.auth = false;
    socket.on('authenticate', (data) => {
        console.log("1 nguoi vua Authen");
        if (arrUsers.indexOf(data.username) == -1) {
            socket.auth = true;
            console.log("Authenticated socket ", socket.id);
            console.log("Have a new connection: " + socket.id);
            socket.userName = userName = data.username;
            arrUsers.push(socket.userName);
            console.log("USERS ONLINE: ", arrUsers);
            io.sockets.emit("server-send-arrUsers", {
                status: true,
                msg: "There is a new person online",
                data: {users: arrUsers}
            });
        }
    });
   
    setTimeout(function(){
      //sau 1s mà client vẫn chưa dc auth, lúc đấy chúng ta mới disconnect.
      console.log("SOCKET AUTH: ",socket.auth);
      if (!socket.auth) {
        console.log("Disconnecting socket ", socket.id);
        socket.disconnect('unauthorized');
      }
    }, 1000);
    

    socket.on("disconnect", () => {
        console.log(socket.id + " was disconnected");
        
        socket.gamereSults = -1;
        io.sockets.in(myroom).emit("server-send-data", {
            loser: socket.userName
        });

        console.log("arr: ", arrRooms);
        console.log("myroom: ", myroom);

        if (arrRooms.indexOf(myroom) >= 0)
            arrRooms.splice(arrRooms.indexOf(myroom), 1);
            console.log("arr2: ", arrRooms);
        io.sockets.emit("server-send-arrRooms", {
            arrrooms: arrRooms,
            status: true
        });
        
        if (arrUsers.indexOf(socket.userName) >= 0) {
            arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
            socket.broadcast.emit("server-send-arrUsers", {
                status: true,
                msg: "There is one person already offline",
                data: {users: arrUsers}
            });
        }

        console.log("Disconnect: USERS ",arrUsers);

        socket.leave(myroom);

        delete dataRoom[myroom];
        myroom = "";
    });

    socket.on("client-send-logout", () => {
        console.log(socket.id + " was disconnected");
        
        socket.gamereSults = -1;
        io.sockets.in(myroom).emit("server-send-data", {
            loser: socket.userName
        });
        
        if (arrRooms.indexOf(myroom) >= 0)
            arrRooms.splice(arrRooms.indexOf(myroom), 1);
        io.sockets.emit("server-send-arrRooms", {
            arrrooms: arrRooms,
            status: true
        });

        console.log("Before:",arrUsers);

        if (arrUsers.indexOf(socket.userName) >= 0) {
            arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
            socket.broadcast.emit("server-send-arrUsers", {
                status: true,
                msg: "There is one person already offline",
                data: {users: arrUsers}
            });
        }

        console.log("After:,",arrUsers);
        // arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
        // socket.broadcast.emit("server-send-arrUsers", {
        //     status: true,
        //     msg: "There is one person already offline",
        //     data: {users: arrUsers}
        // });


        socket.leave(myroom);

        delete dataRoom[myroom];
        myroom = "";
    });

    io.sockets.emit("server-send-arrRooms", {
        status: true,
        data: {rooms: arrRooms}
    });
    
    socket.on("client-send-createRoom", (data) => {
        if (typeof myroom === 'undefined' || myroom === "") {
            if (verifyToken(data.token, data.username)) {
                myroom = data.idroom;
                socket.join(data.idroom);
                console.log(socket.adapter.rooms);

                arrRooms = [];
                for (r in socket.adapter.rooms) {
                    if (r.length === 6) arrRooms.push(r);
                }

                // add object turn for dataRoom
                dataRoom[myroom] = [1, 0];
                
                socket.emit("server-send-gamer", {
                    status: true,
                    data: { gamer: 1}
                });

                console.log("arrrooms: ", arrRooms);
                io.sockets.emit("server-send-arrRooms", {
                    status: true,
                    data: {rooms: arrRooms}
                });
            }
            else {
                socket.emit("server-send-hack", {
                    status: false,
                    msg: "You are unauthorized access. Please log in again."
                })
            }
        }
        else {
            socket.emit("server-send-existRoom", {
                status: true,
                data: { myroom: myroom }
            });
        }
    });

    socket.on("client-send-joinRoom", (data) => {
        if (myroom == "" && socket.adapter.rooms[data.idroom].length < 2) {
            if (verifyToken(data.token, data.username)) {
                socket.join(data.idroom);
                myroom = data.idroom;
                chessBoard = Array.matrix(boardSize, 0);
                socket.gamereSults = -1;
                totalTurns = 0;
                
                if (arrRooms.indexOf(myroom) >= 0)
                    arrRooms.splice(arrRooms.indexOf(myroom), 1);
                io.sockets.emit("server-send-arrRooms", {
                    status: true,
                    data: { rooms: arrRooms }
                });

                socket.emit("server-send-gamer", {
                    status: true,
                    data: { gamer: 2}
                });

                io.sockets.in(myroom).emit("server-send-matched", {
                    status: true,
                    data: { matrix: chessBoard }
                });
            }
            else {
                socket.emit("server-send-hack", {
                    status: false,
                    msg: "You are unauthorized access. Please log in again."
                })
            }
        }
        else {
            socket.emit("server-send-enoughRoom");
        }
    });

    socket.on("client-send-closeRoom", () => {
        // io.sockets.in(myroom).emit("server-send-closeRoom");

        socket.leave(myroom);
        console.log(socket.adapter.rooms);
        if (arrRooms.indexOf(myroom) >= 0)
            arrRooms.splice(arrRooms.indexOf(myroom), 1);
        io.sockets.emit("server-send-arrRooms", {
            status: true,
            data: { rooms: arrRooms }
        });

        delete dataRoom[myroom];
        myroom = "";
    });

    socket.on("client-send-play", (data) => {
        console.log("send-data",data);
        console.log("gamer: ", data.gamer);
        console.log("dataRoom: ", dataRoom);
        if (dataRoom[myroom][data.gamer-1] === 1) {
            let mark = data.gamer;
            let x = data.x;
            let y = data.y;
            chessBoard = data.matrix;
            socket.gamereSults = -1; //CHUOI
            if (check_existMark(chessBoard, x, y, mark)) {
                socket.emit("server-send-checkExistMark");
            }
            else {
                totalTurns++;
                chessBoard[y][x] = mark;
                console.log("Total: ", totalTurns);
                if (totalTurns >= 50) socket.gamereSults = 0;
                if (check_Horizontal(chessBoard, x, y, mark) || check_Vertical(chessBoard, x, y, mark) || check_DiagonalMain(chessBoard, x, y, mark) || check_DiagonalSub(chessBoard, x, y, mark)) {
                    socket.gamereSults = 1;
                }
                // chessBoard = extendAroundCenter(x,y,boardSize,chessBoard);
                // Swap turn
                let tmp = dataRoom[myroom][0];
                dataRoom[myroom][0] = dataRoom[myroom][1];
                dataRoom[myroom][1] = tmp;

                io.sockets.in(myroom).emit("server-send-data", {
                    name: data.username,
                    matrix: chessBoard,
                    x: x,
                    y: y,
                    mark: mark,
                    total: totalTurns,
                    game: socket.gamereSults
                });
            }
        }
        else {
            socket.emit("server-send-checkTurn");
        }
    });

    socket.on("client-send-resetResult", () => {
        socket.gamereSults = -1;
    });

    socket.on("client-send-score-win", (data) => {
        console.log("WINNER: ",data.username)
        if (verifyToken(data.token, data.username)) {
            let curScore = 0;
            USER.findOne({raw: true, where: {username: data.username}})
            .then((user) => {
                curScore = user.score + 1;
                USER.update({
                    score: curScore
                },{
                    where: {username: data.username}
                })
                .then(row => console.log("Update win: ", row));
            });
        }
        else {
            socket.emit("server-send-hack", {
                status: false,
                msg: "You are unauthorized access. Please log in again."
            })
        }
    });

    socket.on("client-send-score-lose", (data) => {
        console.log("LOSER: ",socket.username)
        if (verifyToken(data.token, data.username)) {
            let curScore = 0;
            USER.findOne({raw: true, where: {username: data.username}})
            .then((user) => {
                curScore = user.score - 1;
                USER.update({
                    score: curScore
                },{
                    where: {username: data.username}
                })
                .then(row => console.log("Update lose: ", row));
            });
        }
        else {
            socket.emit("server-send-hack", {
                status: false,
                msg: "You are unauthorized access. Please log in again."
            })
        }
    });
});


function check_Horizontal(matrix, cur_x, cur_y, mark) {
    let count = result = 0;
    let start   = Math.max(0, cur_x - 4);
    let end     = Math.min(boardSize-1, cur_x + 4);

    for (let i = start; i <= end; i++) {
        if (matrix[cur_y][i] === mark) count++;
        else {
            count = 0;
        }
        if (count == 5) return true;
    }
    return false;
}

function check_Vertical(matrix, cur_x, cur_y, mark) {
    let count = result = 0;
    let start   = Math.max(0, cur_y - 4);
    let end     = Math.min(boardSize-1, cur_y + 4);

    for (let i = start; i <= end; i++) {
        if (matrix[i][cur_x] === mark) count++;
        else {
            count = 0;
        }
        if(count == 5) return true;
    }
    return false;
}

function check_DiagonalMain(matrix, cur_x, cur_y, mark) {
    let count = result = 0;
    let start_x = cur_x;
    let start_y = cur_y;
    let end_x   = cur_x;
    let end_y   = cur_y;
    let k = 1;

    while (start_x != 0 && start_y != 0 && k < 5) {
        start_x--;
        start_y--;
        k++;
    }
    k = 1;
    while ((end_x < boardSize-1) && (end_y < boardSize-1) && k < 5) {
        end_x++;
        end_y++;
        k++;
    }
    for (let i = start_x, j = start_y; i <= end_x && j <= end_y; i++, j++) {
        if (matrix[j][i] === mark) count++;
        else {
            count = 0;
        }
        if (count == 5) return true;
    }
    return false;
}

function check_DiagonalSub(matrix, cur_x, cur_y, mark) {
    let count = result = 0;
    let start_x = cur_x;
    let start_y = cur_y;
    let end_x   = cur_x;
    let end_y   = cur_y;
    let k = 1;
    while ((start_x != 0) && (start_y < boardSize-1) && k < 5) {
        start_x--;
        start_y++;
        k++;
    }
    k = 1;
    while ((end_x < boardSize-1) && (end_y != 0) && k < 5) {
        end_x++;
        end_y--;
        k++;
    }
    for (let i = start_x, j = start_y; i <= end_x && j >= end_y; i++, j --) {
        if (matrix[j][i] === mark) count++;
        else {
            count = 0;
        }
        if (count == 5) return true;
    }
    return false;
}

function check_existMark(matrix, cur_x, cur_y, mark) {
    if (matrix[cur_y][cur_x] > 0) return true;
    else return false;
}

function randUser() {
    let stringRand = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY1234567890";
    var charOne = stringRand[Math.floor(Math.random() * stringRand.length)];
    var charTwo = stringRand[Math.floor(Math.random() * stringRand.length)];
    var charThree = stringRand[Math.floor(Math.random() * stringRand.length)];
    return charOne + charTwo + charThree;
}

const port = process.env.port || 3000;
http.listen(port, function() {
    console.log("App listening on port: " + port);
});

function extendAroundCenter(x, y, tmp_boardSize, chessBoard){
    let oldChessBoard = chessBoard
    if ( x == 0 || y == 0 || x ==  tmp_boardSize || y == tmp_boardSize){
        chessBoard = Array.matrix(tmp_boardSize+3,0)
        for (let i = 0 ; i <= tmp_boardSize ; i++){
            for (let j = 0 ; j <= tmp_boardSize ; j++){
                chessBoard[i+1][j+1] = oldChessBoard[i][j]
            }
        }
        boardSize = tmp_boardSize+3;
    }

    return chessBoard;
}