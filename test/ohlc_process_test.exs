Code.require_file "test_helper.exs", __DIR__

defmodule OhlcTest do
  use ExUnit.Case

  test "the truth" do
    
    trade = Ohlc.Event.new time: Ohlc.now, price: 52.31, size: 5
    bar = Ohlc.Bar.process trade
    assert(bar != nil)
    assert bar.open_time == trade.time
    assert(bar.open == trade.price)
    assert(bar.high == trade.price)
    assert(bar.low == trade.price)
    assert(bar.close == trade.price)
    assert(bar.volume == trade.size)

    last_event = Ohlc.Event.new(time: Ohlc.now, price: 52.29, size: 3)

    Ohlc.Bar.process bar, last_event

    assert bar.open == trade.price
    assert bar.close == last_event.price
  end
end
