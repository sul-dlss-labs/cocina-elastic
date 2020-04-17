module Cocina
  module Elastic
    class IndexService  < Thor
      class_option :log, :type => :boolean, :default => false

      desc 'create [DELETE_IF_EXISTS=true]', 'Create dro index, optionally deleting if it exists.'
      def create(delete_if_exists = true)
        delete if delete_if_exists && exists?
        body = {
            mappings: {
            dynamic: false,
            properties: {
                label: {
                    type: 'text'
                },
                version: {
                    type: 'integer'
                },
                identification: {
                    type: "nested",
                    properties: {
                        sourceId: {
                            type: 'keyword'
                        },
                        catalogLinks: {
                            type: 'nested',
                            properties: {
                                catalog: {
                                    type: 'keyword'
                                },
                                catalogRecordId: {
                                    type: 'keyword'
                                }
                            }
                        }
                    }
                }
            }
          }
        }
        client.indices.create(index: 'dro', body: body)
        puts 'Created dro.'
      end

      desc 'delete', 'Delete dro index'
      def delete
        client.indices.delete(index: 'dro')
        puts 'Deleted dro.'
      end

      private

      def client
        @client ||= Elasticsearch::Client.new log: options[:log]
      end

      def exists?
        client.indices.exists(index: 'dro')
      end
    end
  end
end