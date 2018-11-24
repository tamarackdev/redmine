REDMINE_DIR = 'D:\apps\helpdesk\redmine'
LOG_FILE = "#{REDMINE_DIR}\\log\\service.log" 
RUBY_DIR = 'D:\Ruby23-x64\bin'
File.open(LOG_FILE,'a+'){ |f| f.puts " \n\n***LOG FILE Started #{Time.now.to_s}\n\n" }

begin
  require 'win32/daemon'
  include Win32

  class RedmineService < Daemon

    def service_init
      File.open(LOG_FILE, 'a'){ |f| f.puts "Initializing service #{Time.now}" } 

      @server_pid = Process.spawn RUBY_DIR + '\bundle.bat exec thin start -e production', :chdir => REDMINE_DIR, :err => [LOG_FILE, 'a']
    end

    def service_main
      File.open(LOG_FILE, 'a'){ |f| f.puts "Service is running #{Time.now} with pid #{@server_pid}" }
      while running?
        sleep 10
      end
    end

    def service_stop
      File.open(LOG_FILE, 'a'){ |f| f.puts "Stopping server thread #{Time.now}" }
      system "taskkill /PID #{@server_pid} /T /F" 
      Process.waitall
      File.open(LOG_FILE, 'a'){ |f| f.puts "Service stopped #{Time.now}" }
      SetEvent(@@hStopCompletedEvent)
#      exit!
    end
  end

  RedmineService.mainloop

rescue Exception => e
  File.open(LOG_FILE,'a+'){ |f| f.puts " ***Daemon failure #{Time.now} exception=#{e.inspect}\n#{e.backtrace.join($/)}" }
  raise
end