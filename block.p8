pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--cassette match
--by songbird

function _init()
  --states
  s = {
    fall = 1,
    drop = 2,
    match = 3,
    lose = 4
  }
  init_grid()
  init_blocks()
  init_fall()
end

function _update()
  if state == s.fall then
    update_fall()
  elseif state == s.drop then
    update_drop()
  elseif state == s.match then
    update_match()
  elseif state == s.lose then
    update_lose()
  end
end

function _draw()
  cls()
  draw_grid()
  draw_blocks()
  if state == s.fall then
    draw_fall()
  elseif state == s.drop then
    draw_drop()
  elseif state == s.match then
    draw_match()
  elseif state == s.lose then
    draw_lose()
  end
end

-->8
--grid

function init_grid()
  block_size = 8
  left = 32
  right = 96
  top = 16
  bottom = 112
end

function draw_grid()
  line(
    left, top,
    left, bottom
  )
  line(
    right, top,
    right, bottom
  )
  line(
    left, bottom,
    right, bottom
  )

  local x = left + block_size
  local y = top

  while x < right do
    while y < bottom do
      line(x, y, x, y)
      y += block_size
    end
    x += block_size
    y = top
  end
end

-->8
--blocks

function init_blocks()
  num_colors = 4
  blocks = {}
end

function add_block(b)
  blocks[b.x .. "," .. b.y] = b
end

function del_block(b)
  blocks[b.x .. "," .. b.y] = nil
end

function draw_blocks()
  for k, b in pairs(blocks) do
    draw_block(b)
  end
end

function draw_block(b)
  spr(b.sprite, convert_coords(b.x, b.y))
end

--converts grid coords to pixel coords
function convert_coords(x, y)
  local x = left + x * block_size
  local y = top + y * block_size
  return x, y
end

-->8
--falling

function init_fall()
  state = s.fall
  tick = 0
  rate = 0.05

  if not check_lose() then
    spawn_block()
  else
    init_lose()
  end
end

function check_lose()
  for i = 0, 7 do
    if blocks[i .. "," .. 0] then
      return true
    end
  end
  return false
end

function spawn_block()
  vert = true
  b1 = make_block(3, 0)
  b2 = make_block(3, 1)
end

function make_block(x, y)
  return {
    sprite = ceil(rnd(num_colors)),
    x = x,
    y = y
  }
end

function update_fall()
  if btnp(⬅️) then
    move_left()
  end
  if btnp(➡️) then
    move_right()
  end
  if btnp(⬇️) then
    move_down()
  end
  if btnp(❎) then
    rotate_clockwise()
  end
  if btnp(🅾️) then
    rotate_anticlockwise()
  end

  tick += rate
  if tick >= 1 then
    if block_end() then
      init_drop()
    end

    move_down()
    tick = 0
  end
end

function move_left()
  if not collision(b1.x - 1, b1.y)
      and not collision(b2.x - 1, b2.y) then
    b1.x -= 1
    b2.x -= 1
  end
end

function move_right()
  if not collision(b1.x + 1, b1.y)
      and not collision(b2.x + 1, b2.y) then
    b1.x += 1
    b2.x += 1
  end
end

function move_down()
  if not block_end() then
    b1.y += 1
    b2.y += 1
  end
end

function rotate_clockwise()
  local x, y

  if b2.x > b1.x then
    x = b1.x
    y = b2.y + 1
  elseif b2.y > b1.y then
    x = b1.x - 1
    y = b1.y
  elseif b2.x < b1.x then
    x = b1.x
    y = b2.y - 1
  elseif b2.y < b1.y then
    x = b1.x + 1
    y = b1.y
  end

  if not collision(x, y) then
    b2.x, b2.y = x, y
    vert = not vert
  end
end

function rotate_anticlockwise()
  local x, y

  if b2.x > b1.x then
    x = b1.x
    y = b2.y - 1
  elseif b2.y > b1.y then
    x = b1.x + 1
    y = b1.y
  elseif b2.x < b1.x then
    x = b1.x
    y = b2.y + 1
  elseif b2.y < b1.y then
    x = b1.x - 1
    y = b1.y
  end

  if not collision(x, y) then
    b2.x, b2.y = x, y
    vert = not vert
  end
end

--checks for object at given coords
function collision(x, y)
  return x < 0 or x > 7
      or y < 0 or y > 11
      or blocks[x .. "," .. y]
end

function can_move_down(b)
  return not collision(b.x, b.y + 1)
end

function block_end()
  return not can_move_down(b1)
      or not can_move_down(b2)
end

function draw_fall()
  draw_block(b1)
  draw_block(b2)
end

-->8
--dropping

function init_drop()
  state = s.drop
  tick = 0
  rate = 0.1
  r1, r2 = false, false
end

function update_drop()
  tick += rate
  if tick >= 1 then
    if vert then
      r1, r2 = true, true
    else
      if can_move_down(b1) then
        b1.y += 1
      else
        r1 = true
      end
      if can_move_down(b2) then
        b2.y += 1
      else
        r2 = true
      end
    end

    if r1 and r2 then
      end_drop()
    end

    tick = 0
  end
end

function end_drop()
  add_block(b1)
  add_block(b2)
  init_match({ b1, b2 })
end

function draw_drop()
  draw_block(b1)
  draw_block(b2)
end

-->8
--matching

function init_match(dropped)
  state = s.match
  to_check = dropped
  matches = {}
  to_drop = {}
  check_matches()
end

function check_matches()
  local matched = false

  --check blocks that just dropped
  for b in all(to_check) do
    if check_match(b) then
      matched = true
    end
  end

  if not matched then
    init_fall()
    return
  end

  resolve_match()
end

function check_match(b)
  local matched = false
  local up = check_match_up(b)
  local down = check_match_down(b)
  local left = check_match_left(b)
  local right = check_match_right(b)

  if #up + #down >= 2 then
    matched = true
    foreach(up, add_match)
    foreach(down, add_match)
  end
  if #left + #right >= 2 then
    matched = true
    foreach(left, add_match)
    foreach(right, add_match)
  end

  if matched then
    add_match(b)
  end

  return matched
end

function check_match_up(b)
  local x, y = b.x, b.y - 1
  local matches = {}
  while check_color(x, y, b.sprite) do
    add(matches, { x = x, y = y })
    y -= 1
  end
  return matches
end

function check_match_down(b)
  local x, y = b.x, b.y + 1
  local matches = {}
  while check_color(x, y, b.sprite) do
    add(matches, { x = x, y = y })
    y += 1
  end
  return matches
end

function check_match_left(b)
  local x, y = b.x - 1, b.y
  local matches = {}
  while check_color(x, y, b.sprite) do
    add(matches, { x = x, y = y })
    x -= 1
  end
  return matches
end

function check_match_right(b)
  local x, y = b.x + 1, b.y
  local matches = {}
  while check_color(x, y, b.sprite) do
    add(matches, { x = x, y = y })
    x += 1
  end
  return matches
end

function check_color(x, y, color)
  return blocks[x .. "," .. y]
      and blocks[x .. "," .. y].sprite == color
end

function add_match(b)
  add(matches, { x = b.x, y = b.y })
end

function resolve_match()
  foreach(matches, del_block)
  foreach(matches, check_above)
  to_check = {}
end

function check_above(b)
  if blocks[b.x .. "," .. b.y - 1] then
    local b = blocks[b.x .. "," .. b.y - 1]
    del_block(b)
    add(to_drop, b)
    check_above(b)
  end
end

function update_match()
  tick += rate
  if tick >= 1 then
    for b in all(to_drop) do
      if can_move_down(b) then
        b.y += 1
      else
        del(to_drop, b)
        add(to_check, b)
        add_block(b)
      end
    end

    if #to_drop == 0 then
      init_match(to_check)
    end

    tick = 0
  end
end

function draw_match()
  foreach(to_drop, draw_block)
end

-->8
--lose

function init_lose()
  state = s.lose
end

function update_lose()
  if btnp(❎) or btnp(🅾️) then
    _init()
  end
end

function draw_lose()
  rectfill(left + 1, 52, right - 1, 74, 0)
  print("game over :(", 41, 54, 7)
  print("press ❎/🅾️", 43, 61, 6)
  print("to play again", 39, 68, 6)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
007007005ffffff557777775599999955aaaaaa55333333559999995000000000000000000000000000000000000000000000000000000000000000000000000
000770005e0550e55c0550c558055085590550955b0550b55f0550f5000000000000000000000000000000000000000000000000000000000000000000000000
000770005eeeeee55cccccc558888885599999955bbbbbb55ffffff5000000000000000000000000000000000000000000000000000000000000000000000000
00700700555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddd00111111002222220088888800eeeeee00999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddccccdd11dddd112288882288eeee88ee9999ee99ffff9900000000000000000000000000000000000000000000000000000000000000000000000000000000
dccc7ccd1ddd7dd12888f8828eeefee8e999799e9fff7ff900000000000000000000000000000000000000000000000000000000000000000000000000000000
dcccc7cd1dddd7d128888f828eeeefe8e999979e9ffff7f900000000000000000000000000000000000000000000000000000000000000000000000000000000
dccccccd1dddddd1288888828eeeeee8e999999e9ffffff900000000000000000000000000000000000000000000000000000000000000000000000000000000
dccccccd1dddddd1288888828eeeeee8e999999e9ffffff900000000000000000000000000000000000000000000000000000000000000000000000000000000
ddccccdd11dddd112288882288eeee88ee9999ee99ffff9900000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddd00111111002222220088888800eeeeee00999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
