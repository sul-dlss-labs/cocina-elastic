# frozen_string_literal: true

module Cocina
  module Elastic
    class RandomDroGenerator
      def self.generate
        new.generate
      end

      attr_reader :druid

      def initialize
        @druid = rand_druid
      end

      def generate
        # TODO: Description
        params = {
            type: Cocina::Models::DRO::TYPES.sample,
            externalIdentifier: druid,
            label: rand_label,
            version: rand(1..10),
            access: generate_access,
            administrative: generate_administrative,
            identification: generate_identification,
            structural: generate_structural
        }.tap do |hash|
          hash[:geographic] = { iso19139: rand_phrase } if flip_coin?
        end
        Cocina::Models::DRO.new(params)
      end

      private

      def generate_access
        {
            access: rand_access
        }.tap do |hash|
          hash[:copyright] = rand_phrase if flip_coin?
          hash[:download] = rand_download if flip_coin?
          hash[:readLocation] = rand_read_location if flip_coin?
          hash[:useAndReproductionStatement] = rand_phrase if flip_coin?
          hash[:embargo] = generate_embargo if flip_coin?
        end
      end

      def generate_embargo
        {
            access: rand_access,
            releaseDate: rand_future_date
        }.tap do |hash|
          hash[:useAndReproductionStatement] = rand_phrase if flip_coin?
        end
      end

      def generate_administrative
        {
            hasAdminPolicy: rand_druid
        }.tap do |hash|
          hash[:partOfProject] = rand_label if flip_coin?
          hash[:releaseTags] = generate_release_tags if flip_coin?
        end
      end

      def generate_release_tags
        rand(1..5).times.map do
          {
              release: flip_coin?
          }.tap do |hash|
            hash[:who] = Faker::Name.first_name if flip_coin?
            hash[:what] = %w[self collection].sample if flip_coin?
            hash[:date] = rand_past_date if flip_coin?
            hash[:to] = 'Searchworks' if flip_coin?
          end
        end
      end

      def generate_identification
        {
            sourceId: "sul:#{rand_label.gsub(' ', '_')}",
            catalogLinks: [
                catalog: 'symphony',
                catalogRecordId: rand(10_000_000..20_000_000).to_s
            ]
        }
      end

      def generate_structural
        {
            contains: rand(1..1000).times.map { |index| generate_fileset(index) }
        }.tap do |hash|
          hash[:isMemberOf] = rand_druid if flip_coin?
          hash[:hasAgreement] = rand_label if flip_coin?
          hash[:hasMemberOrders] = [{ viewingDirection: %w[right-to-left left-to-right].sample }] if flip_coin?
        end
      end

      def generate_fileset(index)
        {
            type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
            externalIdentifier: "#{druid}_#{index}",
            label: "Object #{index}",
            version: rand(1..10),
            structural: generate_fileset_structural(index)
        }
      end

      def generate_fileset_structural(fileset_index)
        {
            contains: rand(1..10).times.map { |index| generate_file(fileset_index, index) }
        }
      end

      def generate_file(fileset_index, file_index)
        identifier = "#{druid}_#{fileset_index}_#{file_index}"
        {
            type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
            externalIdentifier: identifier,
            label: identifier,
            filename: "#{identifier}.#{Faker::File.extension}",
            size: rand(1..100_000_000),
            hasMimeType: Faker::File.mime_type,
            version: rand(1..10),
            administrative: {
                sdrPreserve: flip_coin?,
                shelve: flip_coin?
            },
            hasMessageDigests: generate_message_digests,
            access: generate_file_access
        }.tap do |hash|
          hash[:presentation] = { height: rand(100..500), width: rand(100..500) } if flip_coin?
        end
      end

      def generate_message_digests
        [].tap do |array|
          array << { type: 'md5', digest: Digest::MD5.hexdigest(rand_phrase) } if flip_coin?
          array << { type: 'sha1', digest: Digest::SHA1.hexdigest(rand_phrase) } if flip_coin?
        end
      end

      def generate_file_access
        {}.tap do |hash|
          hash[:access] = rand_access if flip_coin?
          hash[:download] = rand_download if flip_coin?
          hash[:readLocation] = rand_read_location if flip_coin?
        end
      end

      def rand_druid
        # druid:[b-df-hjkmnp-tv-z]{2}[0-9]{3}[b-df-hjkmnp-tv-z]{2}[0-9]{4}$
        "druid:#{rand_druid_char}#{rand_druid_char}#{rand_digit}#{rand_digit}#{rand_digit}#{rand_druid_char}#{rand_druid_char}#{rand_digit}#{rand_digit}#{rand_digit}#{rand_digit}"
      end

      def rand_druid_char
        %w[b c d f g h j k m n p q r s t v w x y z].sample
      end

      def rand_digit
        rand(0..9)
      end

      def rand_label
        Faker::Lorem.words(number: rand(1..15)).join(' ')
      end

      def rand_access
        %w[world stanford location-based citation-only dark].sample
      end

      def rand_phrase
        Faker::Lorem.sentence
      end

      def flip_coin?
        rand(2) == 1
      end

      def rand_future_date
        rand_date(Time.now, Time.now + 50 * 365 * 24 * 60 * 60)
      end

      def rand_past_date
        rand_date(0.0, Time.now)
      end

      def rand_date(from, to)
        Time.at(from + rand * (to.to_f - from.to_f)).iso8601
      end

      def rand_download
        %w[world stanford location-based none].sample
      end

      def rand_read_location
        %w[spec music ars art hoover m&m].sample
      end
    end

  end
end
