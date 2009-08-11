require 'rubygems'
require 'ncurses'

Ncurses.initscr
count = 0

while true
  Ncurses.attrset(Ncurses::A_NORMAL)
  if (count % 2) == 0 
    Ncurses.attrset(Ncurses::A_BOLD) 
  end

  Ncurses.addch(Ncurses::ACS_CKBOARD)
  count = count + 1
  Ncurses.refresh
end
