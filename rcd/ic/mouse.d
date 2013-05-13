module rcd.ic.mouse;

private {
    version(Posix) {
        import xmouse = rcd.ic.x11;
        import deimos.X11.Xlib;
        import deimos.X11.X;
    }
}


enum MouseButton : int {
    Left = 1,
    Right = 2,
    Middle = 3,
    Other4 = 4,
    Other5 = 5
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
    } else {
        throw new Exception("mouse.move not implemented");
    }
}

void move_to(int x, int y) {
    version(Posix) {
        xmouse.move_to(display, x, y);
    } else {
        throw new Exception("mouse.move_to not implemented");
    }
}

void click(bool press, MouseButton btn = MouseButton.Left) {
    version(Posix) {
        xmouse.click(display, cast(ButtonName)btn, press);
    } else {
        throw new Exception("mouse.click not implemented");
    }
}