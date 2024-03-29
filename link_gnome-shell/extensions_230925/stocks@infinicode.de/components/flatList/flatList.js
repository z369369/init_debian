const { Clutter, GObject, Graphene, St, Gtk } = imports.gi

const ExtensionUtils = imports.misc.extensionUtils
const Me = ExtensionUtils.getCurrentExtension()

const { ScaleLayout } = Me.imports.components.scaleLayout.scaleLayout
const { cacheOrDefault, removeCache } = Me.imports.helpers.data
const { Translations } = Me.imports.helpers.translations

var MESSAGE_ANIMATION_TIME = 100

var FlatList = GObject.registerClass({
  GTypeName: 'StockExtension_FlatList',
  Signals: {
    'clicked-item': {
      param_types: [GObject.TYPE_OBJECT]
    }
  }
}, class FlatList extends St.ScrollView {
  _init ({ id, persistScrollPosition } = {}) {
    super._init({
      style_class: 'scroll-box',
      overlay_scrollbars: true,
      x_expand: true,
      y_expand: true,
      clip_to_allocation: true,
      hscrollbar_policy: Gtk.PolicyType.NEVER,
      vscrollbar_policy: Gtk.PolicyType.AUTOMATIC
    })

    this._id = id
    this._persist_scroll_position = persistScrollPosition
    this._resetScrollPositionTimeoutId = null

    this._content = new St.BoxLayout({
      style_class: 'flatlist',
      vertical: true,
      x_expand: true,
      y_expand: true
    })

    if (this._persist_scroll_position) {
      this.enable_persistent_scroll_position()
    }

    this.add_actor(this._content)

    this.connect('destroy', this._onDestroy.bind(this))
  }

  get items () {
    return this._content.get_children().map(i => i.child)
  }

  clear_list_items () {
    this._content.destroy_all_children()
  }

  enable_persistent_scroll_position () {
    const cacheKey = `${this._id}_scroll_position`;
    this.connect('scroll-event', () => {
      cacheOrDefault(cacheKey, () => this.vscroll.adjustment.value, -1)
    })

    this.vscroll.connect('scroll-stop', () => {
      cacheOrDefault(cacheKey, () => this.vscroll.adjustment.value, -1)
    })

    this._content.connect('stage-views-changed', async () => {
      const savedScrollPosition = await cacheOrDefault(cacheKey, () => this.vscroll.adjustment.value, 365 * 24 * 60 * 60 * 1000)

      this._resetScrollPositionTimeoutId = setTimeout(() => {
        if (this.vscroll.adjustment.value !== savedScrollPosition) {
          this.vscroll.adjustment.value = savedScrollPosition
        }
      }, 150)
    })
  }

  show_loading_info (text) {
    this.clear_list_items()

    const listInfo = new St.Button({
      style_class: 'flat-list-loading-text',

      label: text || Translations.LOADING_DATA
    })

    this._content.add_child(listInfo)
  }

  show_error_info (text) {
    this.clear_list_items()

    const errorInfo = new St.Button({
      style_class: 'flat-list-error-text',
      label: text || Translations.ERROR_LOADING_DATA
    })

    this._content.add_child(errorInfo)
  }

  addItem (item, animate) {
    this.addItemAtIndex(item, -1, animate)
  }

  addItemAtIndex (item, index, animate) {
    if (this.items.includes(item)) {
      throw new Error('Message was already added previously')
    }

    item.connect('clicked', () => {
      this.emit('clicked-item', item)
    })

    const listItem = new St.Bin({
      child: item,
      layout_manager: new ScaleLayout(),
      pivot_point: new Graphene.Point({ x: .5, y: .5 })
    })

    this._content.insert_child_at_index(listItem, index)

    if (animate) {
      listItem.set({ scale_x: 0, scale_y: 0 })
      listItem.ease({
        scale_x: 1,
        scale_y: 1,
        duration: MESSAGE_ANIMATION_TIME,
        mode: Clutter.AnimationMode.EASE_OUT_QUAD
      })
    }
  }

  _onDestroy () {
    if (this._resetScrollPositionTimeoutId) {
      clearTimeout(this._resetScrollPositionTimeoutId)
    }
  }
})
