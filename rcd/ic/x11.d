module rcd.ic.x11;

private {
    import deimos.X11.X;
    import deimos.X11.Xlib;

    import std.stdio : stderr;

    import rcd.ic.util : Coord;
}

void click(Display *display, int button) {
    XEvent event;

    event.xbutton.button = button;
    event.xbutton.same_screen = Bool.True;
    event.xbutton.subwindow = DefaultRootWindow(display);
    while(event.xbutton.subwindow) {
      event.xbutton.window = event.xbutton.subwindow;
      XQueryPointer (display, event.xbutton.window,
             &event.xbutton.root, &event.xbutton.subwindow,
             &event.xbutton.x_root, &event.xbutton.y_root,
             &event.xbutton.x, &event.xbutton.y,
             &event.xbutton.state);
    }

    // Press
    event.type = EventType.ButtonPress;
    if (XSendEvent (display, PointerWindow, Bool.True, EventMask.ButtonPressMask, &event) == 0)
        stderr.writeln("Error to send the event!");
    XFlush (display);

    // Release
    event.type = EventType.ButtonRelease;
    if (XSendEvent (display, PointerWindow, Bool.True, EventMask.ButtonReleaseMask, &event) == 0)
        stderr.writeln("Error to send the event!");
    XFlush(display);
}


Coord get_mouse_coords(Display *display) {
    XEvent event;

    XQueryPointer(display, DefaultRootWindow (display),
                    &event.xbutton.root, &event.xbutton.window,
                    &event.xbutton.x_root, &event.xbutton.y_root,
                    &event.xbutton.x, &event.xbutton.y,
                    &event.xbutton.state);
    return Coord(event.xbutton.x, event.xbutton.y);
}


void move(Display* display, Coord coord) {
    return move(display, coord.x, coord.y);
}

void move(Display* display, int x, int y) {
    XWarpPointer(display, None, None, 0, 0, 0, 0, x, y);
    XFlush(display);
}

void move_to(Display *display, Coord coord) {
    return move_to(display, coord.x, coord.y);
}

void move_to(Display* display, int x, int y) {
  auto cur_pos = get_mouse_coords(display);
  XWarpPointer(display, None, None, 0, 0, 0, 0, -cur_pos.x, -cur_pos.y);
  XWarpPointer(display, None, None, 0, 0, 0, 0, x, y);
}


