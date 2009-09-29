namespace :tiny do
  namespace :cache  do

    def config(key = nil)
      @config ||= YAML.load_configuration(File.dirname(__FILE__) + '/../config.yml', {})
      key ? @config[key].merge(@config['common']) : @config['common']
    end
    
    def read_pid_file
      File.read(config['pid_file']).to_i rescue nil      
    end
        
    namespace :mc do      
      namespace :server do
        
        desc "Start the Memcached server"
        task :start do
          c = config('mem_cache')
          host, port = Array(config['servers']).first.split(':')
          `/usr/bin/env memcached -d -I #{host} -m #{c['memory']} -p #{port} -U #{c['port']} -P #{c['pid_file']} -t #{c['threads']}`
        end
  
        desc "Stop the Memcached server"
        task :stop do
          pid = read_pid_file
          Process.kill("TERM", pid) if pid          
        end
        
        desc "Restart the Memcached server"
        task :restart => [:stop, :start]  
      end      
    end

    namespace :tt do
      
      desc "Create a new Tokyo Cabinet Hash-DB"
      task :create do
        c = config('tokyo')
        `/usr/bin/env tchmgr create #{c['database']}`
        puts File.exist?(c['database']) ? "File #{c['database']} was successfully created." : 'Failed!'
      end
  
      desc "Optimize the Tokyo Cabinet DB"
      task :optimize do
        c = config('tokyo')
        `/usr/bin/env tchmgr optimize #{c['database']}`
      end      
  
      desc "Drop the Tokyo Cabinet DB"
      task :drop do
        c = config('tokyo')
        FileUtils.rm c['database'], :force => true
      end      
  
      desc "Drop and rebuild the Tokyo Cabinet DB"
      task :rebuild => [:drop, :create]
  
      namespace :server do
        
        desc "Start the Tokyo Tyrant server"
        task :start do
          c = config('tokyo')
          `/usr/bin/env ttserver -dmn -le -host #{c['host']} -port #{c['port']} -pid #{c['pid_file']} -log #{c['log_file']} -thnum #{c['threads']} #{c['database']}`
        end
  
        desc "Show the Tokyo Tyrant server status"
        task :status do
          if pid = read_pid_file
            puts "Server is running PID=#{pid}"
          else
            puts "Server is NOT running"
          end
        end
  
        desc "Stop the Tokyo Tyrant server"
        task :stop do
          pid = read_pid_file
          begin
            Process.kill("TERM", pid)
            sleep(0.5)
          rescue Errno::ESRCH => e
            if e.message =~ /No such process/i
              FileUtils.rm config['pid_file'], :force => true
            else
              raise
            end
          end if pid
        end
        
        desc "Restart the Tokyo Tyrant server"
        task :restart => [:stop, :start]
  
        desc "Reload the Tokyo Tyrant server"
        task :reload do 
          pid = read_pid_file
          Process.kill("HUP", pid) if pid
        end

      end      
    end
  end
end