const { GObject, St } = imports.gi

const ExtensionUtils = imports.misc.extensionUtils
const Me = ExtensionUtils.getCurrentExtension()

const { EditTransactionScreen } = Me.imports.components.screens.editTransactionScreen.editTransactionScreen
const { StockOverviewScreen } = Me.imports.components.screens.stockOverviewScreen.stockOverviewScreen
const { StockNewsListScreen } = Me.imports.components.screens.stockNewsListScreen.stockNewsListScreen
const { StockTransactionsScreen } = Me.imports.components.screens.stockTransactionsScreen.stockTransactionsScreen
const { StockDetailsScreen } = Me.imports.components.screens.stockDetailsScreen.stockDetailsScreen

var ScreenWrapper = GObject.registerClass({
      GTypeName: 'StockExtension_ScreenWrapper'
    },
    class ScreenWrapper extends St.Widget {
      _init (mainEventHandler) {
        super._init({
          style_class: 'screen-wrapper'
        })

        this._mainEventHandler = mainEventHandler

        this._showScreenConnectId = this._mainEventHandler.connect('show-screen', (sender, { screen, additionalData }) => this.showScreen(screen, additionalData))

        this.connect('destroy', this._onDestroy.bind(this))

        this.showScreen()
      }

      showScreen (screenName, additionalData) {
        let screen

        switch (screenName) {
          case 'stock-details':
            screen = new StockDetailsScreen({ portfolioId: additionalData.portfolioId, quoteSummary: additionalData.item, mainEventHandler: this._mainEventHandler })
            break

          case 'stock-news-list':
            screen = new StockNewsListScreen({ portfolioId: additionalData.portfolioId, quoteSummary: additionalData.item, mainEventHandler: this._mainEventHandler })
            break

          case 'stock-transactions':
            screen = new StockTransactionsScreen({ portfolioId: additionalData.portfolioId, quoteSummary: additionalData.item, mainEventHandler: this._mainEventHandler })
            break

          case 'edit-transaction':
            screen = new EditTransactionScreen({ transaction: additionalData.transaction, portfolioId: additionalData.portfolioId, quoteSummary: additionalData.item, mainEventHandler: this._mainEventHandler })
            break

          case 'overview':
          default:
            screen = new StockOverviewScreen(this._mainEventHandler)
            break
        }

        this.destroy_all_children()

        this.add_actor(screen)
      }

      _onDestroy () {
        if (this._showScreenConnectId) {
          this._mainEventHandler.disconnect(this._showScreenConnectId)
        }
      }
    }
)
