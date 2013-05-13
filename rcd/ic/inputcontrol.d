module rcd.ic.inputcontrol;

private {
    import vibe.d : UrlRouter, handleWebSockets, WebSocket,
                    Json, staticTemplate, parseJsonString,
                    logError, logDebug, logInfo;

    import std.stdio : writefln;
    import std.signals;

    import mouse = rcd.ic.mouse;
    import rcd.utils.ctfe;
    import rcd.utils.defaultaa : DefaultAA;
}

private struct SignalWrapper(Args...) {
    mixin Signal!(Args);
}

private struct Action {
    string command;
}

class InputControl {
    protected DefaultAA!(SignalWrapper!(Json), string) actions;

    this() {
        init_actions();
    }

    protected void init_actions() {
        alias T = typeof(this);

        foreach(member; __traits(allMembers, T)) {
            static if(__traits(compiles, hasAttribute!(mixin(member), Action)) &&
                        hasAttribute!(mixin(member), Action)) {
                alias ParameterTypeTuple!(mixin(member)) Args;

                static if(__traits(compiles, __traits(getAttributes, mixin(member))[0].command)) {
                    enum string n = __traits(getAttributes, mixin(member))[0].command;

                    static if(n.length) {
                        alias n command;
                    } else {
                        alias member command;
                    }
                } else {
                    alias member command;
                }


                //pragma(msg, command);
                actions[command].connect(&(_wrapper!(mixin(member), member, Args)));
            }
        }
    }

    private auto _wrapper(alias fun, string name, Args...)(Json json) {
        Args new_args;
        string[] names = [ParameterIdentifierTuple!fun];

        foreach(i, arg; new_args) {
            static if(is(typeof(arg) == Json)) {
                new_args[i] = json;
            } else {
                new_args[i] = json[names[i]].get!(typeof(arg))();
            }
        }

        return fun(new_args);
    }


    void dispatch(Json json) {
        // these can both throw!
        string action = json["action"].get!string();
        actions[action].emit(json);
    }


    @Action
    void move_mouse(int x, int y) {
        mouse.move(x, y);
    }

    @Action
    void move_mouse_to(int x, int y) {
        mouse.move_to(x, y);
    }

    @Action
    void click() {
        mouse.click(true);
    }

    @Action
    void click_release() {
        mouse.click(false);
    }

    @Action("log")
    void log_js(Json json) {
        logInfo("[JS Log Request]: %s", json);
    }
}


class WSInputControl : InputControl {
    this(UrlRouter router) {
        super();

        router.get("/inputcontrol", staticTemplate!("inputcontrol.dt"));
        router.get("/ws/inputcontrol", handleWebSockets(&on_new_connection));
    }

    void on_new_connection(WebSocket socket) {
        while(socket.connected) {
            auto msg = socket.receiveText();
            writefln("Incoming: %s", msg);
            auto json = parseJsonString(msg);

            dispatch(json);
        }
    }

    override
    void dispatch(Json json) {
        try {
            super.dispatch(json);
        } catch(Exception e) {
            logError("[Error: WSInputControl.dispatch]: %s", e.msg);
            logDebug(e.toString());
        }
    }
}