module TinyGit
  mattr_accessor :persistent_cache 
  self.persistent_cache = nil

  class Repo
    
    def run_command_with_persistent_cache(call)
      return run_command_without_persistent_cache(call) unless persistently_cachable?(call)
      
      TinyGit.persistent_cache.fetch(Digest::MD5.hexdigest(call)) do
        run_command_without_persistent_cache(call)
      end
    end

    alias_method_chain :run_command, :persistent_cache
    
    private
    
      def persistently_cachable?(call)
        TinyGit.persistent_cache.present? && call !~ /HEAD/
      end

  end
end