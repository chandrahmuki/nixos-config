import QtQuick
import Quickshell.Io

// The shell theme: the theme profiles, the palette derived from the active profile and
// from the Matugen colours of its wallpaper (with the colour animations), the Matugen
// scheme, the full-screen wallpaper transition, and the calls to muggy-theme. The
// shell exposes it as `shell.theme`.
Item {
    id: themeService

    property string activeThemeId: "muggy"
    // Which Matugen colour-scheme algorithm generates the live palette from
    // the chosen wallpaper — independent of which wallpaper/theme is
    // selected. Session-only: resets to the punchiest default on restart
    // rather than persisting, since it's a taste knob, not identity like
    // activeThemeId.
    property string matugenScheme: "scheme-vibrant"
    readonly property var matugenSchemes: [
        { id: "scheme-tonal-spot", name: "TONAL" },
        { id: "scheme-vibrant", name: "VIBRANT" },
        { id: "scheme-rainbow", name: "RAINBOW" },
        { id: "scheme-expressive", name: "EXPRESSIF" },
        { id: "scheme-neutral", name: "NEUTRE" }
    ]
    // Replaced atomically after Matugen has analysed the selected wallpaper.
    // The static profile remains the safe visual fallback if generation fails.
    property var generatedPalette: ({})

    readonly property var themeProfiles: [
        { id: "muggy", name: "MUGGY // NEON", description: "Le wallpaper NixOS néon, cyan et rose sur fond profond.", wallpaper: "muggy.png", background: "#293d39", surface: "#344b46", selection: "#3d5b56", muted: "#71918a", foreground: "#e9e1dc", accent: "#00dfc1", active: "#f5b6c8", pillBackground: "#172522", pillForeground: "#f3efec", pillMuted: "#65817b", pillActive: "#10201d", panelSurface: "#223530", panelLine: "#44645d", retroAmber: "#e3b264", retroCyan: "#00dfc1", retroCoral: "#f27d9a" },
        { id: "gnome-lines", name: "GNOME // LINES", description: "Le wallpaper GNOME aux bandes cyan, bleues, ambre et roses.", wallpaper: "gnome-lines.png", background: "#252a3d", surface: "#343b55", selection: "#414b6b", muted: "#8996c4", foreground: "#edf0ff", accent: "#72d8ca", active: "#f27a96", pillBackground: "#171b2b", pillForeground: "#edf0ff", pillMuted: "#69769f", pillActive: "#171b2b", panelSurface: "#29314a", panelLine: "#526285", retroAmber: "#e5b261", retroCyan: "#72d8ca", retroCoral: "#f27a96" },
        { id: "gnome-gradient", name: "GNOME // GRADIENT", description: "Le wallpaper GNOME texturé, turquoise, prune et ivoire.", wallpaper: "gnome-gradient.png", background: "#1f302d", surface: "#30423f", selection: "#43534f", muted: "#829b95", foreground: "#f5eee6", accent: "#00e2d2", active: "#efcfc6", pillBackground: "#15211f", pillForeground: "#f5eee6", pillMuted: "#6c837e", pillActive: "#15211f", panelSurface: "#263a36", panelLine: "#4a615b", retroAmber: "#e9d2b9", retroCyan: "#00e2d2", retroCoral: "#a8547d" },
        { id: "catppuccin", name: "CATPPUCCIN", description: "Catppuccin Mocha — pastel doux sur fond violet nuit.", wallpaper: "quattro-catppuccin.jpg", background: "#1e1e2e", surface: "#313244", selection: "#45475a", muted: "#585b70", foreground: "#cdd6f4", accent: "#89b4fa", active: "#89b4fa", pillBackground: "#161622", pillForeground: "#cdd6f4", pillMuted: "#585b70", pillActive: "#1e1e2e", panelSurface: "#313244", panelLine: "#585b70", retroAmber: "#f6b6ab", retroCyan: "#94e2d5", retroCoral: "#f38ba8" },
        { id: "catppuccin-latte", name: "CATPPUCCIN LATTE", description: "Catppuccin Latte — palette claire aux accents bleu lavande.", wallpaper: "quattro-catppuccin-latte.jpg", background: "#eff1f5", surface: "#dce0e8", selection: "#ccd0da", muted: "#acb0be", foreground: "#4c4f69", accent: "#1e66f5", active: "#1e66f5", pillBackground: "#e3e4e8", pillForeground: "#4c4f69", pillMuted: "#acb0be", pillActive: "#eff1f5", panelSurface: "#dce0e8", panelLine: "#acb0be", retroAmber: "#df8e1d", retroCyan: "#179299", retroCoral: "#d20f39" },
        { id: "ethereal", name: "ETHEREAL", description: "Bleu nocturne, lavande et tons doux inspirés du cosmos.", wallpaper: "quattro-ethereal.jpg", background: "#060B1E", surface: "#131a3a", selection: "#252e56", muted: "#6d7db6", foreground: "#ffcead", accent: "#7d82d9", active: "#7d82d9", pillBackground: "#040816", pillForeground: "#ffcead", pillMuted: "#6d7db6", pillActive: "#060B1E", panelSurface: "#131a3a", panelLine: "#6d7db6", retroAmber: "#eb8b54", retroCyan: "#a3bfd1", retroCoral: "#ED5B5A" },
        { id: "everforest", name: "EVERFOREST", description: "Verts de forêt, tons terre et contraste doux.", wallpaper: "quattro-everforest.jpg", background: "#2d353b", surface: "#343f44", selection: "#3d484d", muted: "#475258", foreground: "#d3c6aa", accent: "#7fbbb3", active: "#7fbbb3", pillBackground: "#21272c", pillForeground: "#d3c6aa", pillMuted: "#475258", pillActive: "#2d353b", panelSurface: "#343f44", panelLine: "#475258", retroAmber: "#e09d7f", retroCyan: "#83c092", retroCoral: "#e67e80" },
        { id: "flexoki-light", name: "FLEXOKI LIGHT", description: "Papier ivoire et couleurs d’encre chaleureuses.", wallpaper: "muggynix-flexoki-light.jpg", background: "#FFFCF0", surface: "#E6E4D9", selection: "#CECDC3", muted: "#B7B5AC", foreground: "#100F0F", accent: "#205EA6", active: "#205EA6", pillBackground: "#f2efe4", pillForeground: "#100F0F", pillMuted: "#B7B5AC", pillActive: "#FFFCF0", panelSurface: "#E6E4D9", panelLine: "#B7B5AC", retroAmber: "#d0772b", retroCyan: "#3AA99F", retroCoral: "#D14D41" },
        { id: "gruvbox", name: "GRUVBOX", description: "Palette rétro chaude, bruns profonds et accents doux.", wallpaper: "quattro-gruvbox.jpg", background: "#282828", surface: "#3c3836", selection: "#504945", muted: "#665c54", foreground: "#d4be98", accent: "#7daea3", active: "#7daea3", pillBackground: "#1e1e1e", pillForeground: "#d4be98", pillMuted: "#665c54", pillActive: "#282828", panelSurface: "#3c3836", panelLine: "#665c54", retroAmber: "#e1875c", retroCyan: "#89b482", retroCoral: "#ea6962" },
        { id: "hackerman", name: "HACKERMAN", description: "Vert terminal phosphore et ambiance cyberpunk.", wallpaper: "quattro-hackerman.jpg", background: "#0B0C16", surface: "#151828", selection: "#1f253a", muted: "#2d3450", foreground: "#ddf7ff", accent: "#82FB9C", active: "#82FB9C", pillBackground: "#080910", pillForeground: "#ddf7ff", pillMuted: "#2d3450", pillActive: "#0B0C16", panelSurface: "#151828", panelLine: "#2d3450", retroAmber: "#50f7d4", retroCyan: "#7cf8f7", retroCoral: "#50f872" },
        { id: "kanagawa", name: "KANAGAWA", description: "Inspiré des estampes japonaises, indigo et sable.", wallpaper: "quattro-kanagawa.jpg", background: "#1f1f28", surface: "#223249", selection: "#363646", muted: "#54546D", foreground: "#dcd7ba", accent: "#dcd7ba", active: "#7e9cd8", pillBackground: "#17171e", pillForeground: "#dcd7ba", pillMuted: "#54546D", pillActive: "#1f1f28", panelSurface: "#223249", panelLine: "#54546D", retroAmber: "#c17158", retroCyan: "#6a9589", retroCoral: "#c34043" },
        { id: "last-horizon", name: "LAST HORIZON", description: "Ciel crépusculaire et tons mauves désaturés.", wallpaper: "quattro-last-horizon.jpg", background: "#0c0b0c", surface: "#0c0b0c", selection: "#584e51", muted: "#584e51", foreground: "#FAFCFB", accent: "#b59790", active: "#b59790", pillBackground: "#090809", pillForeground: "#FAFCFB", pillMuted: "#584e51", pillActive: "#0c0b0c", panelSurface: "#0c0b0c", panelLine: "#584e51", retroAmber: "#6B5E73", retroCyan: "#a5a0b6", retroCoral: "#c38b7b" },
        { id: "lumon", name: "LUMON", description: "Bleu acier et lumière froide de l’univers Severance.", wallpaper: "quattro-lumon.jpg", background: "#16242d", surface: "#1b2d40", selection: "#243d56", muted: "#304860", foreground: "#d6e2ee", accent: "#8bc9eb", active: "#8bc9eb", pillBackground: "#101b21", pillForeground: "#d6e2ee", pillMuted: "#304860", pillActive: "#16242d", panelSurface: "#1b2d40", panelLine: "#304860", retroAmber: "#8bc9eb", retroCyan: "#b4e4f6", retroCoral: "#4d86b0" },
        { id: "lupine", name: "LUPINE", description: "Fleurs de cerisier, fond clair et accents bleus.", wallpaper: "muggynix-lupine.jpg", background: "#fafafa", surface: "#f5f5f5", selection: "#d0d0d0", muted: "#9e9e9e", foreground: "#212121", accent: "#3264eb", active: "#3264eb", pillBackground: "#ececec", pillForeground: "#212121", pillMuted: "#9e9e9e", pillActive: "#fafafa", panelSurface: "#f5f5f5", panelLine: "#9e9e9e", retroAmber: "#026fde", retroCyan: "#0c67de", retroCoral: "#c900c4" },
        { id: "matte-black", name: "MATTE BLACK", description: "Noir mat minimal et accents ambre.", wallpaper: "quattro-matte-black.jpg", background: "#121212", surface: "#1e1e1e", selection: "#2a2a2a", muted: "#333333", foreground: "#bebebe", accent: "#e68e0d", active: "#e68e0d", pillBackground: "#0d0d0d", pillForeground: "#bebebe", pillMuted: "#333333", pillActive: "#121212", panelSurface: "#1e1e1e", panelLine: "#333333", retroAmber: "#c63d3d", retroCyan: "#bebebe", retroCoral: "#D35F5F" },
        { id: "miasma", name: "MIASMA", description: "Verts moussus et ambre sur une palette sombre.", wallpaper: "quattro-miasma.jpg", background: "#222222", surface: "#2c2c2c", selection: "#383838", muted: "#666666", foreground: "#c2c2b0", accent: "#78824b", active: "#78824b", pillBackground: "#191919", pillForeground: "#c2c2b0", pillMuted: "#666666", pillActive: "#222222", panelSurface: "#2c2c2c", panelLine: "#666666", retroAmber: "#8d6242", retroCyan: "#c9a554", retroCoral: "#685742" },
        { id: "nord", name: "NORD", description: "Bleu glacier et gris scandinaves.", wallpaper: "quattro-nord.jpg", background: "#2e3440", surface: "#3b4252", selection: "#434c5e", muted: "#4c566a", foreground: "#d8dee9", accent: "#81a1c1", active: "#81a1c1", pillBackground: "#222730", pillForeground: "#d8dee9", pillMuted: "#4c566a", pillActive: "#2e3440", panelSurface: "#3b4252", panelLine: "#4c566a", retroAmber: "#d5967a", retroCyan: "#88c0d0", retroCoral: "#bf616a" },
        { id: "osaka-jade", name: "OSAKA JADE", description: "Vert jade, ville nocturne et lumière néon.", wallpaper: "quattro-osaka-jade.jpg", background: "#111c18", surface: "#23372B", selection: "#32473B", muted: "#53685B", foreground: "#C1C497", accent: "#509475", active: "#509475", pillBackground: "#0c1512", pillForeground: "#C1C497", pillMuted: "#53685B", pillActive: "#111c18", panelSurface: "#23372B", panelLine: "#53685B", retroAmber: "#a2734b", retroCyan: "#2DD5B7", retroCoral: "#FF5345" },
        { id: "retro-82", name: "RETRO 82", description: "Néons rétro, bleu profond et ambre lumineux.", wallpaper: "quattro-retro-82.jpg", background: "#05182e", surface: "#0a2540", selection: "#134e5a", muted: "#2a6b78", foreground: "#f6dcac", accent: "#faa968", active: "#faa968", pillBackground: "#031222", pillForeground: "#f6dcac", pillMuted: "#2a6b78", pillActive: "#05182e", panelSurface: "#0a2540", panelLine: "#2a6b78", retroAmber: "#e97b3c", retroCyan: "#8cbfb8", retroCoral: "#f85525" },
        { id: "ristretto", name: "RISTRETTO", description: "Bruns espresso, crème et tons de café.", wallpaper: "quattro-ristretto.jpg", background: "#2c2525", surface: "#3d2f2a", selection: "#403e41", muted: "#72696a", foreground: "#e6d9db", accent: "#f38d70", active: "#f38d70", pillBackground: "#211b1b", pillForeground: "#e6d9db", pillMuted: "#72696a", pillActive: "#2c2525", panelSurface: "#3d2f2a", panelLine: "#72696a", retroAmber: "#fb9a77", retroCyan: "#85dacc", retroCoral: "#fd6883" },
        { id: "rose-pine", name: "ROSE PINE", description: "Ivoire, rose poudré et accents de pin.", wallpaper: "muggynix-rose-pine.jpg", background: "#faf4ed", surface: "#f2e9e1", selection: "#dfdad9", muted: "#cecacd", foreground: "#575279", accent: "#56949f", active: "#56949f", pillBackground: "#ede7e1", pillForeground: "#575279", pillMuted: "#cecacd", pillActive: "#faf4ed", panelSurface: "#f2e9e1", panelLine: "#cecacd", retroAmber: "#cf8057", retroCyan: "#d7827e", retroCoral: "#b4637a" },
        { id: "solitude", name: "SOLITUDE", description: "Gris froid, atmosphère calme et monochrome.", wallpaper: "quattro-solitude.jpg", background: "#101315", surface: "#101315", selection: "#343d41", muted: "#4b4e55", foreground: "#cacccc", accent: "#798186", active: "#798186", pillBackground: "#0c0e10", pillForeground: "#cacccc", pillMuted: "#4b4e55", pillActive: "#101315", panelSurface: "#101315", panelLine: "#4b4e55", retroAmber: "#d9dbdc", retroCyan: "#707070", retroCoral: "#565d60" },
        { id: "tokyo-night", name: "TOKYO NIGHT", description: "Bleu nuit urbain, violet et lumières de Tokyo.", wallpaper: "quattro-tokyo-night.jpg", background: "#1a1b26", surface: "#24283b", selection: "#292e42", muted: "#414868", foreground: "#a9b1d6", accent: "#7aa2f7", active: "#7aa2f7", pillBackground: "#13141c", pillForeground: "#a9b1d6", pillMuted: "#414868", pillActive: "#1a1b26", panelSurface: "#24283b", panelLine: "#414868", retroAmber: "#eb927b", retroCyan: "#449dab", retroCoral: "#f7768e" },
        { id: "vantablack", name: "VANTABLACK", description: "Noir absolu et gamme monochrome à fort contraste.", wallpaper: "quattro-vantablack.jpg", background: "#000000", surface: "#1a1a1a", selection: "#1a1a1a", muted: "#7a7a7a", foreground: "#ffffff", accent: "#8d8d8d", active: "#8d8d8d", pillBackground: "#090909", pillForeground: "#ffffff", pillMuted: "#7a7a7a", pillActive: "#000000", panelSurface: "#1a1a1a", panelLine: "#7a7a7a", retroAmber: "#b9b9b9", retroCyan: "#b0b0b0", retroCoral: "#a4a4a4" },
        { id: "white", name: "WHITE", description: "Thème clair minimal, blanc et gris.", wallpaper: "quattro-white.jpg", background: "#ffffff", surface: "#c0c0c0", selection: "#c0c0c0", muted: "#808080", foreground: "#000000", accent: "#6e6e6e", active: "#6e6e6e", pillBackground: "#f5f5f5", pillForeground: "#000000", pillMuted: "#808080", pillActive: "#ffffff", panelSurface: "#c0c0c0", panelLine: "#808080", retroAmber: "#4a4a4a", retroCyan: "#3e3e3e", retroCoral: "#2a2a2a" }
    ]
    readonly property var activeTheme: themeProfiles.find(function(theme) { return theme.id === activeThemeId; }) || themeProfiles[0]
    function generatedColor(role, fallback) {
        return generatedPalette[role] || fallback;
    }
    // Not readonly: Behavior below needs write access to animate these when
    // the bindings recompute (readonly properties reject Behavior entirely).
    property color background: generatedColor("background", activeTheme.background)
    property color surface: generatedColor("surface_container", activeTheme.surface)
    property color selection: generatedColor("surface_container_highest", activeTheme.selection)
    property color muted: generatedColor("outline", activeTheme.muted)
    property color foreground: generatedColor("on_surface", activeTheme.foreground)
    property color accent: generatedColor("primary", activeTheme.accent)
    property color active: generatedColor("primary_fixed", activeTheme.active)
    property color pillBackground: generatedColor("surface_container_lowest", activeTheme.pillBackground)
    property color pillForeground: generatedColor("on_surface", activeTheme.pillForeground)
    property color pillMuted: generatedColor("outline_variant", activeTheme.pillMuted)
    property color pillActive: generatedColor("on_primary", activeTheme.pillActive)
    // Secondary text and icons of the pill: the foreground at 65% over the pill
    // background. The "muted" greys of the profiles are too faint on several themes.
    readonly property color pillSecondary: Qt.tint(pillBackground,
        Qt.rgba(pillForeground.r, pillForeground.g, pillForeground.b, 0.65))
    // The accent at 55% and 22% over the pill background: labels and frames, then dotted
    // lines and unlit gauge blocks, of the terminal-style panels.
    readonly property color panelDim: Qt.tint(pillBackground, Qt.rgba(retroCyan.r, retroCyan.g, retroCyan.b, 0.55))
    readonly property color panelFaint: Qt.tint(pillBackground, Qt.rgba(retroCyan.r, retroCyan.g, retroCyan.b, 0.22))
    // Shared micro-console language for expandable pill panels.  Keep the
    // accents deliberately sparse so future panels read as one system.
    property color panelSurface: generatedColor("surface_container_low", activeTheme.panelSurface)
    property color panelLine: generatedColor("outline_variant", activeTheme.panelLine)
    property color retroAmber: generatedColor("secondary", activeTheme.retroAmber)
    property color retroCyan: generatedColor("primary", activeTheme.retroCyan)
    property color retroCoral: generatedColor("tertiary", activeTheme.retroCoral)
    // Semantic roles shared by every overlay and micro-panel.  Components
    // must consume these roles instead of inventing a second hard-coded
    // palette, otherwise a wallpaper change only recolours the pill.
    property color onAccent: generatedColor("on_primary", pillActive)
    property color surfaceHover: generatedColor("surface_container_high", selection)
    property color surfacePressed: generatedColor("surface_container_highest", selection)
    property color surfaceMuted: generatedColor("surface_container_low", panelSurface)
    property color borderStrong: generatedColor("outline", muted)
    property color borderMuted: generatedColor("outline_variant", panelLine)
    property color iconMuted: generatedColor("on_surface_variant", muted)
    property color critical: generatedColor("error", active)
    property color warning: generatedColor("secondary", retroAmber)
    property color success: generatedColor("tertiary", retroCyan)
    property color overlayScrim: "#000000"
    // Applying a theme flips activeTheme immediately, then generatedPalette
    // arrives moments later once Matugen finishes analysing the wallpaper.
    // Animate every derived colour so both steps read as one smooth
    // transition across the whole shell instead of two abrupt snaps.
    Behavior on background { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on surface { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on selection { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on muted { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on foreground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on accent { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on active { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillBackground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillForeground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillMuted { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillActive { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on panelSurface { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on panelLine { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroAmber { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroCyan { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroCoral { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    readonly property string pillFont: "Pixelify Sans"

    Process {
        id: applyProcess
        command: ["muggy-theme", "apply", "muggy"]
        running: false
        onExited: function(exitCode) {
            // Replacing a theme while Matugen is still running intentionally
            // terminates the previous process (SIGTERM is reported as 15).
            // That is a normal latest-selection-wins transition, not a
            // backend failure.
            if (exitCode !== 0 && exitCode !== 15)
                console.warn("Matugen theme application failed with exit code", exitCode);
        }
        stderr: SplitParser {
            onRead: data => console.warn("Matugen theme:", data.trim())
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const report = JSON.parse(data.trim());
                    themeService.setPalette(report.colors);
                } catch (error) {
                    console.warn("Matugen returned an invalid palette:", error);
                }
            }
        }
    }

    Process {
        id: restoreProcess
        command: ["muggy-theme", "current"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const themeId = data.trim();
                if (themeId.length > 0)
                    themeService.apply(themeId);
            }
        }
    }

    function apply(themeId): bool {
        if (!themeProfiles.some(function(theme) { return theme.id === themeId; }))
            return false;
        playTransition(activeThemeId, themeId);
        // generatedPalette still holds the OUTGOING theme's Matugen colours,
        // and generatedColor() prefers it over the fallback — so without
        // clearing it here the UI would keep showing the old palette (no
        // visible change at all) until Matugen finishes on the new
        // wallpaper, seconds later. Clearing it lets every generatedColor()
        // fall back to the new theme's static profile immediately, so the
        // Behaviors above animate right away; the later Matugen result then
        // refines colours with a second, subtler animated step.
        generatedPalette = {};
        activeThemeId = themeId;
        applyScheme(matugenScheme, themeId);
        return true;
    }

    // A scheme click is an immediate preview/apply action, not just a
    // selection marker. Keep the deck open so the result can be compared.
    function applyScheme(schemeId, themeId = activeThemeId): void {
        if (!matugenSchemes.some(function(scheme) { return scheme.id === schemeId; }))
            return;
        matugenScheme = schemeId;
        if (activeThemeId !== themeId) {
            playTransition(activeThemeId, themeId);
            activeThemeId = themeId;
        }
        generatedPalette = {};
        applyProcess.running = false;
        applyProcess.command = ["muggy-theme", "apply", themeId, schemeId];
        applyProcess.running = true;
    }

    // Full-screen wallpaper reveal (ThemeTransitionWindow), à la Omarchy: a
    // circular mask grows from the centre of every monitor to swap the old
    // wallpaper for the new one, instead of the theme deck's own confirm
    // ripple staying confined to its small panel.
    property string transitionFromId: ""
    property string transitionToId: ""
    property real transitionProgress: 1
    function playTransition(fromId, toId): void {
        transitionFromId = fromId;
        transitionToId = toId;
        transitionProgress = 0;
        transitionAnim.restart();
    }
    NumberAnimation {
        id: transitionAnim
        target: themeService
        property: "transitionProgress"
        from: 0
        to: 1
        duration: 750
        easing.type: Easing.InOutCubic
        onFinished: {
            themeService.transitionFromId = "";
            themeService.transitionToId = "";
        }
    }

    function setPalette(colors): void {
        if (!colors)
            return;

        const next = {};
        for (const role in colors) {
            const shade = colors[role] && colors[role].dark;
            if (shade && shade.color)
                next[role] = shade.color;
        }
        if (Object.keys(next).length > 0)
            generatedPalette = next;
    }
}
