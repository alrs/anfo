#!/usr/bin/ruby

require 'rubygems'
require 'ncurses'
require 'net/telnet'


class Graph 

  def initialize(label,size,y,x)
    @label = label
    @size = size
    @y = y
    @x = x
  end

  def draw
    Ncurses.curs_set(0)
    Ncurses.move(@y,@x)
    Ncurses.clrtoeol()
    Ncurses.addstr(@label)
    Ncurses.move(@y,(@x + 12))
    @size.times {Ncurses.addch(Ncurses::ACS_CKBOARD)}
    Ncurses.refresh
  end

  def plot(value)
    self.draw
    Ncurses.move(@y,(@x+12))
    Ncurses.attrset(Ncurses::A_BOLD)
    if value.to_i > @size.to_i
      @size.to_i.times do
	Ncurses.addch(Ncurses::ACS_DIAMOND)
      end
    else
      value.to_i.times do 
	Ncurses.addch(Ncurses::ACS_CKBOARD)
      end
    end
    Ncurses.attrset(Ncurses::A_NORMAL)
    Ncurses.mvprintw(@y,(@x + 14 + @size), value.to_s)
    Ncurses.refresh
  end

end

class AsteriskManager
  def initialize(host,port,username,secret)
    @connection = Net::Telnet.new('Host' => host,
				  'Port' => port,
				  'Prompt' => /.*/,
				  'Waittime' => 0.5,
				  'Telnetmode' => false)
    @connection.cmd('String' => \
      "Action: login\nUsername: #{username}\nSecret: #{secret}\nEvents: off\n")
  end

  def active_calls
    @connection.cmd('String' => "Action: command\nCommand: show channels\n") do |c| 
      result = c.split("\n")
      calls = result.grep(/active calls/).to_s.split(' ')[0].to_i
      return calls
      end
  end 

  def show_span(span_number)
    @connection.cmd('String' => "Action: command\nCommand: pri show span #{span_number.to_s}\n") do |c|
      result = c.split("\n")
      primary_d_channel = result.grep(/Primary D-channel/).to_s.split(' ')[2].to_i
      status = result.grep(/Status:/).to_s.split(':')[1].to_s
      switchtype = result.grep(/Switchtype:/).to_s.split(':')[1].to_s
      return {:result => result, :primary_d_channel => primary_d_channel,
	      :status => status, :switchtype => switchtype}
    end
  end    
end


Ncurses.initscr
Ncurses.noecho()
Ncurses.curs_set(0)
Ncurses.timeout(1000)

call_graph = Graph.new('calls:', 23, 1, 1)
asterisk = AsteriskManager.new('localhost', 5038, 'anfo', 'anfokills')

while true do
  keypress = Ncurses.getch
  if (keypress == Ncurses::ERR)
    keypress = '0'
  else
    keypress = keypress.chr
  end
  
  if (keypress.downcase == 'q')
    Ncurses.curs_set(1)
    Ncurses.endwin()
    exit
  end

  call_graph.plot(asterisk.active_calls)
  Ncurses.move(3,0)
  Ncurses.clrtoeol()
  Ncurses.mvprintw(3,1,"pri span 2:")
  span = asterisk.show_span(2)[:status]
  Ncurses.mvprintw(3,12,span)
  Ncurses.refresh()
  Ncurses.napms(500)

end
