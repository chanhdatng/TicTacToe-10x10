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
app.set("view engine", "ejs");

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
    secret: "mysecret",
    cookie: {
        maxAge: 1000*60*5
    }
}))
app.use(Passport.initialize());
app.use(Passport.session());




const http = require("http").createServer(app);
const io = require("socket.io")(http);



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
    res.status(401).json({status: false})
})
.post((req, res, next) => {
    Passport.authenticate('local', (err, user, info) => {
        if (err) return next(err);
        if (!user) return res.status(401).json({status: false})
        req.logIn(user, (err) => {
            if (err) return next(err);
            return res.status(200).json({
                status: true, 
                username: user.username, 
                access_token: getToken(user.username)
            })
        })
    })(req, res, next);
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
    socket.myroom = "";

    socket.auth = false;
    socket.on('authenticate', (data) => {
        socket.auth = true;
        console.log("Authenticated socket ", socket.id);
        console.log("Have a new connection: " + socket.id);
        socket.userName = userName = data.username;
        arrUsers.push(socket.userName);
        io.sockets.emit("server-send-arrUsers", {
            users: arrUsers,
            status: "success",
            message: "Có một người mới tham gia!"
        });
    });
   
    // setTimeout(function(){
    //   //sau 1s mà client vẫn chưa dc auth, lúc đấy chúng ta mới disconnect.
    //   if (!socket.auth) {
    //     console.log("Disconnecting socket ", socket.id);
    //     socket.disconnect('unauthorized');
    //   }
    // }, 1000);
    

    socket.on("disconnect", () => {
        console.log(socket.id + " was disconnected");
        
        socket.gamereSults = 1;
        io.sockets.in(socket.myroom).emit("server-send-data", {
            loser: socket.userName
        });
        
        arrRooms.splice(arrRooms.indexOf(socket.userName), 1);
        io.sockets.emit("server-send-arrRooms", {
            arrrooms: arrRooms,
            status: true
        });

        arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
        socket.broadcast.emit("server-send-arrUsers", {
            users: arrUsers,
            status: "warning",
            message: "Có một người đã rời đi!"
        });

        socket.leave(socket.myroom);

        delete dataRoom[socket.myroom];
        socket.myroom = "";
    });

    socket.on("client-send-logout", () => {
        console.log(socket.id + " was disconnected");
        
        socket.gamereSults = 1;
        io.sockets.in(socket.myroom).emit("server-send-data", {
            loser: socket.userName
        });

        
        arrRooms.splice(arrRooms.indexOf(socket.userName), 1);
        io.sockets.emit("server-send-arrRooms", {
            arrrooms: arrRooms,
            status: true
        });

        arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
        socket.broadcast.emit("server-send-arrUsers", {
            users: arrUsers,
            status: "warning",
            message: "Có một người đã rời đi!"
        });
        
        socket.leave(socket.myroom);

        delete dataRoom[socket.myroom];
        socket.myroom = "";

        // arrUsers.splice(arrUsers.indexOf(socket.userName), 1);
        // socket.broadcast.emit("server-send-arrUsers", {
        //     users: arrUsers,
        //     status: "warning",
        //     message: "Có một người đã rời đi!"
        // });
    });

    io.sockets.emit("server-send-arrRooms", {
        arrrooms: arrRooms,
        status: true
    });
    
    socket.on("client-create-newRoom", (data) => {
        if (typeof socket.myroom === 'undefined' || socket.myroom === "") {
            if (verifyToken(data.token, data.username)) {
                socket.myroom = data.idroom;
                socket.join(data.idroom);
                console.log(socket.adapter.rooms);

                arrRooms = [];
                for (r in socket.adapter.rooms) {
                    if (r.length === 6) arrRooms.push(r);
                }

                // add object turn for dataRoom
                dataRoom[socket.myroom] = [1, 0];
                
                socket.emit("server-send-gamer", {
                    gamer: 1
                });

                console.log("arrrooms: ", arrRooms);
                io.sockets.emit("server-send-arrRooms", {
                    arrrooms: arrRooms,
                    status: true
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
                myroom: socket.myroom,
                username: socket.userName
            });
        }
    });

    socket.on("client-send-joinRoom", (data) => {
        if (socket.myroom == "") {
            if (socket.adapter.rooms[data.idroom].length < 2) {
                if (verifyToken(data.token, data.username)) {
                    socket.join(data.idroom);
                    socket.myroom = data.idroom;
                    chessBoard = Array.matrix(boardSize, 0);
                    socket.gamereSults = -1;
                    totalTurns = 0;
                    
                    arrRooms.splice(arrRooms.indexOf(socket.myroom), 1);
                    io.sockets.emit("server-send-arrRooms", {
                        arrrooms: arrRooms,
                        status: true
                    });

                    socket.emit("server-send-gamer", {
                        gamer: 2
                    });

                    io.sockets.in(socket.myroom).emit("server-send-matched", {
                        username: socket.userName,
                        matrix: chessBoard,
                        status: true
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
        }
        else {
            socket.emit("server-send-enoughRoom");
        }
    });

    socket.on("client-send-closeRoom", () => {
        socket.leave(socket.myroom);
        console.log(socket.adapter.rooms);
        arrRooms.splice(arrRooms.indexOf(socket.myroom), 1);
        io.sockets.emit("server-send-arrRooms", {
            arrrooms: arrRooms,
            status: true
        });
        delete dataRoom[socket.myroom];
        socket.myroom = "";
    });

    socket.on("client-send-play", (data) => {
        console.log("send-data",data);
        console.log("gamer: ", data.gamer);
        console.log("dataRoom: ", dataRoom);
        if (dataRoom[socket.myroom][data.gamer-1] === 1) {
            let mark = data.gamer;
            let x = data.x;
            let y = data.y;
            chessBoard = data.matrix;
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
                
                // Swap turn
                let tmp = dataRoom[socket.myroom][0];
                dataRoom[socket.myroom][0] = dataRoom[socket.myroom][1];
                dataRoom[socket.myroom][1] = tmp;

                io.sockets.in(socket.myroom).emit("server-send-data", {
                    name: data.username,
                    matrix: chessBoard,
                    x: x * parseInt(data.boxsize),
                    y: y * parseInt(data.boxsize),
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