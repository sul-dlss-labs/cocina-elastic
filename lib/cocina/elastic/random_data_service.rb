module Cocina
  module Elastic
    class RandomDataService < Thor
      desc 'generate FILE_COUNT [DROS_PER_FILE=25]', "Generate random DROs and write to file in ElastisSearch bulk format."
      def generate(file_count, dros_per_file=25)
        file_count.to_i.times do |index|
          puts "Generating file #{index+1} of #{file_count}"
          body_array = []
          dros_per_file.to_i.times do
            dro = Cocina::Elastic::RandomDroGenerator.generate
            body_array << JSON.generate({index: {'_id': dro.externalIdentifier}})
            body_array << JSON.generate(dro.to_h)
          end
          body = body_array.join("\n") + "\n"
          Zlib::GzipWriter.open("data/#{Time.now.iso8601}.jsonl.gz") { |gz| gz.write(body) }
        end
      end
    end
  end
end