if !Rails.env.development?
	require 'thread'
	Thread.new { EventMachine.run } unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
end