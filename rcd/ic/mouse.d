module rcd.ic.mouse;

private {
    version(Posix) {
        import xmouse = rcd.ic.x11;
        import deimos.X11.Xlib;
    }
}


version(Posix) {
    private __gshared Display* _display = null;

    @property
    Display* display() {
        /*synchronized?*/ if(_display is null) {
            _display = XOpenDisplay(null);
        }

        return _display;
    }
}


void move(int x, int y) {
    version(Posix) {
        xmouse.move(display, x, y);
    }
}

void move_to(int x, int y) {
}
