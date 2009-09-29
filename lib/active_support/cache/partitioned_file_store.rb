module ActiveSupport
  module Cache
    
    # Partitioned file-store  
    class PartitionedFileStore < FileStore

      private

        def real_file_path(name)
          name  = Digest::SHA1.hexdigest(name) unless name =~ /^[0-9a-f]{4}/
          parts = [name[0, 2], name[2, 2], name[4, 36]]
          File.join(@cache_path, *parts) + '.cache'
        end
      
      
    end
  end
end
