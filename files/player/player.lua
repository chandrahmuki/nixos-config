-- Retro-cute terminal UI for a plain mpv: draws the player in the terminal,
-- binds the keys, and writes a .m3u of the loaded folder on demand.
--
-- The look is data: each theme is a JSON file (PLAYER_THEMES for the built-in ones,
-- PLAYER_USER_THEMES for yours, which win on a name clash). See
-- files/player/themes/README.md for the format. `t` / `T` switch themes.
local mp = require 'mp'
local utils = require 'mp.utils'

local W = 48 -- width of the whole box
local HELP = {
  'spc pause      n/b next / previous',
  '←→ seek        ↑↓ volume   m mute',
  'j/k browse     ⏎/l play    g/G ends',
  '/ search       p back to the playing track',
  's shuffle  r loop  c make playlist  q quit',
  'R radio (again: back to the music)',
  't / T          next / previous theme',
}
local DIGITS = {
  ['0'] = {'╭─╮', '│ │', '╰─╯'},
  ['1'] = {' ╷ ', ' │ ', ' ╵ '},
  ['2'] = {'╶─╮', '╭─╯', '╰─╴'},
  ['3'] = {'╶─╮', '╶─┤', '╶─╯'},
  ['4'] = {'╷ ╷', '╰─┤', '  ╵'},
  ['5'] = {'╭─╴', '╰─╮', '╶─╯'},
  ['6'] = {'╭─╴', '├─╮', '╰─╯'},
  ['7'] = {'╶─╮', '  │', '  ╵'},
  ['8'] = {'╭─╮', '├─┤', '╰─╯'},
  ['9'] = {'╭─╮', '╰─┤', '╶─╯'},
  [':'] = {'   ', ' · ', '   '},
}
local REEL = {'◐', '◓', '◑', '◒'}
local SPIN = {'●·', '·●'}
local dir = os.getenv('PLAYER_DIR') or '.'
local background = os.getenv('PLAYER_BG') == '1'
local shuffled = false
local viz_path = os.getenv('PLAYER_VIZ')
local viz_levels = {} -- CAVA bars, 0 to 48
local show_help = false
local cursor = 0 -- browsing position in the list, independent from the playing track
local flash_text, flash_until = '', 0
-- Fuzzy search ("/"): the query, the matching playlist indexes and the picked one.
local searching, query, results, picked, haystack = false, '', {}, 0, {}
local state_dir = os.getenv('PLAYER_STATE_DIR')
-- Radio mode ("R"): the playlist is swapped for the stations and swapped back on the next "R".
local radio = false
local saved = nil -- {files, pos, time} of the music left behind
local tags_of = {} -- station url -> its tags, searched along with the name

local function ulen(s)
  local _, n = s:gsub('[^\128-\191]', '')
  return n
end

local function utrunc(s, max)
  if ulen(s) <= max then
    return s
  end
  local out, n = {}, 0
  for ch in s:gmatch('[%z\1-\127\194-\244][\128-\191]*') do
    n = n + 1
    if n > max - 1 then
      break
    end
    out[#out + 1] = ch
  end
  return table.concat(out) .. '…'
end

-- Exactly `width` columns: cut or padded with spaces.
local function fit(text, width)
  text = utrunc(text, width)
  return text .. string.rep(' ', width - ulen(text))
end

local function clock(seconds)
  seconds = math.floor(seconds or 0)
  return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60)
end

local function basename(path)
  local name = path:match('([^/]+)$') or path
  return (name:gsub('%.[%w]+$', ''):gsub('_', ' '))
end

local function track_name(index)
  local title = mp.get_property('playlist/' .. index .. '/title')
  if title and title ~= '' then
    return title
  end
  return basename(mp.get_property('playlist/' .. index .. '/filename') or '?')
end

local function flash(text)
  flash_text, flash_until = text, mp.get_time() + 3
  if background then
    mp.command_native_async({name = 'subprocess', args = {'@notify@', '-t', '3000', 'player', text}})
  end
end

-- ---------------------------------------------------------------- themes

-- Used when no theme file can be read, so the player never draws nothing.
local FALLBACK = {
  name = 'fallback',
  label = 'Fallback',
  colors = {frame = '#d7afff', accent = '#ffafd7', alt = '#afffd7', dim = '#8c9694'},
  frame = {v = '│', color = 'frame', pad = 1},
  rows = {
    {edge = {'╭', '─', '╮'}, align = 'center', text = {{'accent', 'TinyMugg'}}},
    {segs = {{'accent', '{title:40}'}}},
    {segs = {{'@bar', {w = 30, on = 'accent', off = 'dim'}}, {'dim', '  {time} / {duration}'}}},
    {list = {rows = 6}},
    {edge = {'╰', '─', '╯'}, status = true},
  },
}
local theme = FALLBACK
local themes = {}

local function hex_rgb(hex)
  local r, g, b = tostring(hex or ''):match('^#(%x%x)(%x%x)(%x%x)$')
  if not r then
    return nil
  end
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

-- A theme color name or a literal "#rrggbb".
local function color_of(name)
  if type(name) ~= 'string' or name == '' then
    return nil
  end
  if name:sub(1, 1) == '#' then
    return name
  end
  return theme.colors and theme.colors[name]
end

local function paint(fg, text, bg)
  if text == '' then
    return ''
  end
  local codes = {}
  local r, g, b = hex_rgb(color_of(fg))
  if r then
    codes[#codes + 1] = string.format('38;2;%d;%d;%d', r, g, b)
  end
  r, g, b = hex_rgb(color_of(bg))
  if r then
    codes[#codes + 1] = string.format('48;2;%d;%d;%d', r, g, b)
  end
  if #codes == 0 then
    return text
  end
  return '\27[' .. table.concat(codes, ';') .. 'm' .. text .. '\27[0m'
end

-- "accent|dim@shuf" is accent while the flag is on, dim otherwise.
local function pick_color(spec, flags)
  if type(spec) ~= 'string' then
    return spec
  end
  local on, off, flag = spec:match('^(.-)|(.-)@(.+)$')
  if flag then
    return flags[flag] and on or off
  end
  return spec
end

-- {name} or {name:width}, with the values of the current frame.
local function subst(text, vars)
  return (text:gsub('{([%w_]+):?(%d*)}', function(key, width)
    local value = vars[key]
    if value == nil then
      return ''
    end
    value = tostring(value)
    if width ~= '' then
      return fit(value, tonumber(width))
    end
    return value
  end))
end

local function glyphs_of(text)
  local list = {}
  for ch in text:gmatch('[%z\1-\127\194-\244][\128-\191]*') do
    list[#list + 1] = ch
  end
  return list
end
local DEFAULT_GLYPHS = glyphs_of('▁▂▃▄▅▆▇█')

-- One segment of a row to a list of {color, text, background}.
local function expand(seg, ctx)
  local kind, cfg = seg[1], seg[2]
  if kind == '@bar' then
    local fraction = cfg.of == 'volume' and ctx.volume / 100 or ctx.fraction
    local width = cfg.w or 20
    local filled = math.floor(math.max(0, math.min(1, fraction)) * width + 0.5)
    local fill, rest = cfg.fill or '━', cfg.rest or '─'
    if cfg.head and filled < width then
      return {
        {cfg.on, fill:rep(filled), cfg.bg},
        {cfg.on, cfg.head, cfg.bg},
        {cfg.off, rest:rep(width - filled - 1), cfg.bg},
      }
    end
    return {{cfg.on, fill:rep(filled), cfg.bg}, {cfg.off, rest:rep(width - filled), cfg.bg}}
  elseif kind == '@viz' then
    -- `rows` cells tall of 8 levels each; this is row `row`, counted from the top.
    local bars, rows, row = cfg.bars or 22, cfg.rows or 2, cfg.row or 0
    local glyphs = cfg.glyphs and glyphs_of(cfg.glyphs) or DEFAULT_GLYPHS
    local gap = cfg.gap or ' '
    local colors = cfg.colors or {'accent'}
    local out = {}
    for i = 1, bars do
      local value = math.max(0, math.min(viz_levels[i] or 0, 48))
      local level = math.floor(value * rows * 8 / 48 + 0.5)
      local cell = math.max(0, math.min(level - (rows - 1 - row) * 8, 8))
      local shade
      if cfg.rowcolors then
        shade = cfg.rowcolors[math.min(#cfg.rowcolors, row + 1)]
      else
        shade = colors[math.floor((i - 1) * #colors / bars) + 1]
      end
      if cell > 0 then
        out[#out + 1] = {shade, glyphs[cell] .. gap, cfg.bg}
      elseif row == rows - 1 and cfg.baseline then
        out[#out + 1] = {cfg.basecolor or 'dim', cfg.baseline .. gap, cfg.bg}
      else
        out[#out + 1] = {shade, ' ' .. gap, cfg.bg}
      end
    end
    return out
  elseif kind == '@clock' then
    local out = {}
    for ch in clock(ctx.time):gmatch('.') do
      local digit = DIGITS[ch] or DIGITS['0']
      out[#out + 1] = {cfg.color, digit[(cfg.row or 0) + 1] .. (ch == ':' and '' or ' '), cfg.bg}
    end
    return out
  end
  return {{pick_color(kind, ctx.flags), subst(seg[2], ctx.vars), seg[3]}}
end

local function expand_all(segs, ctx)
  local out = {}
  for _, seg in ipairs(segs) do
    for _, part in ipairs(expand(seg, ctx)) do
      out[#out + 1] = part
    end
  end
  return out
end

-- A framed row from expanded segments, padded to the inner width.
local function frame_row(parts)
  local frame = theme.frame or {}
  local v, pad = frame.v or '│', frame.pad or 1
  local inner = W - 2 * ulen(v) - 2 * pad
  local used, out = 0, {}
  for _, part in ipairs(parts) do
    local room = inner - used
    if room <= 0 then
      break
    end
    local text = part[2]
    if ulen(text) > room then
      text = utrunc(text, room)
    end
    used = used + ulen(text)
    out[#out + 1] = paint(part[1], text, part[3])
  end
  local edge = paint(frame.color or 'frame', v)
  return edge .. string.rep(' ', pad) .. table.concat(out) .. string.rep(' ', inner - used + pad) .. edge
end

-- A box edge, with a short text inset in the line like the title of the box.
local function edge_line(chars, col, parts, align)
  local left, hbar, right = chars[1], chars[2], chars[3]
  if not parts or #parts == 0 then
    return paint(col, left .. hbar:rep(W - 2) .. right)
  end
  local used, out = 2, {}
  for _, part in ipairs(parts) do
    used = used + ulen(part[2])
    out[#out + 1] = paint(part[1], part[2], part[3])
  end
  local fill = math.max(0, W - 2 - used)
  local before = 2
  if align == 'right' then
    before = fill - 2
  elseif align == 'center' then
    before = math.floor(fill / 2)
  end
  before = math.max(0, math.min(before, fill))
  return paint(col, left .. hbar:rep(before) .. ' ') .. table.concat(out) .. paint(col, ' ' .. hbar:rep(fill - before) .. right)
end

-- What the bottom edge says: the search prompt, the last message, or the hint.
local function status_parts(ctx)
  if searching then
    return {
      {'accent', '/ '},
      {'alt', utrunc(query, 16) .. '▏'},
      {'dim', string.format(' %d/%d  ↑↓ ⏎ esc', #results, ctx.count)},
    }, 'left'
  elseif mp.get_time() < flash_until then
    return {{'alt', '✔ ' .. utrunc(flash_text, 36)}}, 'left'
  end
  local total = ctx.count > 0 and string.format('%d/%d · ', ctx.pos + 1, ctx.count) or ''
  local hint = show_help and 'h or esc: back' or total .. (radio and 'radio · R music · h help' or 'h help')
  return {{'dim', hint}}, 'right'
end

-- The playlist, or the search results while searching, as rows of segments.
local function list_rows(cfg, ctx)
  local rows = cfg.rows or 5
  local shown = searching and #results or ctx.count
  local selected = math.max(0, math.min(searching and picked or cursor, shown - 1))
  local first = math.max(0, math.min(selected - math.floor(rows / 2), shown - rows))
  local out = {}
  for k = first, first + rows - 1 do
    if k >= 0 and k < shown then
      local index = searching and results[k + 1] or k
      local is_selected, is_playing = k == selected, index == ctx.pos
      local text = subst(cfg.fmt or '{cursor}{play} {num} {name:34}', {
        cursor = is_selected and (cfg.cursor or '>') or ' ',
        play = is_playing and (cfg.note or '♪') or ' ',
        n = index + 1,
        -- The number padded to the width of the biggest one, so the names stay aligned.
        num = string.format('%' .. #tostring(ctx.count) .. 'd', index + 1),
        name = track_name(index),
      })
      local shade = cfg.dim or 'dim'
      if is_selected then
        shade = cfg.sel or 'alt'
      elseif is_playing then
        shade = cfg.playing or 'accent'
      end
      out[#out + 1] = {{shade, text}}
    else
      out[#out + 1] = {}
    end
  end
  return out
end

local function compose(ctx)
  local lines = {}
  local frame_color = theme.frame and theme.frame.color or 'frame'
  for _, row in ipairs(theme.rows) do
    if row.edge then
      local parts, align = nil, row.align
      if row.status then
        parts, align = status_parts(ctx)
      elseif row.text then
        parts = expand_all(row.text, ctx)
      end
      lines[#lines + 1] = edge_line(row.edge, row.color or frame_color, parts, align)
    elseif row.list then
      for _, segs in ipairs(list_rows(row.list, ctx)) do
        lines[#lines + 1] = frame_row(expand_all(segs, ctx))
      end
    elseif row.viz then
      for r = 0, (row.viz.rows or 2) - 1 do
        local cfg = {}
        for key, value in pairs(row.viz) do
          cfg[key] = value
        end
        cfg.row = r
        lines[#lines + 1] = frame_row(expand({'@viz', cfg}, ctx))
      end
    else
      lines[#lines + 1] = frame_row(expand_all(row.segs or {}, ctx))
    end
  end
  -- The help replaces everything between the first and last edge.
  if show_help and not searching and #lines > 2 then
    local middle = #lines - 2
    local top = math.max(0, math.floor((middle - #HELP) / 2))
    for i = 1, middle do
      local text = HELP[i - top]
      lines[i + 1] = frame_row(text and {{'dim', text}} or {})
    end
  end
  return lines
end

-- ---------------------------------------------------------------- theme files

local function read_json(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local text = file:read('*a')
  file:close()
  return utils.parse_json(text)
end

local function merged(base, extra)
  local out = {}
  for key, value in pairs(base or {}) do
    out[key] = value
  end
  for key, value in pairs(extra or {}) do
    out[key] = value
  end
  return out
end

-- A theme with "extends" takes everything from another theme and overrides only what
-- it defines: colors and frame are merged key by key, rows are replaced whole.
local function resolve(data, name, own, builtin, depth)
  if not data.extends or depth > 4 then
    return data
  end
  local base = (data.extends ~= name and own[data.extends]) or builtin[data.extends]
  if not base then
    return data
  end
  base = resolve(base, data.extends, own, builtin, depth + 1)
  local out = merged(base, data)
  out.colors = merged(base.colors, data.colors)
  out.frame = merged(base.frame, data.frame)
  out.rows = data.rows or base.rows
  return out
end

-- Built-in themes, then the user's: a user theme with the same name replaces it.
local function load_themes()
  local sources = {{}, {}} -- built-in, then the user's
  local bases = {os.getenv('PLAYER_THEMES') or '', os.getenv('PLAYER_USER_THEMES') or ''}
  for i, base in ipairs(bases) do
    for _, file in ipairs(base ~= '' and utils.readdir(base, 'files') or {}) do
      local name = file:match('^(.+)%.json$')
      local data = name and read_json(base .. '/' .. file)
      if type(data) == 'table' then
        sources[i][name] = data
      end
    end
  end
  local by_name, list = {}, {}
  for i = 1, 2 do
    for name, data in pairs(sources[i]) do
      local theme_data = resolve(data, name, sources[2], sources[1], 0)
      if type(theme_data.rows) == 'table' then
        theme_data.name, theme_data.label = name, data.label or theme_data.label or name
        by_name[name] = theme_data
      end
    end
  end
  for _, data in pairs(by_name) do
    list[#list + 1] = data
  end
  table.sort(list, function(a, b)
    local oa, ob = a.order or 100, b.order or 100
    if oa ~= ob then
      return oa < ob
    end
    return a.name < b.name
  end)
  themes = list
end

local function saved_theme()
  local file = state_dir and io.open(state_dir .. '/theme', 'r')
  if not file then
    return nil
  end
  local name = file:read('*l')
  file:close()
  return name
end

local function save_theme(name)
  local file = state_dir and io.open(state_dir .. '/theme', 'w')
  if file then
    file:write(name, '\n')
    file:close()
  end
end

local function use_theme(name)
  for _, data in ipairs(themes) do
    if data.name == name then
      theme = data
      return true
    end
  end
  return false
end

local function cycle_theme(delta)
  load_themes() -- edits to a theme file show up without restarting
  if #themes == 0 then
    theme = FALLBACK
    flash('no theme found')
    return
  end
  local current = 0
  for i, data in ipairs(themes) do
    if data.name == theme.name then
      current = i
    end
  end
  local target = themes[(current - 1 + delta) % #themes + 1]
  theme = target
  save_theme(target.name)
  flash('theme: ' .. target.label)
end

-- ---------------------------------------------------------------- drawing

-- The latest CAVA frame ("3;9;48;...") is kept in a file by the wrapper.
local function read_viz()
  local file = viz_path and io.open(viz_path, 'r')
  if not file then
    return
  end
  local line = file:read('*l')
  file:close()
  if not line then
    return
  end
  local levels = {}
  for value in line:gmatch('%d+') do
    levels[#levels + 1] = tonumber(value)
  end
  if #levels > 0 then
    viz_levels = levels
  end
end

local function render()
  read_viz()
  local count = mp.get_property_number('playlist-count', 0)
  local pos = mp.get_property_number('playlist-pos', 0)
  local paused = mp.get_property_bool('pause', false)
  local volume = mp.get_property_number('volume', 100)
  local time = mp.get_property_number('time-pos', 0)
  local duration = mp.get_property_number('duration', 0)
  local looping = mp.get_property('loop-playlist') ~= 'no'
  local now = mp.get_time()
  local tick = math.floor(now * 2) % 2

  local face, note = '(-.-)', 'zZ'
  if not paused then
    face, note = tick == 0 and '(^o^)' or '(^-^)', tick == 0 and '♪' or '♫'
  end
  local artist = mp.get_property('metadata/by-key/artist') or ''
  local title = mp.get_property('metadata/by-key/title') or (count > 0 and track_name(pos) or 'nothing to play')
  if radio then
    -- A stream has no artist/title tags: its song comes as ICY metadata, the station is the entry's name.
    local song = mp.get_property('metadata/by-key/icy-title')
    artist = count > 0 and track_name(pos) or ''
    title = song and song ~= '' and song or artist
  end
  local spaced = title:upper():gsub('[%z\1-\127\194-\244][\128-\191]*', function(ch)
    return ch .. ' '
  end):gsub('%s+$', '')

  local ctx = {
    count = count, pos = pos, time = time, volume = volume,
    fraction = duration > 0 and time / duration or 0,
    flags = {shuf = shuffled, loop = looping, paused = paused, playing = not paused},
    vars = {
      face = face, note = note, title = title, artist = artist, title_spaced = spaced,
      time = clock(time), duration = clock(duration),
      pos = count > 0 and pos + 1 or 0, count = count, vol = math.floor(volume),
      reel = paused and REEL[2] or REEL[math.floor(now * 4) % 4 + 1],
      spin = paused and '●●' or SPIN[tick + 1],
    },
  }
  local ok, lines = pcall(compose, ctx)
  if not ok then
    lines = {'theme "' .. tostring(theme.name) .. '" failed:', tostring(lines), 'press t for the next theme'}
  end
  io.stdout:write('\27[H', table.concat(lines, '\27[K\n'), '\27[K\27[J')
  io.stdout:flush()
end

local function relative(path)
  local prefix = dir .. '/'
  if path:sub(1, #prefix) == prefix then
    return path:sub(#prefix + 1)
  end
  return path
end

local function make_playlist()
  local count = mp.get_property_number('playlist-count', 0)
  local name = (dir:match('([^/]+)$') or 'playlist') .. '.m3u'
  local target = dir .. '/' .. name
  local file, err = io.open(target, 'w')
  if not file then
    flash('cannot write ' .. tostring(err))
    return
  end
  file:write('#EXTM3U\n')
  local written = 0
  for i = 0, count - 1 do
    local path = mp.get_property('playlist/' .. i .. '/filename') or ''
    if path ~= '' and not path:match('%.m3u8?$') then
      file:write(relative(path), '\n')
      written = written + 1
    end
  end
  file:close()
  flash(string.format('%s (%d tracks)', name, written))
end

-- Fuzzy score of one term in a text (both lowercase): every character must
-- appear in order; consecutive and word-start matches score higher.
local function fuzzy(term, text)
  local score, pos, prev = 0, 1, 0
  for ch in term:gmatch('.') do
    local i = text:find(ch, pos, true)
    if not i then
      return nil
    end
    score = score + 1
    if i == prev + 1 then
      score = score + 5
    end
    if i == 1 or text:sub(i - 1, i - 1):match('[%s/_%-%.]') then
      score = score + 4
    end
    prev, pos = i, i + 1
  end
  if text:match('[^/]*$'):find(term, 1, true) then
    score = score + 10
  end
  return score - #text * 0.05
end

local function update_results()
  local terms = {}
  for term in query:lower():gmatch('%S+') do
    terms[#terms + 1] = term
  end
  local scored = {}
  for i, text in ipairs(haystack) do
    local total, ok = 0, true
    for _, term in ipairs(terms) do
      -- Radios: the words you type must appear as they are ("eno" is not e..n..o spread over
      -- a name); the stations then stay in the order of the list, which is your priority.
      local score
      if radio then
        score = text:find(term, 1, true) and 1 or nil
      else
        score = fuzzy(term, text)
      end
      if not score then
        ok = false
        break
      end
      total = total + score
    end
    if ok then
      scored[#scored + 1] = {index = i - 1, score = total}
    end
  end
  table.sort(scored, function(a, b)
    if a.score ~= b.score then
      return a.score > b.score
    end
    return a.index < b.index
  end)
  results = {}
  for n, hit in ipairs(scored) do
    results[n] = hit.index
  end
  picked = 0
end

local function stop_search()
  searching = false
  mp.remove_key_binding('player-text')
end

local function type_text(text)
  query = query .. text
  update_results()
end

local function start_search()
  haystack = {}
  for i, entry in ipairs(mp.get_property_native('playlist') or {}) do
    haystack[i] = relative(entry.filename or ''):lower()
    if radio then
      haystack[i] = ((entry.title or '') .. ' ' .. (tags_of[entry.filename] or '')):lower()
    end
  end
  searching, query = true, ''
  update_results()
  -- Characters without their own binding (digits, punctuation, accents).
  mp.add_forced_key_binding('any_unicode', 'player-text', function(event)
    if searching and event.key_text and event.event ~= 'up' then
      type_text(event.key_text)
      render()
    end
  end, {complex = true, repeatable = true})
end

local function pick(delta)
  picked = math.max(0, math.min(picked + delta, #results - 1))
end

-- While searching, every bound key is text or a search command.
local function search_key(key)
  if key == 'ESC' then
    stop_search()
  elseif key == 'ENTER' then
    local index = results[picked + 1]
    stop_search()
    if index then
      cursor = index
      mp.set_property_number('playlist-pos', index)
      mp.set_property_bool('pause', false)
    end
  elseif key == 'BS' then
    query = query:gsub('[%z\1-\127\194-\244][\128-\191]*$', '')
    update_results()
  elseif key == 'Ctrl+u' then
    query = ''
    update_results()
  elseif key == 'UP' or key == 'Ctrl+p' then
    pick(-1)
  elseif key == 'DOWN' or key == 'Ctrl+n' then
    pick(1)
  elseif key == 'SPACE' then
    type_text(' ')
  elseif #key == 1 then
    type_text(key)
  end
end

-- Redraw right after a key, otherwise the change waits for the next timer tick.
local function bind(key, fn)
  mp.add_forced_key_binding(key, 'player-' .. key, function()
    if searching then
      search_key(key)
    else
      fn()
    end
    if not background then
      render()
    end
  end, {repeatable = true})
end

-- ---------------------------------------------------------------- radio

-- Built-in stations first, then yours (PLAYER_USER_RADIOS); a station of yours with the same url
-- replaces the built-in one and comes first, so the order of the file is your priority.
local function load_stations()
  local out, seen = {}, {}
  for _, path in ipairs({os.getenv('PLAYER_USER_RADIOS'), os.getenv('PLAYER_RADIOS')}) do
    local list = path and read_json(path)
    if type(list) == 'table' then
      for _, st in ipairs(list) do
        if type(st) == 'table' and type(st.url) == 'string' and not seen[st.url] then
          seen[st.url] = true
          out[#out + 1] = st
        end
      end
    end
  end
  return out
end

local function write_m3u(path, lines)
  local file = io.open(path, 'w')
  if not file then
    return false
  end
  file:write('#EXTM3U\n', table.concat(lines, '\n'), '\n')
  file:close()
  return true
end

local function m3u_path(name)
  return (state_dir or os.getenv('TMPDIR') or '/tmp') .. '/' .. name
end

local function toggle_radio()
  if not radio then
    local stations = load_stations()
    if #stations == 0 then
      flash('no stations (radios.json)')
      return
    end
    local lines = {}
    tags_of = {}
    for _, st in ipairs(stations) do
      local tags = type(st.tags) == 'table' and table.concat(st.tags, ' ') or ''
      tags_of[st.url] = tags
      local label = (st.name or st.url):gsub('[\r\n]', ' ')
      lines[#lines + 1] = '#EXTINF:-1,' .. label
      lines[#lines + 1] = st.url
    end
    local path = m3u_path('radio.m3u')
    if not write_m3u(path, lines) then
      flash('cannot write ' .. path)
      return
    end
    local files = {}
    for _, entry in ipairs(mp.get_property_native('playlist') or {}) do
      files[#files + 1] = entry.filename
    end
    saved = {files = files, pos = mp.get_property_number('playlist-pos', 0), time = mp.get_property_number('time-pos', 0)}
    radio, shuffled = true, false
    mp.commandv('loadfile', path, 'replace')
    flash(string.format('radio: %d stations', #stations))
  else
    radio = false
    local back = saved
    saved = nil
    if not back or #back.files == 0 then
      mp.commandv('playlist-clear')
      flash('back to the music')
      return
    end
    local path = m3u_path('music.m3u')
    if not write_m3u(path, back.files) then
      flash('cannot write ' .. path)
      return
    end
    -- Back on the same track, at the same second.
    mp.commandv('loadfile', path, 'replace', -1, 'playlist-start=' .. back.pos)
    local function resume()
      mp.unregister_event(resume)
      if back.time and back.time > 1 then
        mp.commandv('seek', back.time, 'absolute')
      end
    end
    mp.register_event('file-loaded', resume)
    flash('back to the music')
  end
  cursor = 0
end

bind('SPACE', function() mp.command('cycle pause') end)
bind('n', function() mp.command('playlist-next') end)
bind('b', function() mp.command('playlist-prev') end)
bind('RIGHT', function() mp.command('seek 5') end)
bind('LEFT', function() mp.command('seek -5') end)
bind('UP', function() mp.command('add volume 5') end)
bind('DOWN', function() mp.command('add volume -5') end)
bind('m', function() mp.command('cycle mute') end)
bind('r', function() mp.command('cycle-values loop-playlist inf no') end)
bind('s', function()
  shuffled = not shuffled
  mp.command(shuffled and 'playlist-shuffle' or 'playlist-unshuffle')
end)
local function move_cursor(delta)
  local count = mp.get_property_number('playlist-count', 0)
  cursor = math.max(0, math.min(cursor + delta, count - 1))
end

bind('j', function() move_cursor(1) end)
bind('k', function() move_cursor(-1) end)
bind('g', function() cursor = 0 end)
bind('G', function() cursor = math.max(0, mp.get_property_number('playlist-count', 1) - 1) end)
bind('h', function() show_help = not show_help end)
bind('p', function() cursor = mp.get_property_number('playlist-pos', 0) end)
bind('t', function() cycle_theme(1) end)
bind('T', function() cycle_theme(-1) end)
local function play_cursor()
  mp.set_property_number('playlist-pos', cursor)
  mp.set_property_bool('pause', false)
end
bind('ENTER', play_cursor)
bind('l', play_cursor)
-- The cursor follows the playing track whenever it changes.
mp.register_event('file-loaded', function()
  cursor = mp.get_property_number('playlist-pos', 0)
end)
-- mpv moves on by itself when a stream cannot be opened: say so instead of skipping silently.
mp.register_event('end-file', function(event)
  if radio and event.reason == 'error' then
    flash('station unreachable, next')
  end
end)
bind('c', make_playlist)
bind('R', toggle_radio)
bind('/', start_search)
bind('ESC', function() show_help = false end)
for _, key in ipairs({'BS', 'Ctrl+u', 'Ctrl+n', 'Ctrl+p'}) do
  bind(key, function() end)
end
bind('q', function() mp.command('quit') end)

-- Sent by `player save` when the player runs in the background.
mp.register_script_message('player-make-playlist', make_playlist)

if not background then
  load_themes()
  local wanted = os.getenv('PLAYER_THEME')
  if not wanted or wanted == '' then
    wanted = saved_theme() or 'pastel'
  end
  if not use_theme(wanted) and #themes > 0 then
    theme = themes[1]
  end
  io.stdout:write('\27[?1049h\27[?25l\27[2J')
  mp.register_event('shutdown', function()
    io.stdout:write('\27[?25h\27[?1049l')
    io.stdout:flush()
  end)
  mp.add_periodic_timer(0.05, render)
end
