// Documentation: https://github.com/Rayzeq/libpanel/wiki
// Useful links:
//   - Drag & Drop example: https://gitlab.com/justperfection.channel/how-to-create-a-gnome-shell-extension/-/blob/master/example11%40example11.com/extension.js

const { GLib, GObject, Clutter, Meta, St } = imports.gi;

const DND = imports.ui.dnd;
const Main = imports.ui.main;
const { PopupMenu } = imports.ui.popupMenu;
const { BoxPointer, PopupAnimation } = imports.ui.boxpointer;
const { QuickSettingsMenu } = imports.ui.quickSettings;

const MenuManager = Main.panel.menuManager;
const QuickSettings = Main.panel.statusArea.quickSettings;
const QuickSettingsLayout = QuickSettings.menu._grid.layout_manager.constructor;

const Self = function () {
	// See this link for explanations: https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/main/js/misc/extensionUtils.js#:~:text=function-,installImporter,-(extension)
	function create_importer(path) {
		path = path.split('/');
		if (path.at(-1) === '') path.pop();
		const name = path.pop();
		path = path.join('/');

		const oldSearchPath = imports.searchPath.slice();
		imports.searchPath = [path];
		importer = imports[name];
		imports.searchPath = oldSearchPath;
		return importer;
	}

	const libpanel_path = new Error().stack.split('\n')[0] // first line of the call stack
		.split('@').slice(1).join('@') // the first @ separate the function name and the file path
		.split('/').slice(0, -1).join('/') + '/'; // the last item of the path is the current file, so we take the one just before
	const Self = create_importer(libpanel_path);

	const handler = {
		get(target, name) {
			if (name in target) {
				return target[name];
			}
			return Self[name];
		},
	};

	return new Proxy({ path: libpanel_path }, handler);
}();
const { Patcher } = Self.patcher;
const {
	array_remove, array_insert,
	get_extension_uuid, get_shell_version,
	add_named_connections, find_panel, get_settings,
	set_style
} = Self.utils;

const VERSION = 1;
// The spacing between elements of the grid, in pixels.
const GRID_SPACING = 5;

function registerClass(metadata, klass) {
	if (klass === undefined) {
		klass = metadata;
		metadata = {};
	}

	metadata.GTypeName = `${metadata.GTypeName || `LibPanel_${klass.name}`}_${get_extension_uuid().replace(/[^A-Za-z_-]/g, '-')}`;

	return GObject.registerClass(metadata, klass);
}

const AutoHidable = superclass => {
	// We need to cache the created classes or else we would register the same class name multiple times
	if (AutoHidable.cache === undefined) AutoHidable.cache = {};
	if (AutoHidable.cache[superclass.name] !== undefined) return AutoHidable.cache[superclass.name];

	const klass = registerClass({
		GTypeName: `LibPanel_AutoHidable_${superclass.name}`,
	}, class extends superclass {
		constructor(...args) {
			const container = args.at(-1).container;
			delete args.at(-1).container;
			super(...args);

			// We need to accept `null` as valid value here
			// which is why we don't do `container || this`
			this.container = container === undefined ? this : container;
		}

		get container() {
			return this._lpah_container;
		}

		set container(value) {
			if (this._lpah_container !== undefined) this.disconnect_named(this._lpah_container);
			if (value !== null) {
				this._lpah_container = value;
				this.connect_named(this._lpah_container, 'actor-added', (_container, children) => {
					this.connect_named(children, 'notify::visible', this._update_visibility.bind(this));
					this._update_visibility();
				});
				this.connect_named(this._lpah_container, 'actor-removed', (_container, children) => {
					this.disconnect_named(children);
					this._update_visibility();
				});
				this._update_visibility();
			}
		}

		_get_ah_children() {
			return this._lpah_container.get_children();
		}

		_update_visibility() {
			for (const child of this._get_ah_children()) {
				if (child.visible) {
					this.show();
					return;
				}
			}

			this.hide();
			// Force the widget to take no space when hidden (this fixes some bugs but I don't know why)
			this.queue_relayout();
		}
	});
	AutoHidable.cache[superclass.name] = klass;
	return klass;
};

const Semitransparent = superclass => {
	// We need to cache the created classes or else we would register the same class name multiple times
	if (Semitransparent.cache === undefined) Semitransparent.cache = {};
	if (Semitransparent.cache[superclass.name] !== undefined) return Semitransparent.cache[superclass.name];

	const klass = registerClass({
		GTypeName: `LibPanel_Semitransparent_${superclass.name}`,
		Properties: {
			'transparent': GObject.ParamSpec.boolean(
				'transparent',
				'Transparent',
				'Whether this widget is transparent to pointer events',
				GObject.ParamFlags.READWRITE,
				true
			),
		},
	}, class extends superclass {
		get transparent() {
			if (this._transparent === undefined)
				this._transparent = true;

			return this._transparent;
		}

		set transparent(value) {
			this._transparent = value;
			this.notify('transparent');
		}

		vfunc_pick(context) {
			if (!this.transparent) {
				super.vfunc_pick(context);
			}
			for (const child of this.get_children()) {
				child.pick(context);
			}
		}
	});
	Semitransparent.cache[superclass.name] = klass;
	return klass;
};

const GridItem = superclass => {
	// We need to cache the created classes or else we would register the same class name multiple times
	if (GridItem.cache === undefined) GridItem.cache = {};
	if (GridItem.cache[superclass.name] !== undefined) return GridItem.cache[superclass.name];

	const klass = registerClass({
		GTypeName: `LibPanel_GridItem_${superclass.name}`,
		Properties: {
			'draggable': GObject.ParamSpec.boolean(
				'draggable',
				'draggable',
				'Whether this widget can be dragged',
				GObject.ParamFlags.READWRITE,
				true
			),
		},
	}, class extends superclass {
		constructor(panel_name, ...args) {
			super(...args);

			this.is_grid_item = true;
			this.panel_name = panel_name;

			this._drag_handle = DND.makeDraggable(this);
			this.connect_named(this._drag_handle, 'drag-begin', () => {
				QuickSettings.menu.transparent = false;

				// Prevent the first column from disapearing if it only contains `this`
				const column = this.get_parent();
				this._source_column = column;
				if (column.get_next_sibling() === null && column.get_children().length === 1) {
					column._width_constraint.source = this;
					column._inhibit_constraint_update = true;
				}

				this._dnd_placeholder?.destroy();
				this._dnd_placeholder = new DropZone(this);

				this._drag_monitor = {
					dragMotion: this._on_drag_motion.bind(this),
				};
				DND.addDragMonitor(this._drag_monitor);

				this._drag_orig_index = this.get_parent().get_children().indexOf(this);
				// dirty fix for Catppuccin theme (because it relys on CSS inheriting)
				// this may not work with custom grid items
				this.add_style_class_name?.("popup-menu");
			});
			// This is emited BEFORE drag-end, which means that this._dnd_placeholder is still available
			this.connect_named(this._drag_handle, 'drag-cancelled', () => {
				// This stop the dnd system from doing anything with `this`, we want to manage ourselves what to do.
				this._drag_handle._dragState = DND.DragState.CANCELLED;

				if (this._dnd_placeholder.get_parent() !== null) {
					this._dnd_placeholder.acceptDrop(this);
				} else { // We manually reset the position of the panel because the dnd system will set it at the end of the column
					this.get_parent().remove_child(this);
					this._drag_handle._dragOrigParent.insert_child_at_index(this, this._drag_orig_index);
				}
			});
			// This is called when the drag ends with a drop and when it's cancelled
			this.connect_named(this._drag_handle, 'drag-end', (_drag_handle, _time, _cancelled) => {
				QuickSettings.menu.transparent = true;

				if (this._drag_monitor !== undefined) {
					DND.removeDragMonitor(this._drag_monitor);
					this._drag_monitor = undefined;
				}

				this._dnd_placeholder?.destroy();
				this._dnd_placeholder = null;

				const column = this._source_column;
				if (!column._is_destroyed && column._width_constraint.source == this) {
					column._width_constraint.source = column.get_next_sibling();
					column._inhibit_constraint_update = false;
				}

				// Something, somewhere is setting a forced width & height for this actor,
				// so we undo that
				this.width = -1;
				this.height = -1;
				this.remove_style_class_name?.("popup-menu");
			});
			this.connect_named(this, 'destroy', () => {
				if (this._drag_monitor !== undefined) {
					DND.removeDragMonitor(this._drag_monitor);
					this._drag_monitor = undefined;
				}
			});
		}

		get draggable() {
			return this._drag_handle._disabled || false;
		}

		set draggable(value) {
			this._drag_handle._disabled = value;
			this.notify('draggable');
		}

		_on_drag_motion(event) {
			if (event.source !== this) return DND.DragMotionResult.CONTINUE;
			if (event.targetActor === this._dnd_placeholder) return DND.DragMotionResult.COPY_DROP;

			const panel = find_panel(event.targetActor);

			const previous_sibling = panel?.get_previous_sibling();
			const target_pos = panel?.get_transformed_position();
			const self_size = this.get_transformed_size();

			this._dnd_placeholder.get_parent()?.remove_child(this._dnd_placeholder);

			if (event.targetActor.is_panel_column) {
				event.targetActor.add_child(this._dnd_placeholder);
			} else if (panel !== undefined) {
				const column = panel.get_parent();
				if (previous_sibling === this._dnd_placeholder || event.y > (target_pos[1] + self_size[1])) {
					column.insert_child_above(this._dnd_placeholder, panel);
				} else {
					column.insert_child_below(this._dnd_placeholder, panel);
				}
			}

			return DND.DragMotionResult.NO_DROP;
		}
	});
	GridItem.cache[superclass.name] = klass;
	return klass;
};

const DropZone = registerClass(class DropZone extends St.Widget {
	constructor(source) {
		super({ style_class: source._drag_actor?.style_class || source.style_class, opacity: 127 });
		this._delegate = this;

		this._height_constraint = new Clutter.BindConstraint({
			coordinate: Clutter.BindCoordinate.WIDTH,
			source: source,
		});
		this._width_constraint = new Clutter.BindConstraint({
			coordinate: Clutter.BindCoordinate.HEIGHT,
			source: source,
		});
		this.add_constraint(this._height_constraint);
		this.add_constraint(this._width_constraint);
	}

	acceptDrop(source, _actor, _x, _y, _time) {
		if (!source.is_grid_item) return false;

		source.get_parent().remove_child(source);

		const column = this.get_parent();
		column.replace_child(this, source);

		column.get_parent()._delegate._cleanup();
		LibPanel.get_instance()._save_layout();
		return true;
	}
});

class PanelGrid extends PopupMenu {
	constructor(sourceActor) {
		super(sourceActor, 0, St.Side.TOP);

		// ==== We replace the BoxPointer with our own because we want to make it transparent ====
		global.focus_manager.remove_group(this._boxPointer);
		this._boxPointer.bin.set_child(null); // prevent `this.box` from being destroyed
		this._boxPointer.destroy();
		// The majority of this code has been copied from here:
		// https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/main/js/ui/popupMenu.js#L801

		// We want to make the actor transparent
		this._boxPointer = new (Semitransparent(BoxPointer))(this._arrowSide);
		this.actor = this._boxPointer;
		this.actor._delegate = this;
		this.actor.style_class = 'popup-menu-boxpointer';
		// Force the popup to take all the screen to allow drag and drop to empty spaces
		this.actor.connect_after('parent-set', () => {
			if (this._height_constraint) this.actor.remove_constraint(this._height_constraint);
			const parent = this.actor.get_parent();
			if (parent === null) {
				this._height_constraint = undefined;
			} else {
				this._height_constraint = new Clutter.BindConstraint({
					coordinate: Clutter.BindCoordinate.HEIGHT,
					source: parent,
				});
				this.actor.add_constraint(this._height_constraint);
			}
		});
		// And manually add the bottom margin. This is useless as the grid is invisible,
		// but in case something make it visible it looks nice
		this.actor.connect_after('stage-views-changed', () => {
			if (this.actor.get_stage() === null || this._height_constraint === undefined) return;
			this._height_constraint.offset = -this.actor.getArrowHeight();
		});

		this._boxPointer.bin.set_child(this.box);
		this.actor.add_style_class_name('popup-menu');
		this.actor.add_style_class_name('QSAP-panel-grid');

		global.focus_manager.add_group(this.actor);
		this.actor.reactive = true;
		// =======================================================================================

		this.box._delegate = this;  // this used so columns can get `this` using `column.get_parent()._delegate`
		this.box.vertical = false;
		this._panel_style_class = this.box.style_class; // we save the style class that's used to make a nice panel
		this.box.style_class = ''; // and we remove it so it's invisible
		this.box.style = `spacing: ${GRID_SPACING}px`;

		this.actor.connect_after('notify::allocation', () => {
			// The `setTimeout` fixes the following warning:
			// Can't update stage views actor ... is on because it needs an allocation.
			if (this.actor.x > 0)
				this._timeout_id = setTimeout(() => {
					this._timeout_id = null;
					this._add_column();
				}, 0);
		});
		this.actor.connect('destroy', () => {
			if (this._timeout_id) clearTimeout(this._timeout_id);
		});
	}

	get transparent() {
		return this.actor.transparent;
	}

	set transparent(value) {
		this.actor.transparent = value;
	}

	close(animate) {
		for (const column of this.box.get_children()) {
			column._close();
		}
		super.close(animate);
	}

	_add_panel(panel) {
		if (this.box.get_children().length === 0) {
			this._add_column()._add_panel(panel);
			return;
		}

		for (const column of this.box.get_children()) {
			if (column._panel_layout.indexOf(panel.panel_name) > -1) {
				column._add_panel(panel);
				return;
			}
		}

		// Everything here is really approximated because we can't have the allocations boxes at this point
		// Most notably, `max_height` will be wrong
		const max_height = this._height_constraint?.source?.height || this.actor.height;
		let column;
		for (const children of this.box.get_children().reverse()) {
			if (this._get_column_height(children) < max_height) {
				column = children;
				break;
			}
		}
		if (!column) column = this.box.first_child;
		if (this._get_column_height(column) > max_height) {
			column = this._add_column();
		}
		column._add_panel(panel);
	}

	_get_column_height(column) {
		return column.get_children().reduce((acc, widget) => acc + widget.height, 0);
	}

	_add_column(layout = []) {
		const column = new PanelColumn(layout);
		this.actor.bind_property('transparent', column, 'transparent', GObject.BindingFlags.SYNC_CREATE);
		this.box.insert_child_at_index(column, 0);
		return column;
	}

	_get_panel_layout() {
		return this.box.get_children().map(column => column._panel_layout);
	}

	_cleanup() {
		while (this.box.last_child.get_children().length === 0) this.box.last_child.destroy();
	}

	_get_panels() {
		return this.box.get_children().map(column => column.get_children()).flat();
	}
}

const PanelColumn = registerClass(class PanelColumn extends Semitransparent(St.BoxLayout) {
	constructor(layout = []) {
		super({ vertical: true, style: `spacing: ${GRID_SPACING}px` });
		this.is_panel_column = true; // since we can't use instanceof, we use this attribute
		this._panel_layout = layout;

		this._inhibit_constraint_update = false;
		this._width_constraint = new Clutter.BindConstraint({
			coordinate: Clutter.BindCoordinate.WIDTH,
			source: null,
		});
		this.add_constraint(this._width_constraint);

		this.connect_after_named(this, 'actor-added', (_self, actor) => {
			if (this.get_children().length === 1) this.remove_constraint(this._width_constraint);
			if (!actor.is_grid_item) return;

			const prev_index = this._panel_layout.indexOf(actor.get_previous_sibling()?.panel_name);
			const index = this._panel_layout.indexOf(actor.panel_name);
			const next_index = this._panel_layout.indexOf(actor.get_next_sibling()?.panel_name);
			// `actor` is in the layout but is misplaced
			if (index > -1 && ((prev_index > -1 && index < prev_index) || (next_index > -1 && next_index < index))) {
				array_remove(this._panel_layout, actor.panel_name);
				index = -1;
			}
			if (index < 0) { // `actor` is not in the layout
				if (prev_index > -1)
					array_insert(this._panel_layout, prev_index + 1, actor.panel_name);
				else if (next_index > 0)
					array_insert(this._panel_layout, next_index - 1, actor.panel_name);
				else
					array_insert(this._panel_layout, 0, actor.panel_name);
			}
		});
		this.connect_after_named(this, 'actor-removed', (_self, actor) => {
			if (this.get_children().length === 0) this.add_constraint(this._width_constraint);
			if (actor._keep_layout || !actor.is_grid_item) return;

			array_remove(this._panel_layout, actor.panel_name);
		});

		this.connect('destroy', () => this._is_destroyed = true);
		this.connect_after_named(this, 'parent-set', (_self, old_parent) => {
			if (old_parent !== null) this.disconnect_named(old_parent);

			const parent = this.get_parent();
			if (parent === null) return;
			const update_source = (_parent, _actor) => {
				// clutter is being dumb and emit this signal even though `_parent` and `this` are destroyed
				// this fix it
				if (this._is_destroyed || this._inhibit_constraint_update) return;
				this._width_constraint.source = this.get_next_sibling();
			};
			this.connect_after_named(parent, 'actor-added', update_source);
			this.connect_after_named(parent, 'actor-removed', update_source);

			update_source();
		});
	}

	_close() {
		for (const panel of this.get_children()) {
			panel._close();
		}
	}

	_add_panel(panel) {
		const index = this._panel_layout.indexOf(panel.panel_name);
		if (index > -1) {
			const panels = this.get_children().map(children => children.panel_name);
			for (const panel_name of this._panel_layout.slice(0, index).reverse()) {
				const children_index = panels.indexOf(panel_name);
				if (children_index > -1) {
					this.insert_child_at_index(panel, children_index + 1);
					return;
				}
			}
			this.insert_child_at_index(panel, 0);
		} else {
			this.add_child(panel);
		}
	}
});

var Panel = registerClass(class Panel extends GridItem(AutoHidable(St.Widget)) {
	constructor(panel_name, nColumns = 2) {
		super(`${get_extension_uuid()}/${panel_name}`, {
			// I have no idea why, but sometimes, a panel (not all of them) gets allocated too much space (behavior similar to `y-expand`)
			// This prevent it from taking all available space
			y_align: Clutter.ActorAlign.START,
			// Enable this so the menu block any click event from propagating through
			reactive: true,
			// We want to set this later
			container: null,
		});
		this._delegate = this;

		// Overlay layer that will hold sub-popups
		this._overlay = new Clutter.Actor({ layout_manager: new Clutter.BinLayout() });

		// Placeholder to make empty space when opening a sub-popup
		const placeholder = new Clutter.Actor({
			// The placeholder have the same height as the overlay, which means
			// it have the same height as the opened sub-popup
			constraints: new Clutter.BindConstraint({
				coordinate: Clutter.BindCoordinate.HEIGHT,
				source: this._overlay,
			}),
		});

		// The grid holding every element
		this._grid = new St.Widget({
			style_class: LibPanel.get_instance()._panel_grid._panel_style_class + ' quick-settings quick-settings-grid',
			layout_manager: new QuickSettingsLayout(placeholder, { nColumns }),
		});
		// Force the grid to take up all the available width. I'm using a constraint because x_expand don't work
		this._grid.add_constraint(new Clutter.BindConstraint({
			coordinate: Clutter.BindCoordinate.WIDTH,
			source: this,
		}));
		this.add_child(this._grid);
		this.container = this._grid;
		this._drag_actor = this._grid;
		this._grid.add_child(placeholder);

		this._dimEffect = new Clutter.BrightnessContrastEffect({ enabled: false });
		this._grid.add_effect_with_name('dim', this._dimEffect);

		this._overlay.add_constraint(new Clutter.BindConstraint({
			coordinate: Clutter.BindCoordinate.WIDTH,
			source: this._grid,
		}));

		this.add_child(this._overlay);
	}

	getItems() {
		// Every child except the placeholder
		return this._grid.get_children().filter(item => item != this._grid.layout_manager._overlay);
	}

	addItem(item, colSpan = 1) {
		this._grid.add_child(item);
		this.setColumnSpan(item, colSpan);

		if (item.menu) {
			this._overlay.add_child(item.menu.actor);

			this.connect_named(item.menu, 'open-state-changed', (_, isOpen) => {
				this._setDimmed(isOpen);
				this._activeMenu = isOpen ? item.menu : null;
				// The sub-popup for the power menu is too high.
				// I don't know if it's the real source of the issue, but I suspect that the constraint that fixes its y position
				// isn't accounting for the padding of the grid, so we add it to the offset manually
				// Later: I added the name check because it breaks on the audio panel
				// so I'm almost certain that this is not a proper fix
				if (isOpen && this.getItems().indexOf(item) == 0 && this.panel_name == "gnome@main") {
					const constraint = item.menu.actor.get_constraints()[0];
					constraint.offset = 
						// the offset is normally bound to the height of the source
						constraint.source.height
						+ this._grid.get_theme_node().get_padding(St.Side.TOP);
					// note: we don't reset this property when the item is removed from this panel because
					// we hope that it will reset itself (because it's bound to the height of the source),
					// which in the case in my tests, but maybe some issue will arise because of this
				}
			});
		}
		if (item._menuButton) {
			item._menuButton._libpanel_y_expand_backup = item._menuButton.y_expand;
			item._menuButton.y_expand = false;
		}
	}

	removeItem(item) {
		if (!this._grid.get_children().includes(item)) console.error(`[LibPanel] ${get_extension_uuid()} tried to remove an item not in the panel`);

		item.get_parent().remove_child(item);
		if (item.menu) {
			this.disconnect_named(item.menu);
			item.menu.actor.get_parent().remove_child(item.menu.actor);
		}
		if (item._menuButton) {
			item._menuButton.y_expand = item._menuButton._libpanel_y_expand_backup;
			item._menuButton._libpanel_y_expand_backup = undefined;
		}
	}

	getColumnSpan(item) {
		if (!this._grid.get_children().includes(item)) console.error(`[LibPanel] ${get_extension_uuid()} tried to get the column span of an item not in the panel`);

		const value = new GObject.Value();
		this._grid.layout_manager.child_get_property(this._grid, item, 'column-span', value);
		const column_span = value.get_int();
		value.unset();
		return column_span;
	}

	setColumnSpan(item, colSpan) {
		if (!this._grid.get_children().includes(item)) console.error(`[LibPanel] ${get_extension_uuid()} tried to set the column span of an item not in the panel`);

		this._grid.layout_manager.child_set_property(this._grid, item, 'column-span', colSpan);
	}

	_close() {
		this._activeMenu?.close(PopupAnimation.NONE);
	}

	_get_ah_children() {
		return this.getItems();
	}

	_setDimmed(dim) {
		// copied from https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/main/js/ui/quickSettings.js
		const DIM_BRIGHTNESS = -0.4;
		const POPUP_ANIMATION_TIME = 400;

		const val = 127 * (1 + (dim ? 1 : 0) * DIM_BRIGHTNESS);
		const color = Clutter.Color.new(val, val, val, 255);

		this._grid.ease_property('@effects.dim.brightness', color, {
			mode: Clutter.AnimationMode.LINEAR,
			duration: POPUP_ANIMATION_TIME,
			onStopped: () => (this._dimEffect.enabled = dim),
		});
		this._dimEffect.enabled = true;
	}
});

// Patching the default to menu to have the exact same api as the one from `Panel`.
// This way, extensions can use them the same way.
QuickSettingsMenu.prototype.getItems = function () {
	return this._grid.get_children().filter(item => item != this._grid.layout_manager._overlay);
};
QuickSettingsMenu.prototype.removeItem = function (item) {
	this._grid.remove_child(item);
	if (item.menu) {
		// it seems that some menus don't have _signalConnectionsByName (probably custom menus)
		// we check it exists before using it
		if (item.menu._signalConnectionsByName) {
			// Manually remove the connection since we don't have its id.
			for (const id of item.menu._signalConnectionsByName["open-state-changed"]) {
				if (item.menu._signalConnections[id].callback.toString().includes("this._setDimmed")) {
					item.menu.disconnect(id);
				}
			}
		}

		this._overlay.remove_child(item.menu.actor);
	}
};
QuickSettingsMenu.prototype.getColumnSpan = function (item) {
	const value = new GObject.Value();
	this._grid.layout_manager.child_get_property(this._grid, item, 'column-span', value);
	const column_span = value.get_int();
	value.unset();
	return column_span;
};
QuickSettingsMenu.prototype.setColumnSpan = function (item, colSpan) {
	this._grid.layout_manager.child_set_property(this._grid, item, 'column-span', colSpan);
};

var LibPanel = class {
	static _AutoHidable = AutoHidable;
	static _Semitransparent = Semitransparent;
	static _GridItem = GridItem;

	static _DropZone = DropZone;
	static _PanelGrid = PanelGrid;
	static _PanelColumn = PanelColumn;

	static _importer = Self;

	static get_instance() {
		return Main.panel._libpanel;
	}

	static get VERSION() {
		return LibPanel.get_instance()?.VERSION || VERSION;
	}

	// make the main panel available whether it's the gnome one or the libpanel one
	static get main_panel() {
		return LibPanel.get_instance()?._main_panel || QuickSettings.menu;
	}

	static get enabled() {
		return LibPanel.enablers.length !== 0;
	}

	static get enablers() {
		return LibPanel.get_instance()?._enablers || [];
	}

	static enable() {
		let instance = LibPanel.get_instance();
		if (!instance) {
			instance = Main.panel._libpanel = new LibPanel();
			instance._enable();
		};
		if (instance.constructor.VERSION != VERSION)
			console.warn(`[LibPanel] ${get_extension_uuid()} depends on libpanel ${VERSION} but libpanel ${instance.constructor.VERSION} is loaded`);

		const uuid = get_extension_uuid();
		if (instance._enablers.indexOf(uuid) < 0) instance._enablers.push(uuid);
	}

	static disable() {
		const instance = LibPanel.get_instance();
		if (!instance) return;

		const index = instance._enablers.indexOf(get_extension_uuid());
		if (index > -1) instance._enablers.splice(index, 1);

		if (instance._enablers.length === 0) {
			instance._disable();
			Main.panel._libpanel = undefined;
		};
	}

	static addPanel(panel) {
		const instance = LibPanel.get_instance();
		if (!instance)
			console.error(`[LibPanel] ${get_extension_uuid()} tried to add a panel, but the library is disabled.`);

		if (instance._settings.get_boolean('padding-enabled'))
			set_style(panel._grid, 'padding', `${instance._settings.get_int('padding')}px`);
		if (instance._settings.get_boolean('row-spacing-enabled'))
			set_style(panel._grid, 'spacing-rows', `${instance._settings.get_int('row-spacing')}px`);
		if (instance._settings.get_boolean('column-spacing-enabled'))
			set_style(panel._grid, 'spacing-columns', `${instance._settings.get_int('column-spacing')}px`);
		instance._panel_grid._add_panel(panel);
		instance._save_layout();
	}

	static removePanel(panel) {
		panel._keep_layout = true;
		panel.get_parent()?.remove_child(panel);
		panel._keep_layout = undefined;
	}

	constructor() {
		this._enablers = [];

		this._patcher = null;
		this._settings = null;
		this._panel_grid = null;
		this._old_menu = null;
	}

	_enable() {
		this._settings = get_settings(`${Self.path}/org.gnome.shell.extensions.libpanel.gschema.xml`);

		// ======================== Patching ========================
		this._patcher = new Patcher();
		// Permit disabling widget dragging
		this._patcher.replace_method(DND._Draggable, function _grabActor(wrapped, device, touchSequence) {
			if (this._disabled) return;
			wrapped(device, touchSequence);
		});
		// Backport from https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/2770
		if (get_shell_version().major <= 44) {
			this._patcher.replace_method(DND._Draggable, function _updateDragHover(_wrapped) {
				this._updateHoverId = 0;
				let target = this._pickTargetActor();

				let dragEvent = {
					x: this._dragX,
					y: this._dragY,
					dragActor: this._dragActor,
					source: this.actor._delegate,
					targetActor: target,
				};

				let targetActorDestroyHandlerId;
				let handleTargetActorDestroyClosure;
				handleTargetActorDestroyClosure = () => {
					target = this._pickTargetActor();
					dragEvent.targetActor = target;
					targetActorDestroyHandlerId =
						target.connect('destroy', handleTargetActorDestroyClosure);
				};
				targetActorDestroyHandlerId =
					target.connect('destroy', handleTargetActorDestroyClosure);

				for (let i = 0; i < DND.dragMonitors.length; i++) {
					let motionFunc = DND.dragMonitors[i].dragMotion;
					if (motionFunc) {
						let result = motionFunc(dragEvent);
						if (result != DND.DragMotionResult.CONTINUE) {
							global.display.set_cursor(DND.DRAG_CURSOR_MAP[result]);
							dragEvent.targetActor.disconnect(targetActorDestroyHandlerId);
							return GLib.SOURCE_REMOVE;
						}
					}
				}
				dragEvent.targetActor.disconnect(targetActorDestroyHandlerId);

				while (target) {
					if (target._delegate && target._delegate.handleDragOver) {
						let [r_, targX, targY] = target.transform_stage_point(this._dragX, this._dragY);
						// We currently loop through all parents on drag-over even if one of the children has handled it.
						// We can check the return value of the function and break the loop if it's true if we don't want
						// to continue checking the parents.
						let result = target._delegate.handleDragOver(this.actor._delegate,
							this._dragActor,
							targX,
							targY,
							0);
						if (result != DND.DragMotionResult.CONTINUE) {
							global.display.set_cursor(DND.DRAG_CURSOR_MAP[result]);
							return GLib.SOURCE_REMOVE;
						}
					}
					target = target.get_parent();
				}
				global.display.set_cursor(Meta.Cursor.DND_IN_DRAG);
				return GLib.SOURCE_REMOVE;
			});
		}
		// Add named connections to objects
		add_named_connections(this._patcher, GObject.Object);

		// =================== Replacing the popup ==================
		this._panel_grid = new PanelGrid(QuickSettings);
		for (const column of this._settings.get_value("layout").recursiveUnpack().reverse()) {
			this._panel_grid._add_column(column);
		}

		this._old_menu = this._replace_menu(this._panel_grid);

		const new_menu = new Panel('', 2);
		// we do that to prevent the name being this: `quick-settings-audio-panel@rayzeq.github.io/gnome@main`
		new_menu.panel_name = 'gnome@main';
		this._move_quick_settings(this._old_menu, new_menu);
		LibPanel.addPanel(new_menu);
		this._main_panel = new_menu;

		// =================== Compatibility code ===================
		//this._panel_grid.box = new_menu.box; // this would override existing properties
		//this._panel_grid.actor =  = new_menu.actor;
		this._panel_grid._dimEffect = new_menu._dimEffect;
		this._panel_grid._grid = new_menu._grid;
		this._panel_grid._overlay = new_menu._overlay;
		this._panel_grid._setDimmed = new_menu._setDimmed.bind(new_menu);
		this._panel_grid.addItem = new_menu.addItem.bind(new_menu);

		// ================== Visual customization ==================
		const set_style_for_panels = (name, value) => {
			for (const panel of this._panel_grid._get_panels()) {
				set_style(panel._grid, name, value);
			}
		};

		this._settings.connect('changed::padding-enabled', () => {
			if (this._settings.get_boolean('padding-enabled'))
				set_style_for_panels('padding', `${this._settings.get_int('padding')}px`);
			else
				set_style_for_panels('padding', null);
		});
		this._settings.connect('changed::padding', () => {
			if (!this._settings.get_boolean('padding-enabled')) return;
			set_style_for_panels('padding', `${this._settings.get_int('padding')}px`);
		});

		this._settings.connect('changed::row-spacing-enabled', () => {
			if (this._settings.get_boolean('row-spacing-enabled'))
				set_style_for_panels('spacing-rows', `${this._settings.get_int('row-spacing')}px`);
			else
				set_style_for_panels('spacing-rows', null);
		});
		this._settings.connect('changed::row-spacing', () => {
			if (!this._settings.get_boolean('row-spacing-enabled')) return;
			set_style_for_panels('spacing-rows', `${this._settings.get_int('row-spacing')}px`);
		});

		this._settings.connect('changed::column-spacing-enabled', () => {
			if (this._settings.get_boolean('column-spacing-enabled'))
				set_style_for_panels('spacing-columns', `${this._settings.get_int('column-spacing')}px`);
			else
				set_style_for_panels('spacing-columns', null);
		});
		this._settings.connect('changed::column-spacing', () => {
			if (!this._settings.get_boolean('column-spacing-enabled')) return;
			set_style_for_panels('spacing-columns', `${this._settings.get_int('column-spacing')}px`);
		});
		// https://gjs-docs.gnome.org/gio20~2.0/gio.settings#signal-changed
		// "Note that @settings only emits this signal if you have read key at
		// least once while a signal handler was already connected for key."
		this._settings.get_boolean('padding-enabled');
		this._settings.get_boolean('row-spacing-enabled');
		this._settings.get_boolean('column-spacing-enabled');
		this._settings.get_int('padding');
		this._settings.get_int('row-spacing');
		this._settings.get_int('column-spacing');
	};

	_disable() {
		this._move_quick_settings(this._main_panel, this._old_menu);
		this._replace_menu(this._old_menu);
		this._old_menu = null;

		this._panel_grid.destroy();
		this._panel_grid = null;

		this._settings = null;

		this._patcher.unpatch_all();
		this._patcher = null;
	}

	_replace_menu(new_menu) {
		const old_menu = QuickSettings.menu;

		MenuManager.removeMenu(old_menu);
		Main.layoutManager.disconnectObject(old_menu);

		QuickSettings.menu = null; // prevent old_menu from being destroyed
		QuickSettings.setMenu(new_menu);
		old_menu.actor.get_parent().remove_child(old_menu.actor);

		MenuManager.addMenu(new_menu);
		Main.layoutManager.connectObject('system-modal-opened', () => new_menu.close(), new_menu);

		return old_menu;
	}

	_move_quick_settings(old_menu, new_menu) {
		for (const item of old_menu.getItems()) {
			const column_span = old_menu.getColumnSpan(item);
			const visible = item.visible;

			old_menu.removeItem(item);

			new_menu.addItem(item, column_span);
			item.visible = visible; // force reset of visibility
		}
	}

	_save_layout() {
		const layout = this._panel_grid._get_panel_layout();

		// Remove leading empty columns
		while (layout[0]?.length === 0) layout.shift();
		this._settings.set_value(
			"layout",
			GLib.Variant.new_array(
				GLib.VariantType.new('as'),
				layout.map(column => GLib.Variant.new_strv(column))
			)
		);
	}
};
