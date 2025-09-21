pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--falling block game
--by songbird

function _init()
  init_grid()
  init_blocks()
end

function _update()
  update_blocks()
end

function _draw()
  cls()
  draw_grid()
  draw_blocks()
end

function init_grid()
  block_size = 8
  left = 32
  right = 96
  top = 16
  bottom = 112
end

function draw_grid()
  line(left, top, left, bottom)
  line(right, top, right, bottom)
  line(left, bottom, right, bottom)

  local x, y = left + block_size, top
  repeat
    repeat
      line(x, y, x, y)
      y += block_size
    until y >= bottom
    x += block_size
    y = top
  until x >= right
end

-->8
--blocks

function init_blocks()
  num_colors = 4
  blocks = {}
  falling = false
  ready = true
  tick = 0
  rate = 0.05
end

function spawn_block()
  vert = true
  falling = true
  ready = false
  r1 = false
  r2 = false
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

function check_matches()
  --check for blocks that just fell
  check_match(b1)
  check_match(b2)
end

function check_match(b)
  local up = check_match_up(b)
  local down = check_match_down(b)
  local left = check_match_left(b)
  local right = check_match_right(b)

  if #up + #down >= 2 then
    del_block(b)
    foreach(up, del_block)
    foreach(down, del_block)
  end
  if #left + #right >= 2 then
    del_block(b)
    foreach(left, del_block)
    foreach(right, del_block)
  end
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

function del_block(b)
  blocks[b.x .. "," .. b.y] = nil
end

function update_blocks()
  if falling then
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
  end

  tick += rate
  if tick >= 1 then
    if block_end() then
      falling = false
      if vert then
        r1 = true
        r2 = true
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
    end

    if falling then
      move_down()
    elseif r1 and r2 then
      blocks[b1.x .. "," .. b1.y] = b1
      blocks[b2.x .. "," .. b2.y] = b2
      check_matches()
      ready = true
    end

    tick = 0
  end

  if ready then
    spawn_block()
  end
end

--converts grid coords to pixel coords
function convert_coords(x, y)
  local x = left + x * block_size
  local y = top + y * block_size
  return x, y
end

function draw_blocks()
  draw_block(b1)
  draw_block(b2)
  for k, b in pairs(blocks) do
    draw_block(b)
  end
end

function draw_block(b)
  spr(b.sprite, convert_coords(b.x, b.y))
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
