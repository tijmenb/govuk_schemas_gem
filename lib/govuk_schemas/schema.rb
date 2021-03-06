module GovukSchemas
  class Schema
    # Find a schema by name
    #
    # @param schema [Hash] Type => Name of the schema/format:
    # @example
    #
    #   GovukSchemas::Schema.find(links_schema: "detailed_guide")
    #   GovukSchemas::Schema.find(frontend_schema: "detailed_guide")
    #   GovukSchemas::Schema.find(publisher_schema: "detailed_guide")
    #   GovukSchemas::Schema.find(notification_schema: "detailed_guide")
    # @return [Hash] the JSON schema as a hash
    def self.find(schema)
      file_path = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/dist/formats/#{location_for_schema_name(schema)}"
      JSON.parse(File.read(file_path))
    end

    # Return all schemas in a hash, keyed by schema name
    #
    # @param schema_type [String] The type: frontend, publisher, notification or links
    # @return [Array<Hash>] List of JSON schemas as hashes
    def self.all(schema_type: '*')
      schema_type = "publisher_v2" if schema_type == "publisher"
      Dir.glob("#{GovukSchemas::CONTENT_SCHEMA_DIR}/dist/formats/*/#{schema_type}/*.json").reduce({}) do |hash, file_path|
        hash[file_path] = JSON.parse(File.read(file_path))
        hash
      end
    end

    # Return a random schema of a certain type
    #
    # @param schema_type [String] The type: frontend, publisher, notification or links
    # @return [Hash] a JSON schema as a hash
    def self.random_schema(schema_type:)
      all(schema_type: schema_type).values.sample
    end

    # @private
    def self.location_for_schema_name(schema)
      type, schema_name = schema.to_a.flatten
      {
        links_schema: "#{schema_name}/publisher_v2/links.json",
        frontend_schema: "#{schema_name}/frontend/schema.json",
        publisher_schema: "#{schema_name}/publisher_v2/schema.json",
        notification_schema: "#{schema_name}/notification/schema.json",
      }[type]
    end

    private_class_method :location_for_schema_name
  end
end
