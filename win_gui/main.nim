#[
  nim c --app:gui -d:release --opt:size -d:strip .\main.nim
]#
import wNim, osproc

proc popCalc() =
  discard startProcess("calc.exe")

let app = App()
let frame = Frame(title= "Hello World", size=(400,300))

let panel = Panel(frame)
let quitButton = Button(panel, label="Quit")
let calcButton = Button(panel, label="Calc")

quitButton.wEvent_Button do ():
  frame.delete()

calcButton.wEvent_button do ():
  popCalc()

proc layout() =
  panel.autolayout """
  spacing: 10
  V:|-5-{stack1:[calcButton]-[quitButton]
  """

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()


