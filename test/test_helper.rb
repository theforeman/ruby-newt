# frozen_string_literal: true

require 'pty'

INITIAL_TEXT = 'initial text'
NEW_TEXT     = 'new text'
LONG_TEXT    = 'This is a very long line with no newlines...'

ERROR_MESSAGE = 'libnewt is not initialized'

def assert_init_exception(&block)
  err = assert_raises(RuntimeError) do
    block.call
  end
  assert_equal(err.message, ERROR_MESSAGE)
end

# ioctl request to set controlling terminal
TIOCSCTTY = 0x540E

def fork_newt_ui(ui_method, &block)
  # Call `Newt.finish` so it can be reinitialized later with new IO
  # descriptors.
  Newt.finish
  master, slave = PTY.open

  if Process.fork.nil?
    Process.setsid
    master.close
    $stdin.reopen(slave)
    $stdin.ioctl(TIOCSCTTY, 0)
    $stdout.reopen(slave)

    # Reinitialize with new IO descriptors.
    Newt.init
    rv = ui_method.call
    slave.close
    exit!(rv ? 0 : 1)
  else
    slave.close
    sleep 0.5
    block.call(master) if block_given?
    Process.wait
    master.close
    $?.success?
  end
end
