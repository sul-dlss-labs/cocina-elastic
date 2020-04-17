module Cocina
  module Elastic
    class RandomBulkService < Thor
      class_option :log, :type => :boolean, :default => false

      desc 'bulk DRO_COUNT', 'Index random DROs.'
      def bulk(dro_count)
        count = dro_count.to_i
        before_indexing
        begin
          while count > 0
            this_count = [count, 25].min
            count -= this_count
            puts "Indexing #{this_count}. #{count} remaining."
            body_array = []
            puts "Generating random"
            this_count.times do
              dro = Cocina::Elastic::RandomDroGenerator.generate
              body_array << JSON.generate({index: {'_id': dro.externalIdentifier}})
              body_array << JSON.generate(dro.to_h)
            end
            puts "Done generating random"
            body = body_array.join("\n") + "\n"
            client.bulk(index: 'dro', body: body)
          end
        ensure
          after_indexing
        end
      end

      desc 'bulk_files FILE_COUNT', 'Index random DROs from files.'
      def bulk_files(file_count)
        count = file_count.to_i
        files = Dir['data/*.jsonl.gz']
        raise 'Not enough files' if count > files.size
        before_indexing
        begin
          count.times do |index|
            puts "Indexing file #{index + 1} of #{count}."
            body = nil
            Zlib::GzipReader.open(files[index]) { |gz| body = gz.read }
            client.bulk(index: 'dro', body: body)
          end
        ensure
          after_indexing
        end
      end


      private

      def client
        @client ||= Elasticsearch::Client.new log: options[:log]
      end

      def before_indexing
        body = {
            index: {
                number_of_replicas: 0,
                refresh_interval: '-1'
            }
        }
        client.indices.put_settings(index: 'dro', body: body)
      end

      def after_indexing
        body = {
            index: {
                number_of_replicas: 1,
                refresh_interval: '1s'
            }
        }
        client.indices.put_settings(index: 'dro', body: body)
        client.indices.forcemerge(max_num_segments: 5)
      end
    end
  end
end