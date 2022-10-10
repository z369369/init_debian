const St = imports.gi.St;
const Main = imports.ui.main;
const GLib = imports.gi.GLib;

let button, orgIndicator;

function _startGnomePrefs() {
    let s = GLib.spawn_command_line_async('env GDK_BACKEND=x11 gnome-session-quit --power-off');
    if(s == false) {
    Main.notify("Couldn't start gnome-session-quit.");
    }
}

function _startGnomePrefs2() {
    let s = GLib.spawn_command_line_async('env GDK_BACKEND=x11 gnome-session-quit --reboot');
    if(s == false) {
    Main.notify("Couldn't start gnome-session-quit.");
    }
}


function init(extensionMeta) {
    
}

function enable() {
    orgIndicator = Main.panel.statusArea.aggregateMenu._power;

    // Check if battery exist or not
    if (Main.panel.statusArea.aggregateMenu._power._proxy.IsPresent == false) orgIndicator.indicators.hide();
    
    button = new St.Bin({
        style_class: 'panel-button',
        reactive: true,
        can_focus: true,
        track_hover: true
    });
    let icon = new St.Icon({
        icon_name: 'system-shutdown-symbolic',
        style_class: 'system-status-icon'
    });

    button.set_child(icon);
    button.connect('button-press-event', _startGnomePrefs);

    let children = Main.panel._rightBox.get_children();
    Main.panel._rightBox.insert_child_at_index(button, children.length);
    // If you want the position to be left of rightbox, including Frippery Move Clock e.g., replace last line with :
    // Main.panel._rightBox.insert_child_at_index(button, 0);
    
    button2 = new St.Bin({
        style_class: 'panel-button',
        reactive: true,
        can_focus: true,
        track_hover: true
    });
    let icon2 = new St.Icon({
        icon_name: 'system-reboot-symbolic',
        style_class: 'system-status-icon'
    });

    button2.set_child(icon2);
    button2.connect('button-press-event', _startGnomePrefs2);

    let children2 = Main.panel._rightBox.get_children();
    Main.panel._rightBox.insert_child_at_index(button2, children2.length -1);    
    
}

function disable() {
    orgIndicator.indicators.show();
    Main.panel._rightBox.remove_child(button);
    button.destroy();
    button = null;

    Main.panel._rightBox.remove_child(button2);
    button2.destroy();
    button2 = null;
}

