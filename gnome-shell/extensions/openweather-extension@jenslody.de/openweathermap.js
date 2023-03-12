/*
   This file is part of OpenWeather (gnome-shell-extension-openweather).

   OpenWeather is free software: you can redistribute it and/or modify it under the terms of
   the GNU General Public License as published by the Free Software Foundation, either
   version 3 of the License, or (at your option) any later version.

   OpenWeather is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
   See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with OpenWeather.
   If not, see <https://www.gnu.org/licenses/>.

   Copyright 2022 Jason Oickle
*/

const Soup = imports.gi.Soup;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Gettext = imports.gettext.domain(Me.metadata['gettext-domain']);
const _ = Gettext.gettext;

// Map OpenWeatherMap icon codes to icon names
const IconMap = {
    "01d": "weather-clear-symbolic",             // "clear sky"
    "02d": "weather-few-clouds-symbolic",        // "few clouds"
    "03d": "weather-few-clouds-symbolic",        // "scattered clouds"
    "04d": "weather-overcast-symbolic",          // "broken clouds"
    "09d": "weather-showers-scattered-symbolic", // "shower rain"
    "10d": "weather-showers-symbolic",           // "rain"
    "11d": "weather-storm-symbolic",             // "thunderstorm"
    "13d": "weather-snow-symbolic",              // "snow"
    "50d": "weather-fog-symbolic",               // "mist"
    "01n": "weather-clear-night-symbolic",       // "clear sky night"
    "02n": "weather-few-clouds-night-symbolic",  // "few clouds night"
    "03n": "weather-few-clouds-night-symbolic",  // "scattered clouds night"
    "04n": "weather-overcast-symbolic",          // "broken clouds night"
    "09n": "weather-showers-scattered-symbolic", // "shower rain night"
    "10n": "weather-showers-symbolic",           // "rain night"
    "11n": "weather-storm-symbolic",             // "thunderstorm night"
    "13n": "weather-snow-symbolic",              // "snow night"
    "50n": "weather-fog-symbolic"                // "mist night"
}

function getWeatherCondition(code) {
    switch (parseInt(code, 10)) {
        case 200: //약한 비와 천둥
            return _('약한 비와 천둥');
        case 201: //비와 천둥
            return _('비와 천둥');
        case 202: //심한 비와 천둥
            return _('심한 비와 천둥');
        case 210: //약한 천둥
            return _('약한 천둥');
        case 211: //천둥
            return _('천둥');
        case 212: //심한 천둥
            return _('심한 천둥');
        case 221: //불규칙적인 천둥
            return _('약한 천둥');
        case 230: //약한 비와 천둥
            return _('약한 비와 천둥');
        case 231: //비와 천둥
            return _('비와 천둥');
        case 232: //심한 비와 천둥
            return _('심한 비와 천둥');
        case 300: //약한 비
            return _('약한 비');
        case 301: //비
            return _('비');
        case 302: //심한 비
            return _('심한 비');
        case 310: //약한 비
            return _('약한 비');
        case 311: //비
            return _('비');
        case 312: //심한 비
            return _('심한 비');
        case 313: //비
            return _('비');
        case 314: //심한 비
            return _('심한 비');
        case 321: //비
            return _('비');
        case 500: //약한 비
            return _('약한 비');
        case 501: //보통 비
            return _('보통 비');
        case 502: //심한 비
            return _('심한 비');
        case 503: //매우 심한 비
            return _('매우 심한 비');
        case 504: //극심한 비
            return _('극심한 비');

        case 511: //Freezing rain
            return _('추운 비');
        case 520: //Light intensity shower rain
            return _('약한 비');
        case 521: //Shower rain
            return _('비');
        case 522: //Heavy intensity shower rain
            return _('강한 비');
        case 531: //Ragged shower rain
            return _('약한 비');
        case 600: //Light snow
            return _('약한 눈');
        case 601: //Snow
            return _('눈');
        case 602: //Heavy snow
            return _('폭설');
        case 611: //Sleet
            return _('눈');
        case 612: //Light shower sleet
            return _('약한 눈');
        case 613: //Shower sleet
            return _('눈');
        case 615: //Light rain and snow
            return _('약한 비와 눈');
        case 616: //Rain and snow
            return _('비와 눈');
        case 620: //Light shower snow
            return _('약한 비와 눈');
        case 621: //Shower snow
            return _('비와 눈');
        case 622: //Heavy shower snow
            return _('강한 비와 눈');
        case 701: //Mist
            return _('안개');
        case 711: //Smoke
            return _('연기');
        case 721: //Haze
            return _('실안개');
        case 731: //Sand/Dust Whirls
            return _('모래/먼지 회오리');
        case 741: //Fog
            return _('안개');
        case 751: //Sand
            return _('모래');
        case 761: //Dust
            return _('먼지');
        case 762: //volcanic ash
            return _('화산재');
        case 771: //squalls
            return _('돌풍');
        case 781: //tornado
            return _('토네이도');

        case 800: //맑은 하늘
            return _('맑은 하늘');
        case 801: //약간의 구름
            return _('약간 구름');
        case 802: //산개구름
            return _('산개 구름');
        case 803: //부분적으로 흐림
            return _('조금 흐림');
        case 804: //흐린 하늘
            return _('흐린 하늘');
        default:
            return _('사용 불가');
    }
}

async function initWeatherData(refresh) {
    if (refresh) {
        this._lastRefresh = Date.now();
    }
    try {
        await this.refreshWeatherData()
        .then(async () => {
            try {
                if (!this._isForecastDisabled) {
                    await this.refreshForecastData()
                    .then(this.recalcLayout());
                } else {
                    this.recalcLayout();
                }
            }
            catch (e) {
                logError(e);
            }
        });
    }
    catch (e) {
        logError(e);
    }
}

async function reloadWeatherCache() {
    try {
        await this.populateCurrentUI()
        .then(async () => {
            try {
                if (!this._isForecastDisabled) {
                    if (this.forecastJsonCache === undefined) {
                        // cache was cleared, so we need to force a refresh
                        await this.refreshForecastData()
                        .then(this.recalcLayout());
                    } else {
                        // otherwise we just reload the current cache
                        await this.populateTodaysUI()
                        .then(async () => {
                            if (this._forecastDays >= 1) {
                                await this.populateForecastUI();
                            }
                        }).then(this.recalcLayout());
                    }
                }
            }
            catch (e) {
                logError(e);
            }
        });
    }
    catch (e) {
        logError(e);
    }
}

async function refreshWeatherData() {
    let json = undefined;
    let location = this.extractCoord(this._city);
    let params = {
        lat: location.split(",")[0],
        lon: location.split(",")[1],
        units: 'metric'
    };
    if (this._providerTranslations) {
        params.lang = this.locale;
    }
    if (this._appid) {
        params.appid = this._appid;
    }
    const owmCurrentUrl = 'https://api.openweathermap.org/data/2.5/weather';
    try {
        json = await this.loadJsonAsync(owmCurrentUrl, params)
        .then(async (json) => {
            try {
                this.currentWeatherCache = json;
                await this.populateCurrentUI();
            }
            catch (e) {
                logError(e);
            }
        });
    }
    catch (e) {
        // Something went wrong, reload after 10 minutes
        // as per openweathermap.org recommendation.
        this.reloadWeatherCurrent(600);
        logError(e);
    }
    this.reloadWeatherCurrent(this._refresh_interval_current);
}

async function refreshForecastData() {
    // Did the user disable the forecast?
    if (this._isForecastDisabled) {
        return;
    }
    let json = undefined;
    let sortedList = undefined;
    let todayList = undefined;
    let location = this.extractCoord(this._city);
    let params = {
        lat: location.split(",")[0],
        lon: location.split(",")[1],
        units: 'metric'
    };
    if (this._providerTranslations) {
        params.lang = this.locale;
    }
    if (this._appid) {
        params.appid = this._appid;
    }
    const owmForecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    try {
        json = await this.loadJsonAsync(owmForecastUrl, params)
        .then(async (json) => {
            processing: try {

                if (this.forecastJsonCache) {
                    let _freshData = JSON.stringify(json.list[0]);
                    let _cacheData = JSON.stringify(this.forecastJsonCache.list[0]);
                    if (_freshData === _cacheData) {
                        // No need to process if data unchanged
                        break processing;
                    }
                }
                this.forecastJsonCache = json;
                this.todaysWeatherCache = undefined;
                this.forecastWeatherCache = undefined;
                this.owmCityId = json.city.id;
                // Today's forecast
                todayList = await this.processTodaysData(json)
                .then(async (todayList) => {
                    try {
                        this.todaysWeatherCache = todayList;
                        await this.populateTodaysUI();
                    }
                    catch (e) {
                        logError(e);
                    }
                });
                // 5 day / 3 hour forecast
                if (this._forecastDays === 0) {
                    // Stop if only today's forecast is enabled
                    break processing;
                }
                sortedList = await this.processForecastData(json)
                .then(async (sortedList) => {
                    try {
                        this.forecastWeatherCache = sortedList;
                        await this.populateForecastUI();
                    }
                    catch (e) {
                        logError(e);
                    }
                });
            }
            catch (e) {
                logError(e);
            }
        });
    }
    catch (e) {
        /// Something went wrong, reload after 10 minutes
        // as per openweathermap.org recommendation.
        this.reloadWeatherForecast(600);
        logError(e);
    }
    this.reloadWeatherForecast(this._refresh_interval_forecast);
}

function populateCurrentUI() {
    return new Promise((resolve, reject) => {
        try {
            let json = this.currentWeatherCache;
            this.owmCityId = json.id;

            let comment = json.weather[0].description;
            if (this._translate_condition && !this._providerTranslations)
                comment = getWeatherCondition(json.weather[0].id);

            let location = this.extractLocation(this._city);
            let temperature = this.formatTemperature(json.main.temp);
            let sunrise = new Date(json.sys.sunrise * 1000);
            let sunset = new Date(json.sys.sunset * 1000);
            let now = new Date();
            let lastBuild = '-';

            if (this._clockFormat == "24h") {
                sunrise = sunrise.toLocaleTimeString([this.locale], { hour12: false });
                sunset = sunset.toLocaleTimeString([this.locale], { hour12: false });
                lastBuild = now.toLocaleTimeString([this.locale], { hour12: false });
            } else {
                sunrise = sunrise.toLocaleTimeString([this.locale], { hour: 'numeric', minute: 'numeric' });
                sunset = sunset.toLocaleTimeString([this.locale], { hour: 'numeric', minute: 'numeric' });
                lastBuild = now.toLocaleTimeString([this.locale], { hour: 'numeric', minute: 'numeric' });
            }

            let iconname = IconMap[json.weather[0].icon];
            this._currentWeatherIcon.set_gicon(this.getWeatherIcon(iconname));
            this._weatherIcon.set_gicon(this.getWeatherIcon(iconname));

            let weatherInfoC = "";
            let weatherInfoT = "";

            if (this._comment_in_panel)
                weatherInfoC = comment;
            if (this._text_in_panel)
                weatherInfoT = temperature;

            this._weatherInfo.text = weatherInfoC + ((weatherInfoC && weatherInfoT) ? _(", ") : "") + weatherInfoT;

            this._currentWeatherSummary.text = comment + _(", ") + temperature;
            if (this._loc_len_current != 0 && location.length > this._loc_len_current)
                this._currentWeatherLocation.text = location.substring(0, (this._loc_len_current - 3)) + "...";
            else
                this._currentWeatherLocation.text = location;
            this._currentWeatherFeelsLike.text = this.formatTemperature(json.main.feels_like);
            this._currentWeatherHumidity.text = json.main.humidity + ' %';
            this._currentWeatherPressure.text = this.formatPressure(json.main.pressure);
            this._currentWeatherSunrise.text = sunrise;
            this._currentWeatherSunset.text = sunset;
            this._currentWeatherBuild.text = lastBuild;
            if (json.wind != undefined && json.wind.deg != undefined) {
                this._currentWeatherWind.text = this.formatWind(json.wind.speed, this.getWindDirection(json.wind.deg));
                if (json.wind.gust != undefined)
                    this._currentWeatherWindGusts.text = this.formatWind(json.wind.gust);
            } else {
                this._currentWeatherWind.text = _("?");
            }
            resolve(0);
        }
        catch (e) {
            reject(e);
        }
    });
}

function populateTodaysUI() {
    return new Promise((resolve, reject) => {
        try {
            // Populate today's forecast UI
            let forecast_today = this.todaysWeatherCache;

            for (var i = 0; i < 4; i++) {
                let forecastTodayUi = this._todays_forecast[i];
                let forecastDataToday = forecast_today[i];

                let forecastTime = new Date(forecastDataToday.dt * 1000);
                let forecastTemp = this.formatTemperature(forecastDataToday.main.temp);
                let iconTime = forecastTime.toLocaleTimeString([this.locale], { hour12: false });
                let iconname = IconMap[forecastDataToday.weather[0].icon];

                let comment = forecastDataToday.weather[0].description;
                if (this._translate_condition && !this._providerTranslations)
                    comment = getWeatherCondition(forecastDataToday.weather[0].id);

                if (this._clockFormat == "24h") {
                    forecastTime = forecastTime.toLocaleTimeString([this.locale], { hour12: false });
                    forecastTime = forecastTime.substring(0, forecastTime.length -3);
                } else {
                    forecastTime = forecastTime.toLocaleTimeString([this.locale], { hour: 'numeric' });
                }
                forecastTodayUi.Time.text = forecastTime;
                forecastTodayUi.Icon.set_gicon(this.getWeatherIcon(iconname));
                forecastTodayUi.Temperature.text = forecastTemp;
                forecastTodayUi.Summary.text = comment;
            }
            resolve(0);
        }
        catch (e) {
            reject(e);
        }
    });
}

function populateForecastUI() {
    return new Promise((resolve, reject) => {
        try {
            // Populate 5 day / 3 hour forecast UI
            let forecast = this.forecastWeatherCache;

            for (let i = 0; i < this._forecastDays; i++) {
                let forecastUi = this._forecast[i];
                let forecastData = forecast[i];

                for (let j = 0; j < 8; j++) {
                    if (forecastData[j] === undefined)
                        continue;

                    let forecastDate = new Date(forecastData[j].dt * 1000);
                    if (j === 0) {
                        let beginOfDay = new Date(new Date().setHours(0, 0, 0, 0));
                        let dayLeft = Math.floor((forecastDate.getTime() - beginOfDay.getTime()) / 86400000);

                        if (dayLeft == 1)
                            forecastUi.Day.text = '\n'+_("Tomorrow");
                        else
                            forecastUi.Day.text = '\n'+this.getLocaleDay(forecastDate.getDay());
                    }
                    let iconTime = forecastDate.toLocaleTimeString([this.locale], { hour12: false });
                    let iconname = IconMap[forecastData[j].weather[0].icon];
                    let forecastTemp = this.formatTemperature(forecastData[j].main.temp);

                    let comment = forecastData[j].weather[0].description;
                    if (this._translate_condition && !this._providerTranslations)
                        comment = getWeatherCondition(forecastData[j].weather[0].id);

                    if (this._clockFormat == "24h") {
                        forecastDate = forecastDate.toLocaleTimeString([this.locale], { hour12: false });
                        forecastDate = forecastDate.substring(0, forecastDate.length -3);
                    }
                    else {
                        forecastDate = forecastDate.toLocaleTimeString([this.locale], { hour: 'numeric' });
                    }
                    forecastUi[j].Time.text = forecastDate;
                    forecastUi[j].Icon.set_gicon(this.getWeatherIcon(iconname));
                    forecastUi[j].Temperature.text = forecastTemp;
                    forecastUi[j].Summary.text = comment;
                }
            }
            resolve(0);
        }
        catch (e) {
            reject(e);
        }
    });
}

function loadJsonAsync(url, params) {
    return new Promise((resolve, reject) => {

        // Create user-agent string from uuid and (if present) the version
        let _userAgent = Me.metadata.uuid;
        if (Me.metadata.version !== undefined && Me.metadata.version.toString().trim() !== '') {
            _userAgent += '/';
            _userAgent += Me.metadata.version.toString();
        }

        let _httpSession = new Soup.Session();
        let _message = Soup.form_request_new_from_hash('GET', url, params);
        // add trailing space, so libsoup adds its own user-agent
        _httpSession.user_agent = _userAgent + ' ';

        _httpSession.queue_message(_message, (_httpSession, _message) => {
            try {
                if (!_message.response_body.data)
                    reject("No data");

                resolve(JSON.parse(_message.response_body.data));
            }
            catch (e) {
                reject(e);
            }
        });
    });
}

function processTodaysData(json) {
    return new Promise((resolve, reject) => {
        try {
            let data = json.list;
            let todayList = [];

            for (let i = 0; i < 4; i++)
                todayList.push(data[i]);

            resolve(todayList);
        }
        catch (e) {
            reject(e);
        }
    });
}

function processForecastData(json) {
    return new Promise((resolve, reject) => {
        try {
            let i = a = 0;
            let data = json.list;
            let sortedList = [];
            let _now = new Date().toLocaleDateString([this.locale]);

            for (let j = 0; j < data.length; j++) {
                let _this = new Date(data[i].dt * 1000).toLocaleDateString([this.locale]);
                let _last = new Date(data[((i===0) ? 0 : i-1)].dt * 1000).toLocaleDateString([this.locale]);

                if (_now ===_this) {
                    // Don't add today's items
                    i++;
                    continue;
                }
                if (sortedList.length === 0) {
                    // First item in json list
                    sortedList[a] = [data[i]];
                    i++;
                    continue;
                }

                if (_this == _last) {
                    // Add item to current day
                    sortedList[a].push(data[i]);
                } else {
                    if (sortedList.length === this._forecastDays) {
                        // If we reach the forecast limit set by the user
                        break;
                    }
                    // Otherwise start a new day
                    a = a+1;
                    sortedList[a] = [];
                    sortedList[a].push(data[i]);
                }
                i++;
            }
            resolve(sortedList);
        }
        catch (e) {
            reject(e);
        }
    });
}
