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
end

function spawn_block()
  falling = true
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
  if not collision(b1.x, b1.y + 1)
      and not collision(b2.x, b2.y + 1) then
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
  end
end

--checks for object at given coords
function collision(x, y)
  if x < 0 or x > 7
      or y < 0 or y > 11 then
    return true
  end

  for b in all(blocks) do
    if b.x == x and b.y == y then
      return true
    end
  end

  return false
end

function update_blocks()
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

  if not falling then
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
  foreach(blocks, draw_block)
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
