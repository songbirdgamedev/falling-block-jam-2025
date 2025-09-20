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
  falling = {}
end

--converts grid coords to pixel coords
function convert_coords(x, y)
  local x = left + x * block_size
  local y = top + y * block_size
  return x, y
end

function spawn_block()
  falling = {
    make_block(3, 0),
    make_block(3, 1)
  }
end

function make_block(x, y)
  --random int of 1, 2, 3, 4
  local sprite = ceil(rnd(num_colors))
  local x, y = convert_coords(x, y)
  return {
    sprite = sprite,
    x = x,
    y = y
  }
end

function move_left(block)
  if block.x > left then
    block.x -= block_size
  end
end

function move_right(block)
  if block.x < right - block_size then
    block.x += block_size
  end
end

function move_down(block)
  block.y += block_size
end

function update_blocks()
  if btnp(⬅️) then
    --move left
    foreach(falling, move_left)
  end
  if btnp(➡️) then
    --move right
    foreach(falling, move_right)
  end
  if btnp(⬇️)
      and falling[1].y < bottom - block_size * 2 then
    --move down
    foreach(falling, move_down)
  end
  if btnp(❎) then
    --rotate clockwise
  end
  if btnp(🅾️) then
    --rotate anticlockwise
  end

  if #falling == 0 then
    spawn_block()
  end
end

function draw_blocks()
  foreach(falling, draw_block)
  foreach(blocks, draw_block)
end

function draw_block(block)
  spr(
    block.sprite,
    block.x,
    block.y
  )
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
