import QtQuick
import Quickshell.Io

// Current weather and a three-day forecast from wttr.in, refreshed every 20 minutes.
// The shell exposes it as `shell.weather`; the widgets read the values from there.
Item {
    id: weather

    property string city: "LOCALISATION…"
    // IP geolocation can resolve to a nearby town, so keep the weather view
    // tied to the user's actual city instead.
    readonly property string location: "Gänserndorf"
    property string temperature: "—"
    property string feelsLike: "—"
    property string humidity: "—"
    property string wind: "—"
    property string rain: "—"
    property int code: -1
    property string updated: "—"
    property var forecast: []
    property bool online: false

    function icon(code: int): string {
        if (code === 113)
            return "󰖙";
        if (code === 116)
            return "󰖕";
        if (code === 119 || code === 122)
            return "󰖐";
        if ([143, 248, 260].includes(code))
            return "󰖑";
        if ([200, 386, 389, 392, 395].includes(code))
            return "󰖓";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(code))
            return "󰖘";
        if ([176, 182, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308,
            311, 314, 317, 320, 350, 353, 356, 359, 362, 365, 374, 377].includes(code))
            return "󰖖";
        return "󰖐";
    }

    // Name of the pixel icon (assets/icons) for a wttr.in weather code.
    function iconName(code: int): string {
        if (code === 113)
            return "sun";
        if (code === 116)
            return "partly-cloudy";
        if (code === 119 || code === 122)
            return "cloud";
        if ([143, 248, 260].includes(code))
            return "fog";
        if ([200, 386, 389, 392, 395].includes(code))
            return "thunder";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(code))
            return "snow";
        if ([176, 182, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308,
            311, 314, 317, 320, 350, 353, 356, 359, 362, 365, 374, 377].includes(code))
            return "rain";
        return "cloud";
    }

    function condition(code: int): string {
        if (code === 113)
            return "CLEAR";
        if (code === 116)
            return "PARTLY CLOUDY";
        if (code === 119 || code === 122)
            return "CLOUDY";
        if ([143, 248, 260].includes(code))
            return "FOG";
        if ([200, 386, 389, 392, 395].includes(code))
            return "THUNDER";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(code))
            return "SNOW";
        if ([176, 182, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308,
            311, 314, 317, 320, 350, 353, 356, 359, 362, 365, 374, 377].includes(code))
            return "RAIN";
        return "CLOUDY";
    }

    function dayLabel(date: string): string {
        const names = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return names[new Date(date + "T12:00:00").getDay()];
    }


    function setOffline(): void {
        online = false;
        city = "WEATHER OFFLINE";
        temperature = "—";
        feelsLike = "—";
        humidity = "—";
        wind = "—";
        rain = "—";
        code = -1;
        updated = "OFFLINE";
        forecast = [];
    }

    Process {
        id: fetchProcess
        // wttr.in needs no API key. A fixed city is more reliable than an
        // IP-derived location, which can resolve to a nearby town.
        command: ["bash", "-o", "pipefail", "-c", "curl --fail --silent --show-error --max-time 8 'https://wttr.in/G%C3%A4nserndorf?format=j1' | tr -d '\\n'; printf '\\n'"]
        running: true
        onExited: function(exitCode) {
            if (exitCode !== 0)
                weather.setOffline();
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const report = JSON.parse(data.trim());
                    const current = report.current_condition[0];
                    weather.online = true;
                    weather.city = weather.location.toUpperCase();
                    weather.temperature = current.temp_C + "°";
                    weather.feelsLike = current.FeelsLikeC + "°";
                    weather.humidity = current.humidity + "%";
                    weather.wind = current.winddir16Point + " " + current.windspeedKmph + " KM/H";
                    weather.rain = current.precipMM + " MM";
                    weather.code = Number(current.weatherCode);
                    weather.updated = Qt.formatTime(new Date(), "HH:mm");
                    weather.forecast = report.weather.slice(0, 3).map(function(day) {
                        const hourly = day.hourly[Math.floor(day.hourly.length / 2)];
                        return {
                            label: weather.dayLabel(day.date),
                            temperature: day.maxtempC + "°",
                            code: Number(hourly.weatherCode)
                        };
                    });
                } catch (error) {
                    console.warn("Weather update failed:", error);
                    weather.setOffline();
                }
            }
        }
    }

    Timer {
        interval: 1200000
        running: true
        repeat: true
        onTriggered: {
            if (!fetchProcess.running)
                fetchProcess.running = true;
        }
    }
}
