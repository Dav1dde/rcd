module rcd.ic.inputcontrol;

private {
    import std.stdio : writefln;

    import vibe.d;

    import mouse = rcd.ic.mouse;
}


class InputControl {
    this(UrlRouter router) {
        router.get("/inputcontrol", staticTemplate!("inputcontrol.dt"));
        router.get("/ws/inputcontrol", handleWebSockets(&on_new_connection));
    }

    void on_new_connection(WebSocket socket) {
        while(socket.connected) {
            auto msg = socket.receiveText();
            writefln("Incoming: %s", msg);
            auto json = parseJsonString(msg);

            if(json["action"].get!string == "mousemove") {
                mouse.move(json["x"].get!int, json["y"].get!int);
            }
        }
    }
}