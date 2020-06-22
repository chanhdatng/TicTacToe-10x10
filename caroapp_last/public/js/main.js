let domain = "http://172.20.10.3:3000";
let socket = io(domain);
let boxsize = 50;
let n = 10;
let username = "";
let access_token = "";
let gamer;
let matrix;

$(document).ready(() => {
    $("#chessBoard").hide(2000);
    $("#rooms").show(1000);
    $(".profile-userpic").html(`<img src="assets/pages/media/profile/${randAvatar()}.jpg" class="img-responsive" alt="">`)
    
    $.get('/api/ranking', {},
    function(data, status, jqXHR) {
            if (data.status){
                let members = data.data;
                members.forEach(user => {
                    $(".chats").append(`
                        <li class="in">
                            <img class="avatar" alt="" src="assets/pages/media/profile/${randAvatar()}.jpg" />
                            <div class="message">
                                <span class="arrow"> </span>
                                <span class="label label-sm label-danger">${user.score}</span>
                                <a href="javascript:;" class="name"> ${user.username} </a>
                                <div>
                                    <code>${user.email}</code>
                                    <span class="label label-sm label-warning">${user.fullname}</span>
                                </div>
                            </div>
                        </li>
                    `);
                    
                });
            }
    }, 'json');


    if (window.localStorage.getItem("access_token")) {
        username = window.localStorage.getItem("username");
        access_token = window.localStorage.getItem("access_token");
        $("#userName").html(username);
    }
    else window.location.replace("/login");

    // $(window).unload(() => {
    //     window.localStorage.clear();
    // });

    $("#btnLogout").click(() => {
        username = "";
        window.localStorage.clear();
        if (!window.localStorage.getItem("username")){
            socket.emit("client-send-logout");
        }
        // window.localStorage.clear();
        window.location.replace("/login");
    });

    $("#btnCreateNewRoom").click(() => {
        
        $(".modal-body").html(`<img src="assets/global/img/loading-spinner-grey.gif" alt="" class="loading"><span> &nbsp;&nbsp;Loading... </span>`);
        socket.emit("client-send-createRoom", {
            token: access_token,
            username: username,
            idroom: randRoom().toString()
        });
    });

    $("#btnCloseRoom").click(() => {
        socket.emit("client-send-closeRoom");
    });

    $("#btnLeaderBoard").click(() => {
        $(".chats").html("");
        $.get('/api/ranking', {},
            function(data, status, jqXHR) {
                    if (data.status){
                        let members = data.data;
                        members.forEach(user => {
                            $(".chats").append(`
                                <li class="in">
                                    <img class="avatar" alt="" src="assets/pages/media/profile/${randAvatar()}.jpg" />
                                    <div class="message">
                                        <span class="arrow"> </span>
                                        <span class="label label-sm label-danger">${user.score}</span>
                                        <a href="javascript:;" class="name"> ${user.username} </a>
                                        <div>
                                            <code>${user.email}</code>
                                            <span class="label label-sm label-warning">${user.fullname}</span>
                                        </div>
                                    </div>
                                </li>
                            `);
                            
                        });
                    }
            }, 'json');
    });
});

socket.on("connect", function(){
    socket.emit("authenticate", {
        token: access_token,
        username: username
    });
});

socket.on("server-send-hack", (data) => {
    if (!data.status) {
        toastr.error(data.msg, "HACK");
    }
});

socket.on("server-send-arrUsers", (res) => {
    $("#arrUsers").html("");
    let arrUsers = res.data.users;
    arrUsers.forEach((i) => {
        $("#arrUsers").append(`<li><a><i class="icon-user"></i> ${i} </a></li>`);
        
    });
    if (res.status === true)
        toastr.success(res.msg, "Notifications");
    else if (data.status === "warning")
        toastr.warning(res.msg, "Notifications");
});

socket.on("server-send-arrRooms", (res) => {
    $("#listRooms").html("");
    let arrRooms = res.data.rooms;

    arrRooms.forEach((room) => {
        $("#listRooms")
        .append(`
        <div class="portlet-title">
            <div class="caption bg-black">
                <i class="fa fa-spinner fa-spin font-green"></i>
                Room id: <span class="caption-subject bold font-green"> ${room} </span>
            </div>
            <div class="actions">
                <a onclick="joinRoom(${room.toString()});" class="btn blue"><i class="fa fa-paper-plane-o"></i> Join now </a>
            </div>
        </div>`);
    });
});

socket.on("server-send-matched", (res) => {
    $("#rooms").hide(2000);
    $("#chessBoard").show(1000);
    createBoard();
    matrix = res.data.matrix;
});

socket.on("server-send-enoughRoom", () => {
    toastr.error("You can't join a room with enough people", "Notication")
});

socket.on("server-send-gamer", (res) => {
    gamer = parseInt(res.data.gamer);
});

socket.on("server-send-existRoom", (res) => {
    toastr.error(`You already have room ${res.data.myroom}. You can't' create any more.`, "Error");
});

socket.on("server-send-checkExistMark", () => {
    toastr.warning(`You are not marked at that location.`, "Warning");
});

socket.on("server-send-data", (data) => {
    if (typeof data.loser === 'undefined') {
        let x = parseInt(data.x);
        let y = parseInt(data.y);

        let mark = parseInt(data.mark);
        matrix = data.matrix;
        const stamp = svg
            .append("text")
            .attr("x", x*boxsize)
            .attr("y", y*boxsize)
            .attr("text-anchor", "middle")
            .attr("dx", boxsize / 2)
            .attr("dy", boxsize / 2 + 8)
            .text(() => {
                if (mark === 1) {
                    return "X";
                }
                else {
                    return "O";
                }
            })
            .style("font-weight", "bold")
            .style("font-size", "30px")
            .style("fill", () => {
                if (mark === 1) {
                    return "000066";
                }
                else {
                    return "FF0000";
                }
            });
        if (parseInt(data.game) === 1) {
            resetGameRusult();
            if (data.name == username) {
                toastr.success("Victory!!!", "Game over");
                socket.emit("client-send-score-win", {
                    token: access_token,
                    username: username
                });
            }
            else {
                toastr.info("Defeat!", "Game over");
                socket.emit("client-send-score-lose", {
                    token: access_token,
                    username: username
                });
            }
            socket.emit("client-send-closeRoom");
            $("#chessBoard").hide(2000);
            $("#rooms").show(1000);
        }
        else if(parseInt(data.game) === 0) {
            resetGameRusult();
            console.log("Drawing!!!");
            toastr.warning("Drawing!!!", "Game over");

            socket.emit("client-send-closeRoom");

            $("#chessBoard").hide(2000);
            $("#rooms").show(1000);
        }
    }
    else {
        console.log("DAT: ",data.loser);
        resetGameRusult();
        toastr.success("Victory!!!", "Game over");

        socket.emit("client-send-score-win", {
            token: access_token,
            username: username
        });

        socket.emit("client-send-closeRoom");

        $("#chessBoard").hide(2000);
        $("#rooms").show(1000);
    }
    
});

socket.on("server-send-checkTurn", () => {
    toastr.warning("It's not your turn yet. Please wait for your turn!", "Warning");
});



// Create a chessBoard
const div = d3.select("#chessBoard").style("text-align","center");
// create <svg>
const svg = div.append("svg").attr("width", 500).attr("height", 600);
//-------------------------------------------------------



// toastr.options = {
//     closeButton: true,
//     positionClass: "toast-bottom-full-width",
//     showMethod: 'slideDown',
//     timeOut: 4000
// };

toastr.options = {
    closeButton: true,
    debug: false,
    positionClass: "toast-top-right",
    onclick: null,
    showDuration: "1000",
    hideDuration: "1000",
    timeOut: "3000"
  }

function randRoom() {
    return Math.floor(Math.random() * 900000) + 100000;
};

function randAvatar() {
    return Math.floor(Math.random() * 40) + 1;
}

function joinRoom(idRoom) {
    // socket.emit("client-send-joinRoom", idRoom);
    socket.emit("client-send-joinRoom", {
        token: access_token,
        username: username,
        idroom: idRoom
    });
};

function createBoard() {
    for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
            // draw each chess field
            const box = svg.append("rect")
                .attr("x", i * boxsize)
                .attr("y", j * boxsize)
                .attr("width", boxsize)
                .attr("height", boxsize)
                .attr("id", "b" + i + j)
                .attr("fill", "beige")
                .style("stroke","black")
                .on("click", function () {
                    let selected = d3.select(this);
                    let x = selected.attr("x");
                    let y = selected.attr("y");
                    socket.emit("client-send-play", {
                        token: access_token,
                        username: username,
                        gamer: gamer,
                        matrix: matrix,
                        x: x/boxsize, 
                        y: y/boxsize,
                        boxsize: boxsize
                    });
                });
        }
    }
}

function resetGameRusult() {
    socket.emit("client-send-resetResult");
}

var UIButtons = function() {
    var n = function() {
        $(".btn-loading").click(function() {
            var n = $(this);
            n.button("loading"), setTimeout(function() {
                n.button("reset")
            }, 3e3)
        })
    };
    return {
        init: function() {
            n()
        }
    }
}();
UIButtons.init();