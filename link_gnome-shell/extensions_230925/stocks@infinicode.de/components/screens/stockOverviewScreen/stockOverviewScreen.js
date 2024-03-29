const { GObject, St } = imports.gi

const Mainloop = imports.mainloop

const ExtensionUtils = imports.misc.extensionUtils
const Me = ExtensionUtils.getCurrentExtension()

const { ButtonGroup } = Me.imports.components.buttons.buttonGroup
const { FlatList } = Me.imports.components.flatList.flatList
const { StockCard } = Me.imports.components.cards.stockCard
const { SearchBar } = Me.imports.components.searchBar.searchBar
const { setTimeout, clearTimeout } = Me.imports.helpers.components
const { isNullOrEmpty, removeCache } = Me.imports.helpers.data

const {
  SettingsHandler,
  STOCKS_PORTFOLIOS,
  STOCKS_SYMBOL_PAIRS,
  STOCKS_SELECTED_PORTFOLIO,
  STOCKS_USE_PROVIDER_INSTRUMENT_NAMES
} = Me.imports.helpers.settings

const { Translations } = Me.imports.helpers.translations

const FinanceService = Me.imports.services.financeService

const SETTING_KEYS_TO_REFRESH = [
  STOCKS_SYMBOL_PAIRS,
  STOCKS_SELECTED_PORTFOLIO,
  STOCKS_PORTFOLIOS,
  STOCKS_USE_PROVIDER_INSTRUMENT_NAMES
]

var StockOverviewScreen = GObject.registerClass({
  GTypeName: 'StockExtension_StockOverviewScreen'
}, class StockOverviewScreen extends St.BoxLayout {
  _init (mainEventHandler) {
    super._init({
      style_class: 'screen stock-overview-screen',
      vertical: true
    })

    this._mainEventHandler = mainEventHandler

    this._isRendering = false
    this._showLoadingInfoTimeoutId = null
    this._autoRefreshTimeoutId = null

    this._settings = new SettingsHandler()

    this._searchBar = new SearchBar({ mainEventHandler: this._mainEventHandler })
    this._portfolioGroup = new ButtonGroup({ buttons: [], y_expand: false })
    this._list = new FlatList({ id: 'stock_overview', persistScrollPosition: true })

    this.add_child(this._searchBar)
    this.add_child(this._portfolioGroup)
    this.add_child(this._list)

    this.connect('destroy', this._onDestroy.bind(this))

    this._searchBar.connect('refresh', () => {
      removeCache('summary_')
      this._loadData()
      this._createPortfolioButtonGroup()
    })

    this._searchBar.connect('text-change', (sender, searchText) => this._filter_results(searchText))

    this._settingsChangedId = this._settings.connect('changed', (value, key) => {
      if (SETTING_KEYS_TO_REFRESH.includes(key)) {
        this._loadData()
        this._createPortfolioButtonGroup()
      }
    })

    this._list.connect('clicked-item', (sender, item) => this._mainEventHandler.emit('show-screen', {
      screen: 'stock-details',
      additionalData: {
        portfolioId: this._settings.selected_portfolio,
        item: item.cardItem
      }
    }))

    this._createPortfolioButtonGroup()

    this._loadData()

    this._registerTimeout()
  }

  _filter_results (searchText) {
    const listItems = this._list.items

    listItems.forEach(item => {
      const data = item.cardItem

      if (!searchText) {
        item.visible = true
        return
      }

      const searchContent = `${data.FullName} ${data.ExchangeName} ${data.Symbol}`.toUpperCase()

      item.visible = searchContent.includes(searchText.toUpperCase())
    })
  }

  async _createPortfolioButtonGroup () {
    const portfolios = this._settings.portfolios

    if (!portfolios.find(item => item.id == this._settings.selected_portfolio)) {
      this._settings.selected_portfolio = this._settings.portfolios[0].id
    }

    let buttons = []

    if (portfolios && portfolios.length > 1) {
      buttons = portfolios.map(item => ({
        label: item.name,
        value: item.id,
        selected: this._settings.selected_portfolio == item.id
      }))
    }

    const newButtonGroup = new ButtonGroup({ buttons, y_expand: false })
    newButtonGroup.connect('clicked', (_, stButton) => {
      this._settings.selected_portfolio = stButton.buttonData.value
    })

    this.replace_child(this._portfolioGroup, newButtonGroup)

    this._portfolioGroup = newButtonGroup
  }

  _registerTimeout () {
    this._autoRefreshTimeoutId = Mainloop.timeout_add_seconds(this._settings.ticker_interval || 10, () => {
      this._loadData()

      return true
    })
  }

  async _loadData () {
    if (this._showLoadingInfoTimeoutId || this._isRendering) {
      return
    }

    const portfolios = this._settings.portfolios
    const selectedOrFirstPortfolio = portfolios.find(item => item.id == this._settings.selected_portfolio) || portfolios[0]

    const symbols = selectedOrFirstPortfolio.symbols

    if (isNullOrEmpty(symbols)) {
      this._list.show_error_info(Translations.NO_SYMBOLS_CONFIGURED_ERROR)
      return
    }

    this._isRendering = true

    this._showLoadingInfoTimeoutId = setTimeout(() => this._list.show_loading_info(), 500)

    const quoteSummaries = await Promise.all(
        symbols.map(symbolData => FinanceService.getQuoteSummary({
          ...symbolData,
          fallbackName: symbolData.name
        }))
    )

    this._showLoadingInfoTimeoutId = clearTimeout(this._showLoadingInfoTimeoutId)

    this._list.clear_list_items()

    quoteSummaries.forEach(quoteSummary => {
      this._list.addItem(new StockCard(quoteSummary, this._settings.selected_portfolio))
    })

    this._filter_results(this._searchBar.search_text())

    // const savedScrollPosition = await cacheOrDefault('scroll_stock_overview', () => this._list.vscroll.adjustment.value, 365 * 24 * 60 * 60 * 1000)
    //
    // setTimeout(() => {
    //   if (this._list.vscroll.adjustment.value !== savedScrollPosition) {
    //     // could not figure out which event might be appropriate to set the position properly, so we work with this
    //     this._list.vscroll.adjustment.value = savedScrollPosition
    //   }
    // }, 50)

    this._isRendering = false
  }

  _onDestroy () {
    if (this._showLoadingInfoTimeoutId) {
      clearTimeout(this._showLoadingInfoTimeoutId)
    }

    if (this._autoRefreshTimeoutId) {
      Mainloop.source_remove(this._autoRefreshTimeoutId)
    }

    if (this._settingsChangedId) {
      this._settings.disconnect(this._settingsChangedId)
    }
  }
})
