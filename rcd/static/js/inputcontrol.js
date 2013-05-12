

$(function() {
    console.log("Hello World");

    var socket = {
        socket: new WebSocket("ws://" + location.host + "/ws" + location.pathname),
        status: "closed"
    }
    socket.socket.onopen = function() {
        socket.status = "ready";
    };
    socket.socket.onerror = function(err) {
        socket.status = "error";
        console.log("WebSocket Error: ");
        console.log(err);
    };

    var lastMove = null;
    $(window).mousemove(function(event) {
        if(lastMove === null) {
            lastMove = {}
            lastMove["x"] = event.clientX;
            lastMove["y"] = event.clientY;
        }

        offsetX = event.clientX - lastMove["x"];
        offsetY = event.clientY - lastMove["y"];
        lastMove["x"] = event.clientX;
        lastMove["y"] = event.clientY;

        if(socket.status == "ready") {
            socket.socket.send(JSON.stringify({
                action: "mousemove",
                x: offsetX,
                y: offsetY
            }));
        }
    });

    $(window).click(function(event) {
        if(socket.status == "ready") {
            socket.socket.send(JSON.stringify({
                action: "click"
            }));
        }
    });

    $(window).dblclick(function(event) {
        if(socket.status == "ready") {
            socket.socket.send(JSON.stringify({
                action: "dblclick"
            }));
        }
    });
});