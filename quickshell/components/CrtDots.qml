import QtQuick

// A dotted line: 2 px squares every 4 px, like the leader of a terminal listing.
Canvas {
    id: dots
    property color color: "white"
    height: 2
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = dots.color;
        for (let x = 0; x + 2 <= width; x += 4)
            ctx.fillRect(x, 0, 2, 2);
    }
}
