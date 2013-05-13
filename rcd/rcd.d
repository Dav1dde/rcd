module rcd.rcd;


private {
    import std.stdio : stderr, writefln;
    import vibe.d;

    import rcd.ic.inputcontrol : InputControl;
}


class Main {
    HttpServerSettings settings;
    UrlRouter router;
    InputControl ic;

    this() {
        setLogLevel(LogLevel.info);

        settings = new HttpServerSettings();
        settings.hostName = "localhost";
        settings.port = 8076;
        //settings.bindAddresses = ["127.0.0.1", "0.0.0.0"];
        settings.errorPageHandler = &on_error;

        router = new UrlRouter();
        router.get("/static/*", serveStaticFiles("rcd/"));

        ic = new InputControl(router);
    }

    void on_error(HttpServerRequest req, HttpServerResponse res, HttpServerErrorInfo error) {
        res.renderCompat!("error.dt",
            HTTPServerRequest, "req",
            HTTPServerErrorInfo, "error")
            (req, error);
    }

    void run() {
        listenHttp(settings, router);
    }
}



shared static this() {
    auto main = new Main();
    main.run();
}