

$(function() {
    console.log("Hello World");

    var socket = {
        socket: new WebSocket("ws://" + location.host + "/ws" + location.pathname),
        status: "closed",
        onopen: function() {},
        onerror: function() {},
        onmessage: function() {}
    }
    socket.send = function(message) {
        s = JSON.stringify(message);
        //console.log(message);
        //console.log(s);
        socket.socket.send(s);
    }
    socket.socket.onmessage = function(message) {
        socket.onmessage(JSON.parse(message));
    }

    socket.socket.onopen = function() {
        socket.status = "ready";
        socket.onopen();
    };
    socket.socket.onerror = function(err) {
        socket.status = "error";
        console.log("WebSocket Error: ");
        console.log(err);
        socket.onerror(err);
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

        socket.send({
            action: "mousemove",
            x: offsetX,
            y: offsetY
        });
    });

    $(window).click(function(event) {
        socket.send({
            action: "click"
        });
    });

    $(window).dblclick(function(event) {
        socket.send({
            action: "dblclick"
        });
    });


    var lastHammerDelta;
    var hammertime = Hammer($("html").get(0), {
        prevent_default: true,
        no_mouseevents: true
    }).on("dragstart", function(event) {
        if(!event.gesture) { return; }
        lastHammerDelta = {
            x: event.gesture.deltaX,
            y: event.gesture.deltaY
        }
    }).on("drag", function(event) {
        if(!event.gesture) { return; }

        deltaX = event.gesture.deltaX - lastHammerDelta.x;
        deltaY = event.gesture.deltaY - lastHammerDelta.y;
        lastHammerDelta.x = event.gesture.deltaX;
        lastHammerDelta.y = event.gesture.deltaY;

        socket.send({
            action: "mousemove",
            x: deltaX,
            y: deltaY
        });
    }).on("tap", function(event) {
        socket.send({
            action: "click"
        });
    }).on("doubletap", function(event) {
        socket.send({
            action: "dblclick"
        });
    });

});