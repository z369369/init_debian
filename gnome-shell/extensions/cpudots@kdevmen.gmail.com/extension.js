const {St, Clutter, GLib, Gio} = imports.gi;
const Main = imports.ui.main;
const ByteArray = imports.byteArray;

let panelButton,
panelButtonText,
lastActive,
lastTotal,
path;

function getdata(){
	let [type , data] = path.load_contents(null);

	const cpuInfo = ByteArray.toString(data).split('\n').shift().trim().split(/[\s]+/).map(n => parseInt(n, 10));

	const [, // eslint-disable-line
		user,
		nice,
		system,
		idle,
		iowait,
		irq, // eslint-disable-line
		softirq,
		steal,
		guest, // eslint-disable-line
	    ] = cpuInfo;

	const active = user + system + nice + softirq + steal;
	const total = user + system + nice + softirq + steal + idle + iowait;

	utilization = 100 * ((active - lastActive) / (total - lastTotal));

	lastActive = active;
	lastTotal = total;

	panelButtonText.set_text(parseInt(utilization)+"%");
	timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, ()=>{getdata()});
}

function init () {
	//nothing
}



function enable () {
	path = Gio.File.new_for_path('/proc/stat');

	panelButton = new St.Bin({
	style_class : "cpu-dots",
	});

	panelButtonText = new St.Label({
		text : "--",
		y_align: Clutter.ActorAlign.CENTER,
	});
	
	panelButton.set_child(panelButtonText);
	getdata();
	Main.panel._rightBox.insert_child_at_index(panelButton, 0);
}

function disable () {
	GLib.source_remove(timeout)
	Main.panel._rightBox.remove_child(panelButton);
	panelButtonText?.destroy();
	panelButtonText = null;
	panelButton?.destroy();
	panelButton = null;
}

