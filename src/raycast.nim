import raylib, math

const
  sWidth = 800
  sHeight = 475
  mapW: int32 = 7
  mapH: int32 = 7
  cubeSize: int32 = 25
  raySize = 0.5
  fov: int32 = 45
  recW: int32 = 10

var
  plypos = Vector2(x: 50,y: 50)
  plyang = 0.0

var map = @[
  1,1,1,1,1,1,1,
  1,0,0,0,1,0,1,
  1,0,1,0,0,0,1,
  1,0,0,0,1,0,1,
  1,0,0,0,1,0,1,
  1,0,0,0,1,0,1,
  1,1,1,1,1,1,1
]

proc `+=`(a: var Vector2, b: Vector2) =
  a.x += b.x
  a.y += b.y

proc `-=`(a: var Vector2, b: Vector2) =
  a.x -= b.x
  a.y -= b.y

proc drawPly =
  drawRectangle(int32 plypos.x - 7, int32 plypos.y - 7, int32 14, int32 14, Red)

proc plyMove =
  var fwddir = Vector2(x: 0.5*sin(plyang * (PI/180)), y: 0.5*cos(plyang * (PI/180)))
  if isKeyDown(W): plypos += fwddir
  if isKeyDown(S): plypos -= fwddir
  if isKeyDown(A): plyang += 5
  if isKeyDown(D): plyang -= 5
  if plyang >= 360 or plyang <= -360:
    plyang = 0

proc drawMap2D =
  for y in 0..<mapH:
    for x in 0..<mapW:
      if map[y*mapW+x] == 1:
        drawRectangle(x * cubeSize, y * cubeSize, cubeSize, cubeSize, Gray)

proc rayHits(point: Vector2): bool =
  return map[int(point.y/cubeSize.float)*mapW+int(point.x/cubeSize.float)] == 1

proc rayDist(pos: Vector2, ang: float): int32 =
  let start = pos
  var endP = Vector2(x: pos.x - raySize * -sin(ang*(PI/180)), y: pos.y - raySize * -cos(ang*(PI/180)))  
  
  var count:int32 = 0
  while not rayHits(endP):
    endP += Vector2(x:raySize * sin(ang*(PI/180)), y: raySize * cos(ang*(PI/180)))  
    count += 1

  drawLine(start, endP, Green)
  return count

proc drawMap3D =
  for i in -fov..fov:
    let dist = rayDist(plypos, plyang+i.float)
    let col = Color(r: 100,g: 100, b: 200 - dist.uint8, a: 255)
    drawRectangle((i+fov)*recW, int32(sHeight/2) - int32(sHeight/(dist+1)), recW, 4*int32(sHeight/(dist+1)), col)

initWindow(sWidth, sHeight, "Raycast test")
setTargetFPS(30)

while not windowShouldClose():
  beginDrawing()
  clearBackground(Black)

  drawMap3D()
  drawMap2D()
  plyMove()
  drawPly()

  endDrawing()

closeWindow()